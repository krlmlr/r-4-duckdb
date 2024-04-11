FROM rocker/r-ver:4.3.3

RUN R -q -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

RUN R -q -e 'options(repos = "https://p3m.dev/cran/__linux__/focal"); pak::pak(c("duckdb", "dbplyr"))'
