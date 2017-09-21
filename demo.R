source("config/Config.R")
#############################
##### FETCHING THE DATA #####
#############################

#######################################
## Fetch historical market cap data ###
#######################################
Sys.setenv(tz = "UTC")
first.date <- as.POSIXct("2013-04-28", format="%Y-%m-%d", tz="UTC")
last.date  <- as.POSIXct(Sys.Date() - lubridate::days(1), format="%Y-%m-%d", tz="UTC")

historical.market.cap <- GetTotalCryptocurrencyMarketCapitalization(first.date = first.date,
                                                                    last.date  = last.date,
                                                                    save.data  = TRUE)

## Loading the data from previously saved .rds file in ./data directory
historical.market.cap <- GetTotalCryptocurrencyMarketCapitalization(load.data = TRUE)


PlotChart <- function(chart.data, zoom="2016/2017", name=NULL){
  chart.alts <- chartSeries(chart.data, 
                            TA   = 'addEMA(n=10, col="yellow");addEMA(n=30, col="red");addMACD()', 
                            name = name, 
                            plot=FALSE)
  zoomChart(zoom)
}

PlotChart(historical.market.cap$alts, zoom="2016/2017", name = "Weekly Altcoin Market Cap")





#######################################
##### Get all existing tickers ########
#######################################
all.historical.tickers <- GetAllExistingTickers(first.date = first.date,
                                                last.date  = last.date,
                                                save.data  = TRUE)

# Loading the data from previously saved .rds file in ./data directory
all.historical.tickers <- GetAllExistingTickers(load.data = TRUE)

# Show amount of unique tickers
length(all.historical.tickers)
# Show first 100
head(all.historical.tickers, 100)

## Todo: In some cases, there exist multiple tickers for the same ticker-id.
## XLM/STR | LSK/LISK | ANS/NEO | there could potentially be others.. (to fix)
stellar <- "XLM"; names(stellar) <- "id-stellar"
lisk    <- "LSK"; names(lisk)    <- "id-lisk"
neo     <- "NEO"; names(neo)     <- "id-neo"
all.historical.tickers <- c(all.historical.tickers, stellar, lisk, neo)





#######################################
##### Fetch weekly timeseries data ####
##### for a list of tickers ###########
#######################################
historical.crypto.series <- GetHistoricalTimeseriesDataForTickers(tickers    = all.historical.tickers,
                                                                  first.date = first.date,
                                                                  last.date  = last.date,
                                                                  save.data  = TRUE)

historical.crypto.series <- GetHistoricalTimeseriesDataForTickers(load.data = TRUE)


dim(historical.crypto.series)

# plot random selection of coin graphs
# note: make sure that data is available for the plotted serires
head(historical.crypto.series[, 1:10])
tail(historical.crypto.series[, 1:10])
chart.it <- sapply(2:9, function(x) PlotChart(historical.crypto.series[,x],
                                              name = names(historical.crypto.series[,x])))

########
## todo: In some cases, There exist multiple ticker-id's for the same ticker symbol
## ex, ETC corresponds to'id-ethercoin' and 'id-ethereum-classic'
# There could potentially be others as well (to fix)
# etc.tickers        <- "ETC"
# names(etc.tickers) <- "id-ethereum-classic"
# etc <- GetWeeklyTimeseriesDataForTickers(tickers    = etc.tickers,
#                                          first.date = first.date,
#                                          last.date  = last.date)
# # add id-ethereum-classic
# historical.crypto.series <- cbind(historical.crypto.series, etc)





###########################################
##### Fetch Top Market Coins Tickers ######
###########################################
nr.top.coins = 10
historical.top.coins <- GetHistoricalTopPerformingCoins(nr.top.coins = 10,
                                                        first.date   = first.date,
                                                        last.date    = last.date,
                                                        save.data    = TRUE)

historical.top.coins <- GetHistoricalTopPerformingCoins(load.data = TRUE)

head(historical.top.coins)
tail(historical.top.coins)