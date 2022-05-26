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

wrangle_parasitized_llinas_pre_dingo <- function(llinas_treatments_modified_df) {
    
    missing_vars1 <- 
        find_vars_w_missing_data_above_threshold(llinas_treatments_modified_df, 0.1)
    
    df1 <-
        llinas_treatments_modified_df |> 
        filter(target == "Parasitized RBCs") |> 
        mutate(
            any_treatment = 
                factor(
                    if_else(
                        treatment == "None",
                        true = "no",
                        false = "yes"
                    ),
                    ordered = FALSE
                )
        ) |> 
        relocate(any_treatment) |> 
        select(
            -id,
            -date,
            -treatment,
            -target,
            -dosage,
            -replicate,
            -missing_vars1
        )
    
    return(df1)
    
}

convert_parasitized_llinas_dingo_to_df <- function(parasitized_llinas_dingo_obj) {
    
    rho <- 0.1
    
    df1 <-
        dingo_to_df(parasitized_llinas_dingo_obj) |> 
        mutate(
            orq_diff_score = 
                bestNormalize::orderNorm(diff_score)$x.t,
            diff_rank = percent_rank(orq_diff_score),
            plot_alpha = 
                if_else(
                    diff_rank > 0.997 | diff_rank < 0.003,
                    true = "opaque",
                    false = "clear"
                ),
            plot_size = 
                if_else(
                    diff_rank > 0.997 | diff_rank < 0.003,
                    true = "large",
                    false = "small"
                ),
            plot_label =
                case_when(
                    diff_rank > 0.9999 | diff_rank < 0.0001 ~ gene_pair
                ),
            exposure_group = 
                case_when(
                    abs(pcor1) > rho &
                        abs(pcor2) > rho &
                        sign(pcor1) == sign(pcor2)
                    ~ "global",
                    abs(pcor1) > rho &
                        abs(pcor2) < rho &
                        pval < 0.05 
                    ~ "no treatment only",
                    abs(pcor1) < rho &
                        abs(pcor2) > rho &
                        pval < 0.05 
                    ~ "treatment only"
                )
        )
    
    return(df1)
    
}


assemble_parasitized_llinas_dingo_graph <- function(llinas_metabolite_nodes_df, parasitized_llinas_edges_df) {

    llinas_no_treatment_only <-
        parasitized_llinas_edges_df |> 
        filter(exposure_group == "no treatment only") |> 
        as_tbl_graph() |> 
        activate(nodes) |> 
        as_tibble()
    
    llinas_treatment_only <-
        parasitized_llinas_edges_df |> 
        filter(exposure_group == "treatment only") |> 
        as_tbl_graph() |> 
        activate(nodes) |> 
        as_tibble()
    
    edges1 <-
        parasitized_llinas_edges_df |> 
        filter(
            !is.na(exposure_group)
        )
    
    graph1 <-
        tbl_graph(
            nodes = llinas_metabolite_nodes_df,
            edges = edges1,
            node_key = "metabolite_name"
        ) |> 
        activate(nodes) |> 
        mutate(
            exposure_group = "global"
        ) |> 
        morph(
            to_subgraph,
            metabolite_name %in% llinas_treatment_only$name &
                !(metabolite_name %in% llinas_no_treatment_only$name)
        ) |> 
        mutate(
            exposure_group = "treatment only",
            label = metabolite_name
        ) |>
        unmorph() |> 
        morph(
            to_subgraph,
            !(metabolite_name %in% llinas_treatment_only$name) &
                metabolite_name %in% llinas_no_treatment_only$name
        ) |> 
        mutate(
            exposure_group = "no treatment only",
            label = metabolite_name
        ) |> 
        unmorph()
    
    return(graph1)

}