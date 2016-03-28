
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

Pkg <- c("base","fBasics","dplyr","grid","googlesheets","httr","lubridate",
         "PerformanceAnalytics","quantmod","xts","zoo")

inst <- Pkg %in% installed.packages()
if(length(Pkg[!inst]) > 0) install.packages(Pkg[!inst])
instpackages <- lapply(Pkg, library, character.only=TRUE)

# -- --------------------------------------------- Opciones Genericas para el Codigo -- #

options("scipen"=1000,"getSymbols.warning4.0"=FALSE,concordance=TRUE)
Sys.setlocale(category = "LC_ALL", locale = "")

# -- ------------------------------------------------------------------------------- -- #
# -- ------------------------------------- Peticion de descarga de precios de cierre -- #
# -- ------------------------------------------------------------------------------- -- #

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

Rendimientos <- Return.calculate(TotalBMV, method = "log")
Rendimientos <- Rendimientos[complete.cases(Rendimientos)]
DfRendimientos <- fortify.zoo(Rendimientos)
DfRendimientos$Index <- as.POSIXct(DfRendimientos$Index, origin = "1970-01-01")

rm(list = Tickers)  # Eliminar de memoria objetos con precios individuales

# -- ------------------------------------------------------------------------------- -- #
# -- ------------------- Leer una hoja de calculo publica almacenada en Google Drive -- #
# -- --------------- Se utiliza el paquete googlesheets y algunas funciones de dplyr -- #
# -- ------------------------------------------------------------------------------- -- #

# -- Lista de hojas de calculo disponibles en google drive inicio, automaticamente
# -- se pedirá la autenticación y permiso para acceder a google drive a traves de r
gs_ls()
gs_copy(gs_gap(), to = "Multiplos(OPIIF).xlsx")

# -- Buscar en el inicio una hoja de calculo llamada "Multiplos(OPIIF).xlsx"
GSArchivo <- gs_title("Multiplos(OPIIF).xlsx")

# -- Leer hoja de calculo y pagina en particular "GAPB"
DatosGS <- gs_read(GSArchivo, ws = "GAPB")

# -- Estructura de la hoja y pagina leidas, incluye clases de columnas
str(DatosGS)

# -- Primeros renglones de la hoja y pagina leidas, incluye clases de columnas
head(DatosGS)

# -- Descargar hoja y pagina seleccionadas a un archivo local
gs_download(from = GSArchivo, to = "Prueba.csv", overwrite = TRUE)

# -- Borrar de caché datos utilizados para inciiar desde 0
gs_vecdel("GSMultiplos")
