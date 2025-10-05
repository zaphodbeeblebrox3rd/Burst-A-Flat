#!/usr/bin/env Rscript

# Generate sample RData file for Burst-A-Flat project
# Uses built-in R datasets - completely public and open data

# Generate sample data using built-in datasets
# Change to data directory
setwd("../data")

# 1. US State data (state.x77 dataset)
us_states <- data.frame(
  state = rownames(state.x77),
  state.x77,
  stringsAsFactors = FALSE
)
us_states$data_source <- "US State Statistics"
us_states$country <- "United States"

# 2. US Arrests data (USArrests dataset)
us_arrests <- data.frame(
  state = rownames(USArrests),
  USArrests,
  stringsAsFactors = FALSE
)
us_arrests$data_source <- "US Crime Statistics"
us_arrests$country <- "United States"

# 3. Motor Trend data (mtcars dataset) - for economic analysis
mtcars_data <- data.frame(
  car_model = rownames(mtcars),
  mtcars,
  stringsAsFactors = FALSE
)
mtcars_data$data_source <- "Motor Trend Car Tests"
mtcars_data$country <- "United States"

# 4. Create a combined research dataset
# This simulates a typical research scenario where you combine multiple datasets
research_data <- list(
  states = us_states,
  arrests = us_arrests,
  cars = mtcars_data,
  metadata = list(
    created_date = Sys.Date(),
    description = "Sample research dataset combining US economic, demographic, and social indicators",
    source = "R built-in datasets package",
    license = "Public domain",
    variables = list(
      states = c("state", "Population", "Income", "Illiteracy", "Life.Exp", "Murder", "HS.Grad", "Frost", "Area"),
      arrests = c("state", "Murder", "Assault", "UrbanPop", "Rape"),
      cars = c("car_model", "mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb")
    )
  )
)

# Save as RData file
save(research_data, file = "sample_research_data.RData")

# Also create a CSV version for comparison
write.csv(us_states, "sample_states.csv", row.names = FALSE)
write.csv(us_arrests, "sample_arrests.csv", row.names = FALSE)
write.csv(mtcars_data, "sample_cars.csv", row.names = FALSE)

# Print summary
cat("Sample data files created:\n")
cat("- sample_research_data.RData (combined dataset)\n")
cat("- sample_states.csv (US state statistics)\n")
cat("- sample_arrests.csv (US crime statistics)\n")
cat("- sample_cars.csv (Motor Trend car data)\n")
cat("\nData sources: R built-in datasets package (public domain)\n")
cat("Total records: ", nrow(us_states) + nrow(us_arrests) + nrow(mtcars_data), "\n")
cat("Date created: ", Sys.Date(), "\n")
