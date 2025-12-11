import os
import json
import requests

# --- CONFIGURAÇÕES ---
# O robô vai ler a senha dos segredos do GitHub (não coloque a chave aqui direto!)
API_KEY = os.environ['YOUTUBE_API_KEY']
# Substitua pelo ID do Canal da Paróquia da Glória (o mesmo que usava antes)
CHANNEL_ID = 'UC_ID_DO_CANAL_DA_PAROQUIA'

def get_videos():
    url = f"https://www.googleapis.com/youtube/v3/search?key={API_KEY}&channelId={CHANNEL_ID}&part=snippet&order=date&maxResults=10&type=video"

    try:
        response = requests.get(url)
        response.raise_for_status() # Para se der erro 400/500
        data = response.json()

        videos_processados = []

        for item in data.get('items', []):
            snippet = item['snippet']
            broadcast = snippet.get('liveBroadcastContent', 'none')

            # Cria um objeto limpo, só com o que o App precisa
            video = {
                'id': item['id']['videoId'],
                'titulo': snippet['title'],
                'thumbnail': snippet['thumbnails']['high']['url'],
                'data_publicacao': snippet['publishedAt'], # Data crua (o Flutter formata)
                'isLive': broadcast == 'live',
                'isUpcoming': broadcast == 'upcoming'
            }
            videos_processados.append(video)

        return videos_processados

    except Exception as e:
        print(f"Erro no script: {e}")
        return None

if __name__ == "__main__":
    lista_nova = get_videos()

    if lista_nova:
        # Salva no arquivo videos.json na mesma pasta
        with open('videos.json', 'w', encoding='utf-8') as f:
            json.dump(lista_nova, f, ensure_ascii=False, indent=2)
        print("Sucesso! Arquivo videos.json atualizado.")
    else:
        print("Falha ao buscar vídeos. Nada foi alterado.")
        exit(1) # Avisa o GitHub que deu erro