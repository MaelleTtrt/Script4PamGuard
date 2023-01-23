import sys
from tkinter.filedialog import askdirectory
import os
import easygui
import pandas as pd
import pytz
dirname = os.path.dirname
sys.path.append('C:/Users/dupontma2/Desktop/Spyder TL 07-12/source/Aplose results APOCADO_IROISE_C2D1_ST32.csv')

TZ ='Europe/Paris'

# If choice = 1, all the waves are analysed
# If choice = 2, the user define a range of study
# TODO : gérer erreurs input
choice = 2;

# Time vector resolution
# time_bin = str2double(inputdlg("time bin ? (s)"));
time_bin = 10; #Same size than Aplose annotations

# If skip_Ap = 1, only PG detections are analysed
skip_Ap = 1;

# wav folder
folder_data_wav = askdirectory(title='Select folder contening wav files')
if folder_data_wav == '': print("Select folder contening wav files - Error")

# data folder
folder_data = dirname(folder_data_wav)

#Binary folder
folder_data_PG = askdirectory(title='Select folder contening PAMGuard binary results')
if folder_data_PG == '': print("Select folder contening PAMGuard binary results - Error")


input1 = pytz.timezone(TZ).localize(pd.to_datetime(easygui.enterbox("Date & Time beginning (dd MM yyyy HH mm ss) :"), format='%d %m %Y %H %M %S'))

if choice==2:
    input1 = pytz.timezone(TZ).localize(pd.to_datetime(easygui.enterbox("Date & Time begin (dd MM yyyy HH mm ss) :"), format='%d %m %Y %H %M %S'))
    input2 = pytz.timezone(TZ).localize(pd.to_datetime(easygui.enterbox("Date & Time end (dd MM yyyy HH mm ss) :"), format='%d %m %Y %H %M %S'))

#Infos from wav files

#wav infos : name, path, datetime
wavList=[]
wavPath=[]
wavFolderInfo = pd.DataFrame()
from pathlib import Path
for file in Path(folder_data_wav).glob("**/*.wav"):
    wavList.append(os.path.basename(file))
    wavPath.append(os.path.dirname(file))
wavFolderInfo['name'] = pd.DataFrame(wavList, columns=['wavList'])
wavFolderInfo['path'] = pd.DataFrame(wavPath, columns=['wavPath'])


wavSplitName = wavFolderInfo['name'].str.split(pat='.')
for i in range(len(wavSplitName)+1):
    print(i) 
    
#####APOCADO
wavFolderInfo['wavDates'] = [pytz.timezone(TZ).localize(pd.to_datetime(j[1], format='%y%m%d%H%M%S')) for i,j in enumerate(wavSplitName)]
####CETIROISE
# wavFolderInfo['wavDates'] = [pytz.timezone(TZ).localize(pd.to_datetime(j[1], format='%Y-%m-%d_%H-%M-%S')) for i,j in enumerate(wavSplitName)]



