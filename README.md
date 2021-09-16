# DatawareHouse   

### Project Aim:
#### Create a model data warehouse for NY-Airlines by integrating data from two sources. The data sets consist of information about various domestic flights traveling from New York City (JFK Airport) to other airport destinations in the United States. This would facilitate the airline quality assurance manager to quickly access reports of the key performance indices (KPI’s) of interest.

### Data source
#### The datasets are downloaded from the ‘United States Bureau of Transportation Statistics.’
https://www.transtats.bts.gov/ErrPage.asp
#### The datasourses can be downloaded from here
https://drive.google.com/file/d/1LaMC3emlslnDdTI5RhyQtrEQUhlqPeW2/view?usp=sharing
https://drive.google.com/file/d/1pzNTYDmbCQcSNl6a009VEEsmWhigEoH_/view?usp=sharing

#### Objectives
1) Identifying data consistensy issues and clean and integrate the data sources.
2) create a star schema with fact and dimension tables in sql
3) Obtain the following reports
   	1) Number of flights that are delayed on departure per month. (delay more than 10 min). 
	2) Number of flights with taxi in time above 15min per airport per month.

### Star Schema
![ss](https://user-images.githubusercontent.com/90732088/133529689-71c22cdb-e10b-4de7-ad8f-ce7f7abd8964.jpg)

### ETL process
![1](https://user-images.githubusercontent.com/90732088/133526016-5f88bbc9-82a9-484a-b9b8-562d8f560dc7.jpg)

### Data Dictionary for the source data sets
![dd1](https://user-images.githubusercontent.com/90732088/133529117-934911c4-7039-4bc6-8b55-9570c3f15220.jpg)

![dd2](https://user-images.githubusercontent.com/90732088/133529120-d8d183bd-fee6-488a-96db-d2ec47d7d015.jpg)
