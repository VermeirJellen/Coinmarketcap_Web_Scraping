GetHistoricalTopPerformingCoins <- function(nr.top.coins = 10,
                                            first.date   = as.POSIXct("2013-04-28", format="%Y-%m-%d", tz="UTC"),
                                            last.date    = as.POSIXct(Sys.Date() - lubridate::days(1), format="%Y-%m-%d", tz="UTC"),
                                            save.data    = FALSE,
                                            load.data    = FALSE){
  
  if (load.data){
    historical.top.coins <- readRDS("data/historical.top.coins.rds")
    return(historical.top.coins)
  }
  
  date.range      <- seq(first.date, last.date, by="weeks")
  historical.top.coins <- list(length(date.range))
  
  for(i in seq_along(date.range)){
    coinmarket.url  <- paste("https://coinmarketcap.com/historical/",
                             format(date.range[i], "%Y%m%d"), sep="")

    coinmarket.page <- htmlParse(.ProcessWebPage(coinmarket.url))
    all.coins.id  <- xpathSApply(doc = coinmarket.page, path = "//tr[contains(@id, 'id-')]", fun = xmlAttrs)["id", ]
    top.coins     <- lapply(all.coins.id[1:min(nr.top.coins, length(all.coins.id))], function(x){ 
                              ticker <- xpathSApply(doc  = coinmarket.page, 
                                            path = paste("//tr[@id='", x, "']//td[@class='text-left']", sep=""),
                                            fun  = xmlValue)
                              return(data.frame(ticker, stringsAsFactors = FALSE))
                            })
      
    top.coins <- do.call("cbind", top.coins)
    historical.top.coins[[i]] <- top.coins
  }
  
  historical.top.coins <- lapply(historical.top.coins, function(x){
    if(ncol(x) < nr.top.coins){
      
      new.columns        <- data.frame(matrix(rep(NA, nr.top.coins-ncol(x)), nrow=1), stringsAsFactors = FALSE)
      new.names          <- rep("ticker", nr.top.coins-ncol(x))
      names(new.columns) <- new.names
      
      x <- cbind(x, new.columns)
    }
    x
  })
  
  historical.top.coins           <- do.call("rbind", historical.top.coins)
  rownames(historical.top.coins) <- date.range
  names(historical.top.coins)    <- seq(1, ncol(historical.top.coins))
  
  if (save.data){
    saveRDS(historical.top.coins, "data/historical.top.coins.rds")
  }
  
  return(historical.top.coins)
}