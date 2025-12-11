import json
import requests
import csv
import io

# ==============================================================================
# 🔴 IMPORTANTE: COLE AQUI O LINK CSV DA SUA PLANILHA GOOGLE
# (Vá em: Arquivo > Compartilhar > Publicar na Web > Escolha a aba > Formato CSV)
# ==============================================================================
SHEET_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vRoKUGDXqpBldSYmeEyAWxi9u3WVi-rMJJt7hjKwqEbtYldRJOpmwiirZblIMfOHJ2bXBWhIOQ5PoyM/pub?output=csv'

def atualizar_avisos():
    try:
        print("Baixando planilha...")
        response = requests.get(SHEET_URL)
        response.raise_for_status()

        # --- CORREÇÃO DE ACENTUAÇÃO (UTF-8) ---
        # Forçamos a leitura dos dados como UTF-8 para corrigir "Ã§" e outros símbolos
        conteudo_csv = response.content.decode('utf-8')

        # Lê o CSV a partir do texto decodificado
        f = io.StringIO(conteudo_csv)
        reader = csv.DictReader(f)

        avisos = []

        for row in reader:
            # Proteção: Pula linhas onde o Título está vazio
            if not row.get('Titulo'):
                continue

            # Verifica se é destaque (lê "SIM", "Sim" ou "sim")
            # O .get garante que não quebra se a coluna não estiver preenchida
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
        # Salva o arquivo JSON também em UTF-8
        with open('avisos.json', 'w', encoding='utf-8') as f:
            json.dump(dados, f, ensure_ascii=False, indent=2)
        print(f"Sucesso! {len(dados)} avisos sincronizados.")
    else:
        print("Falha na sincronização ou planilha vazia.")
        exit(1) # Avisa o GitHub que deu erro