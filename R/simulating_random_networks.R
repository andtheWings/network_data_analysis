# erdos_renyi_sims <-
#     tibble( 
#         graph_obj = 
#             map(
#                 1:1000,
#                 ~filter_to_max_connected_component(
#                     play_erdos_renyi(
#                         n = gorder(MUC_huttlin_graph),
#                         m = gsize(MUC_huttlin_graph),
#                         directed = FALSE 
#                     )
#                 )
#             ) 
#     )
# 
# erdos_renyi_sims <-
#     erdos_renyi_sims |> 
#     mutate(
#         SWI = map(graph_obj, ~qgraph::smallworldIndex(.x))
#     ) |> 
#     unnest(SWI) |> 
#     unnest(SWI)
# 
# 
# EnvStats::demp(x = 2.679, obs = erdos_renyi_sims$SWI)
# 
# EnvStats::pemp(q = 3, obs = erdos_renyi_sims$SWI) - EnvStats::pemp(q = 2.5, obs = erdos_renyi_sims$SWI)
