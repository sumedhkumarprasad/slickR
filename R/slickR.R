#' @title slick.js image carousel htmlwidget
#'
#' @description use slick.js library in R
#' @param obj character, vector of path or url to images
#' @param slideId character, id of slide
#' @param slideIdx list, numeric indices which images are mapped to which slider
#' @param objLinks character, links to attach to images in slide
#' @param slideType character, type of object to put in slide
#' @param synchSlides data.frame, rowwise pairs of slideId names of sliders are synchronized
#' @param slickOpts list, attributes for each slider, see details
#' @param dotObj list, character vectors of url or images to replace dots with (see details)
#' @param padding character, percent of width between each image in the carousel for each slider, Default: '1\%'
#' @param width character, width of htmlwidget
#' @param height character, height of htmlwidget
#' @param elementId character, id tag of htmlwidget
#' @import htmlwidgets
#' @details slick.js \url{http://kenwheeler.github.io/slick/} is an image carousel javascript library. To find all the attributes
#' that can be used please refer to the link. To create more than one carousel input the attributes into a nested list eg 
#' slickOpts=list(list(slidesToShow=1,slidestoScroll=1,arrows=F,fade=T),
#' list(slidesToShow=3,slidesToScroll=1,dots=T,focusOnSelect=T,centerMode=T)). It is possible to synchronize the slides
#' through the slickOpts calls, using asNavFor attribute. To replace the dots with icons use the dotObj argument to pass in the icon
#' images and in the slickOpts add a customPaging attribute with the appropriate JS(.) function call. The slideType accepts the type 
#' of html DOM you want to be in the slide, eg img, iframe.  
#' 
#' @examples 
#' \donttest{
#' 
#' nba=c("ATL","BKN","BOS","CHA","CHI","CLE","DAL","DEN","DET","GSW",
#' "HOU","IND","LAC","LAL","MEM","MIA","MIL","MIN","NOP","NYK",
#' "OKC","ORL","PHI","PHX","POR","SAC","SAS","TOR","UTA","WAS")
#' 
#' url <- 'https://i.cdn.turner.com/nba/nba/.element/img/4.0/global/logos/512x512/bg.white/svg'
#' 
#' nba_logos <- 
#' sprintf("%s/%s.svg", url, nba)
#' 
#' if(interactive()) 
#'   slickR(obj=nba_logos)
#' }
#'
#' # synching 3 groups
#' 
#' # creating groups
#' sx1 <- as.numeric(grepl('C',nba_logos,ignore.case = FALSE))
#' sx2 <- as.numeric(grepl('D',nba_logos,ignore.case = FALSE))*2
#' sx3 <- sx1 + sx2
#' 
#' # split into list of size 3
#' sIdx <- lapply(split(nba_logos,sx3),function(x) match(x,nba_logos))
#' 
#' # synching logic (a,b) and (a,c)
#' groups <- expand.grid(list('a',c('b','c')),stringsAsFactors = FALSE)
#' 
#' if(interactive()){ 
#' slickR(obj = nba_logos,
#'        slideId = c('a','b','c'),
#'        slideIdx = sx,
#'        slideType = rep('img',3),
#'        synchSlides = groups,
#'        height = 100)
#' }
#'
#' @import htmlwidgets 
#' @export
slickR <- function(obj ,
                   slideId='baseDiv',
                   slideIdx=list(1:length(obj)),
                   objLinks=c(1:length(obj)),
                   slideType=c('img'),
                   slickOpts=list(dots=TRUE),
                   synchSlides=NULL,
                   padding=rep('1%',length(obj)),
                   dotObj=NULL,
                   width = NULL, 
                   height = NULL,
                   elementId = NULL) {

  
  if(!is.character(obj)) stop('obj must be a character vector')
  
  obj <- lapply(obj,function(x){
    if(!grepl('www[.]|http|https|data:image/|body|^<p',x)) x <- readImage(x)
    x
  })
  
  if(length(slideId)!=length(slideIdx)) slideId=paste0('baseDiv',1:length(slideId))
  
  x = vector('list',length(slideIdx))
  
  for(xId in 1:length(x)){
    
    if(length(x[[xId]]$obj)>1) x[[xId]]$obj=unlist(x[[xId]]$obj)
    
    x[[xId]]$divName <- slideId[xId]
    x[[xId]]$links <- objLinks[xId]
    x[[xId]]$divType <- slideType[[xId]]
    x[[xId]]$padding <- paste0(100-as.numeric(gsub('%','',padding[[xId]])),'%')
    
    if(slideType[[xId]]=='p')
      obj[slideIdx[[xId]]] <- gsub('^<p>|</p>$','',obj[slideIdx[[xId]]])
    
    x[[xId]]$obj <- obj[slideIdx[[xId]]]
    
    if(length(slickOpts)>0){
      if(all(sapply(slickOpts,class)=='list')){
        sOL <- slickOpts[[xId]]
      }else{
        sOL <- slickOpts
      } 

      if(!is.null(synchSlides)){
        for(j in 1:2){
          
          ss <- synchSlides[,c(1:2)[j]]%in%slideId[xId]
          
          if(any(ss)){
            sOL$asNavFor <- paste0(sprintf(".%s",synchSlides[ss,c(1:2)[-j]]),collapse = ',')
          }
          
        }
      }
        
      
      if(!is.null(dotObj)) x[[xId]]$dotObj <- dotObj
      
      if(!is.null(sOL[[1]])) x[[xId]]$slickOpts <- sOL
    }
  }

  # forward options using x
  
  # create widget
  hw <- htmlwidgets::createWidget(
    name = 'slickR',
    x,
    width = width,
    height = height,
    package = 'slickR',
    elementId = elementId
  )
  
  style_widget(hw=hw, "margin-left:auto;margin-right:auto")
}

#' Shiny bindings for slickR
#'
#' Output and render functions for using slickR within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a slickR
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name slickR-shiny
#'
#' @export
slickROutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'slickR', width, height, package = 'slickR')
}

#' @rdname slickR-shiny
#' @export
renderSlickR <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, slickROutput, env, quoted = TRUE)
}