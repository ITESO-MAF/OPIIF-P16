
library(xlsx)
library(rJava)
library(xts)
library(foreach)

setwd("C:/RProgs")
loadWorkbook("BasePreciosInfoSel.xlsx")

Nombres <- c("TLEVISA","WALMEX","SANMEX","PINFRA","PENOLES","ICA","OHLMEX",
             "MEXCHEM","LIVEPOL","LALA","LAB","KOFL","KIMBER","IENOVA","ICH",
             "GRUMA","GMEXICO","GFREGIO","GFNORTE","GFINBUR","GENTERA","GCARSO",
             "FEMSA","GAP","CEMEX","ELEKTRA","BIMBO","ASUR","AMX","ALSEA","AC","ALFA")

LsPrecios <- list()
for(i in 1:10) LsPrecios[[i]] <- na.omit(xts(read.xlsx("BasePreciosInfoSel.xlsx", sheetIndex = i)$Cierre,
    order.by = read.xlsx("BasePreciosInfoSel.xlsx", sheetIndex = i)$Fecha))

for(j in 11:20) LsPrecios[[j]] <- na.omit(xts(read.xlsx("BasePreciosInfoSel.xlsx", sheetIndex = j)$Cierre,
    order.by = read.xlsx("BasePreciosInfoSel.xlsx", sheetIndex = j)$Fecha))

for(k in 21:32) LsPrecios[[k]] <- na.omit(xts(read.xlsx("BasePreciosInfoSel.xlsx", sheetIndex = k)$Cierre,
    order.by = read.xlsx("BasePreciosInfoSel.xlsx", sheetIndex = k)$Fecha))
              
XtsPrecios0 <- na.omit(foreach(i=1:length(LsPrecios), .combine=cbind) %do% merge(LsPrecios[[i]]))

colnames(XtsPrecios0) <- Nombres

write.csv(XtsPrecios0,"OPIIFPrecios.csv")
write.xlsx(XtsPrecios0,"OPIIFPrecios.xlsx")



