find_vars_w_missing_data_above_threshold <- function(x_df, threshold_dbl) {
    
    return(names(which(colSums(is.na(x_df))/length(x_df) > threshold_dbl)))
    
}

find_vars_w_any_missing_data <- function(x_df) {
    return(which(colSums(is.na(x_df))>0))
}