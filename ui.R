###############################################
# UK Gender Pay Gap - Shiny App - ui.R
###############################################

shinyUI(fluidPage(
    
    includeCSS('datamaps.css'),
    tags$head(
        tags$script(src="datamaps.js"),
        tags$link(rel="shortcut icon", href="favicon.ico")
    ),
    
    navbarPageWithText(
        header = '', # source(file.path("ui", "ui_hdr.R"),  local = TRUE)$value,
        title = tags$span(HTML(paste0(
            '<img src="datamaps-logotype.png" class="datamaps-logo">',
            '<b style="font-size:160%;"> UK Gender Pay Gap </b>'
        ))), 
        windowTitle = 'UK Gender Pay Gap', 
        id = 'mainNav',
        theme = shinytheme('flatly'), inverse = TRUE,

    	### TABLES (tbl) -------------------------------------------------------------------------------
    	source(file.path("ui", "ui_tbl.R"),  local = TRUE)$value,
    
    	### CHARTS (plt) -------------------------------------------------------------------------------
    	source(file.path("ui", "ui_plt.R"),  local = TRUE)$value,
    
    	### MAPS (mps) -------------------------------------------------------------------------------
    	source(file.path("ui", "ui_mps.R"),  local = TRUE)$value,
    
    	### HELP / ABOUT / CREDITS (hlp) ---------------------------------------------------------------------------------
        source(file.path("ui", "ui_hlp.R"),  local = TRUE)$value,
    
        text = '@2018 datamaps.co.uk'
        
    ),
    
    useShinyjs()

))
