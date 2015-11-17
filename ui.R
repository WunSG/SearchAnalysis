shinyUI(navbarPage("SEARCH KEYWORDS ANALYSIS",
                   tabPanel("1. Setup",
                            sidebarLayout(
                              sidebarPanel(
                                h3("Upload File"),
                                checkboxInput('header', 'Header', TRUE),
                                selectInput("sep", "Seperator", 
                                            c(Comma=',',
                                              Semicolon=';',
                                              Tab='\t'),
                                            ','),
                                fileInput('file1', 'Choose file to upload',
                                          accept = c(
                                            'text/csv',
                                            'text/comma-separated-values',
                                            'text/tab-separated-values',
                                            'text/plain',
                                            '.csv',
                                            '.tsv'
                                          )
                                ),
                                tags$hr(),
                                h3("File Setup"),
                                uiOutput("keyword_col"),
                                uiOutput("month_volume_col")
                              ),
                              mainPanel(
                                tabsetPanel(type = "tabs", 
                                            tabPanel("Summary", tableOutput("sum")), 
                                            tabPanel("File Contents", dataTableOutput("view"))
                                )
                              )
                            )
                   ),
                   
                   
                   tabPanel("2. All Keywords",
                            sidebarLayout(
                              sidebarPanel(
                                h3("Keywords Setup"),
                                sliderInput("freq",
                                            "Minimum Frequency:",
                                            min = 1,  max = 50, value = 15),
                                sliderInput("max",
                                            "Maximum Number of Words:",
                                            min = 1,  max = 300,  value = 200),
                                textInput("omit_text", ("Words to be omited from word cloud (seperated by space)"), value = "")
                              ),
                            mainPanel(
                              downloadButton("wordcloud_img", "Download Wordcloud Image"),
                              downloadButton("freq_csv", "Download Keyword CSV"),
                              tabsetPanel(type = "tabs", 
                                          tabPanel("Wordcloud", imageOutput("wordcloud", height=600)), 
                                          tabPanel("Table", dataTableOutput("plot_table"))
                              )
                            )
                   )
                   ),
                   
                   
                   tabPanel("3. By Category",
                            sidebarLayout(
                              sidebarPanel(
                                h3("Category Setup"),
                              uiOutput("cat1_col"), 
                              uiOutput("cat2_col"), 
                              uiOutput("cat1_options"), 
                              uiOutput("cat2_options"),
                              h3("Keywords Setup"),
                              sliderInput("freq_cat",
                                          "Minimum Frequency:",
                                          min = 1,  max = 50, value = 15),
                              sliderInput("max_cat",
                                          "Maximum Number of Words:",
                                          min = 1,  max = 300,  value = 200),
                              textInput("omit_text_cat", ("Words to be omited from word cloud (seperated by space)"), value = "")
                            ), 
                            mainPanel(
                              downloadButton("wordcloud_img_cat", "Download Image"),
                              downloadButton("freq_csv_cat", "Download Freq CSV"),
                              tabsetPanel(type = "tabs", 
                                          tabPanel("Wordcloud", imageOutput("wordcloud_cat", height=600)), 
                                          tabPanel("Table", dataTableOutput("plot_table_cat"))
                              )
                            )
                   ))
))

