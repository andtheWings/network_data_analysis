# test_nodes <- tibble(names = c("Dan", "Lauren", "DJ"))
# test_edges <- tibble(
#     from = c(1, 1, 2, 2, 3, 3),
#     to = c(2, 3, 1, 3, 1, 2)
# )
# 
# test_graph <- tbl_graph(test_nodes, test_edges)
# 
# ggraph(test_graph) + 
#     geom_edge_fan(arrow = arrow(length = unit(4, 'mm'))) +
#     geom_node_point()
# 
# ggraph(convert(test_graph, to_undirected)) + 
#     geom_edge_fan(arrow = arrow(length = unit(5, 'mm'))) +
#     geom_node_point()
# 
# ggraph(
#     (
#         convert(test_graph, to_undirected) |> 
#             convert(to_simple)
#     ) 
# ) + 
#     geom_edge_fan(arrow = arrow(length = unit(5, 'mm'))) +
#     geom_node_point()