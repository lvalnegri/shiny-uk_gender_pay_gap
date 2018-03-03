###############################################
# UK Gender Pay Gap - Shiny App - server.R
###############################################

shinyServer(function(input, output, session) {

	###  (dts) -----------------------------------------------------------------------------------
    source(file.path("server", "srv_.R"),  local = TRUE)$value
	

})