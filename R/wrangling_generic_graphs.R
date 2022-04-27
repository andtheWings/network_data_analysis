to_max_connected_component <- function(multi_comp_tbl_graph) {
    
    max_connected_component <- 
        convert(
            .data = activate(multi_comp_tbl_graph, nodes),
            .f = to_subgraph,
                components(multi_comp_tbl_graph)$membership == which.max(components(multi_comp_tbl_graph)$csize)
        )
    
    return(max_connected_component)
}
