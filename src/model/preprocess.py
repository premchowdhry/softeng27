import pandas as pd
import csv
from datetime import datetime
import dask.dataframe as dd

ENERGY_DATASET = "src/dataset/Power-Networks-LCL-June2015(withAcornGps)v2.csv"
columns = ['id', 'rate', 'dateTime', 'usage', 'Acorn', 'Acorn_grouped']
to_drop = ['rate', 'Acorn', 'Acorn_grouped']


agg_usages = []

#use date as key, if data is null or doesn't exist, use average usage of the other users on the same day
#count the number of users who has data for each day

def replaceNull(u):
    try:
        return float(u)
    finally:
        return 0


def create_all_agg_demands():

    dataset = dd.read_csv(ENERGY_DATASET, names=columns, header=0, converters={'KWH/hh (per half hour)':replaceNull})

    dataset = dataset.drop(columns = to_drop)

    # print(dataset.head())
    print(dataset.isnull())
    # dataset = dataset[~dataset.usage.isnull()]
    #dataset.drop([c for c in dataset.columns if dataset[c].isnull().any().compute()], axis=0)
    demands = dataset[['dateTime', 'usage']].groupby('dateTime')
    demands.usage.sum().compute()

create_all_agg_demands()
