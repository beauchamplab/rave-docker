#!/usr/bin/env -S Rscript --vanilla
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

if(system.file('', package = 'docopt') == ''){
  utils::install.packages('docopt', repos = c(CRAN = "https://cran.rstudio.com/"), quiet = TRUE)
}


## configuration for docopt
doc <- "Usage: rave_docker [-m] [-u] [-f] [-n NAME] [-p PORT] [-s SECONDARY_PORT] [-c NCPU] [-t TOKEN] [(RAVEROOT)]

-h --help                   show this help text

Options:
  -n --name NAME              Container's name, randonly assigned if blank
  -p --port PORT              Local port to expose
  -s --port2 SECONDARY_PORT   Secondary port for preprocess modules, disabled by default
  -c --ncpu NCPU              Number of CPUs to use, default is 1
  -t --token TOKEN            Secret token for RAVE instance, randonly assigned if blank
  -m --minimal                Minimal setup, avoid installing demo subject [default: FALSE]
  -u --upgrade                Whether to upgrade docker image (this won't affect existing containers)
  -f --force                  Force execute the command even if the container exists

Required:
  RAVEROOT                    Local volume to attach to

Example: rave_docker -n ravetest --port 3333 --port2 3334 --ncpu 1 -u \"~/rave_data\"

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

# container launched by this command before, check docker ps
msg <- system('docker container ls -a', wait = TRUE, intern = TRUE)
if(length(msg) > 1){
  msg <- msg[-1]
  ps <- strsplit(msg, '[ ]+')
  names <- sapply(ps, function(s){
    s[[length(s)]]
  })
  names <- unlist(names)
  if(name %in% names){
    if(!opt$force){
      cat(rep('-', 50), '\n', sep = '')
      cat("\nError: container already exists! You need to stop the running container before calling this command, or use -f to force restart the container\n")
      cat("\nType rave_docker -h or rave_docker --help to see usage\n\n")
      q("no")
    } else {
      cat("\nForce restarting the container... (container will be removed and re-installed)\n")
      cat("Stopping ", name, '\n')
      system(sprintf("docker container stop %s", name), wait = TRUE, intern = TRUE)

      cat("\nRemoving container ", name, '\n')
      system(sprintf("docker container rm %s", name), wait = TRUE, intern = TRUE)

      # do not install demo data
      opt$minimal <- TRUE
    }
  }
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
  token_str <- sprintf(' --token %s', token)
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

if(opt$minimal){
  # no demo data
  demo_str <- sprintf("-e DEMODATA=FALSE")
} else {
  demo_str <- sprintf("-e DEMODATA=TRUE")
}

cmd1 <- sprintf(
  'docker run -it -d --name "%s" %s -v "%s":/data/rave_data %s beauchamplab/rave start_rave --ncpus %d%s',
  name, port_str, rave_root, demo_str, ncpu, token_str
)

cat("\n\n# Starting container...\n")
cat(">$", cmd1, '\n\n')
system(cmd1, wait = TRUE)


if(preprocess_enabled){
  cmd2 <- sprintf('docker exec -d -it "%s" rave_preprocess --ncpus %d%s', name, ncpu, token_str)
  cat("\n\n# Enabling preprocess module...\n")
  cat(">$", cmd2, '\n\n')
  system(cmd2, wait = TRUE)
} else {
  cmd2 <- NULL
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

# Save name file to
R_user_dir <- function (package, which = c("data", "config", "cache")) {
  stopifnot(is.character(package), length(package) == 1L)
  which <- match.arg(which)
  home <- normalizePath("~")
  path <- switch(which, data = {
    if (nzchar(p <- Sys.getenv("R_USER_DATA_DIR"))) p
    else if (nzchar(p <- Sys.getenv("XDG_DATA_HOME"))) p
    else if (.Platform$OS.type == "windows") file.path(Sys.getenv("APPDATA"), "R", "data")
    else if (Sys.info()["sysname"] == "Darwin") file.path(home, "Library", "Application Support", "org.R-project.R")
    else file.path(home, ".local", "share")
  }, config = {
    if (nzchar(p <- Sys.getenv("R_USER_CONFIG_DIR"))) p
    else if (nzchar(p <- Sys.getenv("XDG_CONFIG_HOME"))) p
    else if (.Platform$OS.type == "windows") file.path(Sys.getenv("APPDATA"), "R", "config")
    else if (Sys.info()["sysname"] == "Darwin") file.path(home, "Library", "Preferences", "org.R-project.R")
    else file.path(home, ".config")
  }, cache = {
    if (nzchar(p <- Sys.getenv("R_USER_CACHE_DIR"))) p
    else if (nzchar(p <- Sys.getenv("XDG_CACHE_HOME"))) p
    else if (.Platform$OS.type == "windows") file.path(Sys.getenv("LOCALAPPDATA"), "R", "cache")
    else if (Sys.info()["sysname"] == "Darwin") file.path(home, "Library", "Caches", "org.R-project.R")
    else file.path(home, ".cache")
  })
  file.path(path, "R", package)
}

conf_path <- R_user_dir('raveio', 'config')
instance_path <- file.path(conf_path, 'docker_instances')
dir.create(instance_path, showWarnings = FALSE, recursive = TRUE, mode = '0777')
path <- file.path(instance_path, name)

writeLines(c(cmd1, cmd2), path)
path <- normalizePath(path)
cat("\nInstance command lines are saved to \n  ", path, '\n\n')

q("no")
