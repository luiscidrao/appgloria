import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/youtube_service.dart';
import '../widgets/vitral_background.dart';
import 'video_player_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Cabeçalho com Vitral
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
      body: FutureBuilder<List<VideoModel>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhuma transmissão encontrada."));
          }

          final allVideos = snapshot.data!;
          // Filtra quem é Futuro e quem é Passado
          final upcoming = allVideos.where((v) => v.isUpcoming).toList();
          final past = allVideos.where((v) => !v.isUpcoming).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // SEÇÃO 1: PRÓXIMA (DESTAQUE)
                if (upcoming.isNotEmpty) ...[
                  _buildSectionTitle("Próxima Celebração", Icons.event),
                  const SizedBox(height: 12),
                  _buildUpcomingCard(upcoming.first),
                  const SizedBox(height: 30),
                ],

                // SEÇÃO 2: LISTA DE ANTERIORES
                if (past.isNotEmpty) ...[
                  _buildSectionTitle("Últimas Transmissões", Icons.history),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: past.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildPastCard(past[index]);
                    },
                  ),
                ],
              ],
            ),
          );
        },
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

  // Card Grande (Futuro)
  Widget _buildUpcomingCard(VideoModel video) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Fundo Amarelado suave
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoId: video.id, titulo: video.titulo)),
            );
          },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(video.thumbnail, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_active, color: AppTheme.royalBlue, size: 16),
                          const SizedBox(width: 8),
                          Text("DEFINIR LEMBRETE", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.royalBlue)),
                        ],
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

  // Card Pequeno (Passado)
  Widget _buildPastCard(VideoModel video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoId: video.id, titulo: video.titulo)),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(video.thumbnail, width: 120, height: 100, fit: BoxFit.cover),
                  const Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(video.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(video.data, style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}