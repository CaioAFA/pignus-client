import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// A screen that allows users to take a picture using a given camera.
// ignore: must_be_immutable
class RecordVideoScreen extends StatefulWidget {
  final CameraDescription camera;
  var _serverUrlController;
  var isStarted;
  var logs;

  RecordVideoScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  RecordVideoScreenState createState() => RecordVideoScreenState();
}

class RecordVideoScreenState extends State<RecordVideoScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  void _saveServerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    // Save URL
    prefs.setString('serverUrl', widget._serverUrlController.text);
  }

  void _getSavedServerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    widget._serverUrlController.text = prefs.getString('serverUrl') ?? '';
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    widget._serverUrlController = TextEditingController();
    widget.isStarted = false;
    widget.logs = '';
    _addLogMessage('Logs:');
    _getSavedServerUrl();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendPhoto() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);

      var request = http.MultipartRequest('POST', Uri.parse(widget._serverUrlController.text));
      request.files.add(
          await http.MultipartFile.fromPath(
              'photo',
              path
          )
      );
      try{
        var res = await request.send();
        if(res.statusCode == 200){
          _addLogMessage('Foto enviada com sucesso! ${await res.stream.bytesToString()}');
        }
        else{
          _addLogMessage('Erro ao enviar foto. Status ${res.statusCode}');
        }
      }
      catch(error){
        print(error.toString());
        _addLogMessage('Erro: ' + error.toString());
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
      setState(() {
        _addLogMessage('Erro: ' + e.toString());
      });
    }
  }

  void _beginRecording(){
    _sendPhoto();
    Future.delayed(Duration(seconds: 10), widget.isStarted ? _beginRecording : (){
      _addLogMessage('Encerrado.');
    });
  }

  void _addLogMessage(String message){
    setState(() {
      widget.logs += "${message}\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicie o Sistema!')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Container(
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: TextField(
                                  controller: widget._serverUrlController,
                                  decoration: InputDecoration(
                                      labelText: "URL - Servidor",
                                      labelStyle: TextStyle(
                                          color: Colors.blueAccent
                                      )
                                  ),
                                )
                            ),
                            RaisedButton(
                              color: Colors.blueAccent,
                              child: widget.isStarted ? Text("Parar") : Text("Iniciar"),
                              textColor: Colors.white,
                              onPressed: (){
                                _saveServerUrl();
                                setState(() {
                                  widget.isStarted = !widget.isStarted;
                                  // _sendPhoto();
                                  if(widget.isStarted) _beginRecording();
                                });
                              },
                            )
                          ],
                        ),
                      )
                  ),
                  Container(
                    height: 80.0,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        controller: ScrollController(
                          keepScrollOffset: true,
                          initialScrollOffset: 0
                        ),
                        child: Text(
                            widget.logs
                        ),
                      )
                    ),
                  ),
                  Expanded(
                    child: CameraPreview(_controller),
                  ),
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
