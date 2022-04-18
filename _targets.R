library(targets)

source("R/wrangling_huttlin.R")
source("R/wrangling_shared_MUC_orthologs.R")

# Set target-specific options such as packages.
tar_option_set(
    packages = c("dplyr", "tidyr", "tidygraph", "ggraph")
)

# End this file with a list of target objects.
list(
    # Wrangling Huttlin
    # This source file was downloaded from thebiogrid.org
    # It includes all known, published protein interactions in Homo sapiens
    tar_target(
        name = human_biogrid_file,
        "data/BIOGRID-ORGANISM-Homo_sapiens-4.4.207.tab3.txt",
        format = "file"
    ),
    tar_target(
        name = human_biogrid_raw,
        command = readr::read_delim(human_biogrid_file)
    ),
    tar_target(
        name = huttlin,
        command = extract_huttlin_from_human_biogrid(human_biogrid_raw)
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
    ),
    # Wrangling Park
    #
    # This source file comes from:
    # Comparative proteomic analysis of malformed umbilical cords from somatic cell 
    # nuclear transfer-derived piglets: implications for early postnatal death;
    # By Park et al. 2009;
    # https://bmcgenomics.biomedcentral.com/articles/10.1186/1471-2164-10-511#Sec19
    # The table represents proteins differentially expressed between piglets with
    # and without malformed umbilical cords;
    # I manually modified the table by adding 2 columns using Expasy's SWISS-Model as a ref:
    # One column was for the proteins official symbol,
    # The second column was for the SWISS-PROT id of the human ortholog of each piglet protein;
    tar_target(
        name = park_diff_expressed_proteins_file,
        "data/park_et_al_2009_diff_expressed_proteins.csv",
        format = "file"
    ),
    tar_target(
        name = park_diff_expressed_proteins_raw,
        command = readr::read_csv(park_diff_expressed_proteins_file)
    ),
    # Wrangling Shared Orthologs between Huttlin and Park
    tar_target(
        name = huttlin_orthologs_shared_w_park,
        command = id_huttlin_orthologs_shared_w_park(huttlin_nodes, park_diff_expressed_proteins_raw)
    ),
    tar_target(
        name = MUC_huttlin_graph,
        command = localize_MUC_huttlin_graph(huttlin_orthologs_shared_w_park, huttlin_graph)
    )
    
)
