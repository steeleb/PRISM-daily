# script to grap prism data using r package prism; extracting values from each

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

#make datelist to iterate over
monthlist <- seq.Date(as.Date(paste0(startyear, '-01-01')), as.Date(paste0((endyear+1), '-01-01')), by = 'month')
alldata <- data.frame('')

#locs as Sf
locs <- st_as_sf(cent_file, crs = 'EPSG:4326',coords = c('CentroidLongDD', 'CentroidLatDD'))

for(i in 1:(length(monthlist)-1)){
  for(k in 1:length(vars)) {
    #create a new tmp directory each time
    tmp = 'tmp'
    dir.create(tmp)
    
    prism_set_dl_dir(tmp)
    
    # get_prism_dailys(
    #   type = vars[k],
    #   minDate = monthlist[i],
    #   maxDate = monthlist[i+1],
    #   keepZip = F
    # )
    
    #get list of files
    filelist <- list.dirs(tmp)
    filelist <- filelist[grepl('PRISM', filelist)]
    
    #get bil file anme
    filelist_bil <- paste0(substr(filelist, 4, nchar(filelist)), '.bil')
    
    for(j in 1:length(filelist)){
      #read in bil file as raster
      p_ras <- rast(file.path(filelist[j], filelist_bil[j]))
      
      #extract data from prism locs
      vals <- extract(p_ras, 
              vect(locs))
      colnames(vals) = c('rowid', vars[k])
      
      PRISM_locs <- PRISM_locs %>% 
        rowid_to_column('rowid')
      
      data <- merge(PRISM_locs, vals)
      
      data$date = as.Date(substr(substrRight(filelist_bil[j], 16), 1, 8), format = '%Y%m%d')
      
      alldata <- merge(alldata, data) 
    }
  }
  
  unlink(tmp)
  
}
