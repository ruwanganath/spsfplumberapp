library(httr)
library(plumber)
library(jsonlite)
library(spdep)
library(dplyr)

#* Echo back the input
#* @param msg The message to echo
#* @get /neighbours
function(long =144.95214133755, latt=-37.807937380447) {
 
  opendatalinkdb <- "https://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json"
  
  sampledata <- GET(url=opendatalinkdb)
  sampledata_text <- content(sampledata,"text")
  onstreetSensorData <- fromJSON(sampledata_text, flatten = TRUE)
  onstreetSensorData <- onstreetSensorData[onstreetSensorData$status == 'Unoccupied',]
  onstreetSensorData <- select(onstreetSensorData,bay_id,lat,lon)
 
  options(digits=16)
  currentLocation.coords <- cbind(as.double(long),as.double(latt))
  
  options(digits=16)
  onstreetSensorData.coords <- cbind(as.double(onstreetSensorData$lon),as.double(onstreetSensorData$lat))
  onstreetSensorData.coords <- rbind(onstreetSensorData.coords,currentLocation.coords)
  
  options(digits=16)
  onstreetSensorData.5nn<-knearneigh(onstreetSensorData.coords, k=5, longlat=TRUE)
  onstreetSensorData.5nn.nb<-knn2nb(onstreetSensorData.5nn)
  
  neighbours <- onstreetSensorData.5nn.nb[NROW(onstreetSensorData.5nn.nb)]
  
  neighboursVector <- c(onstreetSensorData[neighbours[[1]][1],])
  neigboursdf <- data.frame(neighboursVector)
  neighboursVector <- c(onstreetSensorData[neighbours[[1]][2],])
  neigboursdf <- rbind(neigboursdf,neighboursVector)
  neighboursVector <- c(onstreetSensorData[neighbours[[1]][3],])
  neigboursdf <- rbind(neigboursdf,neighboursVector)
  neighboursVector <- c(onstreetSensorData[neighbours[[1]][4],])
  neigboursdf <- rbind(neigboursdf,neighboursVector)
  neighboursVector <- c(onstreetSensorData[neighbours[[1]][5],])
  neigboursdf <- rbind(neigboursdf,neighboursVector)
  list(neighboursList = paste0(toJSON(neigboursdf)))
}