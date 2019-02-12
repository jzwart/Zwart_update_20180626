# MFE database updates from Zwart on 2018-06-26; see 'Tasks/mfe_db_tasks_20180626.xlsx' for description of changes to the database, both sensor and non-sensor


sensor_db_changes <- function(ind_file, table, sensor_db, dbname, val_check_yml, site_change_yml,gd_config){

  val_check = yaml::yaml.load_file(val_check_yml) # loading value checks with conversions

  site_change = yaml::yaml.load_file(site_change_yml) # loading site checks with conversions

  if(str_detect(table, 'RAW')){
    var <- str_replace(table, '_RAW', '')
  }else if(str_detect(table, 'CORR')){
    var <- str_replace(table, '_CORR', '')
  }

  if(var %in% c('PRECIP', 'HOBO_PRESS', 'HOBO_METSTATION')){
    db_raw <- sensordbTable(table = paste(var, 'RAW', sep='_'), fpath = file.path(sensor_db), dbname = dbname)
    db_raw <- db_raw %>% dplyr::filter(apply(!is.na(db_raw[5:ncol(db_raw)]), 1, any)) #filter out rows with all NA's
  }else{
    db_raw <- sensordbTable(table = paste(var, 'RAW', sep='_'), fpath = file.path(sensor_db), dbname = dbname)
    db_raw <- db_raw %>% dplyr::filter(apply(!is.na(db_raw[6:ncol(db_raw)]), 1, any)) #filter out rows with all NA's
  }

  # I was having problems with tchain data table where there were 3 rows in the raw table that had missing values for dateTime; and the sensorDB function couldn't read in the table because it forces everything to POSIXct format; I am removing those 3 values which are from WL DeepHole depths 1, 3, 5 m with a recorded temp and light of 0.
  if(var == 'HOBO_TCHAIN'){
    db_raw <- db_raw %>%
      dplyr::filter(grepl(':', dateTime)) %>%
      mutate(dateTime = as.POSIXct(dateTime, tz = 'GMT'),
             dayfrac = date2doy(dateTime))
  }else{
    db_raw <- db_raw %>%
      mutate(dateTime = as.POSIXct(dateTime, tz = 'GMT'),
             dayfrac = date2doy(dateTime))
  }

  if(any(str_detect(names(db_raw), 'depth'))){
    db_corr <- sensordbTable(table = paste(var, 'CORR', sep='_'), fpath = file.path(sensor_db), dbname = dbname) %>%
      mutate(dateTime = as.POSIXct(dateTime, tz = 'GMT'),
             dayfrac = date2doy(dateTime)) %>%
      semi_join(db_raw, by = c('lakeID', 'location', 'depth_m', 'dateTime')) # keep all rows in db_corr where there are matching rows in db_raw

    deleted_code <- '3 7' # changes code for deleted data
    changes_cols <- colnames(db_corr)[grep('changesCode', colnames(db_corr))]
    cleaned_cols <- colnames(db_corr)[grep('cleaned', colnames(db_corr))]

    missing_in_corr <- db_raw %>%
      as_data_frame() %>%
      anti_join(db_corr, by = c('lakeID', 'location', 'depth_m', 'dateTime')) %>% # these were deleted by removing NA's, add them back in with correct changes code
      rename_at(vars(colnames(.)[6:ncol(.)]), ~colnames(db_corr)[6:ncol(db_raw)]) %>%
      mutate_at(vars(colnames(.)[6:ncol(.)]), ~deleted_code) # adding back in delete codes

    #could make this dplyr but couldn't figure it out right now ; adding in NA's for deleted columns
    for(cols in 1:length(cleaned_cols)){
      missing_in_corr <- missing_in_corr %>% mutate(!!cleaned_cols[cols] := NA)
    }
    db_corr <- db_corr %>%
      bind_rows(missing_in_corr) %>%
      unite('dup_check', c('lakeID', 'location', 'depth_m', 'dateTime'), remove = F) %>%
      dplyr::filter(!duplicated(dup_check)) %>% # removing  duplicated rows
      select(-dup_check) %>%
      dplyr::arrange(lakeID, location, depth_m, dateTime)

    db_raw <- db_raw %>%
      unite('dup_check', c('lakeID', 'location', 'depth_m', 'dateTime'), remove = F) %>%
      dplyr::filter(!duplicated(dup_check)) %>% # removing  duplicated rows
      select(-dup_check) %>%
      dplyr::arrange(lakeID, location, depth_m, dateTime)

  }else{
    db_corr <- sensordbTable(table = paste(var, 'CORR', sep='_'), fpath = file.path(sensor_db), dbname = dbname) %>%
      mutate(dateTime = as.POSIXct(dateTime, tz = 'GMT'),
             dayfrac = date2doy(dateTime)) %>%
      semi_join(db_raw, by = c('lakeID', 'location', 'dateTime')) # keep all rows in db_corr where there are matching rows in db_raw

    deleted_code <- '3 7' # changes code for deleted data
    changes_cols <- colnames(db_corr)[grep('changesCode', colnames(db_corr))]
    cleaned_cols <- colnames(db_corr)[grep('cleaned', colnames(db_corr))]

    # make this unique for metstation because 2011-2013 are missing from db_corr for some reason; no changes were made so copy over raw to corr
    if(var == 'HOBO_METSTATION'){
      missing_in_corr <- db_raw %>%
        as_data_frame() %>%
        anti_join(db_corr, by = c('lakeID', 'location', 'dateTime')) %>%
        rename_at(vars(colnames(.)[5:ncol(.)]), ~cleaned_cols)

      #could make this dplyr but couldn't figure it out right now ; adding in NA's for changes code
      for(cols in 1:length(changes_cols)){
        missing_in_corr <- missing_in_corr %>% mutate(!!changes_cols[cols] := NA)
      }
      # reorder to make same as db_corr
      missing_in_corr <- missing_in_corr[,colnames(db_corr)]

    }else{
      missing_in_corr <- db_raw %>%
        as_data_frame() %>%
        anti_join(db_corr, by = c('lakeID', 'location', 'dateTime')) %>% # these were deleted by removing NA's, add them back in with correct changes code
        rename_at(vars(colnames(.)[5:ncol(.)]), ~colnames(db_corr)[5:ncol(db_raw)]) %>%
        mutate_at(vars(colnames(.)[5:ncol(.)]), ~deleted_code) # adding back in delete codes

      #could make this dplyr but couldn't figure it out right now ; adding in NA's for deleted columns
      for(cols in 1:length(cleaned_cols)){
        missing_in_corr <- missing_in_corr %>% mutate(!!cleaned_cols[cols] := NA)
      }
    }

    db_corr <- db_corr %>%
      bind_rows(missing_in_corr) %>%
      unite('dup_check', c('lakeID', 'location', 'dateTime'), remove = F) %>%
      dplyr::filter(!duplicated(dup_check)) %>% # removing  duplicated rows
      select(-dup_check) %>%
      dplyr::arrange(lakeID, location, dateTime)

    db_raw <- db_raw %>%
      unite('dup_check', c('lakeID', 'location', 'dateTime'), remove = F) %>%
      dplyr::filter(!duplicated(dup_check)) %>% # removing  duplicated rows
      select(-dup_check) %>%
      dplyr::arrange(lakeID, location, dateTime)
  }

  # check if there are any bad values and change them
  if(any(colnames(db_corr) %in% names(val_check$bad_vals))){
    for(cols in 1:length(which(colnames(db_corr) %in% names(val_check$bad_vals)))){
      cur_col = colnames(db_corr)[colnames(db_corr) %in% names(val_check$bad_vals)][cols]

      db_corr[,cur_col] <- ifelse(db_corr[,cur_col] == val_check$bad_vals[[cur_col]],
                                 val_check$change_to[[cur_col]],
                                 db_corr[,cur_col])
    }
  }

  # make sure entries are the same for db_raw and db_corr
  if(nrow(db_corr) != nrow(db_raw)){
    warning('there are differing number of rows in the corrected data table and raw data table')
  }

  # change sites that were incorrectly stored
  if(var %in% names(site_change$wrong_sites)){
    lakes = names(site_change$wrong_sites[[var]]$lakeID)
    for(lake in lakes){
      sites = site_change$wrong_sites[[var]]$lakeID[[lake]]
      for(site in sites){
        db_raw <- db_raw %>%
          mutate(location = case_when(lakeID == lake & location == site ~
                                        site_change$change_to[[var]]$lakeID[[lake]][which(site_change$wrong_sites[[var]]$lakeID[[lake]]==site)],
                                      TRUE ~ location))
        db_corr <- db_corr %>%
          mutate(location = case_when(lakeID == lake & location == site ~
                                        site_change$change_to[[var]]$lakeID[[lake]][which(site_change$wrong_sites[[var]]$lakeID[[lake]]==site)],
                                      TRUE ~ location))
      }
    }
  }


  data_file = as_data_file(ind_file)
  if(str_detect(table, 'RAW')){
    write.table(x = db_raw, file = data_file, quote=F, sep='|', row.names = F, col.names = F) # separators need to be consistent with sql
  }else if(str_detect(table, 'CORR')){
    write.table(x = db_corr, file = data_file, quote=F, sep='|', row.names = F, col.names = F) # separators need to be consistent with sql
  }
  gd_put(remote_ind = ind_file, local_source = data_file, config_file = gd_config)
}
