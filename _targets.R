library(targets)

source("R/describing_generic_data.R")
source("R/wrangling_dingo.R")
source("R/wrangling_generic_graphs.R")
source("R/wrangling_huttlin.R")
source("R/wrangling_llinas.R")
source("R/wrangling_shared_MUC_orthologs.R")



# Set target-specific options such as packages.
tar_option_set(
    packages = c("dplyr", "huge", "iDINGO", "igraph", "tidyr", "tidygraph", "ggraph")
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
        command = assemble_huttlin_graph(huttlin_nodes, huttlin_edges)
    ),
    tar_target(
        name = huttlin_293T_comms,
        command = find_huttlin_293T_comms(huttlin_graph)
    ),
    tar_target(
        name = huttlin_293T_comms_filtered_to_eprs_stat5b,
        command = wrangle_huttlin_293T_comms_filtered_to_eprs_stat5b(huttlin_293T_comms)
    ),
    # tar_target(
    #     name = eprs_stat5b_comms,
    #     command = find_communities(huttlin_293T_comms_filtered_to_eprs_stat5b)
    # ),
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
    ),
    # Wrangling Llinas
    tar_target(
        name = llinas_treatments_raw_file,
        "data/llinas_2021_metabolomics.csv",
        format = "file"
    ),
    tar_target(
        name = llinas_treatments_raw,
        command = readr::read_csv(llinas_treatments_raw_file)
    ),
    tar_target(
        name = transposed_llinas_treatments_raw,
        command = transpose_llinas_raw(llinas_treatments_raw)
    ),
    tar_target(
        name = llinas_treatments_modified_file,
        "data/expanded_transposed_llinas_2021.csv",
        format = "file"
    ),
    tar_target(
        name = llinas_treatments_modified,
        command = readr::read_csv(llinas_treatments_modified_file)
    ),
    tar_target(
        name = llinas_treatments_pre_ggm,
        command = wrangle_llinas_pre_ggm(llinas_treatments_modified)
    ),
    tar_target(
        name = llinas_treatments_ggm,
        command = huge(llinas_treatments_pre_ggm, method = "glasso", cov.output=TRUE)
    ),
    tar_target(
        name = llinas_treatments_ggm_ric,
        command = huge.select(llinas_treatments_ggm, criterion = "ric")
    ),
    tar_target(
        name = llinas_treatments_ggm_stars,
        command = huge.select(llinas_treatments_ggm, criterion = "stars")
    ),
    # tar_target(
    #     name = llinas_ggm_ebic,
    #     command = huge.select(llinas_ggm, criterion = "ebic")
    # ),
    # tar_target(
    #     name = llinas_pcor_matrix,
    #     command = corpcor::cor2pcor(cov2cor(llinas_treatments_ggm_ric$opt.cov))
    # ),
    tar_target(
        name = llinas_metabolites_file,
        "data/llinas_2021_metabolites.csv",
        format = "file"
    ),
    tar_target(
        name = llinas_metabolite_nodes,
        command = readr::read_csv(llinas_metabolites_file)
    ),
    tar_target(
        name = llinas_metabolite_graph,
        command = assemble_llinas_metabolite_graph(llinas_metabolite_nodes, llinas_treatments_ggm_ric)
    ),
    tar_target(
        name = parasitized_llinas_pre_dingo,
        command = wrangle_parasitized_llinas_pre_dingo(llinas_treatments_modified)
    ),
    tar_target(
        name = parasitized_llinas_dingo,
        command = 
            iDINGO::dingo(
                dat = parasitized_llinas_pre_dingo[,-1],
                x = parasitized_llinas_pre_dingo$any_treatment,
                cores = 4,
                B = 10
            )
    ),
    tar_target(
        name = parasitized_llinas_dingo_df,
        command = convert_parasitized_llinas_dingo_to_df(parasitized_llinas_dingo)
    ),
    tar_target(
        name = parasitized_llinas_dingo_graph,
        command = 
            assemble_parasitized_llinas_dingo_graph(
                llinas_metabolite_nodes, 
                parasitized_llinas_dingo_df
            )
    )
)
