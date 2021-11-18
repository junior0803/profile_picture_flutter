import 'dart:ffi';
import 'dart:io' as Io;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_profile/photo_view/photo_view.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatefulWidget {

  @override
  _ProfileCreate createState() => _ProfileCreate();
}

class _ProfileCreate extends State<ProfileApp>{
  GlobalKey profileImage = new GlobalKey();
  int profileRadius = 130;
  late Image _image2;

  late bool permissionGranted;

  @override
  Widget build(BuildContext context) {
    _getStoragePermission();

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 33, 29, 156),
        appBar: AppBar(title:Text("Profile Page"),backgroundColor: Color(
            0xff17086f),),
        body: Column(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Add Profile Picture",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40.0
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Drag image to move, double tap on image to ",
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                      fontSize: 18.0,
                    ),
                  ),

                  Text(
                    "zoom or pinch to zoom in or out.",
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(
                    height: 60.0,
                  ),
                  RepaintBoundary(
                    key: profileImage,
                    child: CircleAvatar(
                        radius: 130,
                        backgroundImage: AssetImage('assets/image/background.png'),
                        backgroundColor: Colors.transparent,
                        child:CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: PhotoView(
                              imageProvider: AssetImage('assets/image/Deepika-Padukone-1.jpg'),
                              maxScale: PhotoViewComputedScale.covered * 3.0,
                              minScale: PhotoViewComputedScale.contained * 0.8,
                              initialScale: PhotoViewComputedScale.covered,
                            ),
                          ),
                        )
                    ),
                  ),
                  SizedBox(
                    height: 120.0,
                  ),

                  RaisedButton(
                      onPressed: (){
                        FocusScope.of(context).requestFocus(FocusNode());
                        takeScreenShot();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)
                      ),
                      elevation: 0.0,
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [Colors.pink, Colors.pinkAccent]
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text("Continue",
                            style: TextStyle(color: Colors.white, fontSize: 26.0, fontWeight:FontWeight.w300),
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  takeImageBase64() async {
    RenderRepaintBoundary? boundary =
    profileImage.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    ui.Image image = await boundary!.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String img64 = base64Encode(pngBytes);
      print(img64);
      _write(img64);
    }
  }

  takeScreenShot() async {
    RenderRepaintBoundary? boundary =
        profileImage.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    ui.Image image = await boundary!.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      // Saving the screenshot to the gallery
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(pngBytes),
          quality: 90,
          name: 'screenshot-${DateTime.now()}.png');
      print(result);
      //Saveing the data directory
      // final directory = (await getApplicationDocumentsDirectory()).path;
      // File imgFile = new Io.File('$directory/screenshot.png');
      // imgFile.writeAsBytes(pngBytes);
      setState(() {
        _image2 = Image.memory(pngBytes.buffer.asUint8List());
      });
    }
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        permissionGranted = true;
      });
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      setState(() {
        permissionGranted = false;
      });
    }
  }

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    print(file);
    await file.writeAsString(text);
  }
}
