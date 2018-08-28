!diagnostics off 

setwd("/Users/thirdlovechangethisname/Documents/Map")

require(rgdal)
require(gpclib) 
require(maptools) # make sure rgeos is not available when loading maptools
require(jsonlite)
require(magrittr)
require(dplyr)
require(ggplot2)
require(Cairo)
require(scales)

library(cleangeo)
library(mapproj)
library(tidyverse)

# use gpclib because of bugs in rgeos
#gpclibPermit()

# read in map polygons from file
map = readOGR("nielsentopo.json","nielsen_dma")

#are the geo's valid?
rgeos::gIsValid(map) #returns FALSE
map <- rgeos::gBuffer(map, byid = TRUE, width = 0) #fix self intersection

#correct invalid geographies - https://cran.r-project.org/web/packages/cleangeo/vignettes/quickstart.html
report <- clgeo_CollectionReport(map)
clgeo_SummaryReport(report)

map.clean <- clgeo_Clean(map)

report.clean <- clgeo_CollectionReport(map.clean)
clgeo_SummaryReport(report.clean)

rgeos::gIsValid(map.clean) #returns TRUE

# fortify
map_df <- fortify(map.clean, region = "id") %>% 
  tbl_df() %>%
  mutate(dma=as.integer(id))

# read in toposjon as plain json file for data
json_full <- fromJSON("nielsentopo.json")
properties <- json_full$objects$nielsen_dma$geometries$properties %>%
  tbl_df() %>%
  select(dma, dma_name=dma1) %>%
  mutate(dma_name=gsub("\\s*\\([^\\)]+\\)", "",dma_name , perl=T)) %>%
  mutate(dma_name=gsub("Ft.", "Fort", dma_name, perl=T)) %>%
  rename(dma_cd=dma) %>% 
  arrange(dma_name) %>%
  rename(dma=dma_name)

# read stats data
stats <- read_csv("market_pen.csv") %>%
  filter(!grepl("AK",dma)) %>%
  filter(!grepl("HI",dma)) %>%
  arrange(dma)

# put dma codes on stats data
dma_raw <- read_csv("dma_dummy.csv")
stats <- merge(x = stats, y = dma_raw, by = "dma", all.x = TRUE)

# join stats and properties
dma_data <- merge(x = properties, y = stats, by = "dma_cd", all.x = TRUE)

# rename dma to dma_cd for merge
map_df$dma_cd <- map_df$dma
# join map, map properties and penetration 
plot_df <- merge(x = map_df, y = dma_data, by = "dma_cd", all.x = TRUE)

# plot map
p1 <- ggplot()
p1 <- p1 + geom_map(data=plot_df, map=map_df,
                    aes(map_id=id, x=long, y=lat, group=group, fill=mkt_pen_pct/100),
                    color="white", size=0.25)
p1 <- p1 + coord_map()
p1 <- p1 + labs(x="", y="")
p1 <- p1 + theme_bw()
p1 <- p1 + theme(panel.grid=element_blank())
p1 <- p1 + theme(panel.border=element_blank())
p1 <- p1 + theme(axis.ticks=element_blank())
p1 <- p1 + theme(axis.text=element_blank())
p1 <- p1 + scale_fill_gradient(low='gray88', high='royalblue4', labels=percent)
p1 <- p1 + theme(legend.title=element_blank())
