#!/usr/bin/env r
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

tryCatch({
  rave::finalize_installation(upgrade = 'always')
}, error = function(e){
  cat('Error while finalize installation. Reason:\n', e$message, '\n')
})


