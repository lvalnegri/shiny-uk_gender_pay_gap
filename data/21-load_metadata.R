########################################
# UK London Pay Gap - Load metadata
########################################

# load packages
pkg <- c('data.table', 'RMySQL')
invisible(lapply(pkg, require, char = TRUE))

# connect to database
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')

# download SIC codes
sic <- fread(
    'https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/527619/SIC07_CH_condensed_list_en.csv',
    col.names = c('sic', 'description')
)

# save sics to database
dbSendQuery(dbc, "TRUNCATE TABLE sics")
dbWriteTable(dbc, 'sics', sic, append = TRUE, row.names = FALSE)

# build vars table
vars <- data.frame(
    'var_id' = c('DMH', 'DMdH', 'DMB', 'DMdB', 'MB', 'FB', 'MQ1', 'FQ1', 'MQ2', 'FQ2', 'MQ3', 'FQ3', 'MQ4', 'FQ4'),
    'name'   = c(
        'DiffMeanHourlyPercent', 'DiffMedianHourlyPercent', 'DiffMeanBonusPercent', 'DiffMedianBonusPercent', 
        'MaleBonusPercent', 'FemaleBonusPercent',
        'MaleLowerQuartile', 'FemaleLowerQuartile', 'MaleLowerMiddleQuartile', 'FemaleLowerMiddleQuartile',
        'MaleUpperMiddleQuartile', 'FemaleUpperMiddleQuartile', 'MaleTopQuartile', 'FemaleTopQuartile'
    ),
    'description' = c(
        'Gender Hourly Pay Gap: mean averages',
        'Gender Hourly Pay Gap: median averages',
        'Gender Bonus Pay Gap: mean averages',
        'Gender Bonus Pay Gap: median averages',
        'Proportion of men receiving bonuses',
        'Proportion of women receiving bonuses',
        'Proportion of men in the Lower Quartile: 0-25%',
        'Proportion of women in the Lower Quartile: 0-25%',
        'Proportion of men in the Lower Middle Quartile: 25-50%',
        'Proportion of women in the Lower Middle Quartile: 25-50%',
        'Proportion of men in the Upper Middle Quartile: 50-75%',
        'Proportion of women in the Upper Middle Quartile: 50-75%',
        'Proportion of men in the Top Quartile: 75-100%',
        'Proportion of women in the Female Top Quartile: 75-100%'
     )
 )

# save sics to database
dbSendQuery(dbc, "TRUNCATE TABLE vars")
dbWriteTable(dbc, 'vars', vars, append = TRUE, row.names = FALSE)

# close connection to database
dbDisconnect(dbc)

# clean & exit
rm(list = ls())
gc()

