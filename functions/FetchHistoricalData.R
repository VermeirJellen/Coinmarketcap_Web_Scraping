FetchHistoricalData <- function(
                                first.date   = as.POSIXct("2013-04-28", format="%Y-%m-%d", tz="UTC"),
                                last.date    = as.POSIXct(Sys.Date() - lubridate::days(1), format="%Y-%m-%d", tz="UTC"),
                                nr.top.coins = 10,
                                save.data    = FALSE,
                                load.data    = FALSE){
  
  if (!load.data){
    
    date.range <- seq(first.date, last.date, by="weeks")
    #########################################
    ### FETCH  HISTORICAL MARKET CAP DATA ###
    #########################################
    historical.market.cap <- GetTotalCryptocurrencyMarketCapitalization(first.date = first.date,
                                                                        last.date  = last.date)
    historical.tickers <- GetAllExistingTickers(first.date = first.date,
                                                last.date  = last.date)
    
    ## Todo, there appear to be multiple tickers for the same ticker-id.
    ## XLM/STR | LSK/LISK | ANS/NEO | there could be others..
    stellar     <- "XLM"; names(stellar) <- "id-stellar"
    lisk        <- "LSK"; names(lisk)    <- "id-lisk"
    neo         <- "NEO"; names(neo)     <- "id-neo"
    historical.tickers <- c(historical.tickers, stellar, lisk, neo)
    
    
    
    historical.crypto.series <- GetHistoricalTimeseriesDataForTickers(tickers    = historical.tickers,
                                                                      first.date = first.date,
                                                                      last.date  = last.date)
    ########
    ## todo: In some cases, There exist multiple ticker-id's for the same ticker symbol
    ## ex, ETC corresponds to'id-ethercoin' and 'id-ethereum-classic'
    etc.tickers        <- "ETC"
    names(etc.tickers) <- "id-ethereum-classic"
    etc <- GetWeeklyTimeseriesDataForTickers(tickers    = etc.tickers,
                                             first.date = first.date,
                                             last.date  = last.date)
    
    historical.crypto.series <- cbind(crypto.series, etc)
    historical.top.coins     <- GetHistoricalTopPerformingCoins(nr.top.coins = nr.top.coins,
                                                                first.date   = first.date,
                                                                last.date    = last.date)
    names(top.coins) <- seq(1, ncol(top.coins))
    
    if (save.data){
      saveRDS(date.range,               "data/historical.date.range.rds")
      saveRDS(historical.market.cap,    "data/historical.market.cap.rds")
      saveRDS(historical.tickers,       "data/historical.tickers.rds")
      saveRDS(historical.crypto.series, "data/historical.crypto.series.rds")
      saveRDS(historical.top.coins,     "data/historical.top.coins.rds")
    }
  }
  else {
    date.range               <- readRDS("data/historical.date.range.rds")
    historical.makret.cap    <- readRDS("data/historical.market.cap.rds")
    historical.tickers       <- readRDS("data/historical.tickers.rds")
    historical.crypto.series <- readRDS("data/historical.crypto.series.rds")
    historical.top.coins     <- readRDS("data/historical.top.coins.rds")
  }
  
  return(list(date.range               = date.range,
              historical.tickers       = historical.tickers,
              historical.crypto.series = historical.crypto.series,
              historical.top.coins     = historical.top.coins))
}