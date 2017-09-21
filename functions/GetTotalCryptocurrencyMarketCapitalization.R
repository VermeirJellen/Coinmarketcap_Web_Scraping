GetTotalCryptocurrencyMarketCapitalization <- function(first.date = as.POSIXct("2013-04-28", format="%Y-%m-%d", tz="UTC"),
                                                         last.date  = as.POSIXct(Sys.Date()-lubridate::days(1), format="%Y-%m-%d", tz="UTC"),
                                                         load.data  = FALSE,
                                                         save.data  = FALSE){
  
  if (load.data){
    historical.market.cap <- readRDS("data/historical.market.cap.rds")
    return(historical.market.cap)
  }
  
  GetHistoricalMarketCapitalizationData <- function(historical.date){
    
    coinmarket.url       <- paste("https://coinmarketcap.com/historical/",
                                  format(historical.date, "%Y%m%d"), sep="")
    coinmarket.page.resp   <- httr::GET(coinmarket.url)
    coinmarket.status.code <- httr::status_code(coinmarket.page.resp)
    
    if(coinmarket.status.code == "200"){
      coinmarket.page <- httr::content(coinmarket.page.resp)
      page            <- htmlParse(coinmarket.page)
      
      total.market.cap <- xpathSApply(doc = page, path = "//span[@id='total-marketcap']", fun = xmlValue)
      total.market.cap <- as.numeric(gsub(",", "", gsub(" ", "", 
                                                        strsplit(total.market.cap, "\\$")[[1]][2])))
      
      btc.market.cap   <- xpathSApply(doc = page, 
                                      path = "//tr[@id='id-bitcoin']//td[@class='no-wrap market-cap text-right']",
                                      fun  = xmlAttrs)
      btc.market.cap   <- as.numeric(btc.market.cap["data-usd", ])
      return(xts(matrix(c(total.market.cap, btc.market.cap), nrow=1), order.by = historical.date))
    }
    else{
      return(NULL)
    }
  }
  
  date.range <- seq(first.date, last.date, by="weeks")
  # Scrape coinmarketcap.com to fetch total historical market cap
  historical.market.cap <- lapply(date.range, GetHistoricalMarketCapitalizationData)
  historical.market.cap <- do.call("rbind", historical.market.cap)
  names(historical.market.cap) <- c("total", "btc")
  
  historical.market.cap$alts <- historical.market.cap$total - historical.market.cap$btc
  
  if (save.data){
    saveRDS(historical.market.cap, "data/historical.market.cap.rds")
  }
  
  return(historical.market.cap)
}