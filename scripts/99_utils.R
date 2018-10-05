
# ---- source_utils ----

library(ggplot2)

theme_pred <- function(){
  theme(legend.position = "na",
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        plot.title = element_text(size = 10, face = "bold", color = "black", hjust = 0))
}

signif_star <- function(x){
  if(!is.na(x)){
    if(x){
      "*"
    }else{
      ""
    }
  }else{
    ""
  }
}
