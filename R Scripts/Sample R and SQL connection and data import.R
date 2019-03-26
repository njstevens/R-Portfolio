install.packages("RODBC")  # Use for MS SQL server 
install.packages("RMySQL")
install.packages("ROracle")

library(RODBC)
library(tidyverse)

# first argument in dbConnect is always database backend.
# for RSQLite it is RSQLite::SQLite()
# for RMySQL it is RMySQL::MySQL()
# for RPostgreSQL it is RPostgreSQL::PostgreSQL()
# for odbc it is odbc::odbc()
# for BigQuery it is bigrquery::bigquery()

## In this case the Microsoft SQL Server is what we want to connect to.

Myconn <- DBI::dbConnect(odbc::odbc(),
                         driver = "SQL Server",
                         server = 	"NICKSPC\\SQLEXPRESS",
                         database = "Nick Demo Data",
                         Trusted_Connection = "True")

## Create Data Tables to be imported into MS SQL Server

id <- rep(1:1000) # create similar id's to later be left joined
x1 <- rep(0, 1000)
x2 <- rep(0, 1000)
x3 <- rep(0, 1000)

for (i in 1:1000){
  x1[i] <- rnorm(1, 1,2)
  x2[i] <- rnorm(1, 3.4,1.2)
  x3[i] <- rnorm(1, 4, 8)
}

id <- rep(1:1000) # create similar id's to be left joined
y1 <- rep(0, 1000)
y2 <- rep(0, 1000)
y3 <- rep(0, 1000)

for (i in 1:1000){
  y1[i] <- rnorm(1, 3,4)
  y2[i] <- rnorm(1, 8,2)
  y3[i] <- rnorm(1, 4, 10)
}

# Store data as a Tibble
sampledataA<- tibble(ID = id, X1 = x1, X2 = x2, X3 = x3)
sampledataB<- tibble(ID = id,Y1 = y1, Y2 = y2, Y3 = y3)

# Copy data over to MySQL server
copy_to(Myconn, sampledataA, "sampledataA",
        temporary = F,
        indexes = list(c("ID","X1","X2","X3")))

copy_to(Myconn, sampledataB, "sampledataB",
        temporary = F,
        indexes = list(c("ID","Y1","Y2","Y3")))

