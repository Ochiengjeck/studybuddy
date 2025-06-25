import 'package:flutter/material.dart';
import 'dart:math' as math;

// Main collection class for all loading widgets
class StudyBuddyLoadingWidgets {
  // 1. Animated Book Loading - Perfect for main app loading
  static Widget animatedBookLoader({
    double size = 60.0,
    Color primaryColor = const Color(0xFF6366F1),
    Color accentColor = const Color(0xFF8B5CF6),
  }) {
    return AnimatedBookLoader(
      size: size,
      primaryColor: primaryColor,
      accentColor: accentColor,
    );
  }

  // 2. Pencil Writing Animation - Great for content creation/editing
  static Widget pencilWritingLoader({
    double size = 80.0,
    Color pencilColor = const Color(0xFFEAB308),
    Color lineColor = const Color(0xFF6B7280),
  }) {
    return PencilWritingLoader(
      size: size,
      pencilColor: pencilColor,
      lineColor: lineColor,
    );
  }

  // 3. Floating Books Animation - Ideal for search or browsing
  static Widget floatingBooksLoader({
    double size = 100.0,
    List<Color> bookColors = const [
      Color(0xFFEF4444),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
    ],
  }) {
    return FloatingBooksLoader(size: size, bookColors: bookColors);
  }

  // 4. Brain Thinking Animation - Perfect for AI/matching features
  static Widget brainThinkingLoader({
    double size = 70.0,
    Color brainColor = const Color(0xFFEC4899),
    Color thoughtColor = const Color(0xFF06B6D4),
  }) {
    return BrainThinkingLoader(
      size: size,
      brainColor: brainColor,
      thoughtColor: thoughtColor,
    );
  }

  // 5. Graduation Cap Bounce - Great for achievements/completion
  static Widget graduationCapLoader({
    double size = 60.0,
    Color capColor = const Color(0xFF1F2937),
    Color tasselColor = const Color(0xFFEAB308),
  }) {
    return GraduationCapLoader(
      size: size,
      capColor: capColor,
      tasselColor: tasselColor,
    );
  }

  // 6. Connected Students - Perfect for matching/networking features
  static Widget connectedStudentsLoader({
    double size = 80.0,
    Color studentColor = const Color(0xFF6366F1),
    Color connectionColor = const Color(0xFF10B981),
  }) {
    return ConnectedStudentsLoader(
      size: size,
      studentColor: studentColor,
      connectionColor: connectionColor,
    );
  }

  // 7. Minimal Dots with Study Icons - Subtle for small spaces
  static Widget studyDotsLoader({
    double size = 50.0,
    Color dotColor = const Color(0xFF8B5CF6),
  }) {
    return StudyDotsLoader(size: size, dotColor: dotColor);
  }
}

// 1. Animated Book Loader
class AnimatedBookLoader extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const AnimatedBookLoader({
    Key? key,
    required this.size,
    required this.primaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  _AnimatedBookLoaderState createState() => _AnimatedBookLoaderState();
}

class _AnimatedBookLoaderState extends State<AnimatedBookLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.repeat();
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
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size * 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.primaryColor, widget.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }
}

// 2. Pencil Writing Loader
class PencilWritingLoader extends StatefulWidget {
  final double size;
  final Color pencilColor;
  final Color lineColor;

  const PencilWritingLoader({
    Key? key,
    required this.size,
    required this.pencilColor,
    required this.lineColor,
  }) : super(key: key);

  @override
  _PencilWritingLoaderState createState() => _PencilWritingLoaderState();
}

class _PencilWritingLoaderState extends State<PencilWritingLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnimation;
  late Animation<double> _pencilAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _pencilAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
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
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: PencilWritingPainter(
              lineProgress: _lineAnimation.value,
              pencilProgress: _pencilAnimation.value,
              pencilColor: widget.pencilColor,
              lineColor: widget.lineColor,
            ),
          ),
        );
      },
    );
  }
}

class PencilWritingPainter extends CustomPainter {
  final double lineProgress;
  final double pencilProgress;
  final Color pencilColor;
  final Color lineColor;

  PencilWritingPainter({
    required this.lineProgress,
    required this.pencilProgress,
    required this.pencilColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pencilPaint =
        Paint()
          ..color = pencilColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    // Draw pencil
    final pencilStart = Offset(size.width * 0.1, size.height * 0.2);
    final pencilEnd = Offset(
      size.width * 0.1 + (size.width * 0.8 * pencilProgress),
      size.height * 0.2,
    );
    canvas.drawLine(pencilStart, pencilEnd, pencilPaint);

    // Draw pencil tip
    final tipPath = Path();
    tipPath.moveTo(pencilEnd.dx, pencilEnd.dy - 3);
    tipPath.lineTo(pencilEnd.dx + 8, pencilEnd.dy);
    tipPath.lineTo(pencilEnd.dx, pencilEnd.dy + 3);
    tipPath.close();
    canvas.drawPath(tipPath, Paint()..color = Colors.black87);

    // Draw writing lines
    final lineY1 = size.height * 0.5;
    final lineY2 = size.height * 0.65;
    final lineY3 = size.height * 0.8;

    final lineEnd = size.width * 0.9 * lineProgress;

    canvas.drawLine(
      Offset(size.width * 0.1, lineY1),
      Offset(size.width * 0.1 + lineEnd, lineY1),
      linePaint,
    );

    if (lineProgress > 0.3) {
      canvas.drawLine(
        Offset(size.width * 0.1, lineY2),
        Offset(size.width * 0.1 + lineEnd * 0.7, lineY2),
        linePaint,
      );
    }

    if (lineProgress > 0.6) {
      canvas.drawLine(
        Offset(size.width * 0.1, lineY3),
        Offset(size.width * 0.1 + lineEnd * 0.4, lineY3),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 3. Floating Books Loader
class FloatingBooksLoader extends StatefulWidget {
  final double size;
  final List<Color> bookColors;

  const FloatingBooksLoader({
    Key? key,
    required this.size,
    required this.bookColors,
  }) : super(key: key);

  @override
  _FloatingBooksLoaderState createState() => _FloatingBooksLoaderState();
}

class _FloatingBooksLoaderState extends State<FloatingBooksLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.bookColors.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 200)),
        vsync: this,
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children:
            widget.bookColors.asMap().entries.map((entry) {
              int index = entry.key;
              Color color = entry.value;

              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  final angle =
                      (index * 2 * math.pi / widget.bookColors.length);
                  final radius = 20.0 + (_animations[index].value * 10);

                  return Transform.translate(
                    offset: Offset(
                      radius *
                          math.cos(
                            angle + _animations[index].value * 2 * math.pi,
                          ),
                      radius *
                          math.sin(
                            angle + _animations[index].value * 2 * math.pi,
                          ),
                    ),
                    child: Container(
                      width: 20,
                      height: 25,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }
}

// 4. Brain Thinking Loader
class BrainThinkingLoader extends StatefulWidget {
  final double size;
  final Color brainColor;
  final Color thoughtColor;

  const BrainThinkingLoader({
    Key? key,
    required this.size,
    required this.brainColor,
    required this.thoughtColor,
  }) : super(key: key);

  @override
  _BrainThinkingLoaderState createState() => _BrainThinkingLoaderState();
}

class _BrainThinkingLoaderState extends State<BrainThinkingLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _thoughtAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _thoughtAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.repeat(reverse: true);
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
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Brain
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.psychology,
                  size: widget.size * 0.6,
                  color: widget.brainColor,
                ),
              ),
              // Thought bubbles
              ...List.generate(3, (index) {
                return Positioned(
                  top: widget.size * 0.1,
                  right: widget.size * 0.2 + (index * 8.0),
                  child: Transform.scale(
                    scale: _thoughtAnimation.value,
                    child: Container(
                      width: 8.0 - (index * 2.0),
                      height: 8.0 - (index * 2.0),
                      decoration: BoxDecoration(
                        color: widget.thoughtColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// 5. Graduation Cap Loader
class GraduationCapLoader extends StatefulWidget {
  final double size;
  final Color capColor;
  final Color tasselColor;

  const GraduationCapLoader({
    Key? key,
    required this.size,
    required this.capColor,
    required this.tasselColor,
  }) : super(key: key);

  @override
  _GraduationCapLoaderState createState() => _GraduationCapLoaderState();
}

class _GraduationCapLoaderState extends State<GraduationCapLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _tasselAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    _tasselAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.repeat(reverse: true);
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
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.school,
                  size: widget.size * 0.8,
                  color: widget.capColor,
                ),
                Positioned(
                  top: widget.size * 0.2,
                  right: widget.size * 0.3,
                  child: Transform.rotate(
                    angle: _tasselAnimation.value * 0.5,
                    child: Container(
                      width: 3,
                      height: 15,
                      color: widget.tasselColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 6. Connected Students Loader
class ConnectedStudentsLoader extends StatefulWidget {
  final double size;
  final Color studentColor;
  final Color connectionColor;

  const ConnectedStudentsLoader({
    Key? key,
    required this.size,
    required this.studentColor,
    required this.connectionColor,
  }) : super(key: key);

  @override
  _ConnectedStudentsLoaderState createState() =>
      _ConnectedStudentsLoaderState();
}

class _ConnectedStudentsLoaderState extends State<ConnectedStudentsLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _connectionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _connectionAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
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
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: ConnectedStudentsPainter(
              progress: _connectionAnimation.value,
              studentColor: widget.studentColor,
              connectionColor: widget.connectionColor,
            ),
          ),
        );
      },
    );
  }
}

class ConnectedStudentsPainter extends CustomPainter {
  final double progress;
  final Color studentColor;
  final Color connectionColor;

  ConnectedStudentsPainter({
    required this.progress,
    required this.studentColor,
    required this.connectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final studentPaint = Paint()..color = studentColor;
    final connectionPaint =
        Paint()
          ..color = connectionColor.withOpacity(progress)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw students (circles)
    final student1 = Offset(center.dx - radius, center.dy);
    final student2 = Offset(center.dx + radius, center.dy);
    final student3 = Offset(center.dx, center.dy - radius);

    canvas.drawCircle(student1, 8, studentPaint);
    canvas.drawCircle(student2, 8, studentPaint);
    canvas.drawCircle(student3, 8, studentPaint);

    // Draw connections with animation
    if (progress > 0.2) {
      canvas.drawLine(student1, student2, connectionPaint);
    }
    if (progress > 0.5) {
      canvas.drawLine(student1, student3, connectionPaint);
    }
    if (progress > 0.8) {
      canvas.drawLine(student2, student3, connectionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 7. Study Dots Loader
class StudyDotsLoader extends StatefulWidget {
  final double size;
  final Color dotColor;

  const StudyDotsLoader({Key? key, required this.size, required this.dotColor})
    : super(key: key);

  @override
  _StudyDotsLoaderState createState() => _StudyDotsLoaderState();
}

class _StudyDotsLoaderState extends State<StudyDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _animations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0.3, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.size * 0.15,
                  height: widget.size * 0.15,
                  decoration: BoxDecoration(
                    color: widget.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Usage Examples Widget
class StudyBuddyLoadingExamples extends StatelessWidget {
  const StudyBuddyLoadingExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy Loading Widgets'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildExampleCard(
              'Animated Book Loader',
              'Perfect for main app loading',
              StudyBuddyLoadingWidgets.animatedBookLoader(),
            ),
            _buildExampleCard(
              'Pencil Writing Loader',
              'Great for content creation/editing',
              StudyBuddyLoadingWidgets.pencilWritingLoader(),
            ),
            _buildExampleCard(
              'Floating Books Loader',
              'Ideal for search or browsing',
              StudyBuddyLoadingWidgets.floatingBooksLoader(),
            ),
            _buildExampleCard(
              'Brain Thinking Loader',
              'Perfect for AI/matching features',
              StudyBuddyLoadingWidgets.brainThinkingLoader(),
            ),
            _buildExampleCard(
              'Graduation Cap Loader',
              'Great for achievements/completion',
              StudyBuddyLoadingWidgets.graduationCapLoader(),
            ),
            _buildExampleCard(
              'Connected Students Loader',
              'Perfect for matching/networking',
              StudyBuddyLoadingWidgets.connectedStudentsLoader(),
            ),
            _buildExampleCard(
              'Study Dots Loader',
              'Subtle for small spaces',
              StudyBuddyLoadingWidgets.studyDotsLoader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String title, String description, Widget loader) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(height: 120, child: Center(child: loader)),
          ],
        ),
      ),
    );
  }
}
