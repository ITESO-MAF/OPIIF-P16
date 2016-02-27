
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

Pkg <- c("base","financeR","grid","httr","lubridate","PerformanceAnalytics",
         "quantmod","xts","zoo")

RMetricsPkg <- c("timeDate", "timeSeries", "fImport", "fBasics", "fArma", "fGarch",
                 "fNonlinear", "fUnitRoots", "fTrading", "fMultivar", "fRegression",
                 "fExtremes", "fCopulae", "fBonds", "fOptions", "fExoticOptions",
                 "fAsianOptions", "fAssets", "fPortfolio", "BLCOP", "FKF", "ghyp",
                 "HyperbolicDist", "randtoolbox", "rngWELL", "schwartz97",
                 "SkewHyperbolic", "VarianceGamma", "stabledist")

Paquetes <- c(Pkg,RMetricsPkg)

inst <- Paquetes %in% installed.packages()
if(length(Paquetes[!inst]) > 0) install.packages(Paquetes[!inst])
instpackages <- lapply(Paquetes, library, character.only=TRUE)

# -- --------------------------------------------- Opciones Genericas para el Codigo -- #

options("scipen"=1000,"getSymbols.warning4.0"=FALSE,concordance=TRUE)
Sys.setlocale(category = "LC_ALL", locale = "")

# -- ------------------------------------- Peticion de descarga de precios de cierre -- #

Tickers <- c("ALFAA.MX","ALPEKA.MX","ALSEA.MX","AMXL.MX","ASURB.MX","BIMBOA.MX",
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

Rendimientos <- Return.calculate(TotalBMV, method = "log")
Rendimientos <- Rendimientos[complete.cases(Rendimientos)]
DfRendimientos <- fortify.zoo(Rendimientos)
DfRendimientos$Index <- as.POSIXct(DfRendimientos$Index, origin = "1970-01-01")

rm(list = Tickers)  # Eliminar de memoria objetos con precios individuales

# -- -------------------------------------------- Calcular rendimientos logaritmicos -- #

scenarios <- dim(data)[1]
assets  <- dim(data)[2]
data_ts <- as.timeSeries(DfRendimientos)
spec <- portfolioSpec()
setSolver(spec) <- "solveRquadprog"
setNFrontierPoints(spec) <- 200
constraints <- c("LongOnly")
portfolioConstraints(data_ts, spec, constraints)
frontier <- portfolioFrontier(data_ts, spec, constraints)
print(frontier)
tailoredFrontierPlot(object = frontier)
weightsPlot(frontier, col = rainbow(assets))
