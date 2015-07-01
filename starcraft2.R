## Bodo Winter
## June 7, 2015; Last Edit June 29, 2015
## Download starcraft 2 tournament data

## As in the other tutorial, set the working directory and create data folder:

setwd("/Users/teeniematlock/Desktop/my_courses/data_goldrush/scripts/")
if(!file.exists("data")){
	dir.create("data")
	}
setwd("data")

## Load XML library:

library(XML)
library(RCurl)
library(stringr)

## Download data:

sc2 <- getURL("http://wiki.teamliquid.net/starcraft2/Major_Tournaments")

## Save download date:

writeLines(date(),"sc2_download_date.txt")

## Parse HTML:

sc2 <- htmlTreeParse(sc2,useInternal=T)

## Extract HTML tables:

sc2tab <- readHTMLTable(sc2)

## Check structure:

str(sc2tab)

## These are the meaningful ones, we can safely ignore "1", "5" and "8":

sc2tab[[2]]			# 2015, heart of the swarm
sc2tab[[3]]			# 2014, heart of the swarm
sc2tab[[5]]			# 2013, wings of liberty (people transitioned to heart of the swearm)
sc2tab[[4]]			# 2013, heart of the swarm
sc2tab[[6]]			# 2012, wings of liberty
sc2tab[[7]]			# 2011, wings of liberty

## Get rid of the marginal years and the first erroneous table:

sc2tab <- sc2tab[-c(1,5,8)]

## Cycle through the list and get the prize money for each year:

years <- rep(2015:2011,times=sapply(sc2tab,nrow))			# repeat by row length
prizes <- data.frame(Year=years)

## Create empty prize, winner and player columns:

prizes$Prize <- ""
prizes$Winner <- ""
prizes$Players <- ""

## Cycle through the list sc2tab and extract the prize pools and winners:

for(i in 1:length(sc2tab)){
	prizes[prizes$Year == (2015:2011)[i],]$Prize <- as.character(sc2tab[[i]]$'Prize Pool')
	prizes[prizes$Year == (2015:2011)[i],]$Winner <- as.character(sc2tab[[i]]$'Winner')
	prizes[prizes$Year == (2015:2011)[i],]$Players <- as.character(sc2tab[[i]]$'P#')
	}

## Focus on dollars (exclude the other currencies):

prizes <- prizes[grep("\\$",prizes$Prize),]

## Extract only the numbers:

prizes$Prize <- str_extract(prizes$Prize,"[0-9]+.[0-9]+")

## Delete the commata:

prizes$Prize <- str_replace(prizes$Prize,",","")

## Make numeric:

prizes$Prize <- as.numeric(prizes$Prize)

## Plot money by year using ggplot:

library(ggplot2)
ggplot(prizes,
	aes(x=Year,y=Prize,fill=as.factor(Year))) + geom_boxplot() + scale_fill_brewer()

## Let's test whether there is a significant decrease in prize money:

summary(lm(Prize ~ Year,prizes))		# yes

## Is there a correlation between prize money and the number of players who played in the tournament?

prizes$Players <- as.numeric(prizes$Players)
ggplot(prizes,
	aes(x=Prize,y=Players)) + geom_point(shape=16)		# not really

## Look at money by player:

xagr <- aggregate(Prize ~ Winner,prizes,sum)
xagr

## Who has won the most money?

xagr[which.max(xagr$Prize),]
		
## Who has won the most games?		

which.max(table(prizes$Winner))

