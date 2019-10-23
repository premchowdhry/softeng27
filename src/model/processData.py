# Load the required packages
import time
import psutil
import numpy as np
import pandas as pd
import multiprocessing as mp

ENERGY_DATASET = "src/dataset/Power-Networks-LCL-June2015(withAcornGps)v2.csv"
columns = ['id', 'rate', 'dateTime', 'usage', 'Acorn', 'Acorn_grouped']


# Check the number of cores and memory usage
num_cores = mp.cpu_count()
print("This kernel has ",num_cores,"cores and you can find the information regarding the memory usage:",psutil.virtual_memory())

# Writing as a function
def process_user_log(chunk):
    grouped_object = chunk.groupby(chunk.index,sort=False) # not sorting results in a minor speedup
    func = {' DateTime':['count'],'KWH/hh (per half hour)':['sum']}
    answer = grouped_object.agg(func)
    return answer

# Number of rows for each chunk
size = 1e4 # 10k
reader = pd.read_csv(ENERGY_DATASET, chunksize=size, index_col=[' DateTime'])
start_time = time.time()

for i in range(5):
    user_log_chunk = next(reader)
    if(i==0):
        result = process_user_log(user_log_chunk)
        print("Number of rows ",result.shape[0])
        print("Loop ",i,"took %s seconds" % (time.time() - start_time))
    else:
        result = result.append(process_user_log(user_log_chunk))
        print("Number of rows ",result.shape[0])
        print("Loop ",i,"took %s seconds" % (time.time() - start_time))
    del(user_log_chunk)

# Unique users vs Number of rows after the first computation
print("size of result:", len(result))
check = result.index.unique()
print("unique dateTime in result:", len(check))

result.columns = ['_'.join(col).strip() for col in result.columns.values]


func = {'DateTime_min':['min'],'DateTime_max':['max'],'DateTime_count':['count'], 'KWH/hh (per half hour)_sum':['sum']}
processed_user_log = result.groupby(result.index).agg(func)
print(len(processed_user_log))

processed_user_log.columns = processed_user_log.columns.get_level_values(0)
processed_user_log.head()
