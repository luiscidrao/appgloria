import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Adicione ao pubspec.yaml

class VideoModel {
  final String id;
  final String titulo;
  final String thumbnail;
  final String data;
  final bool isLive;
  final bool isUpcoming;

  VideoModel({
    required this.id,
    required this.titulo,
    required this.thumbnail,
    required this.data,
    this.isLive = false,
    this.isUpcoming = false,
  });

  // Necessário para salvar no cache (Converter para texto)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'thumbnail': thumbnail,
      'data': data,
      'isLive': isLive,
      'isUpcoming': isUpcoming,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'],
      titulo: map['titulo'],
      thumbnail: map['thumbnail'],
      data: map['data'],
      isLive: map['isLive'],
      isUpcoming: map['isUpcoming'],
    );
  }
}

class YoutubeService {
  // --- CONFIGURAÇÃO ---
  static const String _apiKey = 'SUA_API_KEY_AQUI';
  static const String _channelId = 'UC_ID_DO_CANAL';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  // Cache de 1 hora (evita estourar a cota)
  static const Duration _cacheDuration = Duration(hours: 1);

  Future<List<VideoModel>> getVideos() async {
    try {
      // 1. Tenta carregar do Cache primeiro
      final cacheData = await _loadFromCache();
      if (cacheData != null) {
        return cacheData;
      }

      // 2. Se não tiver cache ou venceu, busca na API
      final Uri url = Uri.parse(
          '$_baseUrl?key=$_apiKey&channelId=$_channelId&part=snippet&order=date&maxResults=10&type=video'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        List<VideoModel> videos = items.map((item) {
          final snippet = item['snippet'];
          final String liveBroadcast = snippet['liveBroadcastContent'].toString();

          String dataFormatada = "";
          try {
            DateTime publishedAt = DateTime.parse(snippet['publishedAt']);
            dataFormatada = DateFormat("dd/MM 'às' HH:mm", 'pt_BR').format(publishedAt);
          } catch (e) {
            dataFormatada = "Data desconhecida";
          }

          return VideoModel(
            id: item['id']['videoId'],
            titulo: snippet['title'],
            thumbnail: snippet['thumbnails']['high']['url'],
            data: dataFormatada,
            isLive: liveBroadcast == 'live',
            isUpcoming: liveBroadcast == 'upcoming',
          );
        }).toList();

        // 3. Salva a nova lista no Cache
        _saveToCache(videos);

        return videos;
      } else {
        print("Erro API: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erro: $e");
      // Se der erro de internet, tenta mostrar o cache antigo mesmo vencido (fallback)
      final oldCache = await _loadFromCache(ignoreExpiration: true);
      return oldCache ?? [];
    }
  }

  // --- LÓGICA DE CACHE (Shared Preferences) ---

  Future<void> _saveToCache(List<VideoModel> videos) async {
    final prefs = await SharedPreferences.getInstance();
    // Salva a lista como JSON
    final String jsonList = json.encode(videos.map((v) => v.toMap()).toList());
    // Salva o horário atual
    await prefs.setString('youtube_cache_data', jsonList);
    await prefs.setInt('youtube_cache_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<VideoModel>?> _loadFromCache({bool ignoreExpiration = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('youtube_cache_data')) return null;

    final int? timestamp = prefs.getInt('youtube_cache_time');
    if (timestamp == null) return null;

    final DateTime savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();

    // Se o cache for velho (> 1 hora) e não estamos forçando, retorna null para buscar novo
    if (!ignoreExpiration && now.difference(savedTime) > _cacheDuration) {
      return null;
    }

    final String? jsonList = prefs.getString('youtube_cache_data');
    if (jsonList == null) return null;

    final List<dynamic> decoded = json.decode(jsonList);
    return decoded.map((map) => VideoModel.fromMap(map)).toList();
  }
}