library(cranlogs)
cranlogs::cran_downloads(from=as.Date("2015-01-01"), to=as.Date("2016-12-06"),
                         packages = "Information") %>%
  ggplot(aes(x=date, y=count)) + geom_line()

sum(cranlogs::cran_downloads(from=as.Date("2015-01-01"), to=as.Date("2017-02-16"),
                             packages = "dplyr")$count)

sum(cranlogs::cran_downloads(from=as.Date("2015-01-01"), to=as.Date("2017-02-16"),
                             packages = "infotheo")$count)