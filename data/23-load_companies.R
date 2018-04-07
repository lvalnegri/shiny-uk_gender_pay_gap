#########################################
# UK London Pay Gap - Load companies
#########################################

# load packages
pkg <- c('data.table', 'fst', 'mapsapi', 'RMySQL', 'rvest')
invisible(lapply(pkg, require, char = TRUE))

# set datefield (=year)
dtf <- 2018

# download data file
dts <- fread(
    paste0('https://gender-pay-gap.service.gov.uk/Viewing/download-data?year=', dtf),
    select = c(1:4, 21),
    col.names = c('company', 'address', 'company_id', 'sic', 'size')
)

# clean company_id
dts[company_id == '', company_id := NA]

# add company name
# dts[, company_name := trimws(gsub('\\W', ' ', company)) ]
dts[, company_name := trimws(company) ]
dts[, company_name := gsub('(?<=\\b)([a-z])', '\\U\\1', tolower(company_name), perl = TRUE)]
dts[, company_name := gsub('Ltd|Ltd.|Limited', 'LTD', company_name)]
dts[, company_name := gsub('Llc', 'LLC', company_name)]
dts[, company_name := gsub('Plc|P.L.C.', 'PLC', company_name)]
dts[, company_name := gsub('  ', ' ', company_name)]
dts[, company_name := gsub('Uk|(UK)|U.K.', 'UK', company_name)]
dts[, company_name := gsub('Gb', 'GB', company_name)]
dts[, company_name := gsub('Nhs', 'NHS', company_name)]
dts[, company_name := gsub('(The)|"', '', company_name)]

# clean size
dts[size == 'Not Provided', size := NA]

# clean sic
dts[, sic := gsub('\r\n', '', trimws(sub('^1,(.*)', '\\1', sic)))]
dts[sic == '', sic := NA]

# recode single 1 as 84110
dts[sic == '1', sic := '84110']

# create table with all sics connected to all companies
sc <- dts[!is.na(sic) & !is.na(company_id), .(rep(company, sapply(strsplit(sic, split = ','), length)), unlist(strsplit(sic, split = ',')) )]
setnames(sc, c('company', 'sic'))
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbWriteTable(dbc, 'sics_companies', sc, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# retain only first sic
dts[, sic := gsub(',', '', substr(sic, 1, 5))]

# extract and clean postcode
dts[, postcode := trimws(sub('^.*,(.*)$', '\\1', address))]
dts[, postcode := gsub(' ', '', postcode)]
dts[!grepl("[[:digit:]][[:alpha:]][[:alpha:]]$", postcode), postcode := NA]
dts <- dts[!is.na(postcode),  
    postcode:= toupper(paste0(
        substr( paste0( substr( postcode, 1, nchar(postcode) - 3), '  '), 1, 4),
        substring(postcode, nchar(postcode) - 2)
    ))
]

# save into database
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbWriteTable(dbc, 'companies', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# find missing sic
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbGetQuery(dbc, "SELECT * FROM companies WHERE is_UK AND sic IS NULL AND company_id IS NOT NULL") )
dbDisconnect(dbc)
ms <- dts[is.na(sic), company_id]
cntr <- 1
for(m in ms){
    message('Processing company <', m, '>, ', cntr, ' out of ', length(ms))
    tryCatch(
        {
            sc <- read_html(paste0('https://beta.companieshouse.gov.uk/company/', m)) %>%
                        html_nodes('#sic0') %>% 
                        html_text() %>% 
                        sub('(.*)-.*', '\\1', .) %>% 
                        trimws()
            if(length(sc) > 0) dts[company_id == m, sic := sc]
        }, 
        error = function(e){ cat('Company Not Found!\n') }
    )
    cntr <- cntr + 1
}
dts <- dts[!is.na(sic)]
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, paste0('DELETE FROM companies WHERE company IN ("', paste(dts[, company], collapse = '", "'), '")') )
dbWriteTable(dbc, 'companies', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# geocode
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbGetQuery(dbc, "SELECT * FROM companies WHERE is_UK AND has_coord AND x_lon IS NULL ORDER BY address") )
dbDisconnect(dbc)
gm_key <- readLines('data/key.txt')
for(idx in 1:nrow(dts)){
    adr <- dts[idx, address]
    message('Geocoding company <', dts[idx, company], '>, ', idx, ' out of ', nrow(dts))
    lnlt <- mp_geocode(adr, region = 'uk', key = gm_key)
    lnlt <- mp_get_points(lnlt)
    lnlt <- unlist(lnlt[1]$pnt)
    dts[idx, `:=`(x_lon = lnlt[1], y_lat = lnlt[2])]
}
dts <- dts[!is.na(x_lon)]
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, paste0('DELETE FROM companies WHERE company IN ("', paste(dts[, company], collapse = '", "'), '")') )
dbWriteTable(dbc, 'companies', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# add higher level areas codes
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
strSQL <- "
    UPDATE companies dt 
        JOIN geography_uk.postcodes pc ON pc.postcode = dt.postcode
    SET dt.OA = pc.OA
"
dbSendQuery(dbc, strSQL)
strSQL <- "
    UPDATE companies dt 
        JOIN geography_uk.lookups lk ON lk.OA = dt.OA
    SET dt.LAD = lk.LAD, dt.RGN = lk.RGN, dt.PCON = lk.PCON, dt.WARD = lk.WARD, dt.PCA = lk.PCA
"
dbSendQuery(dbc, strSQL)
dbDisconnect(dbc)

# delete coordinates outside UK bounding box: lng1 = 1.8, lat1 = 49.9, lng2 = -8.3, lat2 = 59.0
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
strSQL <- "
    UPDATE companies
    SET x_lon = NULL, y_lat = NULL, is_UK = 0
    WHERE x_lon > 1.8  OR x_lon < -8.3 OR y_lat > 59.0 OR y_lat < 49.9
"
dbSendQuery(dbc, strSQL)

# substitute null coordinates with postcode centroid
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
strSQL <- "
    UPDATE companies cp
        JOIN geography_uk.postcodes pc ON pc.postcode = cp.postcode
    SET cp.x_lon = pc.x_lon, cp.y_lat = pc.y_lat, cp.has_coord = 0
    WHERE cp.x_lon IS NULL
"
dbSendQuery(dbc, strSQL)
dbSendQuery(dbc, "UPDATE companies SET has_coord = 0 WHERE postcode IS NULL")
dbDisconnect(dbc)

# save values into database, plus as csv
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbReadTable(dbc, 'companies') )
dbDisconnect(dbc)
write.csv(dts, 'data/companies.csv', row.names = FALSE)

# add sics and sectors name
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
sics <- data.table( dbReadTable(dbc, 'sics') )
dbDisconnect(dbc)
dts <- sics[dts, on = 'sic'][, sic := NULL]
setnames(dts, 'description', 'sic')

# convert cat vars to factors, then save as fst for quick reading by shiny
dts[, sic := factor(sic, levels = sort( unique(sic) )) ]
dts[, section := factor(section, levels = sort( unique(section) )) ]
dts[, size := factor(size, levels = c('Less than 250', '250 to 499', '500 to 999', '1000 to 4999', '5000 to 19,999', '20,000 or more'), ordered = TRUE)]
write_fst(dts, 'data/companies.fst', 100)

# check totals
# y <- rbind(
#         cbind( table(dts$section), table(dts$section, dts$size, useNA = 'always') ),
#         c(dts[, .N], table(dts$size, useNA = 'always') )
# )
# rownames(y)[22:23] <- c('Not Available', 'T O T A L')
# colnames(y)[1] <- 'TOTAL'

# clean environment & exit
rm(list = ls())
gc()
