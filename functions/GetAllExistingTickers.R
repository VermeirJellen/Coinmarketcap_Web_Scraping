
# Note: it's missing STR due to 
GetAllExistingTickers <- function(first.date = as.POSIXct("2013-04-28", format="%Y-%m-%d", tz="UTC"),
                                  last.date = as.POSIXct(Sys.Date() - lubridate::days(1), format="%Y-%m-%d", tz="UTC"),
                                  load.data = FALSE,
                                  save.data = FALSE){
  
  if (load.data){
    historical.tickers <- readRDS("data/historical.tickers.rds")
    return(historical.tickers)
  }
  
  GetExistingTickersOnHistoricalDate <- function(historical.date){
    
    coinmarket.url  <- paste("https://coinmarketcap.com/historical/",
                             format(historical.date, "%Y%m%d"), sep="")
    
    coinmarket.page <- htmlParse(.ProcessWebPage(coinmarket.url))
    all.coins.id    <- xpathSApply(doc  = coinmarket.page, 
                                   path = "//tr[contains(@id, 'id-')]", fun = xmlAttrs)["id", ]
    
    tickers <- sapply(all.coins.id, function(x){ 
      xpathSApply(doc  = coinmarket.page, 
                  path = paste("//tr[@id='", x, "']//td[@class='text-left']", sep=""),
                  fun  = xmlValue)})
    return(tickers)
  }
  
  date.range  <- seq(first.date, last.date, by="weeks")
  historical.tickers <- unlist(lapply(date.range, GetExistingTickersOnHistoricalDate))
  historical.tickers <- historical.tickers[!duplicated(names(historical.tickers))]
  
  if (save.data){
    saveRDS(historical.tickers, "data/historical.tickers.rds")
  }
  
  return(historical.tickers)
}