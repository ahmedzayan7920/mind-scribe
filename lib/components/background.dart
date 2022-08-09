import 'package:flutter/material.dart';

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);


  @override
  State<Background> createState() => _MyPainterState();
}

class _MyPainterState extends State<Background> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: CustomPaint(
        size: Size(size.width, size.height),
        painter: Curved(size),
      ),
    );
  }
}

class Curved extends CustomPainter {
  Curved(this.size);

  final Size size;

  @override
  void paint(Canvas canvas, Size size) {
    size = this.size;
    var rect = Offset.zero & size;
    // Path rectPathThree = Path();
    Paint paint = Paint();
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [.01, .8],
      colors: [
        Color.fromARGB(255, 37, 109, 133),
        Color.fromARGB(200, 0, 43, 91),
      ],
    ).createShader(rect);

    var path = Path();

    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.1,
      size.width * 0.1,
      size.height * 0.28,
    );
    path.quadraticBezierTo(
      size.width * 0.06,
      size.height * 0.33,
      size.width * 0,
      size.height * 0.33,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
