## Bodo Winter
## March 25, 2015; Adapted for class July 1, 2015
## Scraping semantic shifts from http://semshifts.iling-ran.ru/

## Load libraries:

library(RCurl)
library(XML)
library(stringr)

## Set working directory:

setwd("/Users/teeniematlock/Desktop/my_courses/data_goldrush/scripts/")
if(!file.exists("data")){
	dir.create("data")
	}
setwd("data")

## Create a list of links; for illustration purposes, we will only do the pages 1:50
## If you want to download the complete data, you need to specify "1:3690":

URLs <- paste("http://semshifts.iling-ran.ru/semantic-shifts/show.html?id=",1:50,sep="")

## Create an empty list, each one will contain the corresponding link:

scraped_pages <- vector(length(URLs),mode="list")

## Fill the list with the downloaded URLs:

for(i in 1:length(scraped_pages)){
    scraped_pages[[i]] <- getURL(URLs[i])
    if(i %% 100 == 0){
	    cat(paste(i,"\n",sep=""))
	    }
}

## Save the date:

writeLines(date(),"semantic_shifts_download_date.txt")

## Save the list of objects as an R data frame:

save(scraped_pages,file="semantic_shifts_raw_data.RData")

## Create a dataframe with empty columns:

xdata <- data.frame(ID=1:length(scraped_pages))

## Add the polysemy/derivation/cognate information into it:

xdata$Polysemy <- sapply(scraped_pages,FUN=function(x)str_count(x,"Polysemy"))
xdata$Derivation <- sapply(scraped_pages,FUN=function(x)str_count(x,"Derivation"))
xdata$Cognates <- sapply(scraped_pages,FUN=function(x)str_count(x,"Cognates"))

## Load in the detailed info about the shift:

major_info <- c()
for(i in 1:length(scraped_pages)){
	major_info <- rbind(major_info,readHTMLTable(scraped_pages[[i]])[[1]])
	if(i %% 10 == 0){cat(paste(i,"\n",sep=""))}
	}

## Let's combine that:

xdata = cbind(major_info,
              xdata[match(major_info$ID,xdata$ID),c("Polysemy","Derivation","Cognates")])

## Let's write the file to our computer:

write.table(xdata,"semantic_shifts.csv",row.names=F,sep=",")

## This is not cleaned yet... but we got the file now!



