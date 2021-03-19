import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int nextHandle = 0;

  Future<Null> signIn() async {
    User user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'lukekonsta@gmail.com',
      password: 'cy_smux123!',
    ))
        .user;
    if (user != null) {
      Firebase.initializeApp().whenComplete(() {
        print("completed");
        readTextDemo();
      });
    }
  }

  @override
  void initState() {
    signIn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<String> _loadImage(String assetFilename) async {
    final Directory directory = await getTemporaryDirectory();

    final String tmpFilename = path.join(
      directory.path,
      "tmp${nextHandle++}.jpg",
    );

    final ByteData data = await rootBundle.load(assetFilename);
    final Uint8List bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(tmpFilename).writeAsBytes(bytes);
    return tmpFilename;
  }

  Future readTextDemo() async {
    final String tmpFilename = await _loadImage('assets/receipt.jpg');
    FirebaseVisionImage ourImage =
        FirebaseVisionImage.fromFile(File(tmpFilename));
    final TextRecognizer cloudTextRecognizer =
        FirebaseVision.instance.cloudTextRecognizer();
    final VisionText visionTextCloud =
        await cloudTextRecognizer.processImage(ourImage);

    for (TextBlock block in visionTextCloud.blocks) {
      final String text = block.text;
      print("Vision Text Cloud Text $text");
      final List<Offset> cornerPoints = block.cornerPoints;
      print("Vision Text Cloud CornerPoints $cornerPoints");
    }

    FirebaseVisionImage deviceImage =
        FirebaseVisionImage.fromFile(File(tmpFilename));
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText deviceText =
        await textRecognizer.processImage(deviceImage);

    for (TextBlock block in deviceText.blocks) {
      final String text = block.text;
      print("Device Text $text");
      final List<Offset> cornerPoints = block.cornerPoints;
      print("Device CornerPoints $cornerPoints");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('App'),
      ),
    );
  }
}
