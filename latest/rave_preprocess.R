#!/usr/bin/env Rscript --no-restore --no-save
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

# Start RAVE preprocess modules

library(docopt)
library(rave)

local({
  user <- system('echo $(whoami)', intern = TRUE, wait = TRUE)
  cat('Running as', user, '\n')
})

## configuration for docopt
doc <- "Usage: rave_preprocess [-h] [-a HOST] [-p PORT] [-n NCPUS] [-t TOKEN] [-x] [--]

-a --host HOST      location in which to install [default: 0.0.0.0]
-p --port PORT      install suggested dependencies as well [default: 6768]
-n --ncpus NCPUS    number of processes to use for parallel install [default: NA]
-t --token TOKEN    token of the application [default: NULL]

-h --help           show this help text
-x --usage          show help and short example usage"
opt <- docopt(doc)			# docopt parsing

if (opt$usage) {
  cat(doc, "\n")
  q("no")
}

opt$port <- as.integer(opt$port)
if(is.na(opt$port) || opt$port < 1000 || opt$port > 65535){
  cat("[port]  : Error: must be integer from 1000~65535\n")
  q("no")
}

opt$ncpus <- local({
  n <- as.integer(opt$ncpus)
  if(length(n)){
    n <- as.integer(n)
    if(raveio::is_valid_ish(n, max_len = 1)){
      cat('[ncores]: Using user-defined settings -', n)
    } else {
      n <- Sys.getenv('NCPUS')
      cat('[ncores]: Using system settings -', n)
    }
  }
  cat('\n')
  return(as.integer(n))
})
opt$aval_ncpu <- future::availableCores()
if(is.na(opt$ncpus) || opt$ncpus < 1 ){
  cat("[ncores]: Error: number of CPU must be integer >= 1\n")
  q("no")
} else if(opt$ncpus > opt$aval_ncpu){
  opt$ncpus <- opt$aval_ncpu
  cat('[ncores]: Warning: maximum available cores is reset to', opt$ncpus,'\n')
}

opt$token <- stringr::str_trim(opt$token)
if(!length(opt$token) || is.na(opt$token) || opt$token %in% c('NA', '', 'NULL')){
  opt$token <- NULL
}

arrange_modules()
arrange_data_dir()

local({
  # get system environment to set dirs
  data_dir <- Sys.getenv('RAVEDATA', unset = '/data/rave_data/data_dir')
  raw_data_dir <- Sys.getenv('RAVERAW', unset = '/data/rave_data/raw_dir')
  tensor_temp_path <- Sys.getenv('RAVECACHE', unset = '/data/rave_data/cache_dir')
  bids_data_dir <- Sys.getenv('RAVEBIDS', unset = '/data/rave_data/bids_dir')

  data_dir <- raveio::dir_create2(data_dir)
  raw_data_dir <- raveio::dir_create2(raw_data_dir)
  tensor_temp_path <- raveio::dir_create2(tensor_temp_path)
  bids_data_dir <- raveio::dir_create2(bids_data_dir)

  # set options
  rave_options(
    'max_worker' = opt$ncpus,
    'disable_startup_speed_check' = TRUE,
    'data_dir' = data_dir,
    'raw_data_dir' = raw_data_dir,
    'tensor_temp_path' = tensor_temp_path,
    'bids_data_dir' = bids_data_dir
  )
  print(raveio::raveio_getopt())
})

install_demo <- Sys.getenv('DEMODATA', unset = '')
if(install_demo != 'FALSE'){
  # finalize installation
  tryCatch({
    rave::finalize_installation(packages = 'ravebuiltins', upgrade = 'never')
  }, error = function(e){
    cat('Error while finalize installation. Reason:\n', e$message, '\n')
  })
}

# Run rave
app <-
  rave_preprocess(
    launch.browser = FALSE,
    host = '0.0.0.0',
    port = opt$port
    # token = opt$token
  )
print(app)

q("no")
