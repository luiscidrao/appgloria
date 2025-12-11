import 'dart:convert';
import 'package:http/http.dart' as http;

class AvisoModel {
  final String titulo;
  final String data;
  final String mensagem;
  final bool destaque;

  AvisoModel({
    required this.titulo,
    required this.data,
    required this.mensagem,
    required this.destaque,
  });
}

class AvisosService {
  // ==============================================================================
  // 🔴 IMPORTANTE: Substitua este link pelo seu RAW do 'avisos.json' no GitHub
  // ==============================================================================
  final String _jsonUrl = 'https://raw.githubusercontent.com/SEU_USUARIO/appgloria/main/avisos.json';

  Future<List<AvisoModel>> getAvisos() async {
    try {
      // O '?t=...' evita que o celular guarde cache velho
      String urlSemCache = "$_jsonUrl?t=${DateTime.now().millisecondsSinceEpoch}";

      final response = await http.get(Uri.parse(urlSemCache));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);

        return list.map((item) {
          return AvisoModel(
            titulo: item['titulo'] ?? "",
            data: item['data'] ?? "",
            mensagem: item['mensagem'] ?? "",
            destaque: item['destaque'] ?? false,
          );
        }).toList();
      } else {
        throw Exception('Erro ao carregar avisos');
      }
    } catch (e) {
      print("Erro avisos: $e");
      return []; // Retorna lista vazia se der erro
    }
  }
}