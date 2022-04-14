library(targets)

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
source("R/wrangling_huttlin.R")
summ <- function(dataset) {
  summarize(dataset, mean_x = mean(x))
}

# Set target-specific options such as packages.
tar_option_set(
    packages = c("dplyr", "tidyr", "tidygraph", "ggraph")
)

# End this file with a list of target objects.
list(
    tar_target(
        name = file_human_biogrid,
        "data/BIOGRID-ORGANISM-Homo_sapiens-4.4.207.tab3.txt",
        format = "file"
    ),
    tar_target(
        name = raw_human_biogrid,
        command = readr::read_delim("data/BIOGRID-ORGANISM-Homo_sapiens-4.4.207.tab3.txt")
    ),
    tar_target(
        name = huttlin,
        command = extract_huttlin_from_human_biogrid(raw_human_biogrid)
    ),
    tar_target(
        name = huttlin_nodes,
        command = assemble_huttlin_nodes(huttlin)
    ),
    tar_target(
        name = huttlin_edges,
        command = assemble_huttlin_edges(huttlin)
    ),
    tar_target(
        name = huttlin_graph,
        command = tbl_graph(nodes = huttlin_nodes, edges = huttlin_edges)
    )
)
