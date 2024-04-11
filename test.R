options(conflicts.policy = list(warn = FALSE))
library(DBI)
library(duckdb)
library(dplyr)

con <- dbConnect(duckdb(), dbdir = "my-db.duckdb", read_only = FALSE)

DBI::dbWriteTable(con, "mtcars", mtcars)

tbl(con, "mtcars")

# List data types (different meaning than in R: content needs to stick to one data type) list can be created like this:
test_list <- list(a = 1, c = list(letters[1:3]), d = list(LETTERS[1:5]), e = list(c(1L, 5L, 9L, 14L)))
# not possible to write a list directly to the DB -> change into dataframe
test_list_tbl <- as_tibble(test_list)
# either:
DBI::dbExecute(con, "CREATE TABLE test_list (a INTEGER, c VARCHAR[], d VARCHAR[], e INTEGER[]);")
duckdb::dbAppendTable(con, "test_list", test_list_tbl)
tbl(con, "test_list")

# or directly:
dbWriteTable(con, "test_list_alternative", test_list_tbl)
tbl(con, "test_list_alternative")

# STRUCT data type: one column that can contain several columns:
test_list_2 <- list(a = 1, b = tibble(c = list(letters[1:6]), d = list(LETTERS[1:2]), e = list(c(1L, 5L, 9L))))
test_list_2_tbl <- as_tibble(test_list_2)

# either:
DBI::dbExecute(con, "CREATE TABLE test_list_2 (a integer, b STRUCT(c VARCHAR[], d VARCHAR[], e INTEGER[]));")
duckdb::dbAppendTable(con, "test_list_2", test_list_2_tbl)
tbl(con, "test_list_2")

# or directly:
dbWriteTable(con, "test_list_2_alternative", test_list_2_tbl)
tbl(con, "test_list_2_alternative")

# with parquet file
if (!file.exists("test_list.parquet")) {
  arrow::write_parquet(test_list_tbl, "test_list.parquet")
}
test_list_from_parquet <- DBI::dbGetQuery(con, "SELECT * FROM 'test_list.parquet'")
test_list_from_parquet
as_tibble(test_list_from_parquet)

if (!file.exists("test_list_2.parquet")) {
  arrow::write_parquet(test_list_2_tbl, "test_list_2.parquet")
}
test_list_2_from_parquet <- DBI::dbGetQuery(con, "SELECT * FROM 'test_list_2.parquet'")
test_list_2_from_parquet
as_tibble(test_list_2_from_parquet)

# read parquet file directly with arrow
test_list_2_from_parquet_2 <- arrow::read_parquet("test_list_2.parquet")
test_list_2_from_parquet_2 %>%
  tidyr::unpack(b)

# # blob column
# tibble_with_blob <- tibble(date = Sys.Date(), data = blob::new_blob(list(test_list_2_from_parquet_2)))
# DBI::dbExecute(con, "CREATE TABLE test_list_3 (date VARCHAR, data BLOB);")
# duckdb::dbAppendTable(con, "test_list_3", tibble_with_blob)
# tbl(con, "test_list_3")

# or directly:
# dbWriteTable(con, "test_list_3", tibble_with_blob)
# tbl(con, "test_list_3")
