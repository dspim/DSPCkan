.url <- "https://data.dsp.im"

#'@importFrom httr add_headers
#'@export
package_list <- function(offset = 0, limit = 31, as = "table") {
  ckanr::package_list(offset = offset, limit = limit, as = as, url = .url, 
                      add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    decode_hex_utf16
}

#'@export
tag_list <- function(as = "table") {
  ckanr::tag_list(query = NULL, vocabulary_id = NULL, all_fields = TRUE,
                  as = as, url = .url, add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    decode_hex_utf16
}

#'@export
organization_list <- function(id, as = "table") {
  ckanr::organization_list(order_by = "name", decreasing = TRUE, organizations = NULL, all_fields = TRUE,
                          as = as, url = .url, add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    decode_hex_utf16
}

decode_hex_utf16 <- function(retval) {
  for(i in seq_len(ncol(retval))) {
    if (class(retval[[i]]) == "character") retval[[i]] <- .decode_hex_utf16(retval[[i]])
  }
  retval
}

#'@importFrom magrittr %>%
.decode_hex_utf16 <- function(x, m = NULL) {
  if (is.null(m)) m <- regmatches(x, regexec("(<U\\+[0-9a-f]{4}>)+", x))
  retval <- x
  for(i in seq_along(m)) {
    if (length(m[[i]]) == 0) next
    value <- sapply(seq_len(nchar(m[[i]][1]) %/% 8), function(j) {
      substring(m[[i]][1], 8 * (j - 1) + 4, 8 * j - 1) %>%
        strtoi(base = 16) %>%
        intToUtf8
    }) %>% paste(collapse = "")
    retval[i] <- gsub(pattern = m[[i]][1], replacement = value, x = x[i], fixed = TRUE)
  }
  m <- regmatches(retval, regexec("(<U\\+[0-9a-f]{4}>)+", retval))
  if (!all(sapply(m, length) == 0)) retval <- .decode_hex_utf16(retval, m)
  retval
}

#'@importFrom svGUI is.gui
#'@importFrom svDialogs dlgForm
#'@export
input_apikey <- function() {
  Form <- list("API-Key:TXT" = "")
  options("X-CKAN-API-Key" = dlgForm(Form, "My API-Key")$res[["API-Key"]])
  NULL
}

