# install.packages("shiny") # If you have not installed this package, remove the # sign and run
library(shiny)
library(DBI) # DBI can connect to other database servers
library(RPostgres)





# Define UI for app that draws a histogram ----
ui <- fluidPage(
  # App title ----
  titlePanel("EPPS6354 HousePrice distribution"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30),
  tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: firebrick}")) # Change color of slider
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "distPlot")
      
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
  output$distPlot <- renderPlot({
    # sqllite
    # Be sure the data file must be in same folder
    sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname ='HouseMarket.db')
    
    # SQL statements to be submitted and processed on server
    sqlite_sql <- "SELECT * FROM house"
    
   
    
    house_df <- dbGetQuery(sqlite_conn, sqlite_sql)
    #class(house_df)
    
    x    <- house_df$price
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = "green", border = "white",
         xlab = "House Price",
         main = "Histogram of House Price")
    
  })
  
}

shinyApp(ui = ui, server = server)
# library(rsconnect)
# rsconnect::setAccountInfo(name='yourShinyappsaccount', token='*', secret='*')
