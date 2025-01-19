#' @keywords internal
#' @importFrom rlang enquo enquos ensym sym .data := as_name as_label
#' @importFrom dplyr %>%
"_PACKAGE"

.onUnload <- function(libpath) {
  library.dynam.unload("vibrrt", libpath)
}
