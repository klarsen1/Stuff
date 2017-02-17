
library(lubridate)
library(bsts)
library(dplyr)
library(ggplot2)
library(Boom)
library(reshape2)

### Model setup
Y <- data$Checkout
ss <- AddLocalLinearTrend(list(), Y)
ss <- AddSeasonal(ss, Y, nseasons = 52)
bsts.model <- bsts(Y, state.specification = ss, niter = 500, ping=0, seed=2016)

### Get a suggested number of burn-ins
burn <- SuggestBurn(0.1, bsts.model)

### Extract the components
components <- cbind.data.frame(
  colMeans(bsts.model$state.contributions[-(1:burn),"trend",]),                               
  colMeans(bsts.model$state.contributions[-(1:burn),"seasonal.52.1",]),
  Y,
  as.Date(tsdata$Date, format="%m/%d/%y"))  
names(components) <- c("Trend", "Seasonality", "Actual", "Date")
components <- melt(components, id="Date")
names(components) <- c("Date", "Component", "Value")


### Plot
ggplot(data=components, aes(x=Date, y=Value)) + geom_line(size=1.2) +
  theme_bw() + theme(legend.title = element_blank()) + ylab("") + xlab("") + 
  facet_grid(Component ~ ., scales="free") + guides(colour=FALSE) + 
  theme(axis.text.x=element_text(angle = -90, hjust = 0))
