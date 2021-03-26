#########################################################
# UK Gender Pay Gap - Shiny App - TABLES - server.R
#########################################################

# TOGGLES -----------------------------------------------------------------------------------------------------------------------
# onclick('tgl_eda_geo', toggle(id = 'hdn_eda_geo', anim = TRUE) )  # geography
# onclick('tgl_eda_mtc', toggle(id = 'hdn_eda_mtc', anim = TRUE) )  # metrics
# onclick('tgl_eda_opt', toggle(id = 'hdn_eda_opt', anim = TRUE) )  # options
# onclick('tgl_eda_dwn', toggle(id = 'hdn_eda_dwn', anim = TRUE) )  # download
# 
# onclick('tgl_eda_brp_gen', toggle(id = 'hdn_eda_brp_gen', anim = TRUE) )           # options / bars / general
# onclick('tgl_eda_brp_axs', toggle(id = 'hdn_eda_brp_axs', anim = TRUE) )           # options / bars / axis
# onclick('tgl_eda_brp_bkg', toggle(id = 'hdn_eda_brp_bkg', anim = TRUE) )           # options / bars / background
# onclick('tgl_eda_brp_brs', toggle(id = 'hdn_eda_brp_brs', anim = TRUE) )           # options / bars / bars
# onclick('tgl_eda_brp_lbl', toggle(id = 'hdn_eda_brp_lbl', anim = TRUE) )           # options / bars / labels
# onclick('tgl_eda_brp_avg', toggle(id = 'hdn_eda_brp_avg', anim = TRUE) )           # options / bars / average line

