###############################################
# UK Gender Pay Gap - Shiny App - ui.R
###############################################

shinyUI(fluidPage(
    
    includeCSS('datamaps.css'),
    tags$head(
        tags$script(src="datamaps.js"),
        tags$link(rel="shortcut icon", href="favicon.png")
    ),
    
    navbarPageWithText(
        header = '', # source(file.path("ui", "ui_hdr.R"),  local = TRUE)$value,
        title = tags$span(HTML(paste0(
            '<img src="logo.png" class="logo">',
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
        source(file.path("ui", "ui_about.R"),  local = TRUE)$value,
    
    	### LAST UPDATED AT --------------------------------------------------------------------------------------------------------
        text = paste('Last updated:', format(last_updated, '%d %b %Y') )
        
    ),
    
    useShinyjs()

))
