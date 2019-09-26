library(shiny)
shinyUI(fluidPage(
    titlePanel("Calculation of annualized returns of the DAX and FTSE indices"),
    sidebarLayout(
        sidebarPanel(
            h3("Return of DAX in %"),
            textOutput("DAX_return"),
            h3("Return of FTSE in %"),
            textOutput("FTSE_return"),
            h3("Usage"),
            h5("This appication calculates the annualized returns of the
               DAX and FTSE indices."),
            h5("Please select an area of interest in the plot with the mouse 
               (hoovering with the mouse over the plot will bring up a cross-hair
               to allow selection)."),
            h5("The application will calculate the annualized return(s) for the
               selected area and report it/them back above"),
            h5("If the selected area only covers one or none of the indices,
               the application will report 'Not selected' for the indices
               that were not selected"),
            h5("The application will show a fit through the data using
               the calculated annualized return.")
        ),
        mainPanel(
            plotOutput("plot1", brush = brushOpts(
                id = "brush1"
            ))
        )
    )
))