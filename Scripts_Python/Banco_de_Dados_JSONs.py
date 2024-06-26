#Importanto as Bibliotecas

import pandas as pd
import json as js
import requests
import urllib.request

#response = requests.get("Dados/ID_Registros.json")

#with open("Dados/ID_Registros.json") as file: data = js.load(file)

#json_registros = js.dumps("Dados/ID_Registros.json")
#print(json_string)

# Carregando arquivo Json

url = "https://raw.githubusercontent.com/Tiago-HCruz/Consumo_Agua_Luz/main/Dados/ID_Registros.json"

with urllib.request.urlopen(url) as response:
     body_json = response.read()

body_dict = js.loads(body_json)
body_dict

df = pd.json_normalize(body_dict)

# Convertendo a classificação das variaveis corretas
df['Id'] = df['Id'].astype(str)
df['Conta'] = df['Conta'].astype(str)
df['Data'] = df['Data'].astype(str)
df['Consumo'] = df['Consumo'].astype(str).astype(int)
df['Dias_de_Consumo'] = df['Dias_de_Consumo'].astype(str).astype(int)
df['Pago'] = df['Pago'].astype(str)

#Calculando o consumo diario e alterando as unidade de medidas da agua e luz
df["Consumo_Diario"] = (df.Consumo/df.Dias_de_Consumo)
df