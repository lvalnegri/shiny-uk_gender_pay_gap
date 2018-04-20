####################################################
# UK Gender Pay Gap - Shiny App - TABLES - ui.R
####################################################

tabPanel('TABLES', icon = icon('table'),

# SIDEBAR PANEL -----------------------------------------------------------------------------------------------------------------
	sidebarPanel(

		# GEOGRAPHY -------------------------------------------------------------------------------------------------------------------
	    conditionalPanel("['map', 'hexbin'].indexOf(input.tabs_eda) == 0",
    		a(id = 'tgl_eda_geo', 'Show/Hide GEOGRAPHY', class = 'toggle-choices'),
    		div(id = "hdn_eda_geo",
    		    p(),
        		selectInput('cbo_eda_geo_zon', 'ZONES:', choices = c('ALL', levels(plots$zone)) ),
        		selectInput('cbo_eda_geo_sec', 'SECTIONS:', choices = c('ALL', levels(plots$section)) )
    		), hr()
	    ),
	    
# 		# METRICS ---------------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_eda_mtc', 'Show/Hide METRICS', class = 'toggle-choices'),
		div(id = 'hdn_eda_mtc',

            # Metric Controls for BARPLOT -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_eda == 'barplot'",
                # Choose Reference metric
                selectInput('cbo_eda_brpX', 'ATTRIBUTE:', choices = build_uiV('CAT') ),
                # Choose Reference metric
                selectInput('cbo_eda_brpY', 'MEASURE:', choices = build_uiY() ),
#                 # Show Percentage, IF chosen reference is type 2 (measure)
#         		uiOutput('ui_eda_brp_pct'),
#                 # Show Average, WHEN measure and IF GROUPED only when dodge or facet
#         		uiOutput('ui_eda_brp_avg'),
                # Choose a filter
                selectInput('cbo_eda_brpF', 'FILTERED BY:', choices = c('NONE', build_uiV(c('CAT')) ) ),
                # Choose which value of previous variable dta should be filtered on
        		conditionalPanel("input.cbo_eda_brpF !== 'NONE'",
        			uiOutput('ui_eda_brp_flt')
        		),
                # Choose if and how group above metric
                selectInput('cbo_eda_brpG', 'GROUPED BY:', choices = c('NONE', build_uiV('CAT')) ),
                # Choose how grouping should be displayed
        		conditionalPanel("input.cbo_eda_brpG !== 'NONE'",
        		    uiOutput('ui_eda_brp_grp'),
        			# Faceting options
            		conditionalPanel("input.cbo_eda_brp_grp == 'facet'",
                        checkboxInput('chk_eda_brp_scl', 'ALIGN SCALES', value = TRUE ),
                        selectInput('cbo_eda_brpG2', 'ADD VARIABLE:', choices = c('NONE', build_uiV(c('CAT', 'GEO')) ) ),
                        # Choose numbers of columns if faceting only once
                		conditionalPanel("input.cbo_eda_brpG2 == 'NONE'",
                			sliderInput('sld_eda_brp_fct', 'COLUMNS:', min = 1, max = 6, value = 2, ticks = FALSE)
                		)
        			)
        		)
            ),
# 
#             # Metric Controls for SCATTERPLOT -------------------------------------------------------------------------------------------------------------
# 		    conditionalPanel("input.tabs_eda == 'scatterplot'",
#                 # Choose effect size (X)
#                 selectInput('cbo_eda_scpX', 'X-axis:', choices = build_uiV(c('INT', 'DEC')) ),
#                 # trimming effect sizes
#                 uiOutput('ui_eda_scp_tmz'),
#                 # Choose reference measure / metric
#                 selectInput('cbo_eda_scpY', 'Y-axis', choices = build_uiY(), selected = 'Mean Revenues' ),
#                 # trimming metric values
#                 uiOutput('ui_eda_scp_tmt'),
#                 # Choose a filter
#                 selectInput('cbo_eda_scpF', 'FILTERED BY:', choices = c('NONE', build_uiV(c('CAT')) ) ),
#                 # Choose which value of previous variable dta should be filtered on
#         		conditionalPanel("input.cbo_eda_scpF !== 'NONE'",
#         			uiOutput('ui_eda_scp_flt')
#         		),
#                 # Choose if and how group above metric
#                 selectInput('cbo_eda_scpG', 'GROUPED BY:', choices = c('NONE', build_uiV('CAT')), selected = 'Occupation_level' ),
#                 # Choose how grouping should be displayed
#         		conditionalPanel("input.cbo_eda_scpG !== 'NONE'",
#         		    uiOutput('ui_eda_scp_grp'),
#         			# Faceting options
#             		conditionalPanel("input.cbo_eda_scp_grp == 'facet'",
#                         checkboxInput('chk_eda_scp_scl', 'ALIGN SCALES', value = TRUE ),
#                         selectInput('cbo_eda_scpG2', 'ADD VARIABLE:', choices = c('NONE', build_uiV(c('CAT', 'GEO')) ) ),
#                         # Choose numbers of columns if faceting only once
#                 		conditionalPanel("input.cbo_eda_scpG2 == 'NONE'",
#                 			sliderInput('sld_eda_scp_fct', 'COLUMNS:', min = 1, max = 6, value = 2, ticks = FALSE)
#                 		)
#         			)
#         		),
#                 # overall average
#                 checkboxInput('chk_eda_scp_avg', 'ADD AVERAGE LINE', FALSE)
#             )
# 
#             # Metric Controls for MAP -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_eda == 'map'",
                # Choose Reference metric
                selectInput('cbo_eda_mapX', 'ATTRIBUTE:', choices = build_uiV('CAT'), selected = 'fill_level' )
            ),
# 
#             # Metric Controls for HEXBIN -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_eda == 'hexbin'",
                # Choose Reference metric
                selectInput('cbo_eda_hxbX', 'MEASURE:', choices = build_uiV('INT'), selected = 'no_of_toilets' ),
                selectInput('cbo_eda_hxx_fun', 'FUNCTION:', choices = c('min', 'max', 'sum', 'mean', 'median', 'quantile', 'var'), selected = 'sum' )
            )
# 
#             # END OF Metrics Controls -------------------------------------------------------------------------------------------

        ), hr(),

		# OPTIONS ---------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_eda_opt', 'Show/Hide OPTIONS', class = 'toggle-choices'),
		hidden(
			div(id = 'hdn_eda_opt',
                p(),

# 			    # Option Controls for TABLE ----------------------------------------------------------------------------------------------
#         		conditionalPanel("input.tabs_eda == 'table'",
#                     # Control the color for the background in the cells with the bars
#                     colourpicker::colourInput('col_eda_tbb', 'FILL COLOUR:', '#63B8FF', showColour = 'background'),
#                     # Control the color for the font when cells are formatted
#                     colourpicker::colourInput('col_eda_tbf', 'FONT COLOUR:', 'black', showColour = 'background', palette = 'limited'),
#                     # Control the divergent palette for the background in the INDEX column
#                     selectInput('pal_eda_tbl', 'PALETTE:', choices = lst.palette[['DIVERGING']], selected = 'Spectral' ),
#                     checkboxInput('chk_eda_tbl_rvc', 'REVERSE COLOURS', value = FALSE),
#                     # Control the number of colours for the above divergent palette
#                     sliderInput('sld_eda_tbl_col', 'NUMBER OF QUANTILES:', min = 2, max = 10, value = 5, step = 1, ticks = FALSE)
# 
#     			    # END OF TABLE Option Controls ---------------------------------------------------------------------------------------
#         		),
# 
# 			    # Option Controls for BARPLOT  -------------------------------------------------------------------------------------------
           		conditionalPanel("input.tabs_eda !== 'table'",

                    # GENERAL --------------------------------------------------------------------------------------------
            		a(id = 'tgl_eda_brp_gen', 'Show/Hide GENERAL', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_eda_brp_gen',
                            p(),
            			    # Plot Zoom
            				sliderInput('sld_eda_brp_ggw', 'ZOOM:', min = 4, max = 10, value = 6.5, step = 0.5, ticks = FALSE),
                			# Force y-axis to show origin
                			checkboxInput('chk_eda_brp_yzr', 'SHOW ORIGIN', TRUE),
                			# Text Size and Font family
                            sliderInput('sld_eda_brp_xlz', 'TEXT SIZE:', min = 1, max = 15, value = 7, step = 0.5, ticks = FALSE),
#                            selectInput('cbo_eda_brp_ffm', 'FONT FAMILY:', choices = font.table, selected = 'Arial')
                            selectInput('cbo_eda_brp_ffm', 'FONT FAMILY:', choices = 'Arial')
            			), hr()
            		), br(),

                    # AXIS --------------------------------------------------------------------------------------------
            		a(id = 'tgl_eda_brp_axs', 'Show/Hide AXIS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_eda_brp_axs',
                            p(),
                            # Control the rotation of the axis labels
                            sliderInput('sld_eda_brp_lbr', 'AXIS LABEL ROTATION:', min = 0, max = 90, value = 45, step = 5, ticks = FALSE),
                            # Control the appearance of Axis Lines and Ticks, plus Plot Border
                			checkboxInput('chk_eda_brp_xlx', 'ADD x-AXIS LINE', TRUE),
                			checkboxInput('chk_eda_brp_xly', 'ADD y-AXIS LINE', TRUE),
                			checkboxInput('chk_eda_brp_xtk', 'ADD AXIS TICKS', TRUE),
                			checkboxInput('chk_eda_brp_plb', 'ADD PLOT BORDER', FALSE),
                       		conditionalPanel("input.chk_eda_brp_xlx || input.chk_eda_brp_xly || input.chk_eda_brp_xtk || input.chk_eda_brp_plb",
                                sliderInput('sld_eda_brp_xsz', 'SIZE:', min = 1, max = 5, value = 2, step = 0.5, ticks = FALSE),
                                colourpicker::colourInput('col_eda_brp_xsc', 'COLOUR:', 'grey50', showColour = 'background')
                       		),
                            # Add and Control the appearance of Axis Titles
                			checkboxInput('chk_eda_brp_xlt', 'ADD AXIS TITLES', FALSE),
                       		conditionalPanel("input.chk_eda_brp_xlt",
                                sliderInput('sld_eda_brp_xlt', 'FONT SIZE MULTIPLE:', min = 0, max = 100, value = 20, step = 5, ticks = FALSE, post = '%'),
                                selectInput('cbo_eda_brp_xlt', 'FONT FACE:', choices = face.types, selected = 'bold')
                       		)
            			), hr()
            		), br(),

                    # BACKGROUND --------------------------------------------------------------------------------------------
            		a(id = 'tgl_eda_brp_bkg', 'Show/Hide BACKGROUND', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_eda_brp_bkg',
                            p(),
                			# Background color
                            colourpicker::colourInput('col_eda_brp_bkg', 'BACKGROUND COLOUR:', 'white', showColour = 'background'),
                			# Grids
                            checkboxGroupInput('chg_eda_brp_grd', 'ADD GRIDS', choices = c('Horizontal', 'Vertical'), inline = TRUE ),
                       		conditionalPanel("input.chg_eda_brp_grd.length > 0",
                                sliderInput('sld_eda_brp_gdz', 'SIZE:', min = 0.5, max = 5, value = 2, step = 0.5, ticks = FALSE),
                                colourpicker::colourInput('col_eda_brp_gdc', 'COLOUR:', 'grey50', showColour = 'background'),
                                selectInput('cbo_eda_brp_gdt', 'TYPE:', choices = line.types, selected = 'dotted')
                       		)
            			), hr()
            		), br(),

                    # BARS ------------------------------------------------------------------------------------------------------
            		a(id = 'tgl_eda_brp_brs', 'Show/Hide BARS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_eda_brp_brs',
                            p(),
                            # Control how bars are ordered
                            selectInput('cbo_eda_brp_ord', 'ORDERING:', choices = c('Alpha (ASC)' = 1, 'Alpha (DESC)' = 2, 'Values (ASC)' = 3, 'Values (DESC)' = 4) ),
                            # Control if barplot is horizontal or vertical
                            radioButtons('rdb_eda_brp_orn', 'ORIENTATION:', choices = c('Vertical', 'Horizontal'), selected = 'Horizontal',  inline = TRUE ),
                            # Choose colour / palette
                			uiOutput('ui_eda_brp_col'),
                   		    conditionalPanel("typeof input.pal_eda_brp !== 'undefined'",
                                checkboxInput('chk_eda_brp_rvc', 'REVERSE COLOURS', value = FALSE)
                            ),
                            # Control width of bars
                            sliderInput('sld_eda_brp_baw', 'WIDTH:', min = 1, max = 10, value = 8, step = 0.5, ticks = FALSE),
                			# Add and customize bars' borders
                			checkboxInput('chk_eda_brp_bdr', 'ADD BARS BORDER', FALSE),
                    		conditionalPanel("input.chk_eda_brp_bdr",
                                sliderInput('sld_eda_brp_bow', 'WIDTH:', min = 1, max = 15, value = 6, step = 1, ticks = FALSE),
                                colourpicker::colourInput('col_eda_brp_boc', 'COLOUR:', 'black', showColour = 'background'),
                                selectInput('cbo_eda_brp_bot', 'TYPE:', choices = line.types, selected = 'solid')
                            )
            			), hr()
            		), br(),

                    # LABELS IN BARS --------------------------------------------------------------------------------------------
            		a(id = 'tgl_eda_brp_lbl', 'Show/Hide LABELS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_eda_brp_lbl',
                            p(),
                			# Add (if not grouped stack/fill), and customize value labels in bars (depends on labels IN/OUT and orientation H/V)
                			checkboxInput('chk_eda_brp_lbl', 'ADD VALUE LABELS IN BARS', FALSE),
                    		conditionalPanel("input.chk_eda_brp_lbl",
                                sliderInput('sld_eda_brp_lbz', 'LABELS FONT SIZE', min = 1, max = 4, value = 1.6, step = 0.2, ticks = TRUE),
                                radioButtons('rdb_eda_brp_lbp', 'LABELS POSITION', choices = c('Inside', 'Outside'), inline = TRUE ),
                                # uiOutput('ui_eda_brp_lbp'),
                                uiOutput('ui_eda_brp_lbc')
                            )
            			), hr()
            		), br(),

                    # AVERAGE LINE ----------------------------------------------------------------------------------------------
                    conditionalPanel("input.chk_eda_brp_avg",
                		a(id = 'tgl_eda_brp_avg', 'Show/Hide AVERAGE LINE', class = 'toggle-choices-sub'),
                		hidden(
                			div(id = 'hdn_eda_brp_avg',
                                p(),
                                checkboxInput('chk_eda_brp_avl', 'ADD VALUE', value = FALSE),
                                colourpicker::colourInput('col_eda_brp_avc', 'COLOUR:', 'black', showColour = 'background'),
                                sliderInput('sld_eda_brp_avz', 'SIZE:', min = 1, max = 8, value = 4, step = 0.5, ticks = FALSE),
                                selectInput('cbo_eda_brp_avt', 'TYPE:', choices = line.types, selected = 'dotdash'),
                                sliderInput('sld_eda_brp_avt', 'TRANSPARENCY:', min = 0, max = 10, value = 4, step = 1, ticks = FALSE)
                		    )
                	    ), br()
                    )

    			    # END OF BARS Option Controls -------------------------------------------------------------------------------------------------
        		),

			    # Option Controls for MAP ----------------------------------------------------------------------------------------------
        		conditionalPanel("input.tabs_eda == 'map'",
                    # Choose background tile
                    selectInput('cbo_eda_map_tls', 'TILES:', choices = c(tiles.list), selected = tile.ini),
                    # Control the divergent palette for the background in the INDEX column
                    selectInput('pal_eda_map', 'PALETTE:', choices = lst.palette, selected = 'Spectral' ),
                    checkboxInput('chk_eda_map_rvc', 'REVERSE COLOURS', value = FALSE),
                    # Transparency
        			sliderInput('sld_eda_map_trp', 'TRANSPARENCY:', min = 0, max = 10, value = 8, ticks = FALSE),
                    # Add Legend
                    checkboxInput('chk_eda_map_lgn', 'ADD LEGEND', TRUE),
                    conditionalPanel("input.chk_eda_map_lgn",
                        # Legend Position
                        selectInput('cbo_eda_map_lgn', 'POSITION:', choices = c('bottomright', 'bottomleft', 'topleft', 'topright') )
                    )

    			    # END OF MAP Option Controls ---------------------------------------------------------------------------------------
        		),

			    # Option Controls for HEXBIN ----------------------------------------------------------------------------------------------
        		conditionalPanel("input.tabs_eda == 'hexbin'",
                    # Number of bins
        			sliderInput('sld_eda_hxb_bin', 'BINS:', min = 10, max = 100, value = 30, ticks = FALSE),
                    # Control the divergent palette for the background in the INDEX column
                    selectInput('pal_eda_hxb', 'PALETTE:', choices = lst.palette, selected = 'Spectral' ),
                    checkboxInput('chk_eda_hxb_rvc', 'REVERSE COLOURS', value = FALSE),
                    # Transparency
        			sliderInput('sld_eda_hxb_trp', 'TRANSPARENCY:', min = 0, max = 10, value = 8, ticks = FALSE),
                    # Add Legend
                    checkboxInput('chk_eda_hxb_lgn', 'ADD LEGEND', TRUE),
                    conditionalPanel("input.chk_eda_hxb_lgn",
                        # Legend Position
                        selectInput('cbo_eda_hxb_lgn', 'POSITION:', choices = c('bottomright', 'bottomleft', 'topleft', 'topright') )
                    )

    			    # END OF MAP Option Controls ---------------------------------------------------------------------------------------
        		)
    
# 			    # END OF Option Controls -------------------------------------------------------------------------------------------------
		)), hr(),

# 		# DOWNLOAD --------------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_eda_dwn', 'Show/Hide DOWNLOAD', class = 'toggle-choices'),
		hidden(
    		div(id = 'hdn_eda_dwn',
                p(),
    		    # Common input for filename, needs a UI to change default
    		    uiOutput('ui_eda_dwn'),
			    # Download dataset for TABLE
           		conditionalPanel("input.tabs_eda == 'table'",
        		    textOutput('txt_eda_dwn'), br(),
                    downloadButton('dwn_eda_dta', label = btndwn.text[1], class = 'btndwn')
           		),
	            # Downloads for remaining substabs
           		conditionalPanel("input.tabs_eda !== 'table'",
    	            # Download dataset behind chart
                    downloadButton('dwn_eda_tbl', label = btndwn.text[5], class = 'btndwn'),
        			# Optional Caption for Charts
                    checkboxInput('chk_eda_cpt', 'ADD CAPTION', value = FALSE ),
               		conditionalPanel("input.chk_eda_cpt",
            		    textInput('txt_eda_cpt', '', value = 'test' ) # plt.caption)
               		),
    	            # Download Chart
                    downloadButton('dwn_eda_plt', label = btndwn.text[2], class = 'btndwn')
           		)
		)), hr(),

		width = 2

	),
# 
# # MAIN PANEL --------------------------------------------------------------------------------------------------------------------
	mainPanel(
        tabsetPanel(id = 'tabs_eda',

            # UNI-VARIATE
            tabPanel('barplot', icon = icon('bar-chart'),
                htmlOutput('out_eda_brx'), withSpinner( ggiraphOutput('out_eda_brp', width = "100%", height = "600px") )
            ),
            tabPanel('boxplot', icon = icon('object-align-vertical', lib = 'glyphicon'),
                htmlOutput('out_eda_bxx'), withSpinner( bpexploderOutput('out_eda_bxp') )
            ),
            tabPanel('histogram', icon = icon('area-chart'),
                htmlOutput('out_eda_hsx'), withSpinner( ggiraphOutput('out_eda_hst') )
            ),

            # BI-VARIATE
            tabPanel('mosaic', icon = icon('th-list'),
                htmlOutput('out_eda_msx'), withSpinner( ggiraphOutput('out_eda_msc') )
            ),
            tabPanel('scatterplot', icon = icon('braille'),
                htmlOutput('out_eda_scx'), withSpinner( ggiraphOutput('out_eda_scp', width = "100%", height = "800px") )
            ),
            tabPanel('map', icon = icon('globe', lib = 'glyphicon'),
                htmlOutput('out_eda_max'), withSpinner( leafletOutput('out_eda_map', width = "100%", height = "800px" ) )
            ),
            tabPanel('hexbin', icon = icon('connectdevelop'),
                htmlOutput('out_eda_hxx'), withSpinner( ggiraphOutput('out_eda_hxb', width = "100%", height = "800px") )
            ),
            tabPanel('pyramid', icon = icon('align-center'),
                htmlOutput('out_eda_pyx'), withSpinner( ggiraphOutput('out_eda_pyr') )
            ),

            # ADVANCED
            tabPanel('parallel', icon = icon('outdent'),  # sliders-h
                htmlOutput('out_eda_prx'), withSpinner( ggiraphOutput('out_eda_prl') )
            )


        )
	)

)
