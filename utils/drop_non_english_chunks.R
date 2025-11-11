
drop_non_english_chunks <- function(text,
                                    min_chars   = 25,  # only drop if chunk >= this many chars
                                    min_tokens  = 5,   # ...and >= this many tokens
                                    keep_short  = TRUE,
                                    glue        = " ") {
  text <- as.character(text)

  # Pick a language detector that exists
  have_cld3 <- requireNamespace("cld3", quietly = TRUE)
  have_cld2 <- requireNamespace("cld2", quietly = TRUE)

  detect_lang <- function(s) {
    if (is.na(s) || s == "") return(NA_character_)
    if (have_cld3) {
      # cld3 returns a single code like "en" or NA
      return(cld3::detect_language(s))
    } else if (have_cld2) {
      return(cld2::detect_language(s, plain_text = TRUE))
    } else {
      return(NA_character_)  # no detector installed → keep content
    }
  }

  keep_one <- function(x) {
    if (is.na(x) || x == "") return(x)

    # Sentence split (no unsupported args)
    sents <- stringi::stri_split_boundaries(x, type = "sentence")[[1]]
    if (length(sents) == 0) return(x)

    kept <- purrr::map_chr(sents, function(s) {
      # Token/length guards so we don't drop short foreign bits
      tokens <- stringi::stri_extract_all_words(s)[[1]]
      token_n <- if (is.null(tokens)) 0L else length(tokens)

      if (keep_short && (nchar(s) < min_chars || token_n < min_tokens)) {
        return(s)  # keep short chunks regardless of language
      }

      ld <- detect_lang(s)

      # Keep English or undecidable; drop long non-English
      if (is.na(ld) || ld == "en") s else ""
    })

    out <- paste(kept[nzchar(kept)], collapse = glue)
    out <- stringi::stri_trim_both(stringi::stri_replace_all_regex(out, "\\s+", " "))
    if (out == "") NA_character_ else out
  }

  vapply(text, keep_one, FUN.VALUE = character(1))
}
