import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final String _jsonUrl =
      'https://raw.githubusercontent.com/luiscidrao/appgloria/refs/heads/main/avisos.json';

  Future<List<AvisoModel>> getAvisos() async {
    final String urlSemCache =
        "$_jsonUrl?t=${DateTime.now().millisecondsSinceEpoch}";
    try {
      final response = await http
          .get(Uri.parse(urlSemCache))
          .timeout(const Duration(seconds: 15));

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
        throw Exception('Erro ao carregar avisos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erro avisos: $e");
      rethrow;
    }
  }
}