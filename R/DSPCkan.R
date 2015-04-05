.url <- "http://data.dsp.im/"

#'@export
package_list <- function(as = "table") {
  ckanr::package_list(as = as, url = .url)
}

#'@export
tag_list <- function(as = "table") {
  ckanr::tag_list(as = as, url = .url)
}

