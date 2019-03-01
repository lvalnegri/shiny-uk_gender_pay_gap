####################################################
# UK Gender Pay Gap - Shiny App - MAPS - ui.R
# ##################################################

tabPanel('MAPS', icon = icon('wpexplorer'),

# SIDEBAR PANEL -----------------------------------------------------------------------------------------------------------------
	sidebarPanel(

# 		# METRICS ---------------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_mps_mtc', 'Show/Hide METRICS', class = 'toggle-choices'),
		div(id = 'hdn_mps_mtc',

#             # Metric Controls for DOTS -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_mps == 'map'",
                # Choose Reference metric
                selectInput('cbo_mps_mapX', 'ATTRIBUTE:', choices = build_uiV('CAT'), selected = 'fill_level' )
            ),
# 
#             # Metric Controls for HEXBIN -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_mps == 'hexbin'",
                # Choose Reference metric
                selectInput('cbo_mps_hxbX', 'MEASURE:', choices = build_uiV('INT'), selected = 'no_of_toilets' ),
                selectInput('cbo_mps_hxx_fun', 'FUNCTION:', choices = c('min', 'max', 'sum', 'mean', 'median', 'quantile', 'var'), selected = 'sum' )
            )
# 
#             # END OF Metrics Controls -------------------------------------------------------------------------------------------

        ), hr(),

		# OPTIONS ---------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_mps_opt', 'Show/Hide OPTIONS', class = 'toggle-choices'),
		hidden(
			div(id = 'hdn_mps_opt',
                p(),

# 			    # Option Controls for TABLE ----------------------------------------------------------------------------------------------
#         		conditionalPanel("input.tabs_mps == 'table'",
#                     # Control the color for the background in the cells with the bars
#                     colourpicker::colourInput('col_mps_tbb', 'FILL COLOUR:', '#63B8FF', showColour = 'background'),
#                     # Control the color for the font when cells are formatted
#                     colourpicker::colourInput('col_mps_tbf', 'FONT COLOUR:', 'black', showColour = 'background', palette = 'limited'),
#                     # Control the divergent palette for the background in the INDEX column
#                     selectInput('pal_mps_tbl', 'PALETTE:', choices = lst.palette[['DIVERGING']], selected = 'Spectral' ),
#                     checkboxInput('chk_mps_tbl_rvc', 'REVERSE COLOURS', value = FALSE),
#                     # Control the number of colours for the above divergent palette
#                     sliderInput('sld_mps_tbl_col', 'NUMBER OF QUANTILES:', min = 2, max = 10, value = 5, step = 1, ticks = FALSE)
# 
#     			    # END OF TABLE Option Controls ---------------------------------------------------------------------------------------
#         		),
# 
# 			    # Option Controls for BARPLOT  -------------------------------------------------------------------------------------------
           		conditionalPanel("input.tabs_mps !== 'table'",

                    # GENERAL --------------------------------------------------------------------------------------------
            		a(id = 'tgl_mps_brp_gen', 'Show/Hide GENERAL', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_mps_brp_gen',
                            p(),
            			    # Plot Zoom
            				sliderInput('sld_mps_brp_ggw', 'ZOOM:', min = 4, max = 10, value = 6.5, step = 0.5, ticks = FALSE),
                			# Force y-axis to show origin
                			checkboxInput('chk_mps_brp_yzr', 'SHOW ORIGIN', TRUE),
                			# Text Size and Font family
                            sliderInput('sld_mps_brp_xlz', 'TEXT SIZE:', min = 1, max = 15, value = 7, step = 0.5, ticks = FALSE),
#                            selectInput('cbo_mps_brp_ffm', 'FONT FAMILY:', choices = font.table, selected = 'Arial')
                            selectInput('cbo_mps_brp_ffm', 'FONT FAMILY:', choices = 'Arial')
            			), hr()
            		), br(),

                    # AXIS --------------------------------------------------------------------------------------------
            		a(id = 'tgl_mps_brp_axs', 'Show/Hide AXIS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_mps_brp_axs',
                            p(),
                            # Control the rotation of the axis labels
                            sliderInput('sld_mps_brp_lbr', 'AXIS LABEL ROTATION:', min = 0, max = 90, value = 45, step = 5, ticks = FALSE),
                            # Control the appearance of Axis Lines and Ticks, plus Plot Border
                			checkboxInput('chk_mps_brp_xlx', 'ADD x-AXIS LINE', TRUE),
                			checkboxInput('chk_mps_brp_xly', 'ADD y-AXIS LINE', TRUE),
                			checkboxInput('chk_mps_brp_xtk', 'ADD AXIS TICKS', TRUE),
                			checkboxInput('chk_mps_brp_plb', 'ADD PLOT BORDER', FALSE),
                       		conditionalPanel("input.chk_mps_brp_xlx || input.chk_mps_brp_xly || input.chk_mps_brp_xtk || input.chk_mps_brp_plb",
                                sliderInput('sld_mps_brp_xsz', 'SIZE:', min = 1, max = 5, value = 2, step = 0.5, ticks = FALSE),
                                colourpicker::colourInput('col_mps_brp_xsc', 'COLOUR:', 'grey50', showColour = 'background')
                       		),
                            # Add and Control the appearance of Axis Titles
                			checkboxInput('chk_mps_brp_xlt', 'ADD AXIS TITLES', FALSE),
                       		conditionalPanel("input.chk_mps_brp_xlt",
                                sliderInput('sld_mps_brp_xlt', 'FONT SIZE MULTIPLE:', min = 0, max = 100, value = 20, step = 5, ticks = FALSE, post = '%'),
                                selectInput('cbo_mps_brp_xlt', 'FONT FACE:', choices = face.types, selected = 'bold')
                       		)
            			), hr()
            		), br(),

                    # BACKGROUND --------------------------------------------------------------------------------------------
            		a(id = 'tgl_mps_brp_bkg', 'Show/Hide BACKGROUND', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_mps_brp_bkg',
                            p(),
                			# Background color
                            colourpicker::colourInput('col_mps_brp_bkg', 'BACKGROUND COLOUR:', 'white', showColour = 'background'),
                			# Grids
                            checkboxGroupInput('chg_mps_brp_grd', 'ADD GRIDS', choices = c('Horizontal', 'Vertical'), inline = TRUE ),
                       		conditionalPanel("input.chg_mps_brp_grd.length > 0",
                                sliderInput('sld_mps_brp_gdz', 'SIZE:', min = 0.5, max = 5, value = 2, step = 0.5, ticks = FALSE),
                                colourpicker::colourInput('col_mps_brp_gdc', 'COLOUR:', 'grey50', showColour = 'background'),
                                selectInput('cbo_mps_brp_gdt', 'TYPE:', choices = line.types, selected = 'dotted')
                       		)
            			), hr()
            		), br(),

                    # BARS ------------------------------------------------------------------------------------------------------
            		a(id = 'tgl_mps_brp_brs', 'Show/Hide BARS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_mps_brp_brs',
                            p(),
                            # Control how bars are ordered
                            selectInput('cbo_mps_brp_ord', 'ORDERING:', choices = c('Alpha (ASC)' = 1, 'Alpha (DESC)' = 2, 'Values (ASC)' = 3, 'Values (DESC)' = 4) ),
                            # Control if barplot is horizontal or vertical
                            radioButtons('rdb_mps_brp_orn', 'ORIENTATION:', choices = c('Vertical', 'Horizontal'), selected = 'Horizontal',  inline = TRUE ),
                            # Choose colour / palette
                			uiOutput('ui_mps_brp_col'),
                   		    conditionalPanel("typeof input.pal_mps_brp !== 'undefined'",
                                checkboxInput('chk_mps_brp_rvc', 'REVERSE COLOURS', value = FALSE)
                            ),
                            # Control width of bars
                            sliderInput('sld_mps_brp_baw', 'WIDTH:', min = 1, max = 10, value = 8, step = 0.5, ticks = FALSE),
                			# Add and customize bars' borders
                			checkboxInput('chk_mps_brp_bdr', 'ADD BARS BORDER', FALSE),
                    		conditionalPanel("input.chk_mps_brp_bdr",
                                sliderInput('sld_mps_brp_bow', 'WIDTH:', min = 1, max = 15, value = 6, step = 1, ticks = FALSE),
                                colourpicker::colourInput('col_mps_brp_boc', 'COLOUR:', 'black', showColour = 'background'),
                                selectInput('cbo_mps_brp_bot', 'TYPE:', choices = line.types, selected = 'solid')
                            )
            			), hr()
            		), br(),

                    # LABELS IN BARS --------------------------------------------------------------------------------------------
            		a(id = 'tgl_mps_brp_lbl', 'Show/Hide LABELS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_mps_brp_lbl',
                            p(),
                			# Add (if not grouped stack/fill), and customize value labels in bars (depends on labels IN/OUT and orientation H/V)
                			checkboxInput('chk_mps_brp_lbl', 'ADD VALUE LABELS IN BARS', FALSE),
                    		conditionalPanel("input.chk_mps_brp_lbl",
                                sliderInput('sld_mps_brp_lbz', 'LABELS FONT SIZE', min = 1, max = 4, value = 1.6, step = 0.2, ticks = TRUE),
                                radioButtons('rdb_mps_brp_lbp', 'LABELS POSITION', choices = c('Inside', 'Outside'), inline = TRUE ),
                                # uiOutput('ui_mps_brp_lbp'),
                                uiOutput('ui_mps_brp_lbc')
                            )
            			), hr()
            		), br(),

                    # AVERAGE LINE ----------------------------------------------------------------------------------------------
                    conditionalPanel("input.chk_mps_brp_avg",
                		a(id = 'tgl_mps_brp_avg', 'Show/Hide AVERAGE LINE', class = 'toggle-choices-sub'),
                		hidden(
                			div(id = 'hdn_mps_brp_avg',
                                p(),
                                checkboxInput('chk_mps_brp_avl', 'ADD VALUE', value = FALSE),
                                colourpicker::colourInput('col_mps_brp_avc', 'COLOUR:', 'black', showColour = 'background'),
                                sliderInput('sld_mps_brp_avz', 'SIZE:', min = 1, max = 8, value = 4, step = 0.5, ticks = FALSE),
                                selectInput('cbo_mps_brp_avt', 'TYPE:', choices = line.types, selected = 'dotdash'),
                                sliderInput('sld_mps_brp_avt', 'TRANSPARENCY:', min = 0, max = 10, value = 4, step = 1, ticks = FALSE)
                		    )
                	    ), br()
                    )

    			    # END OF BARS Option Controls -------------------------------------------------------------------------------------------------
        		),

			    # Option Controls for MAP ----------------------------------------------------------------------------------------------
        		conditionalPanel("input.tabs_mps == 'map'",
                    # Choose background tile
                    selectInput('cbo_mps_map_tls', 'TILES:', choices = c(tiles.list), selected = tile.ini),
                    # Control the divergent palette for the background in the INDEX column
                    selectInput('pal_mps_map', 'PALETTE:', choices = lst.palette, selected = 'Spectral' ),
                    checkboxInput('chk_mps_map_rvc', 'REVERSE COLOURS', value = FALSE),
                    # Transparency
        			sliderInput('sld_mps_map_trp', 'TRANSPARENCY:', min = 0, max = 10, value = 8, ticks = FALSE),
                    # Add Legend
                    checkboxInput('chk_mps_map_lgn', 'ADD LEGEND', TRUE),
                    conditionalPanel("input.chk_mps_map_lgn",
                        # Legend Position
                        selectInput('cbo_mps_map_lgn', 'POSITION:', choices = c('bottomright', 'bottomleft', 'topleft', 'topright') )
                    )

    			    # END OF MAP Option Controls ---------------------------------------------------------------------------------------
        		),

			    # Option Controls for HEXBIN ----------------------------------------------------------------------------------------------
        		conditionalPanel("input.tabs_mps == 'hexbin'",
                    # Number of bins
        			sliderInput('sld_mps_hxb_bin', 'BINS:', min = 10, max = 100, value = 30, ticks = FALSE),
                    # Control the divergent palette for the background in the INDEX column
                    selectInput('pal_mps_hxb', 'PALETTE:', choices = lst.palette, selected = 'Spectral' ),
                    checkboxInput('chk_mps_hxb_rvc', 'REVERSE COLOURS', value = FALSE),
                    # Transparency
        			sliderInput('sld_mps_hxb_trp', 'TRANSPARENCY:', min = 0, max = 10, value = 8, ticks = FALSE),
                    # Add Legend
                    checkboxInput('chk_mps_hxb_lgn', 'ADD LEGEND', TRUE),
                    conditionalPanel("input.chk_mps_hxb_lgn",
                        # Legend Position
                        selectInput('cbo_mps_hxb_lgn', 'POSITION:', choices = c('bottomright', 'bottomleft', 'topleft', 'topright') )
                    )

    			    # END OF MAP Option Controls ---------------------------------------------------------------------------------------
        		)
    
# 			    # END OF Option Controls -------------------------------------------------------------------------------------------------
		)), hr(),

# 		# DOWNLOAD --------------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_mps_dwn', 'Show/Hide DOWNLOAD', class = 'toggle-choices'),
		hidden(
    		div(id = 'hdn_mps_dwn',
                p(),
    		    # Common input for filename, needs a UI to change default
    		    uiOutput('ui_mps_dwn'),
			    # Download dataset for TABLE
           		conditionalPanel("input.tabs_mps == 'table'",
        		    textOutput('txt_mps_dwn'), br(),
                    downloadButton('dwn_mps_dta', label = btndwn.text[1], class = 'btndwn')
           		),
	            # Downloads for remaining substabs
           		conditionalPanel("input.tabs_mps !== 'table'",
    	            # Download dataset behind chart
                    downloadButton('dwn_mps_tbl', label = btndwn.text[5], class = 'btndwn'),
        			# Optional Caption for Charts
                    checkboxInput('chk_mps_cpt', 'ADD CAPTION', value = FALSE ),
               		conditionalPanel("input.chk_mps_cpt",
            		    textInput('txt_mps_cpt', '', value = 'test' ) # plt.caption)
               		),
    	            # Download Chart
                    downloadButton('dwn_mps_mps', label = btndwn.text[2], class = 'btndwn')
           		)
		)), hr(),

		width = 2

	),
# 
# # MAIN PANEL --------------------------------------------------------------------------------------------------------------------
	mainPanel(
        tabsetPanel(id = 'tabs_mps',

            tabPanel('dots', icon = icon('globe', lib = 'glyphicon'),
                htmlOutput('out_mps_dtx'), withSpinner( leafletOutput('out_mps_dts', width = "100%", height = "800px" ) )
            ),
            tabPanel('hexbin', icon = icon('connectdevelop'),
                htmlOutput('out_mps_hxx'), withSpinner( ggiraphOutput('out_mps_hxb', width = "100%", height = "800px") )
            )

        )
	)

)
