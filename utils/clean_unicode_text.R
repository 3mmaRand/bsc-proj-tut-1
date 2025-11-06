clean_unicode_text <- function(text, ascii_only = TRUE, collapse_ws = TRUE) {
  # text: character vector
  # ascii_only: if TRUE, transliterate accents/punctuation to ASCII
  # collapse_ws: if TRUE, collapse runs of whitespace to single spaces and trim

  # Coerce & keep NAs
  text <- as.character(text)

  # Helper: HTML-decode safely, after normalising common literal escapes
  decode_html <- function(x) {
    if (is.na(x) || x == "") return(x)

    # Turn literal escape sequences into real code points (common cases)
    x <- stringi::stri_replace_all_regex(x, "\\\\x(a0|A0)", "\u00A0")     # "\xA0" → NBSP
    x <- stringi::stri_replace_all_regex(x, "\\\\u00(a0|A0)", "\u00A0")  # "\u00A0" → NBSP
    x <- stringi::stri_replace_all_fixed(x, "&nbsp;", "\u00A0")          # HTML nbsp
    x <- stringi::stri_replace_all_regex(x, "&#(160|x[aA]0);", "\u00A0") # &#160; / &#xA0;

    # Decode other HTML entities
    out <- tryCatch(
      xml2::xml_text(xml2::read_html(paste0("<x>", x, "</x>"))),
      error = function(e) x
    )
    out
  }

  # HTML decode elementwise
  out <- vapply(text, decode_html, FUN.VALUE = character(1))

  # Replace a broad set of Unicode spaces with regular spaces
  # NBSP, en/em space, thin/hair/figure spaces, NNBSP, ideographic space, etc.
  out <- stringi::stri_replace_all_regex(
    out,
    "[\\u00A0\\u2000-\\u200A\\u202F\\u205F\\u3000]",
    " "
  )

  # Remove zero-width characters (ZWSP, ZWJ, ZWNJ, word joiner, BOM)
  out <- stringi::stri_replace_all_regex(
    out,
    "[\\u200B-\\u200D\\u2060\\uFEFF]",
    ""
  )

  # Normalise common typographic punctuation
  out <- stringi::stri_replace_all_regex(out, "[\\u2018\\u2019\\u201A\\u201B]", "'") # apostrophes
  out <- stringi::stri_replace_all_regex(out, "[\\u201C\\u201D\\u201E]", "\"")      # quotes
  out <- stringi::stri_replace_all_regex(out, "[\\u2013\\u2014\\u2212]", "-")       # en/em/minus
  out <- stringi::stri_replace_all_fixed(out,  "\u2026", "...")                     # ellipsis

  # Optional: transliterate to ASCII
  if (isTRUE(ascii_only)) {
    out <- stringi::stri_trans_general(out, "Any-ASCII")
  }

  # Optional: collapse whitespace and trim
  if (isTRUE(collapse_ws)) {
    out <- stringi::stri_replace_all_regex(out, "\\s+", " ")
    out <- stringi::stri_trim_both(out)
  }

  out
}
