#!/usr/bin/env r
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

# Start RAVE main application

library(docopt)

## configuration for docopt
doc <- "Usage: start_rave [-h] [--host HOST] [-p PORT] [-n NCPUS] [-x] [--] [PACKAGES ...]

--host HOST         location in which to install [default: 127.0.0.1]
-p --port PORT      install suggested dependencies as well [default: 6767]
-n --ncpus NCPUS    number of processes to use for parallel install [default: 1]
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

opt$ncpus <- as.integer(opt$ncpus)
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

# set options
rave::rave_options(
  'max_worker' = opt$ncpus,
  'disable_startup_speed_check' = TRUE,
  'data_dir' = '/data/rave_data/data_dir',
  'raw_data_dir' = '/data/rave_data/raw_dir',
  'subject_cache_dir' = '/data/rave_data/cache_dir',
  'bids_data_dir' = '/data/rave_data/bids_dir'
)

# Run rave
rave::start_rave(launch.browser = FALSE, host = opt$host, port = opt$port, token = opt$token)

q("no")
