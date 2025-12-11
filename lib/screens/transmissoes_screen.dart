import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../services/youtube_service.dart';
import '../widgets/vitral_background.dart';

class TransmissoesScreen extends StatefulWidget {
  const TransmissoesScreen({super.key});

  @override
  State<TransmissoesScreen> createState() => _TransmissoesScreenState();
}

class _TransmissoesScreenState extends State<TransmissoesScreen> {
  final YoutubeService _service = YoutubeService();
  late Future<List<VideoModel>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _service.getVideos();
  }

  // Função para recarregar puxando a tela
  Future<void> _refresh() async {
    setState(() {
      _videosFuture = _service.getVideos();
    });
  }

  // Função Inteligente: Tenta App -> Falha -> Abre Navegador
  Future<void> _abrirYouTube(String videoId) async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    try {
      // 1. Tenta forçar a abertura do APP nativo do YouTube
      bool appLaunched = await launchUrl(url, mode: LaunchMode.externalApplication);

      if (!appLaunched) {
        // 2. Se falhar, abre no Navegador (Plano B)
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Erro ao abrir app, indo para navegador: $e');
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          ),
          child: const VitralAnimado(),
        ),
        title: const Text("Transmissões", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.gold,
        child: FutureBuilder<List<VideoModel>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
            } else if (snapshot.hasError) {
              return Center(child: Text("Erro de conexão. Verifique sua internet."));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Nenhuma transmissão encontrada."));
            }

            final allVideos = snapshot.data!;
            // Separa Próximas (ou Ao Vivo) das Anteriores
            final destaques = allVideos.where((v) => v.isUpcoming || v.isLive).toList();
            final historico = allVideos.where((v) => !v.isUpcoming && !v.isLive).toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // SEÇÃO 1: DESTAQUE (Próxima Missa ou Ao Vivo)
                  if (destaques.isNotEmpty) ...[
                    _buildSectionTitle(
                        destaques.first.isLive ? "Ao Vivo Agora" : "Próxima Celebração",
                        destaques.first.isLive ? Icons.live_tv : Icons.event
                    ),
                    const SizedBox(height: 12),
                    _buildUpcomingCard(destaques.first),
                    const SizedBox(height: 30),
                  ],

                  // SEÇÃO 2: HISTÓRICO
                  if (historico.isNotEmpty) ...[
                    _buildSectionTitle("Últimas Transmissões", Icons.history),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historico.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildPastCard(historico[index]);
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.royalBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(VideoModel video) {
    return Container(
      decoration: BoxDecoration(
        color: video.isLive ? Colors.red.shade50 : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: video.isLive ? Colors.red : AppTheme.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _abrirYouTube(video.id),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(video.thumbnail, height: 200, width: double.infinity, fit: BoxFit.cover),
                    // Filtro escuro
                    Container(color: Colors.black26),

                    // Ícone Play
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),

                    // Badge: AO VIVO ou LEMBRETE
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: video.isLive ? Colors.red : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                video.isLive ? Icons.circle : Icons.notifications_active,
                                color: video.isLive ? Colors.white : AppTheme.royalBlue,
                                size: 14
                            ),
                            const SizedBox(width: 8),
                            Text(
                                video.isLive ? "AO VIVO AGORA" : "DEFINIR LEMBRETE",
                                style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: video.isLive ? Colors.white : AppTheme.royalBlue
                                )
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(video.titulo, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.royalBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(video.data, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.royalBlue)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastCard(VideoModel video) {
    return GestureDetector(
      onTap: () => _abrirYouTube(video.id),
      child: Container(
        // CORREÇÃO DO ERRO DE OVERFLOW: Removemos altura fixa
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2)
            )
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: SizedBox(
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Image.network(video.thumbnail, fit: BoxFit.cover),
                      Container(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20)
                      ),
                    ],
                  ),
                ),
              ),
              // Texto Responsivo
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        video.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              video.data,
                              style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}