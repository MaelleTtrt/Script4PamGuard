import pandas as pd

filename = 'C:/Users/dupontma2/Desktop/Spyder TL 07-12/source/Aplose results APOCADO_IROISE_C2D1_ST32.csv'

def importAploseselectiontable(filename):
    data = pd.read_csv(filename)
    data['start_datetime'] = pd.to_datetime(data['start_datetime'], format='%Y-%m-%dT%H:%M:%S.%f%Z')
    data['end_datetime'] = pd.to_datetime(data['end_datetime'], format='%Y-%m-%dT%H:%M:%S.%f%Z')
    return data


    