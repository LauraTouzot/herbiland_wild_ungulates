######################################
#           Ungulates data           #
#  from Fédération des Chasseurs 74  #
######################################


### Downloading data
get_obs_ungulates_data <- function() {
    
  shp <- st_read(dsn = 'data/fdc74',
                 layer = 'osb_ongules_selection')  
  return(shp)
  
}



get_counting_chamois_data <- function() {
  
  shp <- st_read(dsn = 'data/fdc74',
                 layer = 'poste_comptage_chamois')  
  return(shp)
  
}


get_routes_reddeer <- function() {
  
  shp <- st_read(dsn = 'data/fdc74',
                 layer = 'circuits_comptage_cerf_selection')  
  plot(st_geometry(shp))
  return(shp)
  
}


get_routes_chamois <- function() {
  
  shp <- st_read(dsn = 'data/fdc74',
                 layer = 'circuit_comptage_chamois')  
  plot(st_geometry(shp))
  return(shp)
  
}


### Formatting data files

clean_obs_ungulates <- function(obs_ungulates_raw) {
  
  # load taxonomic referential information
  taxonomic <- read.delim("data/fdc74/TAXVERNv17.txt")
  
  # extract taxonomic referential to keep from FDC data
  taxo_to_keep <- unique(obs_ungulates_raw$TAX_REF)
  
  # filter within the taxonomic referential table
  taxonomic_filtered <- taxonomic %>% dplyr::filter(CD_NOM %in% taxo_to_keep, ISO639_3 == "eng") %>%
                                      dplyr::select(CD_NOM, LB_VERN) 
  
  sp_names <- as.data.frame(c("reddeer", "roedeer", "chamois", "ibex"))
  taxonomic_filtered <- cbind(taxonomic_filtered$CD_NOM, sp_names)
  names(taxonomic_filtered) <- c("tax_ref", "sp_name")
  
  # only keep necessary columns within FDC data and cleaning by removing observations that may have been compiled twice
  obs_ungulates <- obs_ungulates_raw %>% dplyr::filter(CADRE_OBS == "comptage") %>%
                                         dplyr::select(DATE, TAX_REF, 
                                                       JE_1, JE_2, M_AD, F_AD, NI, EFFECTIF_T, 
                                                       geometry) %>%
                                         dplyr::mutate(validation = paste(DATE, TAX_REF, EFFECTIF_T, geometry)) %>%
                                         dplyr::distinct(validation, .keep_all = TRUE) %>%
                                         dplyr::rename(date = DATE,
                                                       taxonomy = TAX_REF,
                                                       juveniles_1 = JE_1, 
                                                       juveniles_2 = JE_2, 
                                                       males = M_AD, 
                                                       females = F_AD, 
                                                       unidentified = NI, 
                                                       total = EFFECTIF_T, 
                                                       location = geometry) %>%
                                         dplyr::select(-validation) 
  
  obs_ungulates_complete <- left_join(obs_ungulates, taxonomic_filtered, by = c("taxonomy" = "tax_ref"))
  
  return(obs_ungulates_complete)
  
}

