# Scraping the Swadesh list from Wikipedia
### Bodo Winter
### June 7, 2015

### If you do not have the following packages yet, you have to uncomment and run the following code:

# install.packages("RCurl")
# install.packages("XML")
# install.packages("stringr")
# install.packages("openxlsx")

## Set working directory:

setwd("/Users/teeniematlock/Desktop/data_goldrush/")

## Create data directory if it does not exist:

if(!file.exists("data")){
	dir.create("data")
	}

## Set data directory to that folder:

setwd("data")

## Get the Swadesh list from Wikipedia:

library(RCurl)
swadesh = getURL("http://en.wiktionary.org/wiki/Appendix:Swadesh_lists")

## Save the download date in text file:

writeLines(as.character(Sys.time()),"swadesh_download_time.txt")

## Save the download date in text file:

writeLines(text=as.character(Sys.time()),
	"Swadesh_download_time.txt")

## Process the Swadesh list:

library(XML)
swadesh = as.character(readHTMLTable(swadesh)[[2]]$English)

## Extract first word:

library(stringr)
swadesh = str_extract(swadesh,"[a-zA-Z]+")

## Put this into a data frame:

swadesh = data.frame(Word=swadesh)		# we name the column "Word"

## Download the file:

download.file(url="http://crr.ugent.be/papers/SUBTLEX-UK.txt",
	destfile="SUBTLEX-UK.txt",method="curl")

## Save time:

writeLines(text=as.character(Sys.time()),
	"SUBTLEX_download_time.txt")

## Load data in:

SUBTL = read.table("SUBTLEX-UK.txt",sep="\t",quote="",header=T)

## Alternatively, download the Excel file:

# download.file(url="http://crr.ugent.be/papers/SUBTLEX-UK.xlsx",destfile="SUBTLEX-UK.xlsx",method="curl")
# library(openxlsx)
# SUBTL = read.xlsx("SUBTLEX-UK.xlsx",sheetIndex=1,colIndex=1:2)

## Get rid of those that have missing frequency values:

SUBTL = SUBTL[!is.na(SUBTL$FreqCount),]

## Log transform the frequency data:

SUBTL$LogFreq = log(SUBTL$FreqCount)

## Merge frequency data and Swadesh list:

swadesh$LogFreq = SUBTL[match(swadesh$Word,SUBTL$Spelling),]$LogFreq

## Write this into a file:

write.table(swadesh,"swadesh.csv",sep=",",row.names=F)

## Where is the average word frequency of words on the Swadesh list compared to the rest of SUBTLEX?

plot(density(SUBTL$LogFreq))
abline(v=mean(swadesh$LogFreq),col="darkred",lwd=3)

## Let's perform a one-sample t-test of the swadesh frequencies against the mean of the SUBTL frequencies:

t.test(swadesh$LogFreq,mu=mean(SUBTL$LogFreq))

## As expected, the Swadesh list has significantly higher frequency than the rest.


