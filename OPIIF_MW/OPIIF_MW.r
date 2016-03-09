
# -- -------------------------------------------------- ---------------------------- -- #
# -- Codigo: PAP Optimizacion de Programas de Inversion ---------------------------- -- #
# -- Fecha Ult Modificacion: 7.Marzo.2016               ---------------------------- -- #
# -- GitHub: ------------------------------------------ ---------------------------- -- #
# -- -------------------------------------------------- ---------------------------- -- #

rm(list=ls())         # Remover objetos del environment
cat("\014")           # Limpiar la Consola

Pkg <- c("base","fBasics","fPortfolio","grid","httr","lubridate","PerformanceAnalytics",
         "quantmod","xts","zoo","quadprog","quantmod","ggplot2","timeDate")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)

# -- ---------------------------------------------------------- Obtencion de precios -- #

activos <- c("AC.MX","ALFAA.MX","ALPEKA.MX","ALSEA.MX","AMXL.MX","ASURB.MX","BIMBOA.MX",
             "BOLSAA.MX","CEMEXCPO.MX","COMERCIUBC.MX","ELEKTRA.MX","GAPB.MX",
             "GENTERA.MX","GFINBURO.MX","GFNORTEO.MX","GFREGIOO.MX","GMEXICOB.MX",
             "GRUMAB.MX","GSANBORB-1.MX","ICA.MX","ICHB.MX","IENOVA.MX","KIMBERA.MX",
             "KOFL.MX","LABB.MX","LALAB.MX","LIVEPOLC-1.MX","MEXCHEM.MX","OHLMEX.MX",
             "PINFRA.MX","SANMEXB.MX","TLEVISACPO.MX","WALMEX.MX")
getSymbols.yahoo(Symbols = activos,env=.GlobalEnv,from="2014-01-01",to="2016-02-08")

# -- --------------------------------------- matriz de activos con precios de cierre -- #

Precios <- do.call(merge, lapply(activos, function(x) Cl(get(x))))
Precios <- na.omit(Precios)
rm(list = activos)  # Eliminar de memoria objetos con precios individuales

# -- ------------------------------------------- Rendimientos Logaritmicos --------- -- #

RendsLn <- diff(log(Precios))
RendsLn <- na.omit(RendsLn)
colnames(RendsLn) <- c("Rend.AC","Rend.ALFAA","Rend.ALPEKA","Rend.ALSEA","Rend.AMXL",
                       "Rend.ASURB","Rend.BIMBOA","Rend.BOLSAA","Rend.CEMEXCPO",
                       "Rend.COMERCIUBC","Rend.ELEKTRA","Rend.GAPB","Rend.GENTERA",
                       "Rend.GFINBURO","Rend.GFNORTEO","Rend.GFREGIOO","Rend.GMEXICOB",
                       "Rend.GRUMAB","Rend.GSANBORB1","Rend.ICA","Rend.ICHB",
                       "Rend.IENOVA","Rend.KIMBERA","Rend.KOFL","Rend.LABB",
                       "Rend.LALAB","Rend.LIVEPOLC1","Rend.MEXCHEM","Rend.OHLMEX",
                       "Rend.PINFRA","Rend.SANMEXB","Rend.TLEVISACPO","Rend.WALMEX")

df.RendsLn  <- fortify.zoo(RendsLn)
NRends <- length(colnames(RendsLn))
NObs   <- length(df.RendsLn[,1])

# -- ---------------------------------------------- Estadisticas Mensuales --------- -- #

EstadMens <- function(DataEnt,YearNumber, MonthNumber)  {
  
  DfRends <- DataEnt
  NumActivos <- length(DfRends[1,])-1
  Years   <- unique(year(DfRends$Index))
  Months  <- unique(month(DfRends$Index))
  EstadMens  <- data.frame(matrix(ncol = NumActivos+1, nrow = 5))
  row.names(EstadMens) <- c("Media ","Varianza ","DesvEst ","Sesgo ","curtosis ")
  
  NvDat <- DfRends[which(year(DfRends$Index) == Years[YearNumber]),]
  NvDat <- NvDat[which(month(NvDat$Index) == Months[MonthNumber]),]
  colnames(EstadMens)[1] <- "Fecha"
  EstadMens$Fecha <- NvDat$Index[length(NvDat$Index)]
  Long <- length(EstadMens[1,])
  
  EstadMens[1,2:Long] <- round(apply(NvDat[,2:length(NvDat[1,])],MARGIN=2,FUN=mean),4)
  EstadMens[2,2:Long] <- round(apply(NvDat[,2:length(NvDat[1,])],MARGIN=2,FUN=var),4)
  EstadMens[3,2:Long] <- round(apply(NvDat[,2:length(NvDat[1,])],MARGIN=2,FUN=sd),4)
  EstadMens[4,2:Long] <- round(apply(NvDat[,2:length(NvDat[1,])],MARGIN=2,FUN=skewness),4)
  EstadMens[5,2:Long] <- round(apply(NvDat[,2:length(NvDat[1,])],MARGIN=2,FUN=kurtosis),4)
  colnames(EstadMens)[2:Long] <- colnames(DfRends[2:(NumActivos+1)])
  return(EstadMens)
}

df.EstadMens <- EstadMens(DataEnt=df.RendsLn, YearNumber=3, MonthNumber=1)

for(c in 2:1)  {
  for(n in 12:1)  {
    df.EstadMens <-rbind(df.EstadMens,
                         EstadMens(DataEnt=df.RendsLn, YearNumber=c, MonthNumber=n) ) }  }

row.names(df.EstadMens)[1:5] <- c("Media 0","Varianza 0","DesvEst 0","Sesgo 0","Curtosis 0")

# -- -----------------------------  Funcion para Estimar Portafolio Eficiente ----- -- #

# -- 4 restricciones -- #

# -- Restricciones de Igualdad -- #
# -- (R1) Totalidad del capital invertido: Suma de los pesos debe de ser 1
# -- (R2) Rendimiento de portafolio objetivo: Rendimiento igual a 5.5% Anual

# -- Restricciones de Desigualdad -- #
# -- (R3) Participacion minima por activo: Todos los pesos deben de ser mayores a 2%
# -- (R4) Participacion maxima por activo: Todos los pesos deben de ser menores a 12%

NRends <- 4
RendE <- df.EstadMens[46,2:NRends] # Matriz Nx1 rendimientos esperados de activos
CovE  <- cov(RendsLn[325:346,2:NRends]) # Matriz NxN Covarianzas entre rendimientos

Obj.RendEsp <- 0.005
limit.l <- 0.01
limit.u <- 0.5

Dmat <- CovE  # Matriz de Covarianzas
dvec <- t(RendE) # Matriz de Valores esperados

A.Equality <- matrix(c(1,1,1), ncol=1)
Amat <- cbind(A.Equality, dvec, diag(3), -diag(3))
bvec <- c(1, 0.0020, rep(.01, 3), rep(-0.5, 3))
qp <- solve.QP(Dmat, dvec, Amat, bvec, meq=2)
qp$solution

# -- ------------------------------------------------- Aleatorios para Grafica ----- -- #

NPorts <- 1000
df.Alea <- data.frame(matrix(runif(NRends*NPorts),NPorts,NRends))
df.Alea <- df.Alea/rowSums(df.Alea)
colnames(df.Alea)  <- activos
for (i in 1:NPorts) row.names(df.Alea)[i] <- paste("p",i,sep= "")

# -- --------------------------------------------- Generacion de variables --------- -- #

df.EstadMens$Periodo.Mes <- as.numeric(format.Date(df.EstadMens$Fecha, format="%m"))
df.EstadMens$Periodo.Ano <- as.numeric(format.Date(df.EstadMens$Fecha, format="%Y"))

df.EstadMens <- df.EstadMens[,c("Fecha","Periodo.Mes","Periodo.Ano",c(colnames(RendsLn)))]

chart.Boxplot(XtsActiRend, sort.by="variance", colorset = "black", sort.ascending=TRUE)
rp1 <- random_portfolios(portfolio=pspec, permutations=10000, rp_method="sample")
tmp1.mean   <- apply(rp1, 1, function(x) mean(XtsActiRend %*% x))
tmp1.StdDev <- apply(rp1, 1, function(x) StdDev(R=XtsActiRend, weights=x))