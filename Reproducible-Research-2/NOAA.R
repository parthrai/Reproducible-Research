library(lubridate)
library(ggplot2)
library(cowplot)
library(sqldf)
library(grid)
library(gridExtra)



localDir <- "data"
if (!file.exists(localDir)) {
  dir.create(localDir)
}

## download and unzip the data
url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
file <- paste(localDir,basename(url),sep='/')
if (!file.exists(file)) {
  download.file(url, file)
}
data <- read.csv(file, as.is = TRUE)



data$Year <- year(as.Date(data$BGN_DATE, '%m/%d/%Y'))

fatalities_query <- "select EVTYPE as Event, sum(FATALITIES) as Fatalities from
    data
where
Year >= 1950
group by
EVTYPE
order by
sum(FATALITIES) desc
LIMIT 10"


injuries_query <- "select EVTYPE as Event, sum(INJURIES) as Injuries  from
data
where
Year >= 1950
group by
EVTYPE
order by
sum(INJURIES) desc
LIMIT 10 "

fatalities_ds <-sqldf::sqldf(fatalities_query)
injuries_ds <-sqldf::sqldf(injuries_query)

png("plot1.png",height=600,width=800)

fatalities_plot <- ggplot(fatalities_ds, aes(x = Event, y = Fatalities)) + 
  geom_bar(stat = "identity", fill = "red", las = 2) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  xlab("Event Type") + ylab("Fatalities") + ggtitle("Fatalities for top 10 events") + scale_x_discrete(limits=fatalities_ds$Event)

injuries_plot <- ggplot(injuries_ds, aes(x = Event, y = Injuries)) + 
  geom_bar(stat = "identity", fill = "red", las = 2) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  xlab("Event Type") + ylab("Injuries") + ggtitle("Injuries for top 10 events") + scale_x_discrete(limits=injuries_ds$Event)


grid.arrange(fatalities_plot,injuries_plot,ncol=2)

dev.off()

propdmg_query <- "select EVTYPE as Event, sum(PROPDMG) as PropertyDamage  from data 
  where
    YEAR >= 1950
  group by
    EVTYPE
  order by
    sum(PROPDMG) desc
	LIMIT 10 "

propdmg_ds <-sqldf::sqldf(propdmg_query)

png("plot2.png",height=600,width=800)

ggplot(propdmg_ds, aes(x = Event, y = PropertyDamage)) + 
  geom_bar(stat = "identity", fill = "red", las = 2) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  xlab("Event Type") + ylab("Fatalities") + ggtitle("PROPDMG for top 10 events") + scale_x_discrete(limits=propdmg_ds$Event)


dev.off()
