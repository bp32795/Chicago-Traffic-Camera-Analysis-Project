#Brandon Menke & Zac Doyle
#Project
#Oct 22, 2018

#Clear Environment
rm(list = ls())

#Clear Console
cat("\014")  

#load librarys
library(ggplot2)
library(rvest)
library(dplyr)
library(scales)
library(ggmap)
library(jtools)
#Read in tables

#This is commented out due to time constraints.\
#It works, but it takes a while to download so I have the complete massaged data set
#read in elsewhere in the script

# url <- "https://s3.us-east-2.amazonaws.com/dataforgradproject/"
# print("Reading Red Light CSV")
# red_vio <- read.csv(paste(url,'red-light-camera-violations.csv', sep = ""),na.strings = c("NA",""))
# print("Reading Speed CSV")
# spe_vio <- read.csv(paste(url, "speed-camera-violations.csv", sep = ""),na.strings = c("NA",""))
# 
# 
# #add columns
# print("Adding Columns")
# spe_vio$TYPE <- "Speed"
# red_vio$TYPE <- "Red"
# 
# #remove intersection
# red_vio$INTERSECTION <- NULL
# 
# #reorder columns
# red_vio <- red_vio[,c(2,1,3,4,5,6,7,8,9,10)]
# 
# #combine tables
# print("combine Tables")
# vio <- rbind(red_vio[complete.cases(red_vio),],spe_vio[complete.cases(spe_vio),])
# 
# #create "districts"
# print("Starting Districts")
# for(i in 1:nrow(vio)){
#   if(vio$LONGITUDE[i] < mean(vio$LONGITUDE)){
#     vio$EastWest[i] <- "West"
#   }else if(vio$LONGITUDE[i] > mean(vio$LONGITUDE)){
#     vio$EastWest[i] <- "East"
#   }else{
#     vio$EastWest[i] <- "Central"
#   }
# 
#   if(vio$LATITUDE[i] > mean(vio$LATITUDE)){
#     vio$NorthSouth[i] <- "North"
#   }else if(vio$LATITUDE[i] < mean(vio$LATITUDE)){
#     vio$NorthSouth[i] <- "South"
#   }else{
#     vio$NorthSouth[i] <- "Central"
#   }
#   vio$District[i] <- paste(vio$NorthSouth[i],vio$EastWest[i], sep = "-")
# 
#   #Clear Console
#   cat("\014")
#   print(paste("Camera ",vio$CAMERA.ID[i], " is in the ",vio$District[i]," district.", nrow(vio)-i, " cameras left to classify.", sep = "" ))
# }




#comment out this when using full script.
vio <- read.csv("vio.csv")

#change date
vio$VIOLATION.DATE <- as.Date(vio$VIOLATION.DATE)

#create year column
vio$YEAR <- format(as.Date(vio$VIOLATION.DATE, format="%d/%m/%Y"),"%Y")
#Create Month Column
vio$MONTH <- format(as.Date(vio$VIOLATION.DATE, format="%d/%m/%Y"), "%m")
#Create Column referencing the day of the month
vio$DAYOFMONTH <- format(as.Date(vio$VIOLATION.DATE, format="%d/%m/%Y"), "%d")
#Create Day of Week Column
vio$DAYOFWEEK <- as.factor(weekdays(as.Date(vio$VIOLATION.DATE, format='01-01-2009', '%d-%m-%Y')))
vio$DAYOFWEEK <- factor(vio$DAYOFWEEK, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday", "Sunday"))


#create maps
print("Getting google map..")
chicago <- get_googlemap(center = c(lon = mean(vio$LONGITUDE), lat = mean(vio$LATITUDE)), zoom = 11, maptype = "roadmap", key = "AIzaSyCkxmxO7e_vwokUyYRB1uzViLoBIDyXF-E")
chicago <- ggmap(chicago)

#function
make.map <- function(TypeOfCamera = "", NumOfViolations = "", df = vio){
  if(TypeOfCamera != "" && NumOfViolations == ""){
    dots <- geom_point(aes(x = LONGITUDE, y = LATITUDE, color = TypeOfCamera), data = df, alpha = .5)
    return(chicago + dots)  
  }
  else if(TypeOfCamera == "" && NumOfViolations != ""){
    dots <- geom_point(aes(x = LONGITUDE, y = LATITUDE, size = NumOfViolations), data = df, alpha = .5)
    return(chicago + dots)   
  }
  else if(TypeOfCamera != "" && NumOfViolations != ""){
    dots <- geom_point(aes(x = LONGITUDE, y = LATITUDE, color = TypeOfCamera, size = NumOfViolations), data = df, alpha = .5)
    return(chicago + dots)
  }
  else{
    return("Function requires color or size to operate.")
  }
  
}


#draw
png("districts.png", res = 72*4, width = 2000, height = 2000)
print("Printing District Map")
make.map(TypeOfCamera = vio$District)
dev.off()

png("type.png", res = 72*4, width = 2000, height = 2000)
print("Printing Type Map")
make.map(vio$TYPE)
dev.off()

png("violations.png", res = 72*4, width = 2000, height = 2000)
print("Printing Violations Map")
make.map("", vio$VIOLATIONS)
dev.off()

png("typeandviolations.png", res = 72*4, width = 2000, height = 2000)
print("Printing Type and Violations Map")
make.map(vio$TYPE, vio$VIOLATIONS)
dev.off()

#create charts for violations vs type
typeBar <- qplot(vio$TYPE, stat = vio$VIOLATIONS, fill = vio$TYPE, geom = "bar")
typeBar <- typeBar + scale_y_continuous(labels = comma)
png("typeandviolationsBar.png", res = 72*4, width = 2000, height = 2000)
typeBar
dev.off()

#create Type Bar
typeBarr <- qplot(vio$TYPE, fill = vio$TYPE, geom = "bar")
typeBarr <- typeBar + scale_y_continuous(labels = comma)
png("typeBar.png", res = 72*4, width = 2000, height = 2000)
typeBarr
dev.off()
   
#create chart comparing days
days <- qplot(vio$DAYOFWEEK, stat = vio$VIOLATIONS, geom = "bar", fill = vio$TYPE)
png("typeandviolationsDays.png", res = 72*4, width = 2000, height = 2000)
days
dev.off()

#create chart for violations in certain districts
png("DistrictBar.png", res = 72*4, width = 2000, height = 2000)
districtBar <- qplot(vio$District, stat = vio$VIOLATIONS, geom = "bar", fill = vio$TYPE)
districtBar
dev.off()

#make linear model
linearModel <- lm(VIOLATIONS ~ TYPE + District, data = vio)
print("Making Linear Model")
sink("LinearModel.txt", append = F, split = F)
summ(linearModel)
closeAllConnections()

#sum of violations per camera per type
speed <- subset(vio, TYPE == "Speed")
red <- subset(vio, TYPE == "Red")
perSpeed <- sum(speed$VIOLATIONS)/length(speed)
perRed <- sum(red$VIOLATIONS)/length(speed)

sink("TicketsPerCamera.txt", append = F, split = F)
print(paste("Speed cameras had ", perSpeed, " tickets per camera, and Red Light Cameras had ", perRed, " tickets per camera."))
closeAllConnections()

