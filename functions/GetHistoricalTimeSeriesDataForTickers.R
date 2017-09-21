GetHistoricalTimeseriesDataForTickers <- function(tickers, 
                                                  first.date = as.POSIXct("2013-04-28", format="%Y-%m-%d", tz="UTC"), 
                                                  last.date  = as.POSIXct(Sys.Date() - lubridate::days(1), 
                                                                          format="%Y-%m-%d", tz="UTC"),
                                                  save.data  = FALSE,
                                                  load.data  = FALSE){
  
  if (load.data){
    historical.crypto.series <- readRDS("data/historical.crypto.series.rds")
    return(historical.crypto.series)
  }
  
  GetWeeklyDataPoints <- function(historical.date, tickers){
    
    coinmarket.url  <- paste("https://coinmarketcap.com/historical/",
                             format(historical.date, "%Y%m%d"), sep="")
    coinmarket.page <- htmlParse(.ProcessWebPage(coinmarket.url))
    
    series <- vector("list", length(tickers))
    for(i in seq_along(tickers)){
      val <- as.numeric(xpathSApply(doc  = coinmarket.page, 
                                    path = paste("//tr[@id='", names(tickers[i]), 
                                                 "']//td[@class='no-wrap text-right']//a[@data-usd]", sep=""),
                                    fun  = xmlAttrs)["data-usd", ])
      if(length(val) > 0){
        time.series <- xts(matrix(val, ncol=1), order.by = historical.date)
      }
      else {
        time.series <- xts(matrix(NA, ncol=1), order.by = historical.date)
      }
      
      names(time.series) <- as.character(tickers[i])
      series[[i]] <- time.series
    }
    
    series <- do.call("cbind", series)
    return(series)
  }
  
  date.range               <- seq(first.date, last.date, by="weeks")
  historical.crypto.series <- do.call("rbind", 
                                      lapply(date.range, function(x) GetWeeklyDataPoints(x, tickers)))
  
  if (save.data){
    saveRDS(historical.crypto.series, "data/historical.crypto.series.rds")
  }
  return(historical.crypto.series)
}