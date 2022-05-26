dingo_to_df <- function(dingo_obj) {
    
    df1 <- 
        tibble(
            gene1 = dingo_obj$genepair[,1],
            gene2 = dingo_obj$genepair[,2],
            pcor1 = dingo_obj$R1,
            pcor2 = dingo_obj$R2,
            diff_score = dingo_obj$diff.score,
            pval = dingo_obj$p.val
        ) |> 
        mutate(
            gene_pair = paste0(gene1,":",gene2)
        ) |> 
        relocate(gene_pair, .before = pcor1)
    
    return(df1)
    
}