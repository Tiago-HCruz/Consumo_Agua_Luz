#   Importanto as Bibliotecas
import pandas as pd
import json as js
import numpy as np
import requests
import urllib.request


#response = requests.get("Dados/ID_Registros.json")
#with open("Dados/ID_Registros.json") as file: data = js.load(file)
#json_registros = js.dumps("Dados/ID_Registros.json")
#print(json_string)


#   Carregando o Banco de dados original 
url = "https://raw.githubusercontent.com/Tiago-HCruz/Consumo_Agua_Luz/main/Dados/ID_Registros.json"

with urllib.request.urlopen(url) as response:
     body_json = response.read()

body_dict = js.loads(body_json)
body_dict

df = pd.json_normalize(body_dict)


#   Convertendo a classificação das variaveis corretas
df['Id'] = df['Id'].astype(str)
df['Conta'] = df['Conta'].astype(str)
df['Data'] = df['Data'].astype(str)
df['Consumo'] = df['Consumo'].astype(str).astype(int)
df['Dias_de_Consumo'] = df['Dias_de_Consumo'].astype(str).astype(int)
df['Pago'] = df['Pago'].astype(str)


#   Criando um novo banco de dados sobre o consumo medio diario
##   Converter "m³" em "Litros" (1m³ = 1000L)
##   Converter "kWh" em "Wh" (1kWh = 1000Wh")

##   Copiando as variaveis "Id", "Conta", "Data" e "Pago" para o novo banco de dados 
df2 = df[["Id", "Conta", "Data", "Pago"]]

##   Obtendo Consumo Médio Diario para o novo banco de dados.
def Consumo_Medio_Diario(Consumo, Dias_de_Consumo):
        return round((Consumo*1000)/Dias_de_Consumo)

df2["Consumo_Medio_Diario"] = df.loc[:, ["Id", "Conta", "Data", "Pago", 
                                         "Unidade_Medida", "Dias_de_Consumo", 
                                         "Consumo"]].\
                              apply(lambda x: Consumo_Medio_Diario(x['Consumo'], 
                                                                   x['Dias_de_Consumo']), 
                                                                   axis=1)

##   Adicionando nova variavel "Unidade_Medida" com base na conversão feita na 
## codificação anterior.                            
df2["Unidade_Medida"] = np.where(df['Unidade_Medida'] == 'm³', 
                                 'L', 
                                 'Wh')


# Criação de uma função que faça as 'Despesas'
def Despesa(Conta):

  despesa_consumo = [0]
  list_len_conta = [x+1 for x in range(len(df2[df2.Conta == Conta]))]

  print("Iniciandodo o cálculo das despesas de consumo na conta de", Conta)
  for index in list_len_conta:
      if index != df2[df2.Conta == Conta].shape[0]:
        razao_despesa = df2.loc[df2.Conta == Conta, "Consumo_Medio_Diario"].iloc[index] - \
                        df2.loc[df2.Conta == Conta, "Consumo_Medio_Diario"].iloc[index-1]
        despesa_consumo = despesa_consumo + [razao_despesa]
      else:
        print("Cálculo das despesas de consumo na conta de", Conta, "feita com sucesso")
    
  return despesa_consumo
  
df2["Despesa"] = Despesa("Água") + Despesa("Luz")


#   Converta o banco de dados em dicionários e logo depois para JSON 
# (o banco de dados json será demostrado ao imprimir o codigo)
json_result = js.dumps(df2.to_dict('records'))
json_result


#   Carregando o Banco de dados Diario medio
url = "https://raw.githubusercontent.com/Tiago-HCruz/Consumo_Agua_Luz/main/Dados/ID_Registros_Diario.json"

with urllib.request.urlopen(url) as response:
     body_json = response.read()

body_dict = js.loads(body_json)
body_dict

df_test = pd.json_normalize(body_dict)
df_test
