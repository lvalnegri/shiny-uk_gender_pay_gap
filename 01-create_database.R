##############################################################
# UK London Pay Gap - Create MySQL database and tables
##############################################################

# Load packages -----------------------------------------------------------------------------------
library(RMySQL)

# Create database ---------------------------------------------------------------------------------
dbc = dbConnect(MySQL(), group = 'dataOps')
dbSendQuery(dbc, 'DROP DATABASE IF EXISTS uk_gender_pay_gap')
dbSendQuery(dbc, 'CREATE DATABASE uk_gender_pay_gap')
dbDisconnect(dbc)

# Connect to database -----------------------------------------------------------------------------
dbc = dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')

### dataset ---------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE dataset (
    	company_id CHAR(8) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	company CHAR(150) NOT NULL COLLATE 'utf8_unicode_ci',
    	sic TEXT NOT NULL COLLATE 'utf8_unicode_ci',
    	address VARCHAR(150) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	x_lon DECIMAL(9,7) NULL DEFAULT NULL,
    	y_lat DECIMAL(9,7) UNSIGNED NULL DEFAULT NULL,
    	postcode CHAR(7) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	OA CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	DMH DECIMAL(5,2) NOT NULL,
    	DMdH DECIMAL(5,2) NOT NULL,
    	DMB DECIMAL(7,3) NOT NULL,
    	DMdB DECIMAL(7,3) NOT NULL,
    	MB DECIMAL(5,2) UNSIGNED NOT NULL,
    	FB DECIMAL(5,2) UNSIGNED NOT NULL,
    	MQ1 DECIMAL(5,2) UNSIGNED NOT NULL,
    	FQ1 DECIMAL(5,2) UNSIGNED NOT NULL,
    	MQ2 DECIMAL(5,2) UNSIGNED NOT NULL,
    	FQ2 DECIMAL(5,2) UNSIGNED NOT NULL,
    	MQ3 DECIMAL(5,2) UNSIGNED NOT NULL,
    	FQ3 DECIMAL(5,2) UNSIGNED NOT NULL,
    	MQ4 DECIMAL(5,2) UNSIGNED NOT NULL,
    	FQ4 DECIMAL(5,2) UNSIGNED NOT NULL,
    	PRIMARY KEY (company),
    	INDEX postcode (postcode),
    	INDEX OA (OA)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

### sics ------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE sics (
    	sic MEDIUMINT(5) UNSIGNED NOT NULL,
    	description VARCHAR(200) NOT NULL COLLATE 'utf8_unicode_ci',
    	PRIMARY KEY (sic)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)


# Close DB Connection, Clean & Exit ---------------------------------------------------------------
dbDisconnect(dbc)
rm(list = ls())
gc()

