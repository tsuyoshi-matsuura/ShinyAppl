library(shiny)


shinyServer(function(input, output) {
    library(dplyr)
    # Load time series data with DAX and FTSE indices
    data("EuStockMarkets")
    
    # Transform the timeseries to a data frame
    stocks <- as.data.frame(EuStockMarkets) %>%
        mutate(time = time(EuStockMarkets))
    
    # The annualised return is calculated by modeling the index as
    #     index = a * (1+x)^t
    # where
    #     a: some constant
    #     x: annualised return as a fraction
    #     t: time in years
    #
    # the above formula can be transformed by taking log's on both sidesL
    #     log(index) = log(a) + log(1+x) * t
    #
    # By fitting log(1+x) vs t in a linear model, log(1+x) is found as
    # the slope coefficient= slope
    #
    # The annualized return as a fraction is then obtain as
    #     x = exp(slope) - 1
    # 
    
    # mdlDAX is a linear model fit of log(DAX) vs time in the selected box
    mdlDAX <- reactive({
        brushed_data <- brushedPoints(stocks, input$brush1,
                                      xvar = "time", yvar = "DAX")
        if(nrow(brushed_data) < 2){
            return(NULL)
        }
        lm(log(DAX) ~ time, data = brushed_data)
    })
    # mdlFTSE is a linear model fit of log(FTSE) vs time in the selected box
    mdlFTSE <- reactive({
        brushed_data <- brushedPoints(stocks, input$brush1,
                                      xvar = "time", yvar = "FTSE")
        if(nrow(brushed_data) < 2){
            return(NULL)
        }
        lm(log(FTSE) ~ time, data = brushed_data)
    })
    
    # output the annualised return for DAX, if the box includes DAX data
    output$DAX_return <- renderText({
        if(is.null(mdlDAX())){
            "Not selected"
        } else {
            # mdlDAX()[[1]][2] is the slope of the fit
            # transform the slope to the the annualised return and
            # report percentage instead of fraction
            round((exp(mdlDAX()[[1]][2])-1)*100,digits=1)
        }
    })
    
    # output the annualised return for FTSE, if the box includes FTSE data
    output$FTSE_return <- renderText({
        if(is.null(mdlFTSE())){
            "Not selected"
        } else {
            # mdlFTSE()[[1]][2] is the slope of the fit
            # transform the slope to the the annualised return and
            # report percentage instead of fraction
            round((exp(mdlFTSE()[[1]][2])-1)*100,digits=1)
        }
    })
    
    # Make plots
    output$plot1 <- renderPlot({
        # Plots of data
        plot(stocks$time, stocks$DAX, xlab = "Year",
             ylab = "Index", main = "DAX and FTSE indices",
             cex=0.3, col="blue", bty = "n")
        points(stocks$time,stocks$FTSE,cex=0.3,col="red")
        legend("topleft",pch=1,col=c("blue","red"),legend=c("DAX","FTSE"),bty="n")
        
        # Plot of DAX fit
        if(!is.null(mdlDAX())){
            brushed_data <- brushedPoints(stocks, input$brush1,
                                          xvar = "time", yvar = "DAX")
            lines(brushed_data$time,exp(predict(mdlDAX())),col="blue",lwd=4)
        }
        
        # Plot of FTSE fit
        if(!is.null(mdlFTSE())){
            brushed_data <- brushedPoints(stocks, input$brush1,
                                          xvar = "time", yvar = "FTSE")
            lines(brushed_data$time,exp(predict(mdlFTSE())),col="red",lwd=4)
        }
    })
})