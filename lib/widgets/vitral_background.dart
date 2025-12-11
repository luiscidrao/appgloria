import 'dart:math';
import 'package:flutter/material.dart';

class VitralAnimado extends StatefulWidget {
  final Widget? child;

  const VitralAnimado({super.key, this.child});

  @override
  State<VitralAnimado> createState() => _VitralAnimadoState();
}

class _VitralAnimadoState extends State<VitralAnimado> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Voltamos para uma animação LENTA e sutil (respiração)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // 8 segundos para ir e voltar
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _VitralPainter(animationValue: _controller.value),
          child: Container(
            // RECOLOCAMOS O FILTRO ESCURO para dar profundidade e contraste ao texto
            color: const Color(0xFF1D3676).withOpacity(0.5),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _VitralPainter extends CustomPainter {
  final double animationValue;

  _VitralPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Rejunte escuro sutil
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 0.5;

    const double cellSize = 55.0;
    final cols = (size.width / cellSize).ceil();
    final rows = (size.height / cellSize).ceil();

    // --- PALETA ORIGINAL (TONS ESCUROS E PROFUNDOS) ---
    final List<Color> palette = [
      const Color(0xFF1D3676), // Azul Royal (Principal)
      const Color(0xFF152658), // Azul Escuro Profundo
      const Color(0xFF2B468B), // Azul Médio
      const Color(0xFF0F182E), // Azul Quase Preto (Noite)
      const Color(0xFF223F80), // Azul Vibrante
      const Color(0xFF4A3B75), // Roxo Litúrgico Profundo
    ];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        // Hash para consistência visual
        int hash = (x * 73856093 ^ y * 19349663).abs();

        int colorIndex = hash % palette.length;
        // Pega uma cor próxima na paleta para a transição ser suave
        int nextColorIndex = (hash + 1) % palette.length;

        // Movimento ondular lento
        double shift = sin(x * 0.4 + y * 0.4 + animationValue * pi);
        double t = (shift + 1) / 2;

        // Interpolação suave entre os tons escuros
        Color corFinal = Color.lerp(palette[colorIndex], palette[nextColorIndex], t)!;

        // Triângulo Superior
        Path path1 = Path();
        path1.moveTo(x * cellSize, y * cellSize);
        path1.lineTo((x + 1) * cellSize, y * cellSize);
        path1.lineTo(x * cellSize, (y + 1) * cellSize);
        path1.close();

        paint.color = corFinal;
        canvas.drawPath(path1, paint);
        canvas.drawPath(path1, stroke);

        // Triângulo Inferior (Inverte a mistura para contraste sutil)
        Color corFinal2 = Color.lerp(palette[nextColorIndex], palette[colorIndex], t)!;

        Path path2 = Path();
        path2.moveTo((x + 1) * cellSize, y * cellSize);
        path2.lineTo((x + 1) * cellSize, (y + 1) * cellSize);
        path2.lineTo(x * cellSize, (y + 1) * cellSize);
        path2.close();

        paint.color = corFinal2;
        canvas.drawPath(path2, paint);
        canvas.drawPath(path2, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VitralPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}