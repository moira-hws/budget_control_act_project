library(httr)
library(jsonlite)
library(dplyr)

# Set these before running:
base_url <- "https://api.census.gov/data/"
ecols <- "EMP,ESTAB"  # example columns; replace with your actual columns
ejsonpath <- "cbp_data.json"

# Initialize an empty data frame
df <- NULL

for (year in 2017:2020) {
  print(year)
  
  # Construct the URL
  edata_url <- paste0(base_url, year, "/cbp?get=", ecols, "&for=county:*&NAICS2017=31-33")
  print(edata_url)
  
  # Make GET request
  response <- GET(edata_url)
  
  if (status_code(response) == 200) {
    # Parse JSON response
    emp_data <- content(response, as = "text", encoding = "UTF-8")
    emp_data_list <- fromJSON(emp_data)
    
    # Save to file
    write(emp_data, file = ejsonpath)
    print("Data dumped to json file")
  } else {
    print(paste("Problem with retrieval, response code", status_code(response)))
    break
  }
  
  # Read and parse the JSON string into a list
  ejsondata <- fromJSON(ejsonpath)
  
  # Extract the header and data separately
  header <- ejsondata[1, ]
  data <- ejsondata[-1, ]
  
  # Convert the list to a data frame
  cbpemp <- as.data.frame(data, stringsAsFactors = FALSE)
  colnames(cbpemp) <- unlist(header)  # Ensure it's a character vector
  
  cbpemp$YEAR <- year
  
  # Append data
  if (is.null(df)) {
    df <- cbpemp
  } else {
    df <- bind_rows(df, cbpemp)
  }
}


# Set these before running:
base_url <- "https://api.census.gov/data/"
ecols <- "EMP,ESTAB"  # example column names
ejsonpath <- "cbp_data_2012_2016.json"

# Initialize an empty data frame
df <- NULL

for (year in 2012:2016) {
  print(year)
  
  # Construct the URL
  edata_url <- paste0(base_url, year, "/cbp?get=", ecols, "&for=county:*&NAICS2012=31-33")
  print(edata_url)
  
  # Make GET request
  response <- GET(edata_url)
  
  if (status_code(response) == 200) {
    # Parse response and save
    emp_data <- content(response, as = "text", encoding = "UTF-8")
    write(emp_data, file = ejsonpath)
    print("Data dumped to json file")
  } else {
    print(paste("Problem with retrieval, response code", status_code(response)))
    break
  }
  
  # Read and parse the JSON file
  ejsondata <- fromJSON(ejsonpath)
  header <- ejsondata[1, ]
  data <- ejsondata[-1, ]
  
  # Build the data frame
  cbpemp <- as.data.frame(data, stringsAsFactors = FALSE)
  
  if (length(header) == ncol(cbpemp)) {
    colnames(cbpemp) <- unlist(header)
  } else {
    stop("Header length doesn't match number of columns in data.")
  }
  
  cbpemp$YEAR <- year
  
  # Append to main data frame
  if (is.null(df)) {
    df <- cbpemp
  } else {
    df <- bind_rows(df, cbpemp)
  }
}