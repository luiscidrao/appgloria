import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class LiturgiaItem {
  final String titulo;
  final String referencia;
  final String corpo;

  LiturgiaItem({required this.titulo, required this.referencia, required this.corpo});
}

class LiturgiaDiariaModel {
  final String data;
  final String corLiturgica; // Ex: "Cor Litúrgica: Roxo"
  final String tituloDia;    // Ex: "2ª Semana do Advento"
  final LiturgiaItem primeiraLeitura;
  final LiturgiaItem salmo;
  final LiturgiaItem segundaLeitura;
  final LiturgiaItem evangelho;

  LiturgiaDiariaModel({
    required this.data,
    required this.corLiturgica,
    required this.tituloDia,
    required this.primeiraLeitura,
    required this.salmo,
    required this.segundaLeitura,
    required this.evangelho,
  });
}

class LiturgiaService {
  final String _url = 'https://liturgia.cancaonova.com/pb/';

  Future<LiturgiaDiariaModel> getLiturgiaDoDia() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);

        // 1. Extração do Título do Dia
        String tituloDia = document.querySelector('.entry-title')?.text.trim() ?? "Liturgia Diária";

        // 2. Extração da Cor Litúrgica (Novo!)
        String cor = "Cor: Verde"; // Padrão
        var corElement = document.querySelector('.cor-liturgica');
        if (corElement != null) {
          cor = corElement.text.trim(); // Vai pegar "Cor Litúrgica: Roxo"
        }

        return LiturgiaDiariaModel(
          data: DateTime.now().toString(),
          tituloDia: tituloDia,
          corLiturgica: cor,
          primeiraLeitura: _extrairItem(document, 'liturgia-1'),
          salmo: _extrairItem(document, 'liturgia-2'),
          segundaLeitura: _extrairItem(document, 'liturgia-3-extra'),
          evangelho: _extrairItem(document, 'liturgia-3'),
        );
      } else {
        throw Exception('Site indisponível');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  LiturgiaItem _extrairItem(Document document, String id) {
    var elemento = document.getElementById(id);
    // Lógica de fallback para evangelho
    if (elemento == null && id == 'liturgia-3') {
      var tab4 = document.getElementById('liturgia-4');
      if (tab4 != null) elemento = tab4;
    }

    if (elemento == null) {
      return LiturgiaItem(titulo: "", referencia: "", corpo: "Indisponível");
    }

    // Separa Título da Referência (Tentativa básica)
    String tituloCompleto = elemento.querySelector('.entry-title')?.text.trim() ?? "";

    // Limpeza profunda do texto para remover espaços extras do HTML
    var contentElement = elemento.querySelector('.entry-content');
    String corpo = "";

    if (contentElement != null) {
      // Pega o texto preservando quebras de linha básicas
      corpo = contentElement.text.trim();
    } else {
      corpo = elemento.text.trim();
    }

    return LiturgiaItem(
        titulo: tituloCompleto,
        referencia: "",
        corpo: corpo
    );
  }
}