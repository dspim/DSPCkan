.url <- "https://data.dsp.im"

#'@importFrom magrittr %>%
#'@importFrom httr add_headers
package_list <- function(offset = 0, limit = 31, as = "table") {
  ckanr::package_list(offset = offset, limit = limit, as = as, url = .url, 
                      add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    decode_hex_utf16
}

tag_list <- function(as = "table") {
  ckanr::tag_list(query = NULL, vocabulary_id = NULL, all_fields = TRUE,
                  as = as, url = .url, add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    decode_hex_utf16
}

organization_list <- function(as = "table") {
  ckanr::organization_list(order_by = "name", decreasing = TRUE, organizations = NULL, all_fields = TRUE,
                          as = as, url = .url, add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    decode_hex_utf16
}

organization_show <- function(id, as = "table") {
  ckanr::organization_show(id = id, include_datasets = TRUE, url = .url, as = as, 
                           add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", ""))) %>%
    `[`(c("display_name", "description", "title", "package_count", "packages", "name")) %>%
    decode_hex_utf16
}

#'@export
download_course_materials <- function(course_name = NULL, enter_api_key = FALSE, enter_destdir = FALSE) {
  if (is.null(getOption("X-CKAN-API-Key")) || enter_api_key) input_apikey()
  if (is.null(course_name)) {
    retval <- organization_list() %>% 
      `[`(c("title", "name"))
    colnames(retval) <- c("title", "course_name")
    retval
  } else {
    retval <- organization_show(course_name)
    packages <- retval$packages %>%
      `[`(c("title"))
    packages$url <- lapply(retval$packages$resource, `[[`, "url") %>%
      sapply(`[`, 1)
    packages <- packages[grepl("data.dsp.im", packages$url),]
    packages$file_name <- strsplit(packages$url, "/") %>%
      sapply(tail, 1)
    if (is.null(getOption("DSPCKAN_DESTDIR")) || enter_destdir) input_destdir()
    destdir <- getOption("DSPCKAN_DESTDIR")
    if (is.null(destdir) || destdir == "") {
      destdir <- normalizePath(tempdir())
    }
    for(i in seq_len(nrow(packages))) {
      dest <- sprintf("%s/%s", destdir, packages$file_name[i]) %>%
        normalizePath(mustWork = FALSE)
      if (file.exists(dest)) next
      cat(sprintf("\tDownloading %s...\n", packages$file_name[i]))
      res <- httr::GET(packages$url[i], add_headers("X-CKAN-API-Key" = getOption("X-CKAN-API-Key", "")))
      binary <- httr::content(res)
      writeBin(binary, dest)
    }
    cat(sprintf("The data are downloaded to %s\n", destdir))
  }
}

decode_hex_utf16 <- function(retval) {
  for(i in seq_along(retval)) {
    if (class(retval[[i]]) == "character") retval[[i]] <- .decode_hex_utf16(retval[[i]])
    if (class(retval[[i]]) == "data.frame") retval[[i]] <- decode_hex_utf16(retval[[i]])
    if (class(retval[[i]]) == "list") retval[[i]] <- decode_hex_utf16(retval[[i]])
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
input_apikey <- function() {
  Form <- list("API-Key:TXT" = "")
  options("X-CKAN-API-Key" = dlgForm(Form, "My API-Key")$res[["API-Key"]])
  NULL
}

input_destdir <- function() {
  Form <- list("DESTDIR:TXT" = "")
  options("DSPCKAN_DESTDIR" = dlgForm(Form, "Destination")$res[["DESTDIR"]])
  NULL
}
