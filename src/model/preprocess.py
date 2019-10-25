import pandas as pd
import csv
from datetime import datetime
import numpy as np
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
        return 0.0

def convert_float(s):
    try:
        return s
    finally:
        return "Fail"


def create_all_agg_demands():

    dataset = dd.read_csv(ENERGY_DATASET, names=columns, header=0, converters={'KWH/hh (per half hour)':replaceNull}, low_memory=False)
    dataset = dataset.drop(columns = to_drop)
    dataset = dataset.get_partition(0)

    demands = dataset[['dateTime', 'usage']].groupby('dateTime')
    agg_demands_df = demands.usage.sum().reset_index().compute()
    agg_demands_array = agg_demands_df.values

    days = []
    for d in agg_demands_array[:, 0]:
        days.append([d])
    aggs = []
    for a in agg_demands_array[:, 1]:
        val = None
        try:
            val = float(a.split()[0])
        except ValueError:
            val = 0.0
        aggs.append(val)

    return days, aggs

create_all_agg_demands()
