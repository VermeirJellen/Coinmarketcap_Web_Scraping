############################################################################
### Load necessary packages and functions into memory                  #####
############################################################################
# if(!require(installr)) {install.packages("installr"); require(installr)}
# updateR()
packages <- c("timeSeries", "rrcov", "zoo", "xts", "car", "httr", "XML",
              "quadprog", "doParallel", "PerformanceAnalytics", "quantmod")
packages <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x)
    library(x, character.only = TRUE)
  }
})

Sys.setenv(TZ='UTC')

source("functions/ProcessWebPage.R")
source("functions/GetTotalCryptocurrencyMarketCapitalization.R")
source("functions/GetAllExistingTickers.R")
source("functions/GetHistoricalTimeseriesDataForTickers.R")
source("functions/GetHistoricalTopPerformingCoins.R")
source("functions/FetchHistoricalData.R")