import json
import requests
import csv
import io
import os

# ==============================================================================
# COLE O LINK DA SUA PLANILHA AQUI (AQUELE QUE TERMINA EM .csv):
# ==============================================================================
SHEET_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vRoKUGDXqpBldSYmeEyAWxi9u3WVi-rMJJt7hjKwqEbtYldRJOpmwiirZblIMfOHJ2bXBWhIOQ5PoyM/pub?output=csv'

def atualizar_avisos():
    try:
        print("Baixando planilha...")
        response = requests.get(SHEET_URL)
        response.raise_for_status()

        # O Google manda os dados como texto, transformamos em leitura CSV
        f = io.StringIO(response.text)
        reader = csv.DictReader(f)

        avisos = []

        for row in reader:
            # Proteção: Pula linhas vazias (sem título)
            if not row.get('Titulo'):
                continue

            # Verifica se é destaque (lê "SIM" ou "sim")
            e_destaque = str(row.get('Destaque', '')).strip().upper() == 'SIM'

            avisos.append({
                "titulo": row['Titulo'],
                "data": row['Data'],
                "mensagem": row['Mensagem'],
                "destaque": e_destaque
            })

        return avisos

    except Exception as e:
        print(f"Erro ao processar planilha: {e}")
        return None

if __name__ == "__main__":
    dados = atualizar_avisos()
    if dados:
        # Salva o arquivo JSON que o App vai ler
        with open('avisos.json', 'w', encoding='utf-8') as f:
            json.dump(dados, f, ensure_ascii=False, indent=2)
        print(f"Sucesso! {len(dados)} avisos sincronizados.")
    else:
        print("Falha na sincronização.")
        exit(1)