import pandas as pd
import numpy as np

def removeLine():   
    with open('hours.csv', 'r') as fin:
        data = fin.read().splitlines(True)
    with open('hours.csv', 'w') as fout:
        fout.writelines(data[1:])

#removeLine()

data = pd.read_csv('hours.csv')
#print(data.head(10))
pt = pd.pivot_table(data,index=["company"],columns=["name"],values=["hours"],aggfunc=[np.sum],fill_value=0,margins=True)
print(pt)
#pt = pt.sort_values(by=('company','hours','All'), ascending=False,inplace=True)
#print(pt)
