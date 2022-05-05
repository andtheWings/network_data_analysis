transpose_llinas_raw <- function(llinas_raw_df) {
    
    transposed_llinas_raw1 <-
        llinas_raw_df |> 
        tidyr::pivot_longer(
            cols = 2:73,
            names_to = "id"
        ) |> 
        tidyr::pivot_wider(
            names_from = Samples,
            values_from = value
        )
    
    return(transposed_llinas_raw1)
    
}

wrangle_llinas_pre_ggm <- function(transposed_llinas_raw_df) {
    
    missing_vars1 <- 
        find_vars_w_missing_data_above_threshold(transposed_llinas_raw_df, 0.1)
    
    llinas_metabolites1 <-
        transposed_llinas_raw_df |> 
        select(
            -id,
            -date,
            -treatment,
            -target,
            -dosage,
            -replicate,
            -missing_vars1
        ) |> 
        datawizard::standardise() |> 
        as.matrix()
    
    return(llinas_metabolites1)
    
}

assemble_llinas_metabolite_graph <- function(llinas_metabolite_nodes_df, llinas_treatments_ggm_ric_obj) {
    
    llinas_metabolite_ric_edges1 <-
        llinas_treatments_ggm_ric_obj$refit |> 
        as_tbl_graph() |> 
        activate(edges) |> 
        as_tibble()
    
    llinas_metabolite_ric_pcors1 <-
        llinas_treatments_ggm_ric_obj$opt.cov |> 
        cov2cor() |> 
        corpcor::cor2pcor() |> 
        as_tbl_graph() |> 
        activate(edges) |> 
        as_tibble() |> 
        semi_join(
            llinas_metabolite_ric_edges1,
            by = c("from", "to")
        )
    
    llinas_metabolite_graph1 <- 
        tbl_graph(
            llinas_metabolite_nodes_df, 
            llinas_metabolite_ric_pcors1, 
            directed = FALSE
        )
    
    return(llinas_metabolite_graph1)
    
}