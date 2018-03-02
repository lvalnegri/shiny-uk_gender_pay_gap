########################
# UK London Pay Gap
########################

# load packages
pkg <- c('data.table')
invisible(lapply(pkg, require, char = TRUE))

# load data
dts <- fread('https://gender-pay-gap.service.gov.uk/Viewing/download-data?year=2017', select = c(2, 4:18))

# extract postcode
dts[, postcode := trimws(sub('^.*,(.*)$', '\\1', Address))]
