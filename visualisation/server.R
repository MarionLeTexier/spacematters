library(shiny)
library(RColorBrewer)
library(RCurl)
library(ggplot2)
library(reshape2)
library(grid)
library(lattice)


shinyServer(function(input, output) {
  resultFile <- reactiveValues(datapath= "data/result.csv")

  
  output$map_cell <- renderPlot({
    inFile <- input$file1
    
    if (is.null(inFile)) {
      result <- read.csv(resultFile$datapath, sep=",", dec=".", header=F)
    }
    
    if (!is.null(inFile)) {
      result <- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                         quote=input$quote)
    }
  
    
    
   # result <- read.csv("data/result.csv", sep=",", dec=".", header=F)
    summary(result)
    colnames(result) <- c("step", "x", "y", "capacity", "greens", "reds", "satisgreen", "satisred")
 result$totalPop <- result$greens + result$red
 result$pctgreens <- result$greens / result$totalPop * 100
 result$pctreds <- result$reds / result$totalPop * 100
 result$empty <- result$capacity - result$totalPop
 result$pctempty <- result$empty / result$capacity * 100
 result$satisfiedgreen <- ifelse(result$satisgreen == "false", result$greens, 0)
 result$satisfiedred <- ifelse(result$satisred == "false", result$reds, 0)
 result$satisfied <-  result$satisfiedgreen +  result$satisfiedred
 result$pctsatisfied <- result$satisfied / result$totalPop * 100
 result$pctunsatisfied <-  100 -  result$pctsatisfied
 
 
 
 currentstep <- subset(result, step == input$step)[,-1]
 
 tempo <- melt(currentstep,
               id.vars=c("x","y"),
               measure.vars=input$var)
 tempo2 <- dcast(tempo, x~y)

 map <- as.matrix(tempo2[,-1])
 rownames(map) <- tempo2[,1]

size <- dim(map)[[1]]

if (input$var == "totalPop") my_palette <- colorRampPalette(c("white", "black"))(n = 299)
if (input$var == "pctgreens") my_palette <- colorRampPalette(c("white", "forestgreen"))(n = 299)
if (input$var == "pctreds") my_palette <- colorRampPalette(c("white", "firebrick1"))(n = 299)
if (input$var == "pctunsatisfied") my_palette <- colorRampPalette(c("white", "dodgerblue3"))(n = 100)

mapPop <- levelplot(map, 
          col.regions=my_palette, 
          colorkey=T ,
        xlab="", ylab="",
        cex.axis=0.1,
        scales=list(x=list(at=c(0,size+1)), y=list(at=c(0,size+1))
          )
        )
 
return(mapPop)
  })
})
