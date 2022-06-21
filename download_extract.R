# script to grap prism data using r package prism; extracting values from each

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

#make a year list to save files
yearlist = seq(startyear, endyear, by = 1)

#locs as Sf
locs <- st_as_sf(cent_file, crs = 'EPSG:4326',coords = c('CentroidLongDD', 'CentroidLatDD'))
 
for(z in 1:length(yearlist)){
  message('Beginning processing for ', yearlist[z])
  #make datelist to iterate over
  monthlist <- seq.Date(as.Date(paste0(yearlist[z], '-01-01')), as.Date(paste0((yearlist[z]+1), '-01-01')), by = 'month')
  for(i in 1:(length(monthlist)-1)){
    message('Working on month beginning ', monthlist[i])
    for(k in 1:length(vars)) {
      message('Accessing variable ', vars[k])
      #create a new tmp directory each time
      tmp = 'tmp'
      dir.create(tmp)
      #point to directory for PRISM download
      prism_set_dl_dir(tmp)
      #download PRISM
      get_prism_dailys(
        type = vars[k],
        minDate = monthlist[i],
        maxDate = monthlist[i+1],
        keepZip = F
      )
      
      #get list of files
      filelist <- list.dirs(tmp)
      filelist <- filelist[grepl('PRISM', filelist)]
      
      #get bil file name
      filelist_bil <- paste0(substr(filelist, 5, nchar(filelist)), '.bil')
      
        for(j in 1:length(filelist)){
          #read in bil file as raster
          p_ras <- rast(file.path(filelist[j], filelist_bil[j]))
          
          #extract data from prism locs
          vals <- extract(p_ras, 
                  vect(locs))
          colnames(vals) = c('rowid', vars[k])
          
          data <- merge(cent_file, vals)
          
          data$date = as.Date(substr(substrRight(filelist_bil[j], 16), 1, 8), format = '%Y%m%d')
          
          #collate the day's data
          if(j == 1) {
            month_var_collate <- data
          } else {
            month_var_collate <- full_join(month_var_collate, data)
          }
        }
      #create a df of the month data
      if(k == 1){
        month_collate <- month_var_collate
      } else {
        month_collate <- full_join(month_collate, month_var_collate)
      }
      unlink(tmp, recursive = T)
    }
    #collate the month's data
    if(i == 1){
      alldata <- month_collate
    } else {
      alldata <- full_join(alldata, month_collate)
    }
    message('Processing of ', monthlist[i], ' complete for desired variables')
  }
  write.table(alldata, file.path(dumpdir, paste0('PRISM_multisite_daily_', yearlist[z], '_', sitefile, '.csv')), row.names = F, sep = ',')
  message('Processing of ', yearlist[z], ' complete, one-year file located at ', dumpdir)
}
