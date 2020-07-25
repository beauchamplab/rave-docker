#!/usr/bin/env r
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

tryCatch({
  rave::rave_options(
    'disable_startup_speed_check' = TRUE,
    'data_dir' = '/data/rave_data/data_dir',
    'raw_data_dir' = '/data/rave_data/raw_dir',
    'subject_cache_dir' = '/data/rave_data/cache_dir',
    'bids_data_dir' = '/data/rave_data/bids_dir'
  )
  rave::arrange_modules(refresh = TRUE)
  rave::finalize_installation(upgrade = 'always')
}, error = function(e){
  cat('Error while finalize installation. Reason:\n', e$message, '\n')
})


