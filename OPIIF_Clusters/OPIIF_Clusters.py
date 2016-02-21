
# -- ------------------------------------------------------------------------------- -- #
# -- Contexto: Proyecto de Aplicacion Profesional ---------------------------------- -- #
# -- Proyecto: Optimizacion de Programas de Inversion en Intermediarios Financieros  -- #
# -- Periodo: Primavera 2016 ------------------------------------------------------- -- #
# -- Codigo: ML No Supervisado: Cluster Analysis de Series de Tiempo --------------- -- #
# -- Licencia: MIT ----------------------------------------------------------------- -- #
# -- ------------------------------------------------------------------------------- -- #

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from matplotlib.finance import candlestick, quotes_historical_yahoo, date2num
from sklearn.cluster import KMeans
from sklearn.preprocessing import normalize
from datetime import datetime, timedelta

# -- -------------------------------------------------------------------- Funciones -- #

# -- Descargar precios Yahoo Finance -- #

def download_data(symbol, days_delta=60):
    finish_date = datetime.today()
    start_date = finish_date - timedelta(days=days_delta)

    stocks_raw = quotes_historical_yahoo(symbol, start_date, finish_date)
    stocks_df = pd.DataFrame(stocks_raw, columns=["n_date", "open", "close",
                                                  "high", "low", "volume"])
    return stocks_df

# -- Configuracion de fecha -- #

def process_date(stocks_df):
    stocks_df["n_date"] = stocks_df["n_date"].astype(np.int32)
    stocks_df["date"] = stocks_df["n_date"].apply(datetime.fromordinal)
    return stocks_df

# -- Calculo de estadisticas -- #

def calculate_stats(stocks_df):
    stocks_df["average"] = (stocks_df["close"] + stocks_df["high"] + stocks_df["low"]) / 3.0
    stocks_df["change_amount"] = stocks_df["close"] - stocks_df["open"]
    stocks_df["change_per"] = stocks_df["change_amount"] / stocks_df["average"]
    stocks_df["range"] = (stocks_df["high"] - stocks_df["low"]) / stocks_df["average"]
    stocks_df["change_1_amount"] = pd.Series(0.0)
    stocks_df["change_1_amount"][1:] = stocks_df["average"][1:].values - stocks_df["average"][:-1].values
    stocks_df["change_1_per"] = stocks_df["change_1_amount"] / stocks_df["average"]
    return stocks_df

# -- Ajuste de datos para Clustering -- #

def pivot_data(stocks_df, values="change_1_per"):
    clustering_data = stocks_df.pivot(index="Ticker", columns="n_date", values=values)
    return clustering_data

# -- Clustering -- #

def cluster_data(data, n_clusters=8, normalize_data=False):
    if normalize_data:
        data = normalize(data.values, norm='l2', axis=1, copy=True)
    cluster_model = KMeans(n_clusters=n_clusters)
    prediction = cluster_model.fit_predict(data)
    return prediction, cluster_model, data

# -- Visualizar Clusters -- #

def visualize_clusters(data_df, values="change_1_per", n_clusters=8, normalize_data=False):
    data = pivot_data(data_df, values)
    prediction, model, c_data = cluster_data(data, n_clusters=n_clusters, normalize_data=normalize_data)
    c_data = pd.DataFrame(c_data, index=data.index,columns=data.columns)
    data["Cluster"] = prediction
    c_data["Cluster"] = prediction
    plt.figure
    for cluster in np.unique(prediction):
        plt.plot(model.cluster_centers_[cluster], "o-", alpha=0.5, linewidth=2)
    plt.show()
    for cluster in np.unique(prediction):
        temp_cluster_data = c_data[c_data["Cluster"]==cluster]
        print "Cluster: %s" % cluster
        print "Members: %s" % ["%s: %s"% (symbol, stock_dict[symbol]) for symbol in list(temp_cluster_data.index)]
        plt.figure()
        plt.title("Cluster#: %s" % cluster)
        plt.plot(model.cluster_centers_[cluster], "o--", alpha=0.5, linewidth=2)
        for symbol in temp_cluster_data.index:
            plt.plot(np.ravel(temp_cluster_data.loc[[symbol]].drop("Cluster", 1).values),
                     alpha=0.2, linewidth=2)

        plt.grid()
        plt.show();
    return prediction, model, c_data

# -- Medicion de desempeno Cluster -- #

def measure_error(prediction, model, c_data):
    error_score = []
    for counter in range(len(c_data)):
        true_val = c_data.drop("Cluster",1).values[counter]
        center_val = model.cluster_centers_[c_data["Cluster"][counter]]

        error_score.append(np.average(np.abs(true_val - center_val)) / np.average(center_val))

    cluster_counts = c_data["Cluster"].value_counts()

    return np.average(error_score), len(cluster_counts[cluster_counts==1])

# -- -------------------------------------------------------------- Datos Generales -- #

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
stocks_data["NAIC"] = names

# -- -------------------------------------------------------------- Ajuste de Datos -- #

# -- Peticion de Precios -- #

temp_list = []
for symbol in stocks_data["Ticker"]:
    temp_data = download_data(symbol)
    process_date(temp_data)
    calculate_stats(temp_data)
    temp_data["Ticker"] = symbol
    temp_list.append(temp_data)

stocks_df = pd.concat(temp_list)

# -- Seleccion Variable Cluster, Normalizacion -- #

clustering_data = pivot_data(stocks_df, values="change_amount")

norm_data = normalize(clustering_data.values, axis=1)
norm_data = pd.DataFrame(norm_data)
for item in norm_data.values:
    plt.plot(item)
plt.show();

# -- -------------------------------------------------------------------- Clustering -- #

# -- Ejecucion de modelo -- #

prediction, model, data = cluster_data(clustering_data, n_clusters=8, normalize_data=True)
print "Cluster Count: %s" % len(np.unique(prediction))
clustering_data["Cluster"] = prediction

# -- Visualizacion de clusters -- #

prediction, model, c_data = visualize_clusters(stocks_df, values="change_amount",
                                               n_clusters=8, normalize_data=True);

# -- Error de modelo --#

measure_error(prediction, model, c_data)

# -- -------------------------------- Exploracion Parametros Optimos para Clustering -- #

max_clusters = 30
feature = "average"
clustering_data = pivot_data(stocks_df, values=feature)
clustering_data["Cluster"] = pd.Series()
for normalize_data in [True, False]:
    fig = plt.figure(figsize=(10,6))
    plt.title("K-Means - Feature: %s Normalized: %s" % (feature, normalize_data))
    axes_1 = fig.add_subplot(111)
    axes_2 = axes_1.twinx()
    score_error_list = []
    failed_clusters_list = []

    for n_clusters in range(2,max_clusters):
        prediction, model, data = cluster_data(clustering_data.drop("Cluster",1), n_clusters=n_clusters,
                                               normalize_data=normalize_data)
        data = pd.DataFrame(data, index=clustering_data.index,columns=clustering_data.drop("Cluster",1).columns)
        data["Cluster"] = prediction
        score_error, failed_clusters =  measure_error(prediction, model, data)
        score_error_list.append(score_error)
        failed_clusters_list.append(failed_clusters)
    axes_1.plot(range(2,max_clusters), score_error_list, "ro-", label = "Average Error")
    axes_2.plot(range(2,max_clusters), failed_clusters_list, "bo-", label = "Failed Cluster")

    axes_1.grid()
    axes_1.legend(loc = "lower center")
    axes_2.legend(loc = "upper center")
    axes_1.set_ylabel("Average Error")
    axes_2.set_ylabel("Failed Cluster")
    axes_1.set_xlabel("Clusters")
    plt.show()