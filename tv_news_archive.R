## Bodo Winter
## January 19, 2015
## Downloading of "high number" data:

## Preliminaries:

setwd("/Users/teeniematlock/Desktop/my_courses/data_goldrush/scripts/")
if(!file.exists("data")){
     dir.create("data")
}
setwd("data")

library(RCurl)
library(jsonlite)
library(stringr)

## Externally, check how many TV News Archive articles there are for "high number" right now
## it is actually 6558 but let's do "200" for now so that everything runs quicker:

high_max <- 200

## Create an identifier that goes from 0 to the maxima, the search pages go in steps of 50:

high_start_id <- seq(50,high_max,50)

## Create download links from this information:

high_start_url <- c("http://archive.org/details/tv?q=%22high%20number%22&output=json",
	paste("http://archive.org/details/tv?q=%22high%20number%22&output=json&start=",high_start_id,sep=""))

## Create empty list for storing data:

results <- vector(length(high_start_url),mode="list")

## Download the files into the folders, high number:

for(i in 1:length(high_start_url)){
     results[[i]] <- getURL(high_start_url[i])
	Sys.sleep(1)		# build in delay
     
     ## Where are you at:
     
     cat(paste(i,"\n"))
	}

## Save download data and time:

writeLines(date(),"high_number_downloadDate.txt")

## Process JSON:

bigtable <- c()
for(i in 1:length(results)){
     bigtable <- rbind(bigtable,fromJSON(results[[i]]))
}

## Select a random subset, let's do four videos for now:

set.seed(42)
ids <- sample(1:nrow(bigtable),4)
video_selection <- bigtable[ids,]

## Download the videos based on the column "video":

for(i in 1:nrow(video_selection)){
     download.file(video_selection[i,]$video,
                   destfile=paste(video_selection[i,]$identifier,"mp4",sep="."))
     Sys.sleep(1)		# build in delay     
     cat(paste(i,"\n"))
}

## You successfully downloaded 4 files! Now, chances are that your word is not actually contained in there
## This is because the TV News Archive has a little bit of uncertianty surrounding the time stamps for each search term
## If this turns out to be a problem, you need to grep the time stamps out of the links and change them




