#########################################################
# UK Gender Pay Gap - Shiny App - TABLES - server.R
#########################################################

# TOGGLES -----------------------------------------------------------------------------------------------------------------------
onclick('tgl_eda_geo', toggle(id = 'hdn_eda_geo', anim = TRUE) )  # geography
onclick('tgl_eda_mtc', toggle(id = 'hdn_eda_mtc', anim = TRUE) )  # metrics
onclick('tgl_eda_opt', toggle(id = 'hdn_eda_opt', anim = TRUE) )  # options
onclick('tgl_eda_dwn', toggle(id = 'hdn_eda_dwn', anim = TRUE) )  # download

onclick('tgl_eda_brp_gen', toggle(id = 'hdn_eda_brp_gen', anim = TRUE) )           # options / bars / general
onclick('tgl_eda_brp_axs', toggle(id = 'hdn_eda_brp_axs', anim = TRUE) )           # options / bars / axis
onclick('tgl_eda_brp_bkg', toggle(id = 'hdn_eda_brp_bkg', anim = TRUE) )           # options / bars / background
onclick('tgl_eda_brp_brs', toggle(id = 'hdn_eda_brp_brs', anim = TRUE) )           # options / bars / bars
onclick('tgl_eda_brp_lbl', toggle(id = 'hdn_eda_brp_lbl', anim = TRUE) )           # options / bars / labels
onclick('tgl_eda_brp_avg', toggle(id = 'hdn_eda_brp_avg', anim = TRUE) )           # options / bars / average line


# DYNAMIC CONTROLS --------------------------------------------------------------------------------------------------------------

# Geography
output$ui_eda_geo <- renderUI({
    if(input$cbo_eda_geoC == 'ALL') return(NULL)
    y <- unique(dts.units[Country == as.character(input$cbo_eda_geoC), .(as.character(Region))])[order(V1)]
    ui.list <- as.list(y[, V1])
    names(ui.list) <- y[, V1]
    selectInput('cbo_eda_geo', 'REGION:', choices = c('ALL', y))
})


# ### BARPLOT (brp) ---------------------------------------------------------------------------------------------------------------
# Choose a value from the filtering variable
output$ui_eda_brp_flt <- renderUI({
    selectInput('cbo_eda_brp_flt', 'ON:', choices = c('Choose a value...' = 'NONE', build_uiF(input$cbo_eda_brpF) ) )
})
# Choice of grouping type
output$ui_eda_brp_grp <- renderUI({
    ui.list <- c('dodge', 'facet')
    if(metrics[label == input$cbo_eda_brpY, type] == 1) ui.list <- c(ui.list, 'stack', 'fill')
    if(metrics[label == input$cbo_eda_brpY, type] == 2)
        if(!input$chk_eda_brp_pct) ui.list <- c(ui.list, 'stack', 'fill')
	selectInput('cbo_eda_brp_grp', 'GROUPING TYPE:', choices = ui.list)
})


# DOWNLOAD: Choose filename for exporting dataset, chart, map, ...
output$ui_eda_dwn <- renderUI({
    textInput('txt_eda_dwn', 'FILENAME:', paste(input$tabs_eda, input$cbo_eda_geo, Sys.Date(), sep = '_') )
})



# ### DRAW BARPLOT (brp) ----------------------------------------------------------------------------------------------------------
# 
eda_brp_plt <- reactive({
    ch_var_id <- input$cbo_eda_brpX
    dts <- vars[var_id == ch_var_id, dts_id]
    y <- get_ch_var_df(dts, ch_var_id)

#     yg[, ttip := paste0(
#                     'Gender: <b>', Z, '</b><br/>',
#                     'Local Drinking Moments: <b>', X, '</b><br/>',
#                     'Frequency: <b>', N, '</b><br/>'
#     )]
#     # build first layer
    # g <- ggplot(yg, aes(x = X, y = N, fill = Z, tooltip = ttip, data_id = ttip) )
    g <- ggplot(y, aes(x = X, y = N) ) # + geom_bar(stat = 'identity')
#     # bar attributes
    bars.col <- ifelse(length(input$col_eda_brp), input$col_eda_brp, pal.default['col'])
    bars.width <- input$sld_eda_brp_baw / 10
#     # border attributes
    border.size <- ifelse(input$chk_eda_brp_bdr, input$sld_eda_brp_bow / 30, 0)
    border.col <- ifelse(input$chk_eda_brp_bdr, input$col_eda_brp_boc, NA)
    border.type <- ifelse(input$chk_eda_brp_bdr, input$cbo_eda_brp_bot, 'solid')
#     # write ggplot instruction to actually plot the bars corresponding to ungrouped / grouped, and in the latter case if faceting or not
#     g1 <- geom_bar_interactive(stat = 'identity', fill = bars.col, width = bars.width, size = border.size, color = border.col, linetype = border.type)
    g <- g + geom_bar_interactive(stat = 'identity', fill = bars.col, width = bars.width, size = border.size, color = border.col, linetype = border.type)
    # g <- g + g1 # + facet_wrap(~Z)
#     # rotate axis
    if(input$rdb_eda_brp_orn == 'Horizontal') g <- g + coord_flip()
#     # add legend and axis titles (main title and subtitle are added automatically to the print version)
    g <- g + labs(x = '', y = '')
#     # calculate angle rotation for centres labels
#     labels.rotation <- ifelse(length(input$sld_eda_brp_lbr), input$sld_eda_brp_lbr, 45)
#     labels.rotation <- if(input$rdb_eda_brp_orn == 'Vertical'){ c(labels.rotation, 0) } else { c(0, labels.rotation) }
#     # apply general theme
    my.ggtheme(g)
})
# 
output$out_eda_brp <- renderggiraph({
    gg.to.ggiraph(eda_brp_plt(), gg.width = 1)
})
#  
# 
# 
# ### DRAW BOXPLOT (bxp) ----------------------------------------------------------------------------------------------------------
# 
# eda_bxp_plt <- reactive({
#     y1 <- dts.units[Country == 'France' & Occupation_level == 'Low' , .(X = Region, LinkID)]
#     y2 <- dts.survey[, .( Y = round(sum(`Retail_Value_(EUR)`)) ), LinkID]
#     setkey(y1, 'LinkID')
#     setkey(y2, 'LinkID')
#     y <- y1[y2]
#     yg <- y[complete.cases(y)]
#     bpexploder(
#         data = yg,
#         settings = list(
#             groupVar = 'X',
#             levels = levels(yg$X),
#             yVar = 'Y',
#             tipText = list( X = 'Region', Y = 'Revenues' ),
#             yAxisLabel = 'Total Revenues',
#             xAxisLabel = 'Region',
#             relativeWidth = 0.75
#         )
#     )
# })
# 
# output$out_eda_bxp <- renderBpexploder({
#     eda_bxp_plt()
# })
# 
# 
# ### DRAW SCATTERPLOT (scp) ----------------------------------------------------------------------------------------------------------
# 
# eda_scp_plt <- reactive({
#     y1 <- dts.units[Country == 'France', .(Z1 = Occupation_level, Z2 = CI_Coca_Cola, X = Exact_Age, LinkID)]
#     levels(y1$Z1) <- c('Low', 'Middle', 'High')
#     levels(y1$Z2) <- c("Def. Drink", "Prob. Drink", "May (Not) Drink", "Prob. Not Drink", "Def. Not Drink")
#     y2 <- dts.survey[, .( Y = sum(`Retail_Value_(EUR)`) ), LinkID]
#     setkey(y1, 'LinkID')
#     setkey(y2, 'LinkID')
#     y <- y1[y2]
#     yg <- y[complete.cases(y)]
#     yg[, ttip := paste0(
#                     'Occupation Level: <b>', Z1, '</b><br/>',
#                     'Age: <b>', X, '</b><br/>',
#                     'AVG Revenues: <b>', round(Y), '</b><br/>',
#                     'Coca Cola: <b>', Z2, '</b><br/>'
#     )]
#     g <- ggplot(yg, aes(x = X, y = Y, colour = Z1) )
#     g <- g + geom_point_interactive(aes(tooltip = ttip, data_id = ttip),  alpha = 0.6)
#     g <- g + facet_wrap(~Z2)
#     g <- g  + labs(x = 'Age', y = 'Revenues', colour = 'Occupation Level')
#     # apply general theme
#     my.ggtheme(g)
# })
# 
# output$out_eda_scp <- renderggiraph({
#     gg.to.ggiraph(eda_scp_plt(), gg.width = 1)
# })
 
### DRAW MAP (map) ----------------------------------------------------------------------------------------------------------
eda_map_plt <- reactive({
    dts_geo <- plots[!is.na(longitude), .(id, longitude, latitude)]
    ch_var_id <- input$cbo_eda_mapX
    dts <- vars[var_id == ch_var_id, dts_id]
    y <- get_ch_var(dts, ch_var_id)
    dts_geo <- dts_geo[y, on = 'id']
    pal <- colorFactor(
                brewer.pal(length(levels(y$X)), input$pal_eda_map), 
                domain = levels((y$X))
    )
    if(input$chk_eda_map_rvc) pal <- rev(pal)
    p <- leaflet(dts_geo) %>% 
#            setView(lng = 28.23872, lat = -15.43422, zoom = 10) %>% 
            fitBounds(28.205, -15.454, 28.265, -15.417) %>% 
#            addProviderTiles(providers$Stamen.Terrain) %>%
            addTiles(input$cbo_eda_map_tls) %>% 
            addCircleMarkers(
                radius = 4,
                color = ~pal(X),
                stroke = FALSE, fillOpacity = 0.5
            )
    if(input$chk_eda_map_lgn){
        p <- p %>% 
                addLegend(
                    input$cbo_eda_map_lgn, 
                    pal = pal, 
                    values = ~X,
                    title = ch_var_id,
                    opacity = as.numeric(input$sld_eda_map_trp) / 10
                )
    }
    p
})
output$out_eda_map <- renderLeaflet({
    eda_map_plt()
})

### DRAW HEXBIN (hxb) ----------------------------------------------------------------------------------------------------------
eda_hxb_plt <- reactive({
    dts_geo <- plots[!is.na(longitude), .(id, longitude, latitude)]
    ch_var_id <- input$cbo_eda_hxbX
    dts <- vars[var_id == ch_var_id, dts_id]
    y <- get_ch_var(dts, ch_var_id)
    dts_geo <- dts_geo[y, on = 'id']
    pal <- colorFactor(
                brewer.pal(length(levels(y$X)), input$pal_eda_hxb), 
                domain = levels((y$X))
    )
    if(input$chk_eda_map_rvc) pal <- rev(pal)
    g <- ggplot(dts_geo, aes(x = longitude, y = latitude, z = X)) +
            stat_summary_hex(fun = input$cbo_eda_hxx_fun, bins = as.numeric(input$sld_eda_hxb_bin)) +
            coord_cartesian()
    if(input$chk_eda_hxb_lgn){
        
    }
    my.ggtheme(g)
})
output$out_eda_hxb <- renderggiraph({
    gg.to.ggiraph(eda_hxb_plt(), gg.width = 1)
})
