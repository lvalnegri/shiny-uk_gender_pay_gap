####################################################
# UK Gender Pay Gap - Shiny App - CHARTS - ui.R
# ##################################################

tabPanel('CHARTS', icon = icon('wpexplorer'),

# SIDEBAR PANEL -----------------------------------------------------------------------------------------------------------------
	sidebarPanel(

		# GEOGRAPHY -------------------------------------------------------------------------------------------------------------------
	    conditionalPanel("['map', 'hexbin'].indexOf(input.tabs_plt) == 0",
    		a(id = 'tgl_plt_geo', 'Show/Hide GEOGRAPHY', class = 'toggle-choices'),
    		div(id = "hdn_plt_geo",
    		    p(),
        		selectInput('cbo_plt_geo_zon', 'ZONES:', choices = c('ALL', levels(plots$zone)) ),
        		selectInput('cbo_plt_geo_sec', 'SECTIONS:', choices = c('ALL', levels(plots$section)) )
    		), hr()
	    ),
	    
# 		# METRICS ---------------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_plt_mtc', 'Show/Hide METRICS', class = 'toggle-choices'),
		div(id = 'hdn_plt_mtc',

            # Metric Controls for BARPLOT -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_plt == 'barplot'",
                # Choose Reference metric
                selectInput('cbo_plt_brpX', 'ATTRIBUTE:', choices = build_uiV('CAT') ),
                # Choose Reference metric
                selectInput('cbo_plt_brpY', 'MEASURE:', choices = build_uiY() ),
#                 # Show Percentage, IF chosen reference is type 2 (measure)
#         		uiOutput('ui_plt_brp_pct'),
#                 # Show Average, WHEN measure and IF GROUPED only when dodge or facet
#         		uiOutput('ui_plt_brp_avg'),
                # Choose a filter
                selectInput('cbo_plt_brpF', 'FILTERED BY:', choices = c('NONE', build_uiV(c('CAT')) ) ),
                # Choose which value of previous variable dta should be filtered on
        		conditionalPanel("input.cbo_plt_brpF !== 'NONE'",
        			uiOutput('ui_plt_brp_flt')
        		),
                # Choose if and how group above metric
                selectInput('cbo_plt_brpG', 'GROUPED BY:', choices = c('NONE', build_uiV('CAT')) ),
                # Choose how grouping should be displayed
        		conditionalPanel("input.cbo_plt_brpG !== 'NONE'",
        		    uiOutput('ui_plt_brp_grp'),
        			# Faceting options
            		conditionalPanel("input.cbo_plt_brp_grp == 'facet'",
                        checkboxInput('chk_plt_brp_scl', 'ALIGN SCALES', value = TRUE ),
                        selectInput('cbo_plt_brpG2', 'ADD VARIABLE:', choices = c('NONE', build_uiV(c('CAT', 'GEO')) ) ),
                        # Choose numbers of columns if faceting only once
                		conditionalPanel("input.cbo_plt_brpG2 == 'NONE'",
                			sliderInput('sld_plt_brp_fct', 'COLUMNS:', min = 1, max = 6, value = 2, ticks = FALSE)
                		)
        			)
        		)
            ),
# 
#             # Metric Controls for SCATTERPLOT -------------------------------------------------------------------------------------------------------------
# 		    conditionalPanel("input.tabs_plt == 'scatterplot'",
#                 # Choose effect size (X)
#                 selectInput('cbo_plt_scpX', 'X-axis:', choices = build_uiV(c('INT', 'DEC')) ),
#                 # trimming effect sizes
#                 uiOutput('ui_plt_scp_tmz'),
#                 # Choose reference measure / metric
#                 selectInput('cbo_plt_scpY', 'Y-axis', choices = build_uiY(), selected = 'Mean Revenues' ),
#                 # trimming metric values
#                 uiOutput('ui_plt_scp_tmt'),
#                 # Choose a filter
#                 selectInput('cbo_plt_scpF', 'FILTERED BY:', choices = c('NONE', build_uiV(c('CAT')) ) ),
#                 # Choose which value of previous variable dta should be filtered on
#         		conditionalPanel("input.cbo_plt_scpF !== 'NONE'",
#         			uiOutput('ui_plt_scp_flt')
#         		),
#                 # Choose if and how group above metric
#                 selectInput('cbo_plt_scpG', 'GROUPED BY:', choices = c('NONE', build_uiV('CAT')), selected = 'Occupation_level' ),
#                 # Choose how grouping should be displayed
#         		conditionalPanel("input.cbo_plt_scpG !== 'NONE'",
#         		    uiOutput('ui_plt_scp_grp'),
#         			# Faceting options
#             		conditionalPanel("input.cbo_plt_scp_grp == 'facet'",
#                         checkboxInput('chk_plt_scp_scl', 'ALIGN SCALES', value = TRUE ),
#                         selectInput('cbo_plt_scpG2', 'ADD VARIABLE:', choices = c('NONE', build_uiV(c('CAT', 'GEO')) ) ),
#                         # Choose numbers of columns if faceting only once
#                 		conditionalPanel("input.cbo_plt_scpG2 == 'NONE'",
#                 			sliderInput('sld_plt_scp_fct', 'COLUMNS:', min = 1, max = 6, value = 2, ticks = FALSE)
#                 		)
#         			)
#         		),
#                 # overall average
#                 checkboxInput('chk_plt_scp_avg', 'ADD AVERAGE LINE', FALSE)
#             )
# 
#             # Metric Controls for MAP -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_plt == 'map'",
                # Choose Reference metric
                selectInput('cbo_plt_mapX', 'ATTRIBUTE:', choices = build_uiV('CAT'), selected = 'fill_level' )
            ),
# 
#             # Metric Controls for HEXBIN -------------------------------------------------------------------------------------------------------------
		    conditionalPanel("input.tabs_plt == 'hexbin'",
                # Choose Reference metric
                selectInput('cbo_plt_hxbX', 'MEASURE:', choices = build_uiV('INT'), selected = 'no_of_toilets' ),
                selectInput('cbo_plt_hxx_fun', 'FUNCTION:', choices = c('min', 'max', 'sum', 'mean', 'median', 'quantile', 'var'), selected = 'sum' )
            )
# 
#             # END OF Metrics Controls -------------------------------------------------------------------------------------------

        ), hr(),

		# OPTIONS ---------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_plt_opt', 'Show/Hide OPTIONS', class = 'toggle-choices'),
		hidden(
			div(id = 'hdn_plt_opt',
                p(),

# 			    # Option Controls for TABLE ----------------------------------------------------------------------------------------------
#         		conditionalPanel("input.tabs_plt == 'table'",
#                     # Control the color for the background in the cells with the bars
#                     colourpicker::colourInput('col_plt_tbb', 'FILL COLOUR:', '#63B8FF', showColour = 'background'),
#                     # Control the color for the font when cells are formatted
#                     colourpicker::colourInput('col_plt_tbf', 'FONT COLOUR:', 'black', showColour = 'background', palette = 'limited'),
#                     # Control the divergent palette for the background in the INDEX column
#                     selectInput('pal_plt_tbl', 'PALETTE:', choices = lst.palette[['DIVERGING']], selected = 'Spectral' ),
#                     checkboxInput('chk_plt_tbl_rvc', 'REVERSE COLOURS', value = FALSE),
#                     # Control the number of colours for the above divergent palette
#                     sliderInput('sld_plt_tbl_col', 'NUMBER OF QUANTILES:', min = 2, max = 10, value = 5, step = 1, ticks = FALSE)
# 
#     			    # END OF TABLE Option Controls ---------------------------------------------------------------------------------------
#         		),
# 
# 			    # Option Controls for BARPLOT  -------------------------------------------------------------------------------------------
           		conditionalPanel("input.tabs_plt !== 'table'",

                    # GENERAL --------------------------------------------------------------------------------------------
            		a(id = 'tgl_plt_brp_gen', 'Show/Hide GENERAL', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_plt_brp_gen',
                            p(),
            			    # Plot Zoom
            				sliderInput('sld_plt_brp_ggw', 'ZOOM:', min = 4, max = 10, value = 6.5, step = 0.5, ticks = FALSE),
                			# Force y-axis to show origin
                			checkboxInput('chk_plt_brp_yzr', 'SHOW ORIGIN', TRUE),
                			# Text Size and Font family
                            sliderInput('sld_plt_brp_xlz', 'TEXT SIZE:', min = 1, max = 15, value = 7, step = 0.5, ticks = FALSE),
#                            selectInput('cbo_plt_brp_ffm', 'FONT FAMILY:', choices = font.table, selected = 'Arial')
                            selectInput('cbo_plt_brp_ffm', 'FONT FAMILY:', choices = 'Arial')
            			), hr()
            		), br(),

                    # AXIS --------------------------------------------------------------------------------------------
            		a(id = 'tgl_plt_brp_axs', 'Show/Hide AXIS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_plt_brp_axs',
                            p(),
                            # Control the rotation of the axis labels
                            sliderInput('sld_plt_brp_lbr', 'AXIS LABEL ROTATION:', min = 0, max = 90, value = 45, step = 5, ticks = FALSE),
                            # Control the appearance of Axis Lines and Ticks, plus Plot Border
                			checkboxInput('chk_plt_brp_xlx', 'ADD x-AXIS LINE', TRUE),
                			checkboxInput('chk_plt_brp_xly', 'ADD y-AXIS LINE', TRUE),
                			checkboxInput('chk_plt_brp_xtk', 'ADD AXIS TICKS', TRUE),
                			checkboxInput('chk_plt_brp_plb', 'ADD PLOT BORDER', FALSE),
                       		conditionalPanel("input.chk_plt_brp_xlx || input.chk_plt_brp_xly || input.chk_plt_brp_xtk || input.chk_plt_brp_plb",
                                sliderInput('sld_plt_brp_xsz', 'SIZE:', min = 1, max = 5, value = 2, step = 0.5, ticks = FALSE),
                                colourpicker::colourInput('col_plt_brp_xsc', 'COLOUR:', 'grey50', showColour = 'background')
                       		),
                            # Add and Control the appearance of Axis Titles
                			checkboxInput('chk_plt_brp_xlt', 'ADD AXIS TITLES', FALSE),
                       		conditionalPanel("input.chk_plt_brp_xlt",
                                sliderInput('sld_plt_brp_xlt', 'FONT SIZE MULTIPLE:', min = 0, max = 100, value = 20, step = 5, ticks = FALSE, post = '%'),
                                selectInput('cbo_plt_brp_xlt', 'FONT FACE:', choices = face.types, selected = 'bold')
                       		)
            			), hr()
            		), br(),

                    # BACKGROUND --------------------------------------------------------------------------------------------
            		a(id = 'tgl_plt_brp_bkg', 'Show/Hide BACKGROUND', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_plt_brp_bkg',
                            p(),
                			# Background color
                            colourpicker::colourInput('col_plt_brp_bkg', 'BACKGROUND COLOUR:', 'white', showColour = 'background'),
                			# Grids
                            checkboxGroupInput('chg_plt_brp_grd', 'ADD GRIDS', choices = c('Horizontal', 'Vertical'), inline = TRUE ),
                       		conditionalPanel("input.chg_plt_brp_grd.length > 0",
                                sliderInput('sld_plt_brp_gdz', 'SIZE:', min = 0.5, max = 5, value = 2, step = 0.5, ticks = FALSE),
                                colourpicker::colourInput('col_plt_brp_gdc', 'COLOUR:', 'grey50', showColour = 'background'),
                                selectInput('cbo_plt_brp_gdt', 'TYPE:', choices = line.types, selected = 'dotted')
                       		)
            			), hr()
            		), br(),

                    # BARS ------------------------------------------------------------------------------------------------------
            		a(id = 'tgl_plt_brp_brs', 'Show/Hide BARS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_plt_brp_brs',
                            p(),
                            # Control how bars are ordered
                            selectInput('cbo_plt_brp_ord', 'ORDERING:', choices = c('Alpha (ASC)' = 1, 'Alpha (DESC)' = 2, 'Values (ASC)' = 3, 'Values (DESC)' = 4) ),
                            # Control if barplot is horizontal or vertical
                            radioButtons('rdb_plt_brp_orn', 'ORIENTATION:', choices = c('Vertical', 'Horizontal'), selected = 'Horizontal',  inline = TRUE ),
                            # Choose colour / palette
                			uiOutput('ui_plt_brp_col'),
                   		    conditionalPanel("typeof input.pal_plt_brp !== 'undefined'",
                                checkboxInput('chk_plt_brp_rvc', 'REVERSE COLOURS', value = FALSE)
                            ),
                            # Control width of bars
                            sliderInput('sld_plt_brp_baw', 'WIDTH:', min = 1, max = 10, value = 8, step = 0.5, ticks = FALSE),
                			# Add and customize bars' borders
                			checkboxInput('chk_plt_brp_bdr', 'ADD BARS BORDER', FALSE),
                    		conditionalPanel("input.chk_plt_brp_bdr",
                                sliderInput('sld_plt_brp_bow', 'WIDTH:', min = 1, max = 15, value = 6, step = 1, ticks = FALSE),
                                colourpicker::colourInput('col_plt_brp_boc', 'COLOUR:', 'black', showColour = 'background'),
                                selectInput('cbo_plt_brp_bot', 'TYPE:', choices = line.types, selected = 'solid')
                            )
            			), hr()
            		), br(),

                    # LABELS IN BARS --------------------------------------------------------------------------------------------
            		a(id = 'tgl_plt_brp_lbl', 'Show/Hide LABELS', class = 'toggle-choices-sub'),
            		hidden(
            			div(id = 'hdn_plt_brp_lbl',
                            p(),
                			# Add (if not grouped stack/fill), and customize value labels in bars (depends on labels IN/OUT and orientation H/V)
                			checkboxInput('chk_plt_brp_lbl', 'ADD VALUE LABELS IN BARS', FALSE),
                    		conditionalPanel("input.chk_plt_brp_lbl",
                                sliderInput('sld_plt_brp_lbz', 'LABELS FONT SIZE', min = 1, max = 4, value = 1.6, step = 0.2, ticks = TRUE),
                                radioButtons('rdb_plt_brp_lbp', 'LABELS POSITION', choices = c('Inside', 'Outside'), inline = TRUE ),
                                # uiOutput('ui_plt_brp_lbp'),
                                uiOutput('ui_plt_brp_lbc')
                            )
            			), hr()
            		), br(),

                    # AVERAGE LINE ----------------------------------------------------------------------------------------------
                    conditionalPanel("input.chk_plt_brp_avg",
                		a(id = 'tgl_plt_brp_avg', 'Show/Hide AVERAGE LINE', class = 'toggle-choices-sub'),
                		hidden(
                			div(id = 'hdn_plt_brp_avg',
                                p(),
                                checkboxInput('chk_plt_brp_avl', 'ADD VALUE', value = FALSE),
                                colourpicker::colourInput('col_plt_brp_avc', 'COLOUR:', 'black', showColour = 'background'),
                                sliderInput('sld_plt_brp_avz', 'SIZE:', min = 1, max = 8, value = 4, step = 0.5, ticks = FALSE),
                                selectInput('cbo_plt_brp_avt', 'TYPE:', choices = line.types, selected = 'dotdash'),
                                sliderInput('sld_plt_brp_avt', 'TRANSPARENCY:', min = 0, max = 10, value = 4, step = 1, ticks = FALSE)
                		    )
                	    ), br()
                    )

    			    # END OF BARS Option Controls -------------------------------------------------------------------------------------------------
        		),

			    # Option Controls for MAP ----------------------------------------------------------------------------------------------
        		conditionalPanel("input.tabs_plt == 'map'",
                    # Choose background tile
                    selectInput('cbo_plt_map_tls', 'TILES:', choices = c(tiles.list), selected = tile.ini),
                    # Control the divergent palette for the background in the INDEX column
                    selectInput('pal_plt_map', 'PALETTE:', choices = lst.palette, selected = 'Spectral' ),
                    checkboxInput('chk_plt_map_rvc', 'REVERSE COLOURS', value = FALSE),
                    # Transparency
        			sliderInput('sld_plt_map_trp', 'TRANSPARENCY:', min = 0, max = 10, value = 8, ticks = FALSE),
                    # Add Legend
                    checkboxInput('chk_plt_map_lgn', 'ADD LEGEND', TRUE),
                    conditionalPanel("input.chk_plt_map_lgn",
                        # Legend Position
                        selectInput('cbo_plt_map_lgn', 'POSITION:', choices = c('bottomright', 'bottomleft', 'topleft', 'topright') )
                    )

    			    # END OF MAP Option Controls ---------------------------------------------------------------------------------------
        		),

			    # Option Controls for HEXBIN ----------------------------------------------------------------------------------------------
        		conditionalPanel("input.tabs_plt == 'hexbin'",
                    # Number of bins
        			sliderInput('sld_plt_hxb_bin', 'BINS:', min = 10, max = 100, value = 30, ticks = FALSE),
                    # Control the divergent palette for the background in the INDEX column
                    selectInput('pal_plt_hxb', 'PALETTE:', choices = lst.palette, selected = 'Spectral' ),
                    checkboxInput('chk_plt_hxb_rvc', 'REVERSE COLOURS', value = FALSE),
                    # Transparency
        			sliderInput('sld_plt_hxb_trp', 'TRANSPARENCY:', min = 0, max = 10, value = 8, ticks = FALSE),
                    # Add Legend
                    checkboxInput('chk_plt_hxb_lgn', 'ADD LEGEND', TRUE),
                    conditionalPanel("input.chk_plt_hxb_lgn",
                        # Legend Position
                        selectInput('cbo_plt_hxb_lgn', 'POSITION:', choices = c('bottomright', 'bottomleft', 'topleft', 'topright') )
                    )

    			    # END OF MAP Option Controls ---------------------------------------------------------------------------------------
        		)
    
# 			    # END OF Option Controls -------------------------------------------------------------------------------------------------
		)), hr(),

# 		# DOWNLOAD --------------------------------------------------------------------------------------------------------------------
		a(id = 'tgl_plt_dwn', 'Show/Hide DOWNLOAD', class = 'toggle-choices'),
		hidden(
    		div(id = 'hdn_plt_dwn',
                p(),
    		    # Common input for filename, needs a UI to change default
    		    uiOutput('ui_plt_dwn'),
			    # Download dataset for TABLE
           		conditionalPanel("input.tabs_plt == 'table'",
        		    textOutput('txt_plt_dwn'), br(),
                    downloadButton('dwn_plt_dta', label = btndwn.text[1], class = 'btndwn')
           		),
	            # Downloads for remaining substabs
           		conditionalPanel("input.tabs_plt !== 'table'",
    	            # Download dataset behind chart
                    downloadButton('dwn_plt_tbl', label = btndwn.text[5], class = 'btndwn'),
        			# Optional Caption for Charts
                    checkboxInput('chk_plt_cpt', 'ADD CAPTION', value = FALSE ),
               		conditionalPanel("input.chk_plt_cpt",
            		    textInput('txt_plt_cpt', '', value = 'test' ) # plt.caption)
               		),
    	            # Download Chart
                    downloadButton('dwn_plt_plt', label = btndwn.text[2], class = 'btndwn')
           		)
		)), hr(),

		width = 2

	),
# 
# # MAIN PANEL --------------------------------------------------------------------------------------------------------------------
	mainPanel(
        tabsetPanel(id = 'tabs_plt',

            # UNI-VARIATE
            tabPanel('barplot', icon = icon('bar-chart'),
                htmlOutput('out_plt_brx'), withSpinner( ggiraphOutput('out_plt_brp', width = "100%", height = "600px") )
            ),
            tabPanel('boxplot', icon = icon('object-align-vertical', lib = 'glyphicon'),
                htmlOutput('out_plt_bxx'), withSpinner( bpexploderOutput('out_plt_bxp') )
            ),
            tabPanel('histogram', icon = icon('area-chart'),
                htmlOutput('out_plt_hsx'), withSpinner( ggiraphOutput('out_plt_hst') )
            ),

            # BI-VARIATE
            tabPanel('mosaic', icon = icon('th-list'),
                htmlOutput('out_plt_msx'), withSpinner( ggiraphOutput('out_plt_msc') )
            ),
            tabPanel('scatterplot', icon = icon('braille'),
                htmlOutput('out_plt_scx'), withSpinner( ggiraphOutput('out_plt_scp', width = "100%", height = "800px") )
            ),
            tabPanel('map', icon = icon('globe', lib = 'glyphicon'),
                htmlOutput('out_plt_max'), withSpinner( leafletOutput('out_plt_map', width = "100%", height = "800px" ) )
            ),
            tabPanel('hexbin', icon = icon('connectdevelop'),
                htmlOutput('out_plt_hxx'), withSpinner( ggiraphOutput('out_plt_hxb', width = "100%", height = "800px") )
            ),
            tabPanel('pyramid', icon = icon('align-center'),
                htmlOutput('out_plt_pyx'), withSpinner( ggiraphOutput('out_plt_pyr') )
            ),

            # ADVANCED
            tabPanel('parallel', icon = icon('outdent'),  # sliders-h
                htmlOutput('out_plt_prx'), withSpinner( ggiraphOutput('out_plt_prl') )
            )


        )
	)

)
