to_max_connected_component <- function(multi_comp_tbl_graph) {
    
    max_connected_component <- 
        convert(
            .data = activate(multi_comp_tbl_graph, nodes),
            .f = to_subgraph,
                components(multi_comp_tbl_graph)$membership == which.max(components(multi_comp_tbl_graph)$csize)
        )
    
    return(max_connected_component)
}

find_communities <- function(tbl_graph) {
    
    graph0 <- 
        tbl_graph |> 
        mutate(temp_id = row_number())
    
    graph1 <-
        graph0 |> 
        convert(to_undirected) |> 
        mutate(
            louvain_community = group_louvain(),
            walktrap_community = group_walktrap()
        ) |> 
        as_tibble() |> 
        select(temp_id, louvain_community, walktrap_community)
    
    graph1.5 <-
        left_join(
            graph0, graph1, 
            by = "temp_id"
        )
    
    graph2 <-
        graph0 |> 
        to_max_connected_component() |>  
        mutate(spinglass_community = group_spinglass()) |> 
        as_tibble() |> 
        select(temp_id, spinglass_community)
    
    graph3 <- 
        left_join(
            graph1.5, graph2, 
            by = "temp_id"
        ) |> 
        select(-temp_id)
        
    return(graph3)
}
