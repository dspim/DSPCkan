.url <- "http://data.dsp.im/"

#'@export
package_list <- function(as = "table") {
  ckanr::package_list(as = as, url = .url)
}

#'@export
tag_list <- function(as = "table") {
  retval <- ckanr::tag_list(as = as, url = .url)
  for(i in seq_len(ncol(retval))) {
    if (class(retval[[i]]) == "character") retval[[i]] <- decode_hex_utf16(retval[[i]])
  }
  retval
}

#'@importFrom magrittr %>%
decode_hex_utf16 <- function(x) {
  m <- regmatches(x, regexec("(<U\\+[0-9a-f]{4}>)+", x))
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
  retval
}

