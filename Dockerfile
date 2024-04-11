FROM rocker/r-ver:4.0.5

RUN R -q -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

RUN R -q -e 'pak::pak("duckdb")'