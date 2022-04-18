# MUC stands for Malformed umbilical cord
id_huttlin_orthologs_shared_w_park <- function(huttlin_nodes_df, park_diff_expressed_proteins_raw_df) {
    
    human_MUC_orthologs <- 
        semi_join(
            x = huttlin_nodes_df,
            y = park_diff_expressed_proteins_raw_df, 
            by = c("swiss_prot" = "Human SWISS-PROT Ortholog")
        )$cell_line_and_official_symbol
    
    return(human_MUC_orthologs)
}

localize_MUC_huttlin_graph <- function(huttlin_orthologs_shared_w_park_vct, huttlin_tbl_graph) {
    graph1 <- 
        purrr::map(
            .x = huttlin_orthologs_shared_w_park_vct,
            .f = 
                ~convert(
                    huttlin_tbl_graph,
                    to_local_neighborhood,
                    node = which(.N()$cell_line_and_official_symbol == .x),
                    order = 1,
                    mode = "all"
                )
        ) |> 
        purrr::reduce(
            graph_join
        )
    
    return(graph1)
}
