import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Detector',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool _loading = true;
  File _image;
  List _output;
  final _picker = ImagePicker();

  @override
  void initState() {
    loadModel().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path.toString(),
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
        asynch: true);

    setState(() {
      print('output is $output');
      _output = output;
      _loading = false;
    });
  }

  Future loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  pickCameraImage() async {
    var image = await _picker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image);
  }

  pickGalleryImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery);
    print('----------- ${image.path}');
    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image);
  }

  final List<String> imgList = [
    'assets/cars/1.jpg',
    'assets/cars/2.jpg',
    'assets/cars/3.jpg',
    'assets/cars/4.jpg',
    'assets/cars/6.jpg',
    'assets/cars/7.jpg',
    'assets/cars/8.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Car Detector'),
        centerTitle: true,
      ),
      body: Center(
        child: _loading
            ? Builder(
                builder: (context) {
                  return CarouselSlider(
                    options: CarouselOptions(
                        height: height,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        autoPlay: true,
                        aspectRatio: 2.0,
                        enlargeStrategy: CenterPageEnlargeStrategy.height),
                    items: imgList
                        .map((item) => Container(
                              child: Center(
                                  child: Image.asset(item,
                                      fit: BoxFit.cover,
                                      height: height,
                                      width: width)),
                            ))
                        .toList(),
                  );
                },
              )
            : Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(
                      _image,
                      filterQuality: FilterQuality.medium,
                      height: height / 2,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _output == [] || _output.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Unable to detect the name of the car manufacturer',
                        style:
                        TextStyle(color: Colors.black, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ) : _output != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'The name of the car uploaded is ${_output[0]['label']}.',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    _output == [] || _output.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Please try another image.',
                        style:
                        TextStyle(color: Colors.black, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : _output != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'I\'m ${double.parse(_output[0]['confidence'].toStringAsFixed(3)) * 100}% accurate regarding the name of the car you uploaded.',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _output = null;
                          _image = null;
                          _loading = true;
                        });
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      color: Colors.black,
                    )
                  ],
                ),
              ),
      ),
      floatingActionButton: _output != null ||
        _image != null ||
        _loading == false ? Container() : buildSpeedDial(),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      /// both default to 16
      marginEnd: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      buttonSize: 56.0,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 5.0,
      shape: CircleBorder(),
      orientation: SpeedDialOrientation.Up,

      children: [
        SpeedDialChild(
          child: Icon(
            Icons.camera,
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
          label: 'Camera',
          labelStyle: TextStyle(fontSize: 16.0, color: Colors.black),
          onTap: () => pickCameraImage(),
        ),
        SpeedDialChild(
          child: Icon(Icons.image_outlined, color: Colors.white),
          backgroundColor: Colors.black,
          label: 'Gallery',
          labelStyle: TextStyle(fontSize: 16.0, color: Colors.black),
          onTap: () => pickGalleryImage(),
        ),
      ],
    );
  }
}
