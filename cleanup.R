# this script cleans up duplicates in the record (an issue with the PRISM package when downloading multiple adjacent time periods) and re-saves the resulting files

#in this case, we're reading in local files, and then saving to the shared google Drive, then deleting the local files.

# create a list of the PRISM files
file_list <- list.files(dumpdir)
metadata <- file_list[grepl('centroids', file_list)]
file_list <- file_list[!grepl('centroids', file_list)]

#read in the metadata
meta <- read.csv(file.path(dumpdir, metadata)) %>% 
  select(-X)

# get folder id for save location
#get covariates folder id
cov_id = drive_ls(path = as_id(data_id), pattern = 'covariates')$id
prism_id = drive_ls(path = as_id(cov_id), pattern = 'PRISM') $id

# iteratively read in the files, remove dupes, add in metadata, save in the Shared Drive
for (i in 1:length(file_list)){
  df <- read.csv(file.path(dumpdir, file_list[i])) %>% 
    mutate(date = as.Date(date))
  cutoff = first(df$date) + years(1) - days(1)
  df_clean <- df %>% 
    filter(date <= cutoff)
  df_clean <- left_join(df_clean, meta) %>% 
    rename(precipitation_mm = ppt,
           airTemperatureMinimum_degC = tmin,
           airTemperatureMaximum_degC = tmax) %>% 
    select(-tmean)
  df_clean <- df_clean %>% 
    arrange(rowid, date) %>% 
    select(rowid, LakeName, State, date, 
           precipitation_mm, airTemperatureMaximum_degC, airTemperatureMinimum_degC)
  ##write locally
  write.csv(df_clean, file.path(dumpdir, paste0('clean', file_list[i])), row.names = F)
  ## SAVE FILE TO GOOGLE DRIVE ----
  drive_upload(media = file.path(dumpdir, paste0('clean', file_list[i])),
               path = as_id(prism_id),
               name = file_list[i])
}

#save metadata to drive folder
drive_upload(media = file.path(dumpdir, metadata),
             path = as_id(prism_id),
             name = metadata)


