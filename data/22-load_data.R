####################################
# UK London Pay Gap - Load data
####################################

# load packages
pkg <- c('data.table', 'mapsapi', 'RMySQL', 'rvest')
invisible(lapply(pkg, require, char = TRUE))

# download data file
dts <- fread(
    'https://gender-pay-gap.service.gov.uk/Viewing/download-data?year=2017',
    select = c(1:18),
    col.names = c('company', 'address', 'company_id', 'sic', 'DMH', 'DMdH', 'DMB', 'DMdB', 'MB', 'FB', 'MQ1', 'FQ1', 'MQ2', 'FQ2', 'MQ3', 'FQ3', 'MQ4', 'FQ4')
)

# clean and capitalize company names
# proper <- function(x){
#     s <- strsplit(x, ' ')[[1]]
#     paste(toupper(substr(s, 1, 1)), substring(s, 2), sep = '', collapse = ' ')
# }
# dts[, company := proper( gsub('\\W', ' ', company) ) ]

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

# recode 1 as 8411
dts[sic == '1', sic := '8411']

# create table with all sics connected to all company
sc <- dts[!is.na(sic) & !is.na(company_id), .(rep(company_id, sapply(strsplit(sic, split = ','), length)), unlist(strsplit(sic, split = ',')) )]
setnames(sc, c('company_id', 'sic'))
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, "TRUNCATE TABLE sics_companies")
dbWriteTable(dbc, 'sics_companies', sc, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# recode sic as 4-chars, keeping only first if not unique
dts[, sic := substr(sic, 1, 4)]

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

# add output area. NOTE ===> Require newest update of postcodes from ONS 
dbc = dbConnect(MySQL(), group = 'dataOps', dbname = 'geography_uk')
oa <- data.table(dbGetQuery(dbc, "SELECT postcode, OA FROM postcodes"))
dbDisconnect(dbc)
dts <- oa[dts, on = 'postcode']

# save data to database
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbWriteTable(dbc, 'dataset', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# geocode
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbReadTable(dbc, 'dataset') )
dbDisconnect(dbc)
dts <- dts[is.na(x_lon)]
gm_key <- readLines('key.txt')
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

# clean & exit
rm(list = ls())
gc()

