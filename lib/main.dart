import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Webcam Real-Time',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WebcamPage(),
    );
  }
}

class WebcamPage extends StatefulWidget {
  const WebcamPage({super.key});
  @override
  State<WebcamPage> createState() => _WebcamPageState();
}

class _WebcamPageState extends State<WebcamPage> {
  late html.VideoElement _videoElement;
  String? _capturedImageDataUrl;

  @override
  void initState() {
    super.initState();

    // Inisialisasi video element HTML
    _videoElement =
        html.VideoElement()
          ..autoplay = true
          ..muted = true
          ..style.width = '100%'
          ..style.height = 'auto';

    // Dapatkan akses ke kamera
    html.window.navigator.mediaDevices
        ?.getUserMedia({
          'video': {'facingMode': 'user'},
        })
        .then((stream) {
          print('✅ Kamera berhasil diakses');
          _videoElement.srcObject = stream;
        })
        .catchError((error) {
          print('❌ Gagal mengakses kamera: $error');
        });

    // Registrasi elemen viewType untuk Flutter
    // supaya bisa ditampilkan di dalam widget
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'webcamElement',
      (int viewId) => _videoElement,
    );
  }

  void _captureSnapshot() {
    final canvas = html.CanvasElement(
      width: _videoElement.videoWidth,
      height: _videoElement.videoHeight,
    );
    final ctx = canvas.context2D;
    ctx.drawImage(_videoElement, 0, 0);
    setState(() {
      _capturedImageDataUrl = canvas.toDataUrl("image/png");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses Kamera Real-Time')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Live Kamera dari Browser"),
            SizedBox(
              width: 400,
              height: 300,
              child: HtmlElementView(viewType: 'webcamElement'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _captureSnapshot,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Snapshot"),
            ),
            const SizedBox(height: 20),
            if (_capturedImageDataUrl != null) ...[
              const Text("Hasil Snapshot:"),
              Image.network(_capturedImageDataUrl!, width: 300),
            ],
          ],
        ),
      ),
    );
  }
}
