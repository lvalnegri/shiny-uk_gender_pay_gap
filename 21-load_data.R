####################################
# UK London Pay Gap - Load data
####################################

# load packages
pkg <- c('data.table', 'mapsapi', 'RMySQL', 'rvest')
invisible(lapply(pkg, require, char = TRUE))

# download SIC codes
dts <- fread(
    'https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/527619/SIC07_CH_condensed_list_en.csv',
    col.names = c('sic', 'description')
)

# save sics to database
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, "TRUNCATE TABLE sics")
dbWriteTable(dbc, 'sics', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# download data file
dts <- fread(
    'https://gender-pay-gap.service.gov.uk/Viewing/download-data?year=2017',
    select = c(1:18),
    col.names = c('company', 'address', 'company_id', 'sic', 'DMH', 'DMdH', 'DMB', 'DMdB', 'MB', 'FB', 'MQ1', 'FQ1', 'MQ2', 'FQ2', 'MQ3', 'FQ3', 'MQ4', 'FQ4')
)

# clean company_id and sic
dts[company_id == '', company_id := NA]
dts[, sic := gsub('\r\n', '', trimws(sub('^1,(.*)', '\\1', sic)))][sic == '', sic := NA]

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
# dbSendQuery(dbc, "TRUNCATE TABLE dataset")
dbWriteTable(dbc, 'dataset', dts, append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# geocode
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dts <- data.table( dbReadTable(dbc, 'dataset') )
dbDisconnect(dbc)
dts <- dts[is.na(x_lon)]
for(idx in 1:nrow(dts)){
    adr <- dts[idx, address]
    message('Geocoding company <', dts[idx, company], '>, ', idx, ' out of ', nrow(dts))
    lnlt <- mp_geocode(adr, region = 'uk', key = 'AIzaSyDC3sMFvBRUELXhHClSLvfHNjLM2NYDtes')
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


# dts <- data.frame(
#     'var_id' = c('DMH', 'DMdH', 'DMB', 'DMdB', 'MB', 'FB', 'MQ1', 'FQ1', 'MQ2', 'FQ2', 'MQ3', 'FQ3', 'MQ4', 'FQ4'),
#     'name'   = c(
#         'DiffMeanHourlyPercent', 'DiffMedianHourlyPercent', 'DiffMeanBonusPercent', 'DiffMedianBonusPercent', 'MaleBonusPercent', 'FemaleBonusPercent', 
#         'MaleLowerQuartile', 'FemaleLowerQuartile', 'MaleLowerMiddleQuartile', 'FemaleLowerMiddleQuartile', 
#         'MaleUpperMiddleQuartile', 'FemaleUpperMiddleQuartile', 'MaleTopQuartile', 'FemaleTopQuartile'
#     ),
#     'description' = c(
#         
#     )
# )
