import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription>? cameras;
  CameraController? controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _lockOrientation();
    _initCamera();
  }

  Future<void> _lockOrientation() async {
    // Fija solo orientaciones landscape (izquierda y derecha)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _unlockOrientation() async {
    // Restablece a permitir todas las orientaciones (puedes cambiar si quieres otra cosa)
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

      // Opcional: bloquear captura en landscape (ya la pantalla está fija)
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
    _unlockOrientation(); // Restablecer orientación al salir de la pantalla
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        controller!.value.isTakingPicture) {
      return;
    }

    try {
      final XFile file = await controller!.takePicture();

      if (!mounted) return;

      Navigator.pop(context, file.path);
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al tomar foto: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar Foto'),
        backgroundColor: const Color(0xFF971c17),
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
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _takePicture,
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
