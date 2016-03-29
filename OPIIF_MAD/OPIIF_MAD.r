
# -- -------------------------------------------------- ---------------------------- -- #
# -- Codigo: PAP Optimizacion de Programas de Inversion ---------------------------- -- #
# -- Fecha Ult Modificacion: 28.Marzo.2016              ---------------------------- -- #
# -- GitHub: ------------------------------------------ ---------------------------- -- #
# -- -------------------------------------------------- ---------------------------- -- #

rm(list=ls())         # Remover objetos del environment
cat("\014")           # Limpiar la Consola

Pkg <- c("base","fBasics","fPortfolio","grid","httr","lubridate","PerformanceAnalytics",
         "plyr","quantmod","xts","zoo","quadprog","quantmod","Quandl","ggplot2",
         "timeDate")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)

# -- ---------------------------------------------------------- Obtencion de precios -- #

FInicial <- "2014-01-01"
FFinal   <- "2016-02-08"

# -- ------------------------------------------------------------------------------ -- #

# -- Tasa Libre de Riesgo (Cetes) ANUAL
Rf <- Quandl("BDM/SF282", trim_start=FInicial, order = "asc")
colnames(Rf) <- c("Index","Rf")
IndexRf <- Rf$Index
Rf$Index <- format(Rf$Index, format="%b %Y")
Rf <- Rf[-1,]
Rf[,2] <- round((Rf[,2]/25200)*28,4)

# -- BenchMark (IPC)
Bm <- Cl(get(getSymbols(Symbols="^MXX", env=.GlobalEnv, from=FInicial, to=FFinal)))
IndexBm <- (fortify.zoo(Bm))[,1]
Bm <- fortify.zoo(to.monthly(Bm))
Bm <- data.frame(Bm[-1,1], round(diff(log(Bm[,5])),4))
colnames(Bm) <- c("Index","Bm")
  
# -- Fondo de inversion OldMutual
Fd <- Cl(get(getSymbols(Symbols="OMRVMXA.MX", env=.GlobalEnv, from=FInicial, to=FFinal)))
IndexFd <- (fortify.zoo(Fd))[,1]
Fd <- fortify.zoo(to.monthly(Fd))
Fd <- data.frame(Fd[-1,1], round(diff(log(Fd[,5])),4))
colnames(Fd) <- c("Index","Fd")

Df.Datos  <- join_all(list(Rf,Bm,Fd), by = 'Index', type = 'full')
Df.Datos  <- Df.Datos[,-1]
Xts.Datos <- as.xts(Df.Datos, order.by = unique(IndexRf,IndexBm,IndexFd)[-1])

rm(list = "MXX","OMRVMXA.MX","Bm","Fd","Rf","a")
