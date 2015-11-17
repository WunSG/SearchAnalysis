for (package in c('shiny', 'tm', 'wordcloud', 'topicmodels')) {
  if (!require(package, character.only=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#extract keywords from search phrases by seperating keywords using spaces
getKeywords <- function(keywords, omit_text){
  stopWords <- c("for", "of", "the", "is", "and", "from", "to", "with", "on")
  
  names(keywords) <- c("ID", "Words", "Volume")
  
  List <- strsplit(as.character(keywords[, 2]), " ")
  
  x <- data.frame(ID=rep(keywords$ID, sapply(List, length)), Words=unlist(List))
  
  y <- keywords[c("ID", "Volume")]
  
  y <- merge( x, y, by.x = "ID", by.y = "ID")
  y <- y[c("Words", "Volume")]
  y <- y[complete.cases(y), ]
  
  z <- aggregate(as.numeric(y$Volume),by =list(y$Words), FUN = sum)
  
  z <-z[complete.cases(z), ]

  
  tdm_df <- as.data.frame(z)  
  tdm_df <- tdm_df[order(-tdm_df[,2]), ]
  
  omit_text <- unlist(strsplit(omit_text, " "))
  class(omit_text)
  tdm_df <- tdm_df[!tdm_df[, 1] %in% omit_text, ]
  tdm_df <- tdm_df[!tdm_df[, 1] %in% stopWords, ]
  
  tdm_df[, 3] <- tdm_df[, 2]/sum(tdm_df[, 2])*100
  
  names(tdm_df) <- c("Word", "Monthly Volume", "%")
  
  return(tdm_df)
}


#create wordcloud 
make_cloud <- function(keywords, freq, max){

  wordcloud(keywords[ , 1], keywords[ , 2],
            random.order = FALSE, 
            min.freq = freq, max.words=max,
            colors=brewer.pal(8, "Dark2"))
}
