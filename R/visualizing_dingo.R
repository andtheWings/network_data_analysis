plot_pcor_diff <- function(dingo_df) {
    
    ggplot(
        dingo_df,
        aes(
            x = pcor1,
            y = pcor2
        )
    ) +
        geom_abline(intercept = 0, slope = 1) +
        geom_point(
            aes(color = abs(diff_score)), 
            size = 3,
            alpha = 0.5
        ) +
        # geom_text(
        #     aes(label = label_extremes),
        #     vjust = -1
        # ) +
        scale_color_gradient(low = "lightpink", high = "purple")
    
}