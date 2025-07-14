import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class CameraTextRecognizerPage extends StatefulWidget {
  const CameraTextRecognizerPage({super.key});

  @override
  State<CameraTextRecognizerPage> createState() =>
      _CameraTextRecognizerPageState();
}

class _CameraTextRecognizerPageState extends State<CameraTextRecognizerPage> {
  List<CameraDescription>? cameras;
  CameraController? controller;
  bool isReady = false;
  bool _isProcessing = false;
  String _status = "Apunta y toma la foto";

  @override
  void initState() {
    super.initState();
    _lockOrientation();
    _initCamera();
  }

  Future<void> _lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _unlockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      final backCamera = cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras!.first,
      );

      controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller!.initialize();
      await controller!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);

      if (!mounted) return;
      setState(() {
        isReady = true;
      });
    } catch (e) {
      debugPrint('Error al inicializar cámara: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _unlockOrientation();
    super.dispose();
  }

  Future<void> _takePictureAndAnalyze() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        controller!.value.isTakingPicture) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _status = "Procesando...";
      });

      final XFile file = await controller!.takePicture();
      final File imageFile = File(file.path);
      final result = await _recognizeText(imageFile);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _status = result.isEmpty
            ? "No se detectaron números con fondo negro."
            : "Detectado: $result";
      });

      Navigator.pop(context, {
        'codigoTexto': result,
        'rutaImagen': imageFile.path,
      });
    } catch (e) {
      debugPrint('Error al tomar o analizar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<String> _recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) return "";

      List<String> validNumbers = [];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final box = line.boundingBox;
          final x = box.left.toInt().clamp(0, originalImage.width - 1);
          final y = box.top.toInt().clamp(0, originalImage.height - 1);
          final width = box.width.toInt().clamp(1, originalImage.width - x);
          final height = box.height.toInt().clamp(1, originalImage.height - y);
          final cropped = img.copyCrop(originalImage, x, y, width, height);

          int totalBrightness = 0;
          int totalSquaredBrightness = 0;
          int count = 0;

          for (int i = 0; i < cropped.width; i += 2) {
            for (int j = 0; j < cropped.height; j += 2) {
              final pixel = cropped.getPixel(i, j);
              final r = img.getRed(pixel);
              final g = img.getGreen(pixel);
              final b = img.getBlue(pixel);
              final brightness = (r + g + b) ~/ 3;
              totalBrightness += brightness;
              totalSquaredBrightness += brightness * brightness;
              count++;
            }
          }

          final avgBrightness = totalBrightness ~/ count;
          final variance =
              (totalSquaredBrightness ~/ count) -
              (avgBrightness * avgBrightness);

          if (avgBrightness < 60 && variance > 100) {
            final matches = RegExp(r'\d+').allMatches(line.text);
            for (final match in matches) {
              validNumbers.add(match.group(0)!);
            }
          }
        }
      }

      return validNumbers.join('');
    } catch (_) {
      return "";
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizar Código'),
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                _status,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _isProcessing ? null : _takePictureAndAnalyze,
                backgroundColor: const Color(0xFF971c17),
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
