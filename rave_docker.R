#!/usr/bin/env Rscript --vanilla
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

if(system.file('', package = 'docopt') == ''){
  utils::install.packages('docopt', repos = c(CRAN = "https://cran.rstudio.com/"), quiet = TRUE)
}


## configuration for docopt
doc <- "Usage: rave_docker [-n NAME] [-p PORT] [-s SECONDARY_PORT] [-c NCPU] [-t TOKEN] [-u] [RAVEROOT]

-n --name NAME              Container's name, randonly assigned if blank
-p --port PORT              Local port to expose
-s --port2 SECONDARY_PORT   Secondary port for preprocess modules, disabled by default
-c --ncpu NCPU              Number of CPUs to use, default is 1
-t --token TOKEN            Secret token for RAVE instance, randonly assigned if blank
-u --upgrade                Whether to upgrade docker image (this won't affect existing containers)
RAVEROOT                    Local volume to attach to

-h --help           show this help text

Example: rave-docker -n ravetest -p 3333 \"/User/dipterix/rave_data\"

"
opt <- docopt::docopt(doc)			# docopt parsing

# # DEBUG
# opt <- docopt::docopt(doc, list(
#   RAVEROOT = '~/rave_data/'
# ))

rave_root <- opt$RAVEROOT
if(!length(rave_root)){
  cat(doc)
  stop("RAVEROOT must be specified")
}

if(!dir.exists(rave_root)){
  cat(doc)
  stop("RAVEROOT doesn't exist as a directory - ", rave_root)
}

rave_root <- normalizePath(rave_root, mustWork = TRUE)

# name
if(length(opt$name)){
  name <- opt$name
} else {
  name <- paste0('rave-%Y%m%d-%H%M%S-', paste(sample(c(LETTERS,letters,0:9), 4, replace = TRUE), collapse = ''))
  name <- strftime(Sys.time(), name)
}

# port
port <- as.integer(opt$port)
if(length(port) && is.na(port)){
  cat(doc)
  stop("port is not an integer, provided: ", opt$port)
}
if(!length(port)){
  if(system.file('', package = 'servr') == ''){
    utils::install.packages('servr', repos = c(CRAN = "https://cran.rstudio.com/"), quiet = TRUE)
  }
  port <- servr::random_port(host = '0.0.0.0')
}

# port2
port2 <- opt$port2
preprocess_enabled <- !is.null(port2)
if(preprocess_enabled){
  port2 <- as.integer(port2)
  if(is.na(port2)){
    cat('preprocess port is invalid, randonly assign one\n')
    port2 <- servr::random_port(host = '0.0.0.0', port = port + 1)
  }
}

# ncpu
ncpu <- as.integer(opt$ncpu)
if(length(ncpu) && is.na(ncpu)){
  cat(doc)
  stop("ncpu is not an integer, provided: ", opt$ncpu)
}
if(!length(ncpu)){
  ncpu <- 1
}
if(ncpu <= 0){
  cat(doc)
  stop("ncpu must be positive, provided: ", ncpu)
}

# token
token <- opt$token
has_token <- !is.null(token)
random_token <- FALSE
if(has_token){
  token <- sub(' ', '', token)
  if(token == ''){
    token <- paste(sample(c(LETTERS,letters,0:9), 10, replace = TRUE), collapse = '')
    random_token <- TRUE
  }
  token_str <- sprintf(' %s', token)
} else {
  token_str <- ''
}

# generate command
if(preprocess_enabled){
  port_str <- sprintf('-p %d:6767 -p %d:6768', port, port2)
} else {
  port_str <- sprintf('-p %d:6767', port)
}

# Update docker image

if(opt$upgrade){
  cat("\n\n\nUpgrading docker image, running terminal command:\n\ndocker pull beauchamplab/rave\n\n")

  system("docker pull beauchamplab/rave", wait = TRUE)
}
cat(rep('-', 50), '\n', sep = '')

cmd1 <- sprintf(
  'docker run -it -d --name "%s" %s -v "%s":/data/rave_data beauchamplab/rave start_rave --ncpus %d%s',
  name, port_str, rave_root, ncpu, token_str
)

cat("\n\n# Starting container...\n")
cat(">$", cmd1, '\n\n')
system(cmd1, wait = TRUE)


if(preprocess_enabled){
  cmd2 <- sprintf('docker exec -d -it "%s" Rscript --vanilla -e "rave::rave_preprocess(host=\'0.0.0.0\',port=6768,launch.browser=FALSE)"', name)
  cat("\n\n# Enabling preprocess module...\n")
  cat(">$", cmd2, '\n\n')
  system(cmd2, wait = TRUE)
}

cat(rep('-', 50), '\n', sep = '')
cat("Container", sQuote(name), 'initialized!\n')
cat("Please open your browser (chrome recommended) and go to\n\n\n")

if(has_token){
  token_str <- sprintf("?token=%s", token)
} else {
  token_str = ''
}

cat("Main application -\n\n")
cat("      http://localhost:", port, token_str, '\n\n\n', sep = '')

if(preprocess_enabled){
  cat("Preprocess modules -\n\n")
  cat("      http://localhost:", port2, '\n\n\n', sep = '')
}


docker exec -it rave-20200811-154249-DtZk bash