import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/avisos_service.dart';
import '../widgets/vitral_background.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  final AvisosService _service = AvisosService();
  late Future<List<AvisoModel>> _avisosFuture;

  @override
  void initState() {
    super.initState();
    _avisosFuture = _service.getAvisos();
  }

  Future<void> _refresh() async {
    setState(() {
      _avisosFuture = _service.getAvisos();
    });
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
        title: const Text("Mural de Avisos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.gold,
        child: FutureBuilder<List<AvisoModel>>(
          future: _avisosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final avisos = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: avisos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildAvisoCard(avisos[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Nenhum aviso no momento.",
            style: GoogleFonts.raleway(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoCard(AvisoModel aviso) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Se for destaque, borda dourada. Se não, borda cinza suave.
        border: aviso.destaque
            ? Border.all(color: AppTheme.gold, width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chip de Data
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: aviso.destaque ? AppTheme.gold.withOpacity(0.2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: aviso.destaque ? AppTheme.textDark : Colors.grey[700]),
                      const SizedBox(width: 6),
                      Text(
                        aviso.data,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: aviso.destaque ? AppTheme.textDark : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // Ícone de alfinete para destaques
                if (aviso.destaque)
                  const Icon(Icons.push_pin, color: AppTheme.gold, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              aviso.titulo,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              aviso.mensagem,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}