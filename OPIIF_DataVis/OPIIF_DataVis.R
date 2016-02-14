
# ------------------------------------------------------------------------------------ #
# -- Initial Developer: FranciscoME ----------------------------------------------- -- #
# -- Code: MachineTradeR Main Control --------------------------------------------- -- #
# -- License: MIT ----------------------------------------------------------------- -- #
# ------------------------------------------------------------------------------------ #

# ------------------------------------------------------ Grafica 2 Series de Tiempo -- #

DfRendimientos <- fortify.zoo(Rendimientos)
DfRendimientos$Index <- as.POSIXct(DfRendimientos$Index, origin = "1970-01-01")

Years  <- unique(year(DfRendimientos$Index))
Months <- unique(month(DfRendimientos$Index))
Estad  <- c("Index","Media","Varianza","DesvEst","Sesgo","Kurtosis")
EstadMov <- data.frame(matrix(ncol = length(Estad), nrow = length(Years)*length(Months)))
colnames(EstadMov) <- Estad

NvosDatos <- DfRendimientos[which(year(DfRendimientos$Index) == Years[1]),]
NvosDatos <- NvosDatos[which(month(NvosDatos$Index) == Months[1]),]

# --------------------------------------------------- Grafica Portafolios Markowitz -- #

gg_mark  <- ggplot(data = fortify(mu_ds_ports, melt = TRUE), 
                   aes(x = mu_ds_ports[,1], y = mu_ds_ports[,2]))
gg_mark1 <- gg_mark + geom_point(aes(mu_ds_ports[,2], mu_ds_ports[,1],
                                     colour = (mu_ds_ports[,2])), size = 0.650) +
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

# ---------------------------------------------------------- N Aleatorios Markowitz -- #

aleatorios <- 20000

x_a  <- signif(runif(aleatorios, min = 0, max = 1),2)
x_b  <- signif(runif(aleatorios, min = 0, max = 1),2)
x_c  <- signif(runif(aleatorios, min = 0, max = 1),2)

fact <- 1/(x_a+x_b+x_c)
x_a  <- x_a*fact*100
x_b  <- x_b*fact*100
x_c  <- x_c*fact*100

