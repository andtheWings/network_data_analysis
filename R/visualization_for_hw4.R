make_comm_comparison_plot <- function(tbl_graph, color_var, title_txt) {
    
    plot1 <-
        ggraph(
            tbl_graph, 
            layout = "igraph", 
            algorithm = "kk"
        ) +
        geom_edge_fan(
            alpha = 0.20
        ) +
        geom_node_point(
            aes(
                color = {{color_var}}
            )
        ) +
        scale_color_viridis(
            name = "Community Index",
            option = "C"
        ) +
        labs(title = title_txt) +
        theme_graph()
    
    return(plot1)
    
}