
# ------------------------------------------------------------------------------------ #
# -- Initial Developer: FranciscoME ----------------------------------------------- -- #
# -- Code: MachineTradeR Main Control --------------------------------------------- -- #
# -- License: MIT ----------------------------------------------------------------- -- #
# ------------------------------------------------------------------------------------ #

# -------------------------------------------------- Matriz Mensual de Estadisticas -- #

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

Resultado <- EstadMens(DataEnt=DfRendimientos, YearNumber=2, MonthNumber=2)

# ---------------------------------------------------------- N Aleatorios Markowitz -- #

aleatorios <- 20000

x_a  <- signif(runif(aleatorios, min = 0, max = 1),2)
x_b  <- signif(runif(aleatorios, min = 0, max = 1),2)
x_c  <- signif(runif(aleatorios, min = 0, max = 1),2)

fact <- 1/(x_a+x_b+x_c)
x_a  <- x_a*fact*100
x_b  <- x_b*fact*100
x_c  <- x_c*fact*100

