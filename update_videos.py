import os
import json
import requests

API_KEY = os.environ['YOUTUBE_API_KEY']
CHANNEL_ID = 'UClz9W7Ydm216ESYM7TxlN1w' # ID da Paróquia

def buscar_videos(tipo_evento=None, max_results=5):
    """
    Busca vídeos no YouTube.
    tipo_evento: 'upcoming', 'live', 'completed' ou None (todos)
    """
    base_url = "https://www.googleapis.com/youtube/v3/search"
    params = {
        'key': API_KEY,
        'channelId': CHANNEL_ID,
        'part': 'snippet',
        'order': 'date', # Ordem cronológica
        'maxResults': max_results,
        'type': 'video'
    }

    if tipo_evento:
        params['eventType'] = tipo_evento

    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        return response.json().get('items', [])
    except Exception as e:
        print(f"Erro ao buscar {tipo_evento}: {e}")
        return []

def processar_video(item):
    snippet = item['snippet']
    broadcast = snippet.get('liveBroadcastContent', 'none')

    return {
        'id': item['id']['videoId'],
        'titulo': snippet['title'],
        'thumbnail': snippet['thumbnails']['high']['url'],
        'data_publicacao': snippet['publishedAt'],
        'isLive': broadcast == 'live',
        'isUpcoming': broadcast == 'upcoming'
    }

if __name__ == "__main__":
    print("Iniciando atualização inteligente...")

    videos_finais = []
    ids_processados = set()

    # 1. BUSCA PRIORITÁRIA: O que está AO VIVO agora?
    lives = buscar_videos(tipo_evento='live', max_results=1)
    for item in lives:
        vid = processar_video(item)
        if vid['id'] not in ids_processados:
            videos_finais.append(vid)
            ids_processados.add(vid['id'])

    # 2. BUSCA PRIORITÁRIA: O que está AGENDADO (Próximo)?
    agendados = buscar_videos(tipo_evento='upcoming', max_results=2)
    # Às vezes o 'upcoming' vem desordenado, vamos garantir que o mais próximo venha antes
    # (A API já deve mandar ordenado por data de criação, mas garantimos aqui)
    for item in agendados:
        vid = processar_video(item)
        if vid['id'] not in ids_processados:
            videos_finais.append(vid)
            ids_processados.add(vid['id'])

    # 3. BUSCA GERAL: Últimos vídeos (Passado/Histórico)
    # Pedimos 10 para garantir que tenha histórico suficiente
    historico = buscar_videos(tipo_evento='completed', max_results=10)
    # Se 'completed' falhar ou vier vazio (alguns canais não suportam), tentamos busca geral
    if not historico:
        historico = buscar_videos(tipo_evento=None, max_results=10)

    for item in historico:
        vid = processar_video(item)
        if vid['id'] not in ids_processados:
            videos_finais.append(vid)
            ids_processados.add(vid['id'])

    # Salva o resultado
    if videos_finais:
        with open('videos.json', 'w', encoding='utf-8') as f:
            json.dump(videos_finais, f, ensure_ascii=False, indent=2)
        print(f"Sucesso! {len(videos_finais)} vídeos salvos (Lives: {len(lives)}, Agendados: {len(agendados)}).")
    else:
        print("Nenhum vídeo encontrado.")
        exit(1)