import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme.dart';
import '../widgets/vitral_background.dart';

class DizimoScreen extends StatelessWidget {
  const DizimoScreen({super.key});

  void _copiarChave(BuildContext context, String chave) {
    Clipboard.setData(ClipboardData(text: chave));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Chave copiada!", style: GoogleFonts.raleway()),
        backgroundColor: AppTheme.royalBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: const VitralAnimado(),
        ),
        title: Text(
          "Dízimo & Ofertas",
          style: GoogleFonts.montserrat(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Versículo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.royalBlue,
                    AppTheme.royalBlue.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(FontAwesomeIcons.handHoldingHeart,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    '"Cada um dê conforme determinou em seu coração, não com pesar ou por obrigação, pois Deus ama quem dá com alegria."',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "2 Coríntios 9, 7",
                    style: GoogleFonts.montserrat(
                      color: AppTheme.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _buildSectionTitle("Contribua via PIX"),
            const SizedBox(height: 16),

            _buildPixCard(
              context,
              titulo: "Chave PIX",
              subtitulo: "CNPJ da Paróquia",
              valor: "00.000.000/0001-00",
              icon: FontAwesomeIcons.pixiv,
              cor: const Color(0xFF32BCAD),
            ),

            const SizedBox(height: 32),

            _buildSectionTitle("Transferência Bancária"),
            const SizedBox(height: 16),

            _buildBankInfo(),

            const SizedBox(height: 32),

            _buildSectionTitle("Por que contribuir?"),
            const SizedBox(height: 16),

            _buildMotivacaoCard(
              icon: Icons.church,
              titulo: "Manutenção da Paróquia",
              descricao:
                  "Sua contribuição ajuda a manter a estrutura física e os serviços pastorais da comunidade.",
            ),
            const SizedBox(height: 12),
            _buildMotivacaoCard(
              icon: Icons.people,
              titulo: "Obras Sociais",
              descricao:
                  "Apoiamos famílias em situação de vulnerabilidade através de campanhas e doações.",
            ),
            const SizedBox(height: 12),
            _buildMotivacaoCard(
              icon: Icons.music_note,
              titulo: "Pastoral e Evangelização",
              descricao:
                  "Investimos em grupos, retiros e formação para toda a comunidade paroquial.",
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: AppTheme.gold),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.royalBlue),
        ),
      ],
    );
  }

  Widget _buildPixCard(
    BuildContext context, {
    required String titulo,
    required String subtitulo,
    required String valor,
    required IconData icon,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: cor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(valor,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                Text(subtitulo,
                    style: GoogleFonts.raleway(
                        fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copiarChave(context, valor),
            icon: const Icon(Icons.copy_outlined, color: AppTheme.royalBlue),
            tooltip: "Copiar",
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildBankRow("Banco", "Banco do Brasil"),
          const Divider(height: 20),
          _buildBankRow("Agência", "0000-0"),
          const Divider(height: 20),
          _buildBankRow("Conta", "00000-0"),
          const Divider(height: 20),
          _buildBankRow("Favorecido", "Paróquia Nossa Sra. da Glória"),
          const Divider(height: 20),
          _buildBankRow("CNPJ", "00.000.000/0001-00"),
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.raleway(fontSize: 13, color: Colors.grey[600])),
        Text(valor,
            style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildMotivacaoCard({
    required IconData icon,
    required String titulo,
    required String descricao,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.15),
                shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalBlue)),
                const SizedBox(height: 4),
                Text(descricao,
                    style: GoogleFonts.raleway(
                        fontSize: 13, color: Colors.grey[700], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
