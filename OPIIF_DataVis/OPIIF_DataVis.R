
# ------------------------------------------------------------------------------------ #
# -- Initial Developer: FranciscoME ----------------------------------------------- -- #
# -- Code: MachineTradeR Main Control --------------------------------------------- -- #
# -- License: MIT ----------------------------------------------------------------- -- #
# ------------------------------------------------------------------------------------ #

# ------------------------------------------------------ Grafica 2 Series de Tiempo -- #

# --------------------------------------------------- Grafica Portafolios Markowitz -- #

color1 <- "white"
color2 <- "dark grey"
color3 <- "black"
color4 <- "black"
color5 <- "black"

Datos <- data.frame(tmp1.mean,tmp1.StdDev)

gg_mark  <- ggplot(data = fortify(Datos, melt = TRUE), 
                   aes(x = Datos[,1], y = Datos[,2]))

gg_mark1 <- gg_mark + geom_point(aes(Datos[,2], Datos[,1],
                                     colour = (Datos[,2])), size = 0.650) +
  theme(panel.background = element_rect(fill=color1),
        panel.grid.minor.y = element_line(size = .25, color = color2),
        panel.grid.major.y = element_line(size = .25, color = color2),
        panel.grid.minor.x = NULL , panel.grid.major.x = NULL ,
        axis.text.x  = element_text(colour = color4,size = 7, hjust =.5,vjust = 0),
        axis.text.y  = element_text(colour = color4,size = 7, hjust =.5,vjust = 0),
        axis.title.x = element_text(colour = color4,size = 9.5,hjust =.5,vjust =.5),
        axis.title.y = element_text(colour = color4,size = 9.5,hjust =.5,vjust =.9),
        title = element_text(colour = color5, size = 10.5, hjust = 1, vjust = 0.8))
gg_mark2 <- gg_mark1 + labs(title = "Modelo de Markowitz",
                            x = "Desviaci?n Est?ndar de Portafolio",
                            y = "Valor Esperado de Portafolio") + 
  scale_colour_gradient(low = "steel blue", high = "black", guide = FALSE) +
  annotate("point", x = max_mux, y = max_muy, size = 6, colour = "blue")   +
  annotate("point", x = max_mux, y = max_muy, size = 3, colour = "white")  +
  annotate("point", x = min_dsx, y = min_dsy, size = 6, colour = "orange") +
  annotate("point", x = min_dsx, y = min_dsy, size = 3, colour = "white")  + 
  annotate("point", x = min_dsx, y = min_dsy, size = 3, colour = "white") 
gg_mark2

# ------------------------------------------------------ Grafica Multiples BoxPlots -- #

HMedias <- data.frame((df.EstadMens[seq(1,length(df.EstadMens[,1]),5),-1]))
colnames(HMedias) <- seq(1,NRends,1)
HMedias <- fortify.zoo(HMedias)
colnames(HMedias) <- c("Medida",Tickers)
HMedias[,1] <- paste("Media",seq(1,length(HMedias[,1]),1),sep="")
row.names(HMedias) <- NULL

HMediasM <- melt(HMedias, id = "Medida")

Atps <- boxplot(HMedias[,2:length(HMedias[,1])])
Atps$out
ggplot(HMediasM, aes(x=HMediasM[,2], y=HMediasM[,3])) + coord_flip() + 
  geom_boxplot(outlier.colour="red", outlier.shape=1, outlier.size=4, size=.75) +
  labs(x=NULL, y="Rendimiento Esperado Mensual", 
       title="Variacion de Medias Mensuales Historicas") +
  theme(panel.background = element_rect(fill="white"),
        panel.grid.minor.y = element_line(size = .25, color = "dark grey"),
        panel.grid.major.y = element_line(size = .25, color = "dark grey"),
        panel.grid.minor.x = NULL , panel.grid.major.x = NULL ,
        axis.text.x  = element_text(colour = "black",size = 10, hjust =.5,vjust = 0),
        axis.text.y  = element_text(colour = "black",size = 10, hjust =.5,vjust = 0),
        axis.title.x = element_text(colour = "black",size = 15,hjust =.5,vjust =.5),
        axis.title.y = element_text(colour = "black",size = 15,hjust =.5,vjust =.9),
        title = element_text(colour = "black", size = 17, hjust = .5, vjust = 0.5))
