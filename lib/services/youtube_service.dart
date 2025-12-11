import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
}

class YoutubeService {
  // ==============================================================================
  // 🔴 IMPORTANTE: COLE AQUI O SEU LINK RAW DO GITHUB (que termina em videos.json)
  // ==============================================================================
  final String _jsonUrl = 'https://raw.githubusercontent.com/luiscidrao/appgloria/refs/heads/main/videos.json';

  Future<List<VideoModel>> getVideos() async {
    try {
      // Adiciona um número aleatório no final (?t=...) para o celular não usar cache velho
      // Isso garante que se você atualizar o JSON, o usuário vê na hora.
      String urlSemCache = "$_jsonUrl?t=${DateTime.now().millisecondsSinceEpoch}";

      final response = await http.get(Uri.parse(urlSemCache));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);

        return list.map((item) {
          String dataFormatada = "";
          try {
            // O Python salvou como 'data_publicacao' (formato ISO). Vamos formatar bonito.
            DateTime publishedAt = DateTime.parse(item['data_publicacao']);
            dataFormatada = DateFormat("dd/MM 'às' HH:mm", 'pt_BR').format(publishedAt);
          } catch (e) {
            dataFormatada = "Recente";
          }

          return VideoModel(
            id: item['id'],
            titulo: item['titulo'],
            thumbnail: item['thumbnail'],
            data: dataFormatada,
            // O Python manda true/false direto no JSON agora
            isLive: item['isLive'] ?? false,
            isUpcoming: item['isUpcoming'] ?? false,
          );
        }).toList();
      } else {
        throw Exception('Erro ao baixar lista de vídeos');
      }
    } catch (e) {
      print("Erro no YoutubeService: $e");
      return []; // Retorna lista vazia se der erro (sem internet)
    }
  }
}