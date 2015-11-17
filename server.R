# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 32MB.
options(shiny.maxRequestSize = 32*1024^2)


shinyServer(function(input, output){ 
  
  ##File Setup
  #read file based on configuration 
  data <- reactive({ 
    inFile <- input$file1
    if(is.null(inFile)){return()} 
    read.csv(inFile$datapath, header = input$header,
             sep = input$sep, stringsAsFactors=FALSE)
    
  })
  
  #display summary of data in file 
  output$sum <- renderTable({
    if(is.null(data())){return ()}
    summary(data())
  })
  
  #display first few rows of data in file
  output$view <- renderDataTable({
    data()}, options = list(lengthMenu = c(10, 30, 50), pageLength = 10))

  #keyword column selection 
  output$keyword_col <- renderUI({
    selectInput("in_keyword", "Select Keyword Column",  names(data()))
  })
  
  #keyword monthly volume selection 
  output$month_volume_col <- renderUI({
    selectInput("in_month_volume", "Select Monthly Volume Column",  names(data()))
  })

  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(make_cloud)
  
  
  ##Wordcloud - All Output
  #setup dataframe based on keyword and volume selection
  tdm_df <- reactive({
    if(is.null(data())){return ()}
    keywords <- data()
    keywords$ID <- 1:nrow(keywords)
    keywords <- keywords[ , c(which(colnames(keywords)=="ID"),
                              which(colnames(keywords)==input$in_keyword), 
                              which(colnames(keywords)==input$in_month_volume))]
    
    omit_text <- input$omit_text
    
    getKeywords(keywords, omit_text)
  })

  #setup wordcloud to render reactively
  render_cloud <- reactive({
    keywords <- tdm_df()
    
    png("wordcloud.png", pointsize = 18)
    w <- make_cloud(keywords, input$freq, input$max)
    dev.off()
    filename <- "wordcloud.png"    
    
  })
  
  #render wordcloud based on keywords
  output$wordcloud <- renderImage({
    list(src=render_cloud(), alt="Image being generated!")
  },
  deleteFile = FALSE)

  
  #render data table based on keywords 
  output$plot_table <- renderDataTable({
    tdm_df()}, options = list(lengthMenu = c(10, 30, 50), pageLength = 30))  

  # Download handler for the word cloud.  
  output$wordcloud_img <- downloadHandler(
    filename = "wordcloud.png",
    content = function(cloud) {
      file.copy(render_cloud(), cloud)
    })
  
  # Download handler for the csv
  output$freq_csv <- downloadHandler(
    filename = "keywords.csv",
    content = function(freq) {
      write.csv(tdm_df(), freq)
    })
  
  
  ##Extract Category Options
  output$cat1_col <- renderUI({
    options <- names(data())
    options[2:(length(options)+1)] <- options 
    options[1] <- "--none--"
    selectInput("in_cat1", "Select Primary Category Column",  options)
  })
  
  output$cat2_col <- renderUI({
    options <- names(data())
    options[2:(length(options)+1)] <- options 
    options[1] <- "--none--"
    selectInput("in_cat2", "Select Secondary Category Column",  options)
  })
  
  output$cat1_options <- renderUI({
    keywords <- data()
    options <- as.character(unique(keywords[ , which(colnames(keywords)==input$in_cat1)]))
    options[2:(length(options)+1)] <- options 
    options[1] <- ""
    selectInput("cat1", "Select Primary Category",  options)
  })
  
  output$cat2_options <- renderUI({
    keywords <- data()
    options <- as.character(unique(keywords[ , which(colnames(keywords)==input$in_cat2)]))
    options[2:(length(options)+1)] <- options 
    options[1] <- ""
    selectInput("cat2", "Select Secondary Category",  options)
  })

  
    
  ##Wordcloud - Category Input
  #setup dataframe based on keyword and volume selection
  tdm_df_cat <- reactive({
    if(is.null(data())){return ()}
    keywords <- data()
    if (input$in_cat1 !="--none--"){
      if(input$in_cat2 == "--none--") keywords <- keywords[keywords[ , which(colnames(keywords)==input$in_cat1)] == input$cat1, ]
      else keywords <- keywords[keywords[ , which(colnames(keywords)==input$in_cat1)] == input$cat1 & 
                                  keywords[ , which(colnames(keywords)==input$in_cat2)] == input$cat2, ]
    }
    
    keywords$ID <- 1:nrow(keywords)
    keywords <- keywords[ , c(which(colnames(keywords)=="ID"),
                              which(colnames(keywords)==input$in_keyword), 
                              which(colnames(keywords)==input$in_month_volume))]
    
    omit_text <- input$omit_text_cat
    
    getKeywords(keywords, omit_text)
  })

  
  #setup wordcloud to render reactively
  render_cloud_cat <- reactive({
    keywords <- tdm_df_cat()
    png("wordcloud.png", pointsize = 18)
    w <- make_cloud(keywords, input$freq, input$max)
    dev.off()
    filename <- "wordcloud.png"    
    
  })
  
  #render wordcloud based on keywords
  output$wordcloud_cat <- renderImage({
    list(src=render_cloud_cat(), alt="Image being generated!")
  },
  deleteFile = FALSE)

  #render data table based on keywords
  output$plot_table_cat <- renderDataTable({
    tdm_df_cat()}, options = list(lengthMenu = c(10, 30, 50), pageLength = 30))  
  
  
  # Download handler for the word cloud.  
  output$wordcloud_img_cat <- downloadHandler(
    filename = "wordcloud-cat.png",
    content = function(cloud) {
      file.copy(render_cloud_cat(), cloud)
    })
  
  # Download handler for the csv
  output$freq_csv_cat <- downloadHandler(
    filename = "keywords-cat.csv",
    content = function(freq) {
      write.csv(tdm_df_cat(), freq)
    })
  
})












