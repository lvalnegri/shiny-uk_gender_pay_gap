#######################################
# UK London Pay Gap - Load dataset
#######################################

# load packages
pkg <- c('data.table', 'fst', 'mapsapi', 'RMySQL', 'rvest')
invisible(lapply(pkg, require, char = TRUE))

# set datefield (=year)
dtf <- 2018

# download data file
dts <- fread(
    paste0('https://gender-pay-gap.service.gov.uk/Viewing/download-data?year=', dtf),
    select = c(1, 5:18),
    col.names = c('company', 'DMH', 'DMdH', 'DMB', 'DMdB', 'MB', 'FB', 'MQ1', 'FQ1', 'MQ2', 'FQ2', 'MQ3', 'FQ3', 'MQ4', 'FQ4')
)

# add datefield to dataset
dts[, datefield := dtf]

# NULL bonus gap if at least sex havn't had any bonus
dts[MB == 0 | FB == 0, `:=`(DMB = NA, DMdB = NA)]

# NULL values if at least one of them is more than 100 (women can't be paid less than 100% than men) 
dts[DMH >= 100 | DMdH >= 100, `:=`(DMH = NA, DMdH = NA, DMB = NA, DMdB = NA)]

# save values into database, plus csv and fst into data directory
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
dbSendQuery(dbc, paste("DELETE FROM dataset WHERE datefield =", dtf))
dbWriteTable(dbc, 'dataset', dts, append = TRUE, row.names = FALSE)
dts <- data.table(dbReadTable(dbc, 'dataset'))
dbDisconnect(dbc)
dts <- dts[order(-datefield, company)]
write.csv(dts, 'data/dataset.csv', row.names = FALSE)
write_fst(dts, 'data/dataset.fst', 100)

# clean environment & exit
rm(list = ls())
gc()


