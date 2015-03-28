#Downloads metadata of all evaluations listed in the 3IE website
library(rvest, dplyr)
evaluation_table <- data.frame() 
begin_path <- "http://www.3ieimpact.org/en/evidence/impact-evaluations/details/"
end_path <- "/"
for (i in 1001:4000) {
  path <- paste(begin_path,i,end_path, sep="")
  print(path)
  if (!grepl("Error in parse", try(html_text(html(path))))){
    evaluation <- html(path)
    # Check if there is an evaluation date
    if (grepl("Error", try(html_text(html_node(evaluation,"time"))))){
      time <- NA
    } else {
      time <- as.character(html_text(html_node(evaluation,"time")))
    }
    # Retrieve fields names and information
    title <- as.character(html_text(html_nodes(evaluation,"header h1")[2]))
    categories <- html_text(html_nodes(evaluation,"dl dt"))
    details <- html_text(html_nodes(evaluation,"dl dd"))
    categories <- c("3IE_ID", "Title", "Time", categories, "URL")
    categories <- gsub(" ","_", categories)
    details <- c(i,title, time, details, path)
    # Consolidates evaluation info with others
    eval_data <- data.frame(rbind(details), row.names=i)
    colnames(eval_data) <- categories
    eval_data[] <- lapply(eval_data, as.character)
    evaluation_table <- rbind_list(evaluation_table, eval_data)
  }
}
 
write.csv(evaluation_table, "evaluations.csv", row.names = TRUE)
