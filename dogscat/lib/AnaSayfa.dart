import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

// Ana widget
class HayvanSiniflandirici extends StatefulWidget {
  @override
  _HayvanSiniflandiriciDurum createState() => _HayvanSiniflandiriciDurum();
}

class _HayvanSiniflandiriciDurum extends State<HayvanSiniflandirici> {
  String _tahminSonucu = ""; // Tahmin sonucu
  File? _resim; // Seçilen veya çekilen görüntü
  final ImagePicker _resimSecici = ImagePicker(); // Görüntü seçmek için araç
  Interpreter? _yorumlayici; // TFLite model yorumlayıcısı

  @override
  void initState() {
    super.initState();
    modeliYukle();
  }

  // TFLite modelini yükle
  Future<void> modeliYukle() async {
    try {
      _yorumlayici = await Interpreter.fromAsset('assets/dog_cat_model.tflite');
      print("Model başarıyla yüklendi");
    } catch (hata) {
      print("Model yüklenemedi: $hata");
    }
  }

  // Görüntüyü sınıflandır
  Future<void> resmiSiniflandir(File resim) async {
    // Görüntüyü okuyup işle
    img.Image? orijinalResim = img.decodeImage(resim.readAsBytesSync());

    if (orijinalResim == null) {
      setState(() {
        _tahminSonucu = "Görüntü işlenemedi.";
      });
      return;
    }

    // Görüntüyü yeniden boyutlandır
    img.Image yenidenBoyutlanmisResim =
        img.copyResize(orijinalResim, width: 224, height: 224);

    // Model için giriş tensorunu oluştur
    var girisVerisi = List.generate(
        1,
        (i) => List.generate(
            224,
            (j) => List.generate(224, (k) {
                  var piksel = yenidenBoyutlanmisResim.getPixel(k, j);
                  return [
                    img.getRed(piksel) / 255.0,
                    img.getGreen(piksel) / 255.0,
                    img.getBlue(piksel) / 255.0
                  ];
                }))).reshape([1, 224, 224, 3]);

    // Modelden çıkış tensorunu al
    var cikisVerisi = List.filled(1 * 2, 0.0).reshape([1, 2]);
    _yorumlayici?.run(girisVerisi, cikisVerisi);

    // Sonucu değerlendir ve ekrana yazdır
    setState(() {
      double kopekIhtimali = cikisVerisi[0][1];
      _tahminSonucu = kopekIhtimali > 0.5 ? "Köpek" : "Kedi";
      _resim = resim; // Görüntüyü sakla
    });
  }

  // Galeriden görüntü seç
  Future<void> galeridenResimSec() async {
    final XFile? resim = await _resimSecici.pickImage(source: ImageSource.gallery);
    if (resim != null) {
      resmiSiniflandir(File(resim.path));
    }
  }

  // Kameradan görüntü çek
  Future<void> kameradanResimCek() async {
    final XFile? resim = await _resimSecici.pickImage(source: ImageSource.camera);
    if (resim != null) {
      resmiSiniflandir(File(resim.path));
    }
  }

  @override
  void dispose() {
    _yorumlayici?.close(); // Modeli kapat
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),
          // İçerik kısmı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_resim != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _resim!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Tahmin sonucu
                Text(
                  "Sonuç: $_tahminSonucu",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                // Görüntü seçme butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: galeridenResimSec,
                      child: Text("Galeriden Seç"),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: kameradanResimCek,
                      child: Text("Kameradan Çek"),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
