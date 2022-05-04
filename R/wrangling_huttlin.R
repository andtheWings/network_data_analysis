extract_huttlin_from_human_biogrid <- function(raw_human_biogrid_df) {
    huttlin <- 
        raw_human_biogrid_df |> 
        filter(`Publication Source` %in% "PUBMED:33961781") |> 
        separate(
            col = Qualifications,
            into = c(NA, NA, "cell_line"),
            sep = " ",
            remove = FALSE
        ) |> 
        mutate(
            cell_line = 
                case_when(
                    cell_line %in% "HEK" ~ "293T",
                    cell_line %in% "HCT116" ~ "HCT116"
                )
        )
    
    return(huttlin)
}

assemble_huttlin_nodes <- function(huttlin_df) {
    huttlin_nodes_A <-
        huttlin_df |> 
        select(
            cell_line,
            official_symbol = `Official Symbol Interactor A`,
            entrez = `Entrez Gene Interactor A`,
            biogrid_interactor = `BioGRID ID Interactor A`,
            systematic_name = `Systematic Name Interactor A`,
            synonyms = `Synonyms Interactor A`,
            swiss_prot = `SWISS-PROT Accessions Interactor A`,
            trembl = `TREMBL Accessions Interactor A`,
            refseq = `REFSEQ Accessions Interactor A`
        ) |> 
        # `Entrez Gene Interactor A` was parsed incorrectly as character type
        mutate(
            entrez = as.numeric(entrez)
        ) |> 
        unite(
            col = cell_line_and_official_symbol,
            cell_line, official_symbol,
            remove = FALSE
        )
    
    
    # Assemble a nodes dataframe from the "B" interactors then bind to the "A" interactors
    huttlin_nodes <-
        huttlin_df |> 
        select(
            cell_line,
            official_symbol = `Official Symbol Interactor B`,
            entrez = `Entrez Gene Interactor B`,
            biogrid_interactor = `BioGRID ID Interactor B`,
            systematic_name = `Systematic Name Interactor B`,
            synonyms = `Synonyms Interactor B`,
            swiss_prot = `SWISS-PROT Accessions Interactor B`,
            trembl = `TREMBL Accessions Interactor B`,
            refseq = `REFSEQ Accessions Interactor B`
        ) |> 
        unite(
            col = cell_line_and_official_symbol,
            cell_line, official_symbol,
            remove = FALSE
        ) |> 
        bind_rows(huttlin_nodes_A) |> 
        # Remove redundant observations
        distinct()
    
    return(huttlin_nodes)
}

assemble_huttlin_edges <- function(huttlin_df) {
    huttlin_edges <-
        huttlin_df |> 
        unite(
            col = "from",
            cell_line, `Official Symbol Interactor A`,
            remove = FALSE
        ) |>
        unite(
            col = "to",
            cell_line, `Official Symbol Interactor B`,
            remove = FALSE
        ) |> 
        select(
            from,
            to,
            cell_line,
            official_symbol_from = `Official Symbol Interactor A`,
            official_symbol_to = `Official Symbol Interactor B`,
            biogrid_interaction = `#BioGRID Interaction ID`,
            score = Score,
            modification = Modification,
            qualifications = Qualifications,
            tags = Tags,
            ontology_term_ids = `Ontology Term IDs`,
            ontology_term_names = `Ontology Term Names`,
            ontology_term_qualifier_ids = `Ontology Term Qualifier IDs`,
            ontology_term_qualifier_names = `Ontology Term Qualifier Names`,
            ontology_term_types = `Ontology Term Types`
        )
    
    return(huttlin_edges)
}

assemble_huttlin_graph <- function(huttlin_nodes_df, huttlin_edges_df) {
    
    graph1 <-
        tbl_graph(
            nodes = huttlin_nodes_df, 
            edges = huttlin_edges_df
        ) |> 
        convert(
            to_simple,
            remove_multiples = TRUE, 
            remove_loops = FALSE
        )
    
    return(graph1)
}

find_huttlin_293T_comms <- function(huttlin_tbl_graph) {
    
    graph0 <-
        huttlin_tbl_graph |> 
        convert(
            to_subgraph,
            cell_line == "293T"
        )
    
    graph3 <- find_communities(graph0)
    
    return(graph3)
}

wrangle_huttlin_293T_comms_filtered_to_eprs_stat5b <- function(huttlin_293T_comms_tbl_graph) {
    
    graph1 <-
        huttlin_293T_comms_tbl_graph |> 
        convert(
            to_subgraph,
            louvain_community %in% c(10, 12) |
                walktrap_community %in% c(24, 33) |
                spinglass_community %in% c(15, 17)
        ) |> 
        mutate(
            louvain_cat = 
                case_when(
                    louvain_community == 10 ~ "EPRS in 10",
                    louvain_community == 12 ~ "STATB5 in 12",
                    TRUE ~ "Other"
                ),
            walktrap_cat = 
                case_when(
                    walktrap_community == 24 ~ "STAT5B in 24",
                    walktrap_community == 33 ~ "EPRS in 33",
                    TRUE ~ "Other"
                ),
            spinglass_cat = 
                case_when(
                    spinglass_community == 15 ~ "STATB5 in 15",
                    spinglass_community == 17 ~ "EPRS in 17",
                    TRUE ~ "Other"
                ),
            prot_of_interest =
                case_when(
                    official_symbol == "EPRS" ~ "EPRS",
                    official_symbol == "STAT5B" ~ "STAT5B",
                    TRUE ~ "Other"
                )
        )
    
    return(graph1)
}