import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme.dart';
import 'services/liturgia_service.dart';
import 'widgets/vitral_background.dart';
import 'liturgia_detalhada_screen.dart';
import 'screens/transmissoes_screen.dart';

void main() {
  runApp(const ParoquiaApp());
}

class ParoquiaApp extends StatelessWidget {
  const ParoquiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paróquia da Glória',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const TransmissoesScreen(),
    const Center(child: Text("Avisos (Em breve)")),
    const Center(child: Text("Dízimo (Em breve)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          indicatorColor: AppTheme.gold.withOpacity(0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.church_outlined),
              selectedIcon: Icon(Icons.church, color: AppTheme.royalBlue),
              label: 'Início',
            ),
            NavigationDestination(
              icon: const Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle_fill, color: AppTheme.royalBlue),
              label: 'Ao Vivo',
            ),
            NavigationDestination(
              icon: const Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign, color: AppTheme.royalBlue),
              label: 'Avisos',
            ),
            NavigationDestination(
              icon: const Icon(FontAwesomeIcons.handHoldingHeart, size: 20),
              selectedIcon: Icon(FontAwesomeIcons.handHoldingHeart, size: 20, color: AppTheme.royalBlue),
              label: 'Dízimo',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final LiturgiaService _service = LiturgiaService();
  late Future<LiturgiaDiariaModel> _liturgiaFuture;

  @override
  void initState() {
    super.initState();
    _liturgiaFuture = _service.getLiturgiaDoDia();
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: VitralAnimado(),
        ),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withOpacity(0.3))
                              ),
                              child: Text(
                                "${getGreeting()}, Paz e Bem!",
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Paróquia\nda Glória",
                          style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.1,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0,4))
                              ]
                          ),
                        ),
                      ],
                    ),
                  ),

                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0,0))
                          ]
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.church, color: Colors.white, size: 50),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        FutureBuilder<LiturgiaDiariaModel>(
                          future: _liturgiaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildLoadingCard();
                            }
                            if (snapshot.hasData) {
                              return _buildLiturgiaHeroCard(context, snapshot.data!);
                            }
                            return _buildErroCard();
                          },
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Row(
                            children: [
                              Container(width: 4, height: 24, color: AppTheme.gold),
                              const SizedBox(width: 10),
                              Text(
                                "Serviços Paroquiais",
                                style: GoogleFonts.cinzel(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalBlue
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(child: _buildServiceCard(icon: Icons.calendar_month, title: "Horários", color: const Color(0xFFFFF8E1), iconColor: Colors.orange.shade800, onTap: () {})),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildServiceCard(
                                icon: FontAwesomeIcons.youtube,
                                title: "Transmissões",
                                color: const Color(0xFFFFEBEE),
                                iconColor: const Color(0xFFB71C1C),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TransmissoesScreen())
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildServiceCard(icon: Icons.campaign, title: "Avisos", color: const Color(0xFFE3F2FD), iconColor: const Color(0xFF1565C0), onTap: () {})),
                            const SizedBox(width: 16),
                            Expanded(child: _buildServiceCard(icon: FontAwesomeIcons.handHoldingHeart, title: "Dízimo", color: const Color(0xFFE8F5E9), iconColor: const Color(0xFF2E7D32), onTap: () {})),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- MÉTODOS AUXILIARES ---

  Widget _buildLiturgiaHeroCard(BuildContext context, LiturgiaDiariaModel liturgia) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LiturgiaDetalhadaScreen(liturgia: liturgia)));
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  height: 60, width: 60,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppTheme.gold, width: 1.5)),
                  child: const Center(child: Icon(FontAwesomeIcons.bible, color: AppTheme.royalBlue, size: 28)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("LITURGIA DIÁRIA", style: GoogleFonts.raleway(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.gold, letterSpacing: 1.2)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward, size: 16, color: AppTheme.gold)
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(liturgia.tituloDia, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: _getCorLiturgicaColor(liturgia.corLiturgica)),
                          const SizedBox(width: 6),
                          Text(liturgia.corLiturgica.replaceAll("Cor Litúrgica:", "").trim(), style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey[600])),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErroCard() {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)), child: Row(children: const [Icon(Icons.wifi_off, color: Colors.red), SizedBox(width: 16), Expanded(child: Text("Sem conexão."))]));
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

  Widget _buildLoadingCard() {
    return Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: const Center(child: CircularProgressIndicator(color: AppTheme.gold)));
  }

  Widget _buildServiceCard({required IconData icon, required String title, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return Container(height: 110, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 24)), const SizedBox(height: 12), Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]))]))));
  }
}