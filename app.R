library(shiny)
library(plotly)
library(dplyr)
library(ggplot2)
library(reshape2)
library(scales)
library(shinythemes)
GDP20 <- read.csv("GDP20.csv", header=TRUE, check.names = FALSE, stringsAsFactors = FALSE)

ui <- fluidPage(theme = shinytheme("slate"),
  fluidRow(
    column(12, align="center",h1("Singapore GDP Data")),
    column(6,
        checkboxGroupInput("checkbox", label = h3("Please Select Variables"), choices=
          list("Gross Domestic Product At Current Market Prices"=1,
               "Goods Producing Industries"=2,
               "Manufacturing"=3,
               "Construction"=4,
               "Utilities"=5,
               "Other Goods Industries"=6,
               "Services Producing Industries"=7,
               "Wholesale & Retail Trade"=8,
               "Transportation & Storage"=9,
               "Accommodation & Food Services"=10), selected = 1)
      ),

    # Had to add sep="", or else the numbers will have a comma in them
    column(6, align="center",
        sliderInput("slider", label = h3("Year Range"), sep="",min = 1980, 
                       max = 2018, value = c(2000, 2018))
    ),
    fluidRow(
      column(6, verbatimTextOutput("value")),
      column(6, verbatimTextOutput("range"))
    ),
    plotOutput("plot")
   
))


server <- function(input, output){
  output$value <- renderPrint({
    validate(
      need(input$checkbox != "", "Please select at least one Variable")
    )
    # use the next line to show the value of checkbox
    # input$checkbox 
    })
  # Use the next line to show the value of year range
  # output$range <- renderPrint({ input$slider })
  output$plot <- renderPlot({
    # browser()
    # create a new data frame with range of year selected
    a<- input$slider[1]
    b<- input$slider[2]
    yearSeq <- as.character(seq(a,b))
    yearSeq <- append(yearSeq, "Variables")
    GDPNew <- GDP20[grep(paste(yearSeq,collapse="|"), colnames(GDP20))]
    
    # Now filter with the selected Variables
    # store input$ value in check1.  else have to use aes_string() within ggplot
    check1 <- as.numeric(input$checkbox)
    GDPNew <- GDPNew[check1,]
    GDPNew <- melt(GDPNew, id.vars = "Variables")
    # separating + geom_ in the next line causes error. ??
    g <- ggplot(data = GDPNew, aes(x=variable, y=value, color=Variables, group=Variables)) + geom_point() + geom_line() + theme(axis.text.x = element_text(face="italic",angle = 90)) + xlab("Year") + ylab("Singapore Dollars, Million") + theme(legend.position="top") + scale_y_continuous(label=dollar_format())
    g
    # To make plotly: 1) change to renderPloty in Server. 2) plotlyOutput in UI. 3) convert ggplot to plotly
    # plotly does not take ggplot legend.  Need to specify and play with y value. +ve y places the legend on top.  Legend does not wrap when it gets too long.
    # p <- ggplotly(g) %>% layout(legend = list(orientation = "h",y = 1.5, x = 0))
    # p
    })
}

shinyApp(ui=ui, server=server)
