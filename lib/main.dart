import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sauce',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  File _image;
  final picker = ImagePicker();
  List _output;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    loadMLModel().then((value) {
      setState() {
        _isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sauce?'),
        centerTitle: true,
        backgroundColor: Colors.purple[200],
      ),
      body: _isLoading
          ? Text("No Image Selected")
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _image == null
                          ? Container()
                          : SizedBox(
                              height: 40,
                            ),
                      Image.file(_image),
                      SizedBox(
                        height: 16,
                      ),
                      _output == null
                          ? Text("")
                          : Text(
                              "${_output[0]["label"]}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[200],
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _isLoading = true;
      } else {
        print('No image selected.');
      }
    });
    runModelOnImage(File(pickedFile.path));
  }

  runModelOnImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }

  loadMLModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }
}
