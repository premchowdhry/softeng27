import pandas as pd
import csv
from datetime import datetime
import re

ENERGY_DATASET = "../dataset/Power-Networks-LCL-June2015(withAcornGps)v2.csv"
columns = ['id', 'rate', 'dateTime', 'usage', 'Acorn', 'Acorn_grouped']
LIMIT = 10


def create_single_agg_demands(dataset, limit=None):
    agg_usages = []
    next(dataset)
    for i, chunk in enumerate(dataset):
        if limit and i > limit:
            break
        df = pd.DataFrame(chunk)
        date, time = df['dateTime'].iloc[0].split(" ")
        agg_usages.append((date, df['usage'].sum()))

    return agg_usages


def create_all_agg_demands():
    dataset = pd.read_csv(ENERGY_DATASET, chunksize=48, names=columns, header=None)
    create_single_agg_demands(dataset, limit=10)
