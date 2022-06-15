#downloading PRISM data for a givn lat/long using the Data Explorer interface

# library(RCurl)
library(tidyverse)
library(googledrive)
library(readxl)
library(xlsx)
library(sf)
# library(stars)
library(prism)
library(terra)

# point to directory where you want to store output
dumpdir = 'C:/Users/steeleb/Dropbox/EPSCoR/PRISM/'

# authorize google drive
drive_auth()

# enter your email address
email = 'steeleb@caryinstitute.org'

# indicate desired variables (precipitation = 'ppt', minimum daily temp = 'tmin', max temp = 'tmax', mean temp = 'tmean', )
vars = c('ppt', 'tmin', 'tmax', 'tmean')

#indicate years of interest
startyear = 2020
endyear = 2020

# run centroid_setup - point here is to get lat, long, filename into PRISM format
source('centroid_setup.R')

# run extract script -- this can take some time depending on the time frame you are interested it. Go get a coffee.
source('download_extract.R')
