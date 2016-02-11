
# -- ------------------------------------------------------------------------------- -- #
# -- Contexto: Proyecto de Aplicacion Profesional ---------------------------------- -- #
# -- Proyecto: Optimizacion de Programas de Inversion en Intermediarios Financieros  -- #
# -- Periodo: Primavera 2016 ------------------------------------------------------- -- #
# -- Codigo: Colector de Datos ----------------------------------------------------- -- #
# -- Licencia: MIT ----------------------------------------------------------------- -- #
# -- ------------------------------------------------------------------------------- -- #

# -- ---------------------------------------------------------------- Inicializacion -- #

rm(list=ls())         # Remover objetos del environment
cat("\014")           # Limpiar la Consola

Pkg <- c("base","fBasics","grid","httr","lubridate","PerformanceAnalytics",
         "quantmod","xts","zoo")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)

# -- --------------------------------------------- Opciones Genericas para el Codigo -- #

options("scipen"=1000,"getSymbols.warning4.0"=FALSE,concordance=TRUE)
Sys.setlocale(category = "LC_ALL", locale = "")

# -- ------------------------------------- Peticion de descarga de precios de cierre -- #

Tickers <- c("AC.MX","ALFAA.MX","ALPEKA.MX","ALSEA.MX","AMXL.MX","ASURB.MX","BIMBOA.MX",
             "BOLSAA.MX","CEMEXCPO.MX","COMERCIUBC.MX","ELEKTRA.MX","GAPB.MX",
             "GENTERA.MX","GFINBURO.MX","GFNORTEO.MX","GFREGIOO.MX","GMEXICOB.MX",
             "GRUMAB.MX","GSANBORB-1.MX","ICA.MX","ICHB.MX","IENOVA.MX","KIMBERA.MX",
             "KOFL.MX","LABB.MX","LALAB.MX","LIVEPOLC-1.MX","MEXCHEM.MX","OHLMEX.MX",
             "PINFRA.MX","SANMEXB.MX","TLEVISACPO.MX","WALMEX.MX")

getSymbols(Tickers, from="2014-01-01", to="2016-02-01")

# -- -------------------------- Concatenar todos los precios y eliminar filas con NA -- #

ClosePrices <- do.call(merge, lapply(Tickers, function(x) Cl(get(x))))
TotalBMV <- na.omit(ClosePrices)

# -- -------------------------------------------- Calcular rendimientos logaritmicos -- #

Rendimientos <- round(Return.calculate(TotalBMV, method = "discrete")[-1],4)
Rendimientos <- Rendimientos[complete.cases(Rendimientos)]

rm(list = Tickers)  # Eliminar de memoria objetos con precios individuales
