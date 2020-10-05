  import 'dart:async';
  import 'package:camera/camera.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/widgets.dart';
  import 'package:tcccamera/manualMode/takePictureScreen.dart';
  import 'package:tcccamera/automaticMode/recordVideoScreen.dart';

  Future<void> main() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Home(firstCamera: firstCamera)
      ),
    );
  }

  class Home extends StatefulWidget {
    final firstCamera;

    const Home({Key key, @required this.firstCamera}) : super(key: key);

    @override
    _HomeState createState() => _HomeState();
  }

  class _HomeState extends State<Home> {
    @override
    void initState() {
      super.initState();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Pignus - Client')),
        body: Column(
          children: [
            Container(
                padding: EdgeInsets.only(top: 10.0),
                height: 50.0,
                child: SizedBox.expand(
                  child: ElevatedButton(
                    child: Text('Modo Manual'),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakePictureScreen(
                            // Pass the appropriate camera to the TakePictureScreen widget.
                            camera: widget.firstCamera,
                          ),
                        ),
                      );
                    },
                  ),
                )
            ),
            Container(
                padding: EdgeInsets.only(top: 10.0),
                height: 50.0,
                child: SizedBox.expand(
                  child: RaisedButton(
                    child: Text('Modo Automático'),
                    color: Colors.red,
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordVideoScreen(
                            // Pass the appropriate camera to the TakePictureScreen widget.
                            camera: widget.firstCamera,
                          ),
                        )
                      );
                    }
                  ),
                )
            )
          ],
        ),
      );
    }
  }
