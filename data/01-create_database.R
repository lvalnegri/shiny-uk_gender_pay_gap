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

### companies ---------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE companies (
    	company CHAR(150) NOT NULL COLLATE 'utf8_unicode_ci',
    	company_id CHAR(8) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	company_name CHAR(150) NOT NULL COLLATE 'utf8_unicode_ci',
    	size CHAR(15) NOT NULL COLLATE 'utf8_unicode_ci',
    	sic MEDIUMINT(5) UNSIGNED NULL DEFAULT NULL,
    	address VARCHAR(150) NOT NULL COLLATE 'utf8_unicode_ci',
    	x_lon DECIMAL(9,7) NULL DEFAULT NULL,
    	y_lat DECIMAL(9,7) UNSIGNED NULL DEFAULT NULL,
    	postcode CHAR(7) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	OA CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	LAD CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	RGN CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	WARD CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	PCON CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	PCA CHAR(9) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	PRIMARY KEY (company),
    	INDEX size (size),
    	INDEX sic (sic),
    	INDEX postcode (postcode),
    	INDEX OA (OA),
    	INDEX LAD (LAD),
    	INDEX RGN (RGN),
    	INDEX WARD (WARD),
    	INDEX PCON (PCON),
    	INDEX PCA (PCA)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

### sics ------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE sics (
    	sic MEDIUMINT(5) UNSIGNED NOT NULL,
    	description VARCHAR(160) NOT NULL COLLATE 'utf8_unicode_ci',
    	section CHAR(125) NOT NULL COLLATE 'utf8_unicode_ci',
    	PRIMARY KEY (sic),
    	INDEX section (section)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

### sics <-> companies ----------------------------------------------------------------------------
strSQL = "
    CREATE TABLE sics_companies (
    	company_id CHAR(8) NOT NULL COLLATE 'utf8_unicode_ci',
    	sic MEDIUMINT(5) UNSIGNED NOT NULL COLLATE 'utf8_unicode_ci',
    	INDEX company_id (company_id),
    	INDEX sic (sic),
    	PRIMARY KEY (company_id, sic)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

### dataset ---------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE dataset (
    	datefield SMALLINT(4) UNSIGNED NOT NULL,
    	company CHAR(150) NOT NULL COLLATE 'utf8_unicode_ci',
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
    	PRIMARY KEY (datefield, company),
    	INDEX datefield (datefield),
    	INDEX company (company)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

### vars ------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE vars (
    	var_id CHAR(4) NOT NULL,
    	name CHAR(25) NOT NULL,
    	description CHAR(50) NOT NULL,
    	PRIMARY KEY (var_id)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# Close DB Connection, Clean & Exit ---------------------------------------------------------------
dbDisconnect(dbc)
rm(list = ls())
gc()

