## Bodo Winter
## June 9, 2015; Adapted July 1, 2015
## Download concordances of verbs from http://www.lextutor.ca/conc/eng/

## Set working directory:

setwd("/Users/teeniematlock/Desktop/my_courses/data_goldrush/scripts/")
if(!file.exists("data")){
	dir.create("data")
	}
setwd("data")

## Packages:

library(XML)
library(xlsx)
library(RCurl)

### Create a list of search terms, in this case only the verbs "see" and "hear":

searchterms <- c("taste","smell")  # just two for example; expand to include more

### Create link pieces (this is based on looking at the structure of one initial search):

firstpiece <- "http://lextutor.ca/cgi-bin/conc/wwwassocwords.pl?lingo=English&unframed=true&SearchType=equals&SearchStr="
lastpiece <- "&Corpus=BNC_Spoken.txt&ColloSize=1&SortType=left&LineWidth=120&Maximum=9999&Gaps=no_gaps&Fam_or_Word=word&AssocWord=&Associate=left&ScanWidth=5&ScanFreq=4"

### Paste link pieces together with search terms:

URLs <- paste(paste(firstpiece,searchterms,sep=""),lastpiece,sep="")

### Download files:

results <- vector(length(searchterms),mode="list")
for(i in seq(along=searchterms)){
     ## Download:
     
     xtemp <- getURL(URLs[i])
     
     ## Extract relevant table and convert to character:
     
     results[[i]] <- as.character(unlist(readHTMLTable(xtemp)[[2]]))

     ## Tell the outside world where you are at:
     
     cat(paste(paste("Finished ...",i),"\n",sep=""))     
}

## Save the download date:

writeLines(date(),"BNC_speech_concordance_download_date.txt")

## Clean this:

for(i in seq(along=searchterms)){
     ## Get rid of that weird letter:
     
     xtemp <- gsub("Â","",results[[i]])
     
     ## Split by carriage return:
     
     xtemp <- strsplit(xtemp,split="\n")[[1]][-c(1,2)]
     
     ## Put into dataframe:
     
     results[[i]] <- data.frame(concordances=xtemp)
}

## My collaborator wants these as Excel table, so let's write each list element to a table:

for(i in seq(along=searchterms)){
     write.xlsx(results[[i]],file=paste(searchterms[i],"xlsx",sep="."),
                row.names=F)
}



