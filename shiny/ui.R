###############################################
# UK Gender Pay Gap - Shiny App - ui.R
###############################################

shinyUI(fluidPage(
    
    includeCSS('styles.css'),
    tags$head(
        tags$script(src="datamaps.js"),
        tags$link(rel="shortcut icon", href="favicon.ico")
    ),
    
    navbarPageWithText(
        header = '', # source(file.path("ui", "ui_hdr.R"),  local = TRUE)$value,
        title = tags$span(HTML(paste0(
            '<img src="dm-logotype.png" class="dm-logo">',
            '<b style="font-size:160%;"> UK Gender Pay Gap </b>'
        ))), 
        windowTitle = 'UK Gender Pay Gap', 
        id = 'mainNav',
        theme = shinytheme('united'), inverse = TRUE,

    	###  () -------------------------------------------------------------------------------
    	source(file.path("ui", "ui_.R"),  local = TRUE)$value,
    
    	### HELP / ABOUT / CREDITS (hlp) ---------------------------------------------------------------------------------
        source(file.path("ui", "ui_hlp.R"),  local = TRUE)$value,
    
        text = '@2018 datamaps.co.uk'
        
    ),
    
    useShinyjs()

))