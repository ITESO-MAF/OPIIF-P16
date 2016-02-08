
# ------------------------------------------------------------------------------------ #
# -- Initial Developer: FranciscoME ----------------------------------------------- -- #
# -- Code: Lector de PDFs a Texto ------------------------------------------------- -- #
# -- License: Abierta ------------------------------------------------------------- -- #
# ------------------------------------------------------------------------------------ #

# -- --------------------------------------------------------------- Inicializacion -- #

rm(list=ls())
cat("\014")

pkg <- c("base","foreach","zoo","RCurl","tm")

inst <- pkg %in% installed.packages()
if(length(pkg[!inst]) > 0) install.packages(pkg[!inst])
instpackages <- lapply(pkg, library, character.only=TRUE)

# -- ---------------------------------------------------------------- Descargar PDFs -- #

OMWeb <- "https://www.oldmutual.com.mx/plataforma-de-inversion/fondos-old-mutual/Documents/"
OMRVMX  <- paste(OMWeb,'Prospecto_OldMutual_OMRVMX_Cartera.pdf',sep="")
OMRVMXm <- paste(OMRVMXm,'Prospecto_OldMutual_OMRVMX_Cartera_Mensual.pdf',sep="")
OMRVST  <- paste(OMRVST,'Prospecto_OldMutual_OMRVST_Cartera.pdf',sep="")
OMRVSTm <- paste(OMRVSTm,'Prospecto_OldMutual_OMRVST_Cartera_Mensual.pdf',sep="")

# -- -------------------------------------------------------- Convertir PDFs a Texto -- #

pdf.OMRVMX <- readPDF(control=list(text="-layout"))(elem=list(uri=OMRVMX),language="sp")
pdf.OMRVST <- readPDF(control=list(text="-layout"))(elem=list(uri=OMRVST),language="sp")
  
pdf.OMRVMXm <- readPDF(control=list(text="-layout"))(elem=list(uri=OMRVMXm),language="sp")
pdf.OMRVSTm <- readPDF(control=list(text="-layout"))(elem=list(uri=OMRVSTm),language="sp")

Contenido1.titulos <- c("TipoDeValor", "Emisora", "Serie", "CalifBursatilidad",
"CantDeTítulos","ValorRazonable", "ParticipaciónPorcentual")

Contenido1 <- data.frame(matrix(nrow=1, ncol=length(Contenido1.titulos)))
colnames(Contenido1) <- Contenido1.titulos

TextoIni <- "DISPONIBILIDADES"
TextoFin <- "TOTAL DE INVERSION EN VALORES"

Sectores <- c("EMPRESAS ENERGÉTICAS","EMPRESAS MATERIALES", "EMPRESAS INDUSTRIALES",
  "EMPRESAS DE SERVICIOS Y BIENES DE CONSUMO NO BÁSICO",
  "EMPRESAS DE PRODUCTOS DE CONSUMO FRECUENTE","EMPRESAS DE SALUD",
  "EMPRESAS DE SERVICIOS FINANCIEROS","EMPRESAS DE SERVICIOS DE TELECOMUNICACIONES",
  "FONDOS DE INVERSIÓN EN INSTRUMENTOS DE DEUDA","FONDOS DE INVERSIÓN DE RENTA VARIABLE")

Renglones <- seq(2,62,1)

SectoresX <- foreach(i=1:length(Renglones)) %do% 
             (which(pdf.OMRVMX[1]$content == Sectores[i]))[1]
RenSector <- c(na.omit(data.frame(matrix(unlist(SectoresX), byrow=T),
             stringsAsFactors=FALSE))[,1])

pdf.OMRVMX[1]$content[7]
pdf.OMRVMX[1]$content[61]

for(i in 1:length(Contenido1.titulos)){
  Contenido1[1,i] <- strsplit(pdf.OMRVMX[1]$content[9]," ")[[1]][i]}
