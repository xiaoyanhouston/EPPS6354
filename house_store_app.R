# install.packages("shiny") # If you have not installed this package, remove the # sign and run
library(shiny)
library(DBI) # DBI can connect to other database servers
library(RPostgres)





# Define UI for app that draws a histogram ----
ui <- fluidPage(
  # App title ----
  titlePanel("EPPS6354 Stores within selected distance"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "distance",
                  label = "enter the distance(miles):",
                  min = 0,
                  max = 100,
                  value = 5),
     textInput(inputId ="zip",label = "Enter your zip", value="75036"), 
     textInput(inputId = "nrow", label = "Rows to display", value="1"),
  tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: firebrick}")) # Change color of slider
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      dataTableOutput(outputId = "tbl")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  output$tbl <- renderDataTable({
    # sqllite
    # Be sure the data file must be in same folder
    sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname ='HouseMarket.db')
    
    # SQL statements to be submitted and processed on server
    sqlite_sql <- "select address, city, zip,st_name, st_address, distance 
                    from (
                    	select hs.*, 
                    		st.store_name as st_name, 
                    		st.address as st_address, 
                    		st.latitude as st_latitude,
                    		st.longitude as st_longitude,
                    		2 * 3958.756 * asin( sqrt( power(sin((st.latitude- hs.latitude)*PI()/180/2),2) 
                    							  + cos(hs.latitude*PI()/180) * cos(st.latitude*PI()/180) 
                    							  * Power(sin((st.longitude-hs.longitude)*PI()/180/2), 2) ))  
                    							  as distance
                    	from house as hs, store as st
                    ) as b "
    
   
    
    hospital_df <- dbGetQuery(sqlite_conn, sqlite_sql)
   
    
    on.exit(dbDisconnect(sqlite_conn), add = TRUE)
    table_df = dbGetQuery(sqlite_conn, paste0(sqlite_sql, "where distance<=", input$distance,
                                              " and zip=","'", input$zip,"'", " order by address LIMIT ",input$nrow , ";"))

  }, escape = FALSE)
    
  
  
}

shinyApp(ui = ui, server = server)
# library(rsconnect)
# rsconnect::setAccountInfo(name='yourShinyappsaccount', token='*', secret='*')
