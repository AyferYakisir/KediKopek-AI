/*import 'package:camera/camera.dart';
import 'package:dogscat/main.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart'; // tflite_flutter paketini ekleyin

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isWorking = false;
  String result = "";
  CameraController? cameraController;
  CameraImage? imgCamera;
  Interpreter? interpreter;

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
  }

  loadModel() async {
    interpreter = await Interpreter.fromAsset("mobilenet_v1_1.0_224.tflite");
  }

  void initCamera() {
    cameraController = CameraController(
      cameras![0],
      ResolutionPreset.medium,
    );

    cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController?.startImageStream((imageFromStream) {
          if (!isWorking) {
            isWorking = true;
            imgCamera = imageFromStream;
            runModelOnStreamFrames();
          }
        });
      });
    }).catchError((e) {
      print("Kamera başlatma hatası: $e");
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var inputImage = _processCameraImage(imgCamera!);

      var recognitions = List.filled(1, 0).reshape([1, 10]);
      interpreter?.run(inputImage, recognitions);

      result = "";
      for (var recognition in recognitions) {
        result +=
            "${recognition[0]}  ${(recognition[1] as double).toStringAsFixed(2)}\n\n";
      }

      setState(() {
        result = result;
      });

      isWorking = false;
    }
  }

  List<List<int>> _processCameraImage(CameraImage image) {
    final bytes = image.planes[0].bytes;
    final imgImage = img.Image.fromBytes(
      image.width,
      image.height,
      bytes,
      format: img.Format.bgra,
    );

    // Görüntüyü yeniden boyutlandır
    final resizedImage = img.copyResize(imgImage, width: 224, height: 224);
    final input = List.generate(224 * 224, (index) {
      int x = index % 224;
      int y = index ~/ 224;
      var pixel = resizedImage.getPixel(x, y);
      return [img.getRed(pixel), img.getGreen(pixel), img.getBlue(pixel)];
    });

    return input;
  }

  @override
  void dispose() {
    interpreter?.close();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/jarvis.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 320,
                        width: 330,
                        child: Image.asset("assets/camera.jpg"),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          initCamera();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 35),
                          height: 270,
                          width: 360,
                          child: imgCamera == null
                              ? Container(
                                  height: 270,
                                  width: 360,
                                  child: Icon(
                                    Icons.photo_camera_front,
                                    color: Colors.blueAccent,
                                    size: 40,
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio:
                                      cameraController!.value.aspectRatio,
                                  child: CameraPreview(cameraController!),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: TextStyle(
                          backgroundColor: Colors.black87,
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/