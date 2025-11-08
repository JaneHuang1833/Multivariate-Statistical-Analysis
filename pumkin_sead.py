import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from pygam import LogisticGAM, s
import numpy as np
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import StandardScaler
from pygam import LogisticGAM, s
from sklearn.metrics import accuracy_score
from sklearn.metrics import log_loss


df = pd.read_excel('5-Pumpkin_Seeds_Dataset.xlsx')


X = df[['Area', 'Perimeter', 'Major_Axis_Length', 'Minor_Axis_Length','Convex_Area']].to_numpy()
y = df['Class'].to_numpy()

le = LabelEncoder()
y = le.fit_transform(y)

scaler = StandardScaler()
X = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)
