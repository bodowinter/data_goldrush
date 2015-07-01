## Bodo Winter
## June 30, 2015
## Very simple Type I error demo

## Load linear mixed effects model library:

library(lme4)

## Define number of items, number of subjects and number of simulated experiments:

nitems <- 10
nsub <- 10
nsim <- 1000

## Create condition identifiers for 10 items, 5 for each of two conditions:

condition <- gl(2,nitems/2)

## Repeat these condition identifiers for how many subjects there are (each subject sees 10 items):

condition <- rep(condition,nsub)

## Create 10 unique subject identifiers:

subjects <- gl(nsub,nitems)

## Create 10 unique item identifiers:

items <- rep(gl(nitems,1),nsub)

## Let's demonstrate four different analysis methods:
## Create results vectors for subjects-analysis, items-analysis,
## ignoring independence assumption (pseudoreplication) and mixed model (intercept only)

allres.subjects <- numeric(nsim)
allres.items <- numeric(nsim)
allres.ignore <- numeric(nsim)
allres.mixed <- numeric(nsim)

## Loop through how many simulations there are:

for(i in 1:nsim){
	
	## Generate 10 unique item values and 10 unique subject values:	
	
     unique_items <- rnorm(nitems)
     unique_subs <- rnorm(nsub)
     
     ## The response are those values repeated and trial-level error:
     
     resp <- unique_items[items] + unique_subs[subjects] + rnorm(nsub*nitems)
     
     ## Subjects analysis (averaging over subjects):

     subj_aggregate <- aggregate(resp ~ unique_subs[subjects]*condition,FUN=mean)
     allres.subjects[i] <- t.test(resp ~ condition,subj_aggregate,paired=T)$p.val
     
     ## Items analysis (averaging over items):

     item_aggregate <- aggregate(resp ~ unique_items[items]*condition,FUN=mean)
     allres.items[i] <- t.test(resp ~ condition,item_aggregate,paired=F)$p.val
     
     ## Pseudoreplication:
     
     allres.ignore[i] <- t.test(resp ~ condition,paired=F)$p.val
     
     ## Mixed model:
     
     xmdl <- lmer(resp ~ condition + (1|subjects) + (1|items))
     allres.mixed[i] <- summary(xmdl)$coefficients[2,'t value']
     
     ## Tell the outside world where you are at:
     
     if(i %% 200 == 0){
     	print(i)
     	}
}

## The number of significant results by the number of simulations gives the Type I error rate
## (since there we know that any effect can only be due to sampling error)

sum(allres.subjects<0.05)/nsim
sum(allres.items<0.05)/nsim
sum(allres.ignore<0.05)/nsim
sum(abs(allres.mixed)>2)/nsim			# here, we treat |t|>2 as significant

## Recreate the plot that's on the class slides:

quartz("",8,6);par(mai=c(1,1.5,1.5,0.5))
plot(1,1,xlim=c(0.5,5),ylim=c(0,1),
	xlab="",ylab="",xaxt="n",yaxt="n",type="n",bty="n",xaxs="i",yaxs="i")
axis(side=2,at=seq(0,1,0.25),las=2,font=2,cex.axis=1.25,lwd=3)
mtext(side=2,text="Type I error rate",line=4,font=2,cex=2)
rect(xleft=1,xright=2,ybottom=0,ytop=sum(allres.items<0.05)/nsim,
	col="goldenrod3",border=NA)
axis(side=1,at=1.5,labels="accounting for\nindependence",cex.axis=1.25,line=0.5,font=2,tick=FALSE)
rect(xleft=2.25,xright=3.25,ybottom=0,ytop=sum(allres.ignore<0.05)/nsim,
	col="darkred",border=NA)
axis(side=1,at=2.75,labels="ignoring\nindependence",cex.axis=1.25,line=0.5,font=2,tick=FALSE)



