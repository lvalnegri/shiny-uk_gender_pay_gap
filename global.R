###############################################
# UK Gender Pay Gap - Shiny App - global.R
###############################################

#===== LOAD PACKAGES -----------------------------------------------------------------------------------------------------------
pkg <- c(
    # SHINY
    'bsplus', 'colourpicker', 'shiny', 'shinycssloaders', 'shinyDND', 'shinyjqui', 'shinyjs', 'shinymaterial', 'shinythemes', 'shinyWidgets', 
    # DATA WRANGLING
    'data.table', 'fst', 'htmltools', 'plyr', 'RMySQL', 'scales',
    # DATA VIZ
    'bpexploder', 'Cairo', 'circlize', 'd3heatmap', 'DT', 'extrafont', 'geofacet', 'GGally', 'ggplot2', 'ggiraph', 'ggrepel', 'ggthemes', 'RColorBrewer'
)
invisible( lapply(pkg, require, char = TRUE) )

#===== GENERAL OPTIONS ----------------------------------------------------------------------------------------------------------
options(spinner.color = '#e5001a', spinner.size = 1, spinner.type = 4)

#===== LOAD DATA ----------------------------------------------------------------------------------------------------------------
dts <- read.fst('data/dataset.fst', as.data.table = TRUE)
cmp <- read.fst('data/companies.fst', as.data.table = TRUE)
loc <- read.fst('data/locations.fst', as.data.table = TRUE)
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_gender_pay_gap')
vars <- data.table( dbReadTable(dbc, 'vars') )
last_updated <- dbGetQuery(dbc, "SELECT MAX(updated_at) FROM companies")
dbDisconnect(dbc)
last_updated <- as.Date(as.character(last_updated), '%Y-%m-%d')

#===== RECODE DATA --------------------------------------------------------------------------------------------------------------


#===== FUNCTIONS ----------------------------------------------------------------------------------------------------------------
# convert a ggplot into its corresponding interactive plot from ggiraph extension
gg.to.ggiraph <- function(p, sel.type = 'single', gg.width = 0.8){
        ggiraph( code = {print(p)}, 
            width  = gg.width,
            zoom_max  = 5,
            selection_type = sel.type,
            # selected_css = "",
            tooltip_offx = 20, tooltip_offy = -10,
            hover_css = "fill:red;cursor:pointer;r:4pt;opacity-value:0.5;",
            tooltip_extra_css= "background-color:wheat;color:gray20;border-radius:10px;padding:3pt;",
            tooltip_opacity = 0.9,
            pointsize = 12
        )
}

#===== VARIABLES/LABELS ----------------------------------------------------------------------------------------------------------------

# 


# Default color/palette 
pal.default <- c('col' = 'steelblue3', 'cat' = 'Dark2', 'seq' = 'YlGnBu', 'div' = 'RdBu', 'na' = 'grey62')

# List of palettes to be used with ColourBrewer package:  
lst.palette <- list(
    'SEQUENTIAL' = c( # ordinal data where (usually) low is less important and high is more important
        'Blues' = 'Blues', 'Blue-Green' = 'BuGn', 'Blue-Purple' = 'BuPu', 'Green-Blue' = 'GnBu', 'Greens' = 'Greens', 'Greys' = 'Greys',
        'Oranges' = 'Oranges', 'Orange-Red' = 'OrRd', 'Purple-Blue' = 'PuBu', 'Purple-Blue-Green' = 'PuBuGn', 'Purple-Red' = 'PuRd', 'Purples' = 'Purples',
        'Red-Purple' = 'RdPu', 'Reds' = 'Reds', 'Yellow-Green' = 'YlGn', 'Yellow-Green-Blue' = 'YlGnBu', 'Yellow-Orange-Brown' = 'YlOrBr',
        'Yellow-Orange-Red' = 'YlOrRd'
    ), 
    'DIVERGING' = c(  # ordinal data where both low and high are important (i.e. deviation from some reference "average" point)
        'Brown-Blue-Green' = 'BrBG', 'Pink-Blue-Green' = 'PiYG', 'Purple-Red-Green' = 'PRGn', 'Orange-Purple' = 'PuOr', 'Red-Blue' = 'RdBu', 'Red-Grey' = 'RdGy',
        'Red-Yellow-Blue' = 'RdYlBu', 'Red-Yellow-Green' = 'RdYlGn', 'Spectral' = 'Spectral'
    ),  
    'QUALITATIVE' = c(  # categorical/nominal data where there is no logical order
        'Accent' = 'Accent', 'Dark2' = 'Dark2', 'Paired' = 'Paired', 'Pastel1' = 'Pastel1', 'Pastel2' = 'Pastel2',
        'Set1' = 'Set1', 'Set2' = 'Set2', 'Set3' = 'Set3'
    )
)

# list of labels for download buttons
btndwn.text <- c('Save Dataset as CSV', 'Save Chart as PNG', 'Save Static Map as PNG', 'Save Interactive Map as HTML', 'Save Table as CSV')

# list of options for charts
point.shapes <- c('circle' = 21, 'square' = 22, 'diamond' = 23, 'triangle up' = 24, 'triangle down' = 25)
line.types <- c('dashed', 'dotted', 'solid', 'dotdash', 'longdash', 'twodash')
face.types <- c('plain', 'bold', 'italic', 'bold.italic')
val.lbl.pos <- list(
    'Inside'  = list('Vertical' = c(0.5,  1.5), 'Horizontal' = c( 1.2, 0.2) ),
    'Outside' = list('Vertical' = c(0.4, -0.3), 'Horizontal' = c(-0.2, 0.2) )
)
lbl.format <- function(y, type, is.pct = FALSE){
    if(type == 1){
        format(y, big.mark = ',', nsmall = 0)
    } else if(type == 2){
        if(is.pct){
            paste0(format(round(100 * y, 2), nsmall = 2), '%')
        } else {
            format(y, big.mark = ',', nsmall = 0)
        }
    } else {
        format(y, nsmall = 2)
    }
}

#===== STYLES ----------------------------------------------------------------------------------------------------------------

# add text at the right of the upper navbar
navbarPageWithText <- function(..., text) {
    navbar <- navbarPage(...)
    textEl <- tags$p(class = "navbar-text", text)
    navbar[[3]][[1]]$children[[1]] <- htmltools::tagAppendChild( navbar[[3]][[1]]$children[[1]], textEl)
    navbar
}

# return correct spacing for axis labels rotation
lbl.plt.rotation = function(angle, position = 'x'){
    positions = list(x = 0, y = 90, top = 180, right = 270)
    rads  = (angle - positions[[ position ]]) * pi / 180
    hjust = 0.5 * (1 - sin(rads))
    vjust = 0.5 * (1 + cos(rads))
    element_text(angle = angle, vjust = vjust, hjust = hjust)
}

# global style for ggplot charts
my.ggtheme <- function(g, 
                    xaxis.draw = FALSE, yaxis.draw = FALSE, axis.draw = FALSE, ticks.draw = FALSE, axis.colour = 'black', axis.size = 0.1,
                    hgrid.draw = FALSE, vgrid.draw = FALSE, grids.colour = 'black', grids.size = 0.1, grids.type = 'dotted',
                    labels.rotation = c(45, 0), labels.rotate = FALSE, 
                    bkg.colour = 'white', font.size = 6, ttl.font.size.mult = 1.2, ttl.face = 'bold',
                    legend.pos = 'bottom', plot.border = FALSE, font.family = 'Arial'
              ){
    g <- g + theme(
                text             = element_text(family = font.family),
                plot.title       = element_text(hjust = 0, size = rel(1.2) ),  # hjust: 0-left, 0.5-center, 1-right
                plot.background  = element_blank(),
                plot.margin      = unit(c(1, 0.5, 0, 0.5), 'lines'),  # space around the plot as in: TOP, RIGHT, BOTTOM, RIGHT
                plot.caption     = element_text(size = 8, face = 'italic'),
                axis.line        = element_blank(),
                axis.ticks       = element_blank(),
                axis.text        = element_text(size = font.size, color = axis.colour),
                axis.text.x      = element_text(angle = labels.rotation[1], hjust = 1), # vjust = 0.5),
                axis.text.y      = element_text(angle = labels.rotation[2]), # , hjust = , vjust = ),
                axis.title       = element_text(size = font.size * (1 + ttl.font.size.mult), face = ttl.face),
                axis.title.x     = element_text(vjust = -0.3), 
                axis.title.y     = element_text(vjust = 0.8, margin = margin(0, 10, 0, 0) ),
                legend.text      = element_text(size = 6),
                legend.title     = element_text(size = 8), 
                legend.title.align = 1,
                legend.position  = legend.pos,
                legend.background = element_blank(), 
                legend.spacing   = unit(0, 'cm'),
#                legend.key = element_blank(), 
                legend.key.size  = unit(0.2, 'cm'),
                legend.key.height = unit(0.4, 'cm'),      
                legend.key.width = unit(1, 'cm'),
                panel.background = element_rect(fill = bkg.colour, colour = bkg.colour), 
                panel.border     = element_blank(),
                panel.grid       = element_blank(),
                panel.spacing.x  = unit(3, 'lines'),
                panel.spacing.y  = unit(2, 'lines'),
                strip.text       = element_text(hjust = 0.5, size = font.size * (1 + ttl.font.size.mult), face = ttl.face),
                strip.background = element_blank()
    )
    if(plot.border) g <- g + theme( panel.border = element_rect(colour = axis.colour, size = axis.size, fill = NA) )
    if(axis.draw){
        g <- g + theme( axis.line = element_line(color = axis.colour, size = axis.size ) )
    } else {
        if(xaxis.draw) g <- g + theme( axis.line.x = element_line(color = axis.colour, size = axis.size ) )
        if(yaxis.draw) g <- g + theme( axis.line.y = element_line(color = axis.colour, size = axis.size ) )
    }
    if(ticks.draw)  g <- g + theme( axis.ticks = element_line(color = axis.colour, size = axis.size ) )
    if(hgrid.draw & vgrid.draw){
        g <- g + theme( panel.grid.major = element_line(colour = grids.colour, size = grids.size, linetype = grids.type ) )
    } else{
        if(vgrid.draw) g <- g + theme( panel.grid.major.x = element_line(colour = grids.colour, size = grids.size, linetype = grids.type ) ) 
        if(hgrid.draw) g <- g + theme( panel.grid.major.y = element_line(colour = grids.colour, size = grids.size, linetype = grids.type ) )
    }
   if(labels.rotate){
       g <- g + theme( axis.text.x = element_text(hjust = 1, angle = 45 ) )
   }
    return(g)
}
