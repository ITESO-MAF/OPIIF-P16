
# -- ------------------------------------------------------------------------------ -- #
# -- Funciones de Google Finance API ---------------------------------------------- -- #
# -- Desarrollador Inicial: IF Francisco ME --------------------------------------- -- #
# -- Licencia: MIT ---------------------------------------------------------------- -- #
# -- ------------------------------------------------------------------------------ -- #

import pandas as pd
import numpy as np

from matplotlib.finance import candlestick, quotes_historical_yahoo, date2num
from datetime import datetime, timedelta

# -- Prueba de funciones y operaciones individuales para el CLA ------------------- -- #

def download_data(symbol, finish_date, start_date):

    stocks_raw = quotes_historical_yahoo(symbol, start_date, finish_date)
    stocks_df  = pd.DataFrame(stocks_raw, columns=["TimeStamp", "Open", "Close",
                                                  "High", "Low", "Volume"])
    stocks_df["TimeStamp"] = stocks_df["TimeStamp"].astype(np.int32)
    stocks_df["TimeStamp"] = stocks_df["TimeStamp"].apply(datetime.fromordinal)
    return stocks_df

stock_dict={"ALFAA.MX": "ALFA.A",
            "ALPEKA.MX": "ALPEK.A",
            "ALSEA.MX": "ALSEA",
            "AMXL.MX": "AMX.L",
            "ASURB.MX": "ASUR.B",
            "BIMBOA.MX": "BIMBO.A",
            "BOLSAA.MX": "BOLSA.A",
            "CEMEXCPO.MX": "CEMEX.CPO",
            "COMERCIUBC.MX": "COMERCI.UBC",
            "ELEKTRA.MX": "ELEKTRA",
            "GAPB.MX": "GAP.B",
            "GENTERA.MX": "GENTERA",
            "GFINBURO.MX": "GFINBUR.O",
            "GFNORTEO.MX": "GFNORTE.O",
            "GFREGIOO.MX": "GFREGIO.O",
            "GMEXICOB.MX": "GMEXICO.B",
            "GRUMAB.MX": "GRUMA.B",
            "GSANBORB-1.MX": "GSANBOR.B-1",
            "ICA.MX": "ICA",
            "ICHB.MX": "ICH.B",
            "IENOVA.MX": "IENOVA",
            "KIMBERA.MX": "KIMBER.A",
            "KOFL.MX": "KOFL",
            "LABB.MX": "LAB.B",
            "LALAB.MX": "LALA.B",
            "LIVEPOLC-1.MX": "LIVEPOL.C-1",
            "MEXCHEM.MX": "MEXCHEM",
            "OHLMEX.MX": "OHLMEX",
            "PINFRA.MX": "PINFRA",
            "SANMEXB.MX": "SANMEX.B",
            "TLEVISACPO.MX": "TLEVISA.CPO",
            "WALMEX.MX": "WALMEX",
           }
symbols = stock_dict.keys()
names = stock_dict.values()

stocks_data = pd.DataFrame(symbols, columns=["Ticker"])
stocks_data["Empresa"] = names

finish_date = datetime.today()
start_date  = finish_date - timedelta(days=150)

Precios = download_data("ALFAA.MX", finish_date, start_date)
PreciosCl =  ([Precios.TimeStamp, Precios.Close])

import numpy as np

n_assets = 4
n_obs = 100
return_vec = np.random.randn(n_assets, n_obs)
p = np.asmatrix(np.mean(return_vec, axis=1))
a=np.zeros((p.shape[0]),dtype=[('id',int),('mu',float)])