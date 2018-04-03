####################################
# UK London Pay Gap - Load data
####################################

# load packages
pkg <- c('data.table', 'fst', 'mapsapi', 'RMySQL', 'rvest')
invisible(lapply(pkg, require, char = TRUE))

# set datefield
datefield <- 2017

# save copy of recoded data: company_name, sic, x_lon, y_lat, postcode
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, "DROP TABLE IF EXISTS dataset_copy")
dbSendQuery(dbc, paste("
    CREATE table dataset_copy  
        SELECT company, company_name, company_id, sic, x_lon, y_lat, postcode 
        FROM dataset
        WHERE datefield =", datefield, "
        ORDER BY company_name
"))
dbDisconnect(dbc)

# download data file
dts <- fread(
    paste0('https://gender-pay-gap.service.gov.uk/Viewing/download-data?year=', datefield),
    select = c(1:18),
    col.names = c(
        'company', 'address', 'company_id', 'sic', 
        'DMH', 'DMdH', 'DMB', 'DMdB', 'MB', 'FB', 'MQ1', 'FQ1', 'MQ2', 'FQ2', 'MQ3', 'FQ3', 'MQ4', 'FQ4'
    )
)

# add datefield (=year)
dts[, datefield := datefield]

# clean and capitalize company names, fix 
dts[, company_name := trimws(gsub('\\W', ' ', company)) ]
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

# clean company_id and sic
dts[company_id == '', company_id := NA]
dts[, sic := gsub('\r\n', '', trimws(sub('^1,(.*)', '\\1', sic)))]
dts[sic == '', sic := NA]

# find missing sic
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

# recode 1 as 84110
dts[sic == '1', sic := '84110']

# create table with all sics connected to all companies
sc <- dts[!is.na(sic) & !is.na(company_id), .(rep(company_id, sapply(strsplit(sic, split = ','), length)), unlist(strsplit(sic, split = ',')) )]
setnames(sc, c('company_id', 'sic'))
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, "TRUNCATE TABLE sics_companies")
dbWriteTable(dbc, 'sics_companies', sc, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

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

# save data to database
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, "TRUNCATE TABLE dataset")
dbWriteTable(dbc, 'dataset', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# update dataset table with info saved earlier
strSQL <- paste("
    UPDATE dataset dt 
        JOIN dataset_copy dtc ON dtc.company = dt.company
    SET 
	 	dt.company_name = dtc.company_name, dt.company_id = dtc.company_id, 
		dt.x_lon = dtc.x_lon,  dt.y_lat = dtc.y_lat, 
		dt.postcode = dtc.postcode
    WHERE dt.datefield =", datefield
)
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, strSQL)
dbDisconnect(dbc)

# geocode
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbReadTable(dbc, 'dataset') )
dbDisconnect(dbc)
dts <- dts[is.na(x_lon)]
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
dbSendQuery(dbc, paste0('DELETE FROM dataset WHERE company IN ("', paste(dts[, company], collapse = '", "'), '")') )
dbWriteTable(dbc, 'dataset', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# add higher level areas codes
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
strSQL <- "
    UPDATE dataset dt 
        JOIN geography_uk.postcodes pc ON pc.postcode = dt.postcode
    SET dt.OA = pc.OA
"
dbSendQuery(dbc, strSQL)
strSQL <- "
    UPDATE dataset dt 
        JOIN geography_uk.lookups lk ON lk.OA = dt.OA
    SET dt.LAD = lk.LAD, dt.RGN = lk.RGN, dt.PCON = lk.PCON, dt.WARD = lk.WARD, dt.PCA = lk.PCA
"
dbSendQuery(dbc, strSQL)
dbDisconnect(dbc)

# delete coordinates outside UK bounding box: lng1 = 1.8, lat1 = 49.9, lng2 = -8.3, lat2 = 59.0
strSQL <- "
    UPDATE dataset
    SET x_lon = NULL, y_lat = NULL
    WHERE x_lon > 1.8  OR x_lon < -8.3 OR y_lat > 59.0 OR y_lat < 49.9
"
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, strSQL)

# substitute null coordinates with postcode centroid
# strSQL <- "
#     UPDATE dataset dt 
#         JOIN geography_uk.postcode pc ON pc.postcode = dt.postcode
#     SET dt.x_lon = pc.x_lon, dt.y_lat = pc.y_lat
#     WHERE x_lon IS NULL
# "
# dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
# dbSendQuery(dbc, strSQL)

# save as csv, and convert to fst for quick reading by shiny
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbReadTable(dbc, 'dataset') )
dbDisconnect(dbc)
write.csv(dts, 'data/dataset.csv', row.names = FALSE)
write_fst(dts, 'data/dataset.fst', 100)

# clean environment & exit
rm(list = ls())
gc()

