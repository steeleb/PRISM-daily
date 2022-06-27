#downloading PRISM data for a givn lat/long using the Data Explorer interface

# library(RCurl)
library(tidyverse)
library(googledrive)
library(readxl)
library(xlsx)
library(sf)
library(prism)
library(terra)
library(lubridate)

# point to directory where you want to store output
dumpdir = 'C:/Users/steeleb/Dropbox/EPSCoR/PRISM/'

#### STOP HERE AND AUTHORIZE GOOGLEDRIVE ####
# authorize google drive
drive_auth()
#### -------------------------------------------- ####

# indicate desired variables (precipitation = 'ppt', minimum daily temp = 'tmin', max temp = 'tmax', mean temp = 'tmean', )
vars = c('ppt', 'tmin', 'tmax', 'tmean')

#indicate years of interest
startyear = 2000
endyear = 2021

#indicate multisite identifier for datafile
sitefile = 'CrossSiteGloeo'

# run centroid_setup - point here is to get lat, long, filename into PRISM format as 'cent_file'
source('centroid_setup.R')

# run extract script -- this can take some time depending on the time frame you are interested it. Go get a coffee. 
#For each year and variable it's about 20 minutes.
source('download_extract.R')

#run clean up script -- this also saves to the shared drive
source('cleanup.R')

