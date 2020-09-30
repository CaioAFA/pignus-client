// A widget that displays the picture taken by the user.
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final _serverUrlController = TextEditingController();

  DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  void _saveServerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    // Save URL
    prefs.setString('serverUrl', widget._serverUrlController.text);
  }

  void _getSavedServerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    widget._serverUrlController.text = prefs.getString('serverUrl') ?? '';
  }

  Future<String> _sendImage() async {
    var request = http.MultipartRequest('POST', Uri.parse(widget._serverUrlController.text));
    request.files.add(
        await http.MultipartFile.fromPath(
        'photo',
        widget.imagePath
      )
    );
    try{
      var res = await request.send();
      if(res.statusCode == 200){
        return 'Foto enviada com sucesso! Chance: ${await res.stream.bytesToString()}';
      }
      else{
        return 'Erro ao enviar foto. Status ${res.statusCode}';
      }
    }
    catch(error){
      print(error.toString());
      return 'Erro: ' + error.toString();
    }
  }

  void _showSendImageDialog(imagePath) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Enviando Foto..."),
          content: FutureBuilder<String>(
            future: _sendImage(),
            builder: (context, snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    height: 80.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    )
                  );
                default:
                  return Container(
                    height: 80.0,
                    child: Center(
                        child: Text(snapshot.data ?? '',
                            style: TextStyle(color: Colors.green,)
                        )
                    ),
                  );
              }
            }
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();

    _getSavedServerUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enviar')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: <Widget>[
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
                    child: Text("Enviar"),
                    textColor: Colors.white,
                    onPressed: (){
                      _saveServerUrl();
                      _showSendImageDialog(widget.imagePath);
                    },
                  )
                ],
              ),
            )
          ),
          Image.file(File(widget.imagePath))
        ],
      ),
    );
  }
}
