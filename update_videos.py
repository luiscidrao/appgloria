import os
import json
import requests

# O robô pega a chave dos Segredos do GitHub automaticamente
API_KEY = os.environ['YOUTUBE_API_KEY']

# ID do Canal da Paróquia da Glória
CHANNEL_ID = 'UClz9W7Ydm216ESYM7TxlN1w'

def get_videos():
    # URL para buscar snippets (detalhes) dos vídeos
    url = f"https://www.googleapis.com/youtube/v3/search?key={API_KEY}&channelId={CHANNEL_ID}&part=snippet&order=date&maxResults=10&type=video"

    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        videos = []
        for item in data.get('items', []):
            snippet = item['snippet']
            broadcast = snippet.get('liveBroadcastContent', 'none')

            video = {
                'id': item['id']['videoId'],
                'titulo': snippet['title'],
                'thumbnail': snippet['thumbnails']['high']['url'],
                'data_publicacao': snippet['publishedAt'],
                'isLive': broadcast == 'live',
                'isUpcoming': broadcast == 'upcoming'
            }
            videos.append(video)

        return videos

    except Exception as e:
        print(f"Erro: {e}")
        return None

if __name__ == "__main__":
    lista = get_videos()
    if lista:
        with open('videos.json', 'w', encoding='utf-8') as f:
            json.dump(lista, f, ensure_ascii=False, indent=2)
        print("Sucesso! Lista salva em videos.json")
    else:
        print("Falha ao buscar vídeos.")
        exit(1)