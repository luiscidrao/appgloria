import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';
import 'services/liturgia_service.dart';
import 'widgets/vitral_background.dart';

class LiturgiaDetalhadaScreen extends StatefulWidget {
  final LiturgiaDiariaModel liturgia;

  const LiturgiaDetalhadaScreen({super.key, required this.liturgia});

  @override
  State<LiturgiaDetalhadaScreen> createState() => _LiturgiaDetalhadaScreenState();
}

class _LiturgiaDetalhadaScreenState extends State<LiturgiaDetalhadaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterTts flutterTts = FlutterTts();

  double _fontSize = 18.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _tabController = TabController(length: 3, vsync: this);
    _configurarAudio();
  }

  void _configurarAudio() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _speak(String text) async {
    if (_isPlaying) {
      await flutterTts.stop();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      if (text.isNotEmpty && text != "Indisponível") {
        if (mounted) setState(() => _isPlaying = true);
        await flutterTts.speak(text);
      }
    }
  }

  void _changeFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(14.0, 30.0);
    });
  }

  Color _getCorLiturgicaColor(String texto) {
    String t = texto.toLowerCase();
    if (t.contains('roxo')) return Colors.purple;
    if (t.contains('verde')) return Colors.green;
    if (t.contains('vermelho')) return Colors.red;
    if (t.contains('branco')) return Colors.amber.shade100;
    if (t.contains('rosa')) return Colors.pinkAccent;
    return AppTheme.gold;
  }

  @override
  void dispose() {
    flutterTts.stop();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String dia = DateFormat('dd').format(now);
    String mesAno = DateFormat('MMM yyyy', 'pt_BR').format(now).toUpperCase();
    String tituloDia = widget.liturgia.tituloDia.replaceAll(" | ", "\n");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparente para ver o vitral atrás
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80, // Um pouco maior para caber o título
        flexibleSpace: Container(
          // O Vitral fica restrito a este Container
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          ),
          child: const VitralAnimado(),
        ),
        title: const Text("Liturgia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white, // Fundo branco para as abas
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold,
              indicatorWeight: 4,
              labelColor: AppTheme.royalBlue, // Texto ativo Azul
              unselectedLabelColor: Colors.grey, // Texto inativo cinza
              labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "1ª LEITURA"),
                Tab(text: "SALMOS"),
                Tab(text: "EVANGELHO"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de Controles e Data (Cinza claro)
          Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(dia, style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.royalBlue)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mesAno, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Text(DateFormat('EEEE', 'pt_BR').format(now), style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildControlButton("A-", () => _changeFontSize(-2)),
                    const SizedBox(width: 8),
                    _buildControlButton("A+", () => _changeFontSize(2)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        int index = _tabController.index;
                        String texto = "";
                        if (index == 0) texto = widget.liturgia.primeiraLeitura.corpo;
                        if (index == 1) texto = widget.liturgia.salmo.corpo;
                        if (index == 2) texto = widget.liturgia.evangelho.corpo;
                        _speak(texto);
                      },
                      child: CircleAvatar(
                        backgroundColor: _isPlaying ? Colors.red[100] : Colors.blue[100],
                        radius: 20,
                        child: Icon(
                          _isPlaying ? Icons.stop : Icons.volume_up,
                          color: _isPlaying ? Colors.red : AppTheme.royalBlue,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),

          // Informações do Dia (Branco)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: _getCorLiturgicaColor(widget.liturgia.corLiturgica).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getCorLiturgicaColor(widget.liturgia.corLiturgica).withOpacity(0.5))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 10, color: _getCorLiturgicaColor(widget.liturgia.corLiturgica)),
                      const SizedBox(width: 6),
                      Text(
                        widget.liturgia.corLiturgica.replaceAll("Cor Litúrgica:", "").trim(),
                        style: GoogleFonts.raleway(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tituloDia,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.royalBlue),
                ),
              ],
            ),
          ),

          // Conteúdo do Texto
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTextoView(widget.liturgia.primeiraLeitura),
                _buildTextoView(widget.liturgia.salmo),
                _buildTextoView(widget.liturgia.evangelho),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
      ),
    );
  }

  Widget _buildTextoView(LiturgiaItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.titulo.isNotEmpty) ...[
            Text(
              item.titulo,
              style: GoogleFonts.montserrat(
                fontSize: _fontSize + 2,
                fontWeight: FontWeight.w900,
                color: AppTheme.royalBlue,
              ),
            ),
            const SizedBox(height: 20),
          ],

          _buildRichBody(item.corpo),

          const SizedBox(height: 60),
          Center(
            child: Text(
              "Conferência Nacional dos Bispos do Brasil\n© Todos os direitos reservados.",
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(fontSize: 10, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Lógica Avançada de Negrito
  Widget _buildRichBody(String rawText) {
    List<String> lines = rawText.split('\n');
    List<Widget> paragraphs = [];

    // Regex para pegar números isolados no início ou meio da frase (versículos)
    final RegExp numberRegex = RegExp(r'\b\d+\b');

    for (String line in lines) {
      String trimmed = line.trim();
      if (trimmed.isEmpty) {
        paragraphs.add(const SizedBox(height: 16));
        continue;
      }

      // 1. Títulos e Respostas Completas em Negrito
      bool isFullBold = false;
      String lower = trimmed.toLowerCase();
      if (lower.startsWith("leitura") ||
          lower.startsWith("proclamação") ||
          lower.startsWith("primeira leitura") ||
          lower.startsWith("segunda leitura") ||
          lower.startsWith("salmo") ||
          lower.startsWith("evangelho") ||
          lower.startsWith("— palavra") ||
          lower.startsWith("- palavra") ||
          lower.startsWith("— graças") ||
          lower.startsWith("- graças") ||
          lower.startsWith("— glória") ||
          lower.startsWith("- glória") ||
          lower.startsWith("r.") ||
          lower.startsWith("refrão") ||
          lower.startsWith("responsório")) {
        isFullBold = true;
      }

      if (isFullBold) {
        paragraphs.add(
          Text(
            trimmed,
            style: GoogleFonts.raleway(
              fontSize: _fontSize,
              fontWeight: FontWeight.w800, // Extra Bold
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        );
      } else {
        // 2. Texto comum com versículos em negrito colorido
        List<TextSpan> spans = [];

        trimmed.splitMapJoin(
          numberRegex,
          onMatch: (Match m) {
            spans.add(TextSpan(
              text: "${m[0]}",
              // VERSÍCULO: Azul e Negrito
              style: GoogleFonts.raleway(fontWeight: FontWeight.w900, color: AppTheme.royalBlue),
            ));
            return m[0]!;
          },
          onNonMatch: (String n) {
            spans.add(TextSpan(text: n));
            return n;
          },
        );

        paragraphs.add(
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: GoogleFonts.raleway(
                fontSize: _fontSize,
                color: Colors.black87,
                height: 1.6,
              ),
              children: spans,
            ),
          ),
        );
      }
      paragraphs.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: paragraphs,
    );
  }
}