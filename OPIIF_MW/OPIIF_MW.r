
# -- ------------------------------------------------------------------------------- -- #
# -- Contexto: Proyecto de Aplicacion Profesional ---------------------------------- -- #
# -- Proyecto: Optimizacion de Programas de Inversion en Intermediarios Financieros  -- #
# -- Periodo: Primavera 2016 ------------------------------------------------------- -- #
# -- Codigo: Colector de Datos ----------------------------------------------------- -- #
# -- Licencia: MIT ----------------------------------------------------------------- -- #
# -- Desarrolladores: Daniel, Juan Pablo, FranciscoME ------------------------------ -- #

# -- ---------------------------------------------------------------- Inicializacion -- #

rm(list=ls())         # Remover objetos del environment
cat("\014")           # Limpiar la Consola

Pkg <- c("base","fBasics","grid","httr","lubridate","PerformanceAnalytics",
         "PortfolioAnalytics","quantmod","xts","zoo","pso")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)

# -- --------------------------------------------- Opciones Genericas para el Codigo -- #

options("scipen"=1000,"getSymbols.warning4.0"=FALSE,concordance=TRUE)
Sys.setlocale(category = "LC_ALL", locale = "")

# -- ------------------------------------- Peticion de descarga de precios de cierre -- #

Acciones <- c("ALFA.A","ALPEK.A","ALSEA","AMX.L","ASUR.B","BIMBO.A",
             "BOLSA.A","CEMEX.CPO","COMERCI.UBC","ELEKTRA","GAP.B",
             "GENTERA","GFINBUR.O","GFNORTE.O","GFREGIO.O","GMEXICO.B",
             "GRUMA.B","GSANBOR.B-1","ICA","ICH.B","IENOVA","KIMBER.A",
             "KOFL","LAB.B","LALA.B","LIVEPOL.C-1","MEXCHEM","OHLMEX",
             "PINFRA","SANMEX.B","TLEVISA.CPO","WALMEX")

Tickers <- c("ALFAA.MX","ALPEKA.MX","ALSEA.MX","AMXL.MX","ASURB.MX","BIMBOA.MX",
             "BOLSAA.MX","CEMEXCPO.MX","COMERCIUBC.MX","ELEKTRA.MX","GAPB.MX",
             "GENTERA.MX","GFINBURO.MX","GFNORTEO.MX","GFREGIOO.MX","GMEXICOB.MX",
             "GRUMAB.MX","GSANBORB-1.MX","ICA.MX","ICHB.MX","IENOVA.MX","KIMBERA.MX",
             "KOFL.MX","LABB.MX","LALAB.MX","LIVEPOLC-1.MX","MEXCHEM.MX","OHLMEX.MX",
             "PINFRA.MX","SANMEXB.MX","TLEVISACPO.MX","WALMEX.MX")

getSymbols(Tickers, from="2014-01-01", to="2016-02-01")

# -- -------------------------- Concatenar todos los precios y eliminar filas con NA -- #

XtsActiPrec <- do.call(merge, lapply(Tickers, function(x) Ad(get(x))))
XtsActiPrec <- na.omit(XtsActiPrec)
DFActiPrec  <- fortify.zoo(XtsActiPrec)

# -- -------------------------------------------- Calcular rendimientos logaritmicos -- #

XtsActiRend <- round(Return.calculate(XtsActiPrec, method = "log")[-1],4)
XtsActiRend <- XtsActiRend[complete.cases(XtsActiRend)]
DFActiRend  <- fortify.zoo(XtsActiRend)

rm(list = Tickers)  # Eliminar de memoria objetos con precios individuales

# -- ----------------------------------------------------------- Ventanas de tiempo  -- #

EstadMens <- function(DataEnt,YearNumber, MonthNumber)  {
  DfRends <- DataEnt
  NumActivos <- length(DfRends[1,])-1
  Years   <- unique(year(DfRends$Index))
  Months  <- unique(month(DfRends$Index))
  EstadMens  <- data.frame(matrix(ncol = NumActivos+1, nrow = 5))
  row.names(EstadMens) <- c("Media","Varianza","DesvEst","Sesgo","Kurtosis")
  
  NvosDatos <- DfRends[which(year(DfRends$Index) == Years[YearNumber]),]
  NvosDatos <- NvosDatos[which(month(NvosDatos$Index) == Months[MonthNumber]),]
  colnames(EstadMens)[1] <- "Fecha"
  EstadMens$Fecha <- NvosDatos$Index[length(NvosDatos$Index)]
  
  EstadMens[1,2:length(EstadMens[1,])] <- round(apply(NvosDatos[,2:length(NvosDatos[1,])],
                                                      MARGIN=2,FUN=mean),4)
  EstadMens[2,2:length(EstadMens[1,])] <- round(apply(NvosDatos[,2:length(NvosDatos[1,])],
                                                      MARGIN=2,FUN=var),4)
  EstadMens[3,2:length(EstadMens[1,])] <- round(apply(NvosDatos[,2:length(NvosDatos[1,])],
                                                      MARGIN=2,FUN=sd),4)
  EstadMens[4,2:length(EstadMens[1,])] <- round(apply(NvosDatos[,2:length(NvosDatos[1,])],
                                                      MARGIN=2,FUN=skewness),4)
  EstadMens[5,2:length(EstadMens[1,])] <- round(apply(NvosDatos[,2:length(NvosDatos[1,])],
                                                      MARGIN=2,FUN=kurtosis),4)
  colnames(EstadMens)[2:length(EstadMens[1,])] <- colnames(DfRends[2:(NumActivos+1)])
  return(EstadMens)
}

# -- ----------------------------------------------------------- Ventanas de tiempo  -- #

DFMedidas <- EstadMens(DataEnt=DFActiRend, YearNumber=3, MonthNumber=1)

for(c in 2:1)  {
  for(n in 12:1)  {
    Resultado <- EstadMens(DataEnt=DFActiRend, YearNumber=c, MonthNumber=n)
    DFMedidas <- rbind(DFMedidas,Resultado)
  }
}

rm(list = "Resultado") # Eliminar de la memoria objeto Resultado

# -- -------------------------------------------------------------- Portafolio Unico -- #

NActiv <- as.numeric(length(Tickers))
NPesos <- 1000
VMus <- apply(DFActiRend[,2:NActiv+1], 2, mean)
MCov <- cov(DFActiRend[,2:NActiv+1],DFActiRend[,2:NActiv+1])

# -- -------------------------------------------------------------- Portafolio Unico -- #

chart.Boxplot(XtsActiRend, sort.by="variance", colorset = "black", sort.ascending=TRUE)
rp1 <- random_portfolios(portfolio=pspec, permutations=10000, rp_method="sample")
tmp1.mean   <- apply(rp1, 1, function(x) mean(XtsActiRend %*% x))
tmp1.StdDev <- apply(rp1, 1, function(x) StdDev(R=XtsActiRend, weights=x))
