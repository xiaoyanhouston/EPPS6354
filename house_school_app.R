# install.packages("shiny") # If you have not installed this package, remove the # sign and run
library(shiny)
library(DBI) # DBI can connect to other database servers
library(RPostgres)





# Define UI for app that draws a histogram ----
ui <- fluidPage(
  # App title ----
  titlePanel("EPPS6354 Nearest School"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Slider for the number of bins ----
     #sliderInput(inputId = "distance",
                  #label = "enter the distance(miles):",
                 # min = 0,
                  #max = 100,
                  #value = 7),
     textInput(inputId ="zip",label = "Enter your zip", value="75036"), 
     textInput(inputId = "nrow", label = "Rows to display", value="5"),
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
    
    sqlite_sql <- "   select e.*
                      from house_school as e
                      inner join
                      (
                      	select house_address, house_zip, min(distance) as min_dist
                          from house_school
                      	group by house_address,  house_zip
                      ) as b
                      on e.house_address= b.house_address and e.house_zip=b.house_zip
                      where e.distance= b.min_dist "

    
                          
    dbGetQuery(sqlite_conn, "create temp table house_school as 
                      select hs.address as house_address, hs.zip as house_zip, b.school_id,
                      b.school_name, b.rank, b.stu_number,
                      b.staff_number, b.staff_stu_ratio,
                      2 * 3958.756 * asin( sqrt( power(sin((b.latitude- hs.latitude)*PI()/180/2),2)
                      							  + cos(hs.latitude*PI()/180) * cos(b.latitude*PI()/180)
                      							  * Power(sin((b.longitude-hs.longitude)*PI()/180/2), 2) ))
                      							  as distance
                      from house as hs,
                      (
                      	select sc.school_id,sc.school_name,sc.rank,
                      	sc.zip_code,sc.longitude,sc.latitude,
                      	st.stu_number,sa.staff_number,sa.staff_stu_ratio
                      	from school sc
                      	left  join school_student st
                      	on sc.school_id=st.school_id
                      	left join school_staff sa
                      	on sc.school_id= sa.school_id) as b
                      ")
   

    on.exit(dbDisconnect(sqlite_conn), add = TRUE)

    table_df = dbGetQuery(sqlite_conn, paste0(sqlite_sql, " and e.house_zip=",
                                              "'", input$zip,"'",
                                              " order by e.house_address LIMIT ",
                                              input$nrow , ";"))

  }, escape = FALSE)
    
  
  
}

shinyApp(ui = ui, server = server)
# library(rsconnect)
# rsconnect::setAccountInfo(name='yourShinyappsaccount', token='*', secret='*')
