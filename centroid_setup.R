# This script preps the location information for PRISM download

# read in metadata of centroids ----
tmp = 'tmp/'
dir.create(tmp)

## path of file is CrossSiteGloeoModeling/data/metadata/ -- these steps navigate to that folder and identify the file of interest

  #find shared drive info
  did = shared_drive_find('CrossSiteGloeoModeling')$id
  
  #get data folder id
  data_id = drive_ls(path = as_id(did), pattern = 'data')$id
  
  #get metadata folder id
  meta_id = drive_ls(path = as_id(data_id), pattern = 'metadata')$id
  
  #get file id
  file_id = drive_ls(path = as_id(meta_id), pattern = 'metadata.xlsx')$id

#download file to temporary folder
drive_download(as_id(file_id), 
               path = file.path(tmp, 'SiteMetadata.xlsx'),
               overwrite = T)

#open file in r
cent_file = read_xlsx(file.path(tmp, 'SiteMetadata.xlsx'),
                      sheet = 'lakes_centroid_only')

#format for PRISM download pipeline
colnames(cent_file)[1] = 'rowid'

  

