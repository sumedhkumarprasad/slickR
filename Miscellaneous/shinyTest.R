library(slickR)
library(svglite)
library(lattice)
library(ggplot2)
library(shiny)


server <- function(input, output) {
  
  output$slick <- renderSlickR({
    slickR(s.in(),height = 600,slideId = 'myId',
           slickOpts = list(slidesToShow=3,centerMode=TRUE)
    )
  })
  
  network <- shiny::reactiveValues()
  
  shiny::observeEvent(input$slick_current,{
    clicked_slide <- input$slick_current$.clicked
    relative_clicked <- input$slick_current$.relative_clicked
    center_slide <- input$slick_current$.center
    total_slide <- input$slick_current$.total
    active_slide <- input$slick_current$.slide
    
    if(!is.null(clicked_slide)){
      network$clicked_slide <- clicked_slide
      network$center_slide <- center_slide
      network$relative_clicked <- relative_clicked
      network$total_slide <- total_slide
      network$active_slide <- active_slide
      }
  })
  

  output$current <- renderText({
    l <- shiny::reactiveValuesToList(network)
    paste(gsub('_',' ',names(l)), unlist(l),sep=' = ',collapse='\n')
  })

  s.in=reactive({
    sapply(
      list(
        xmlSVG({hist(rnorm(input$obs), col = 'darkgray', border = 'white')},standalone=TRUE)
        ,xmlSVG({print(xyplot(x~x,data.frame(x=1:10),type="l"))},standalone=TRUE)
        ,xmlSVG({show(ggplot(iris,aes(x=Sepal.Length,y=Sepal.Width,colour=Species))+geom_point())},standalone=TRUE)
        ,xmlSVG({
          print(
            dotplot(variety ~ yield | site , data = barley, groups = year,
                    key = simpleKey(levels(barley$year), space = "right"),
                    xlab = "Barley Yield (bushels/acre) ",
                    aspect=0.5, layout = c(1,6), ylab=NULL)        
          )
        },standalone=TRUE
        )
      )
      ,function(sv){
        paste0(
          "data:image/svg+xml;utf8,"
          ,as.character(sv)
        )
      }
    )
  })

}

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Number of observations:", min = 10, max = 500, value = 100),
      shiny::verbatimTextOutput('current')
      ),
    mainPanel(slickROutput("slick",width='100%',height='200px'))
  )
)

shinyApp(ui = ui, server = server)
