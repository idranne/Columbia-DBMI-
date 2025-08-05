//Importing dependencies and packages

//UI widgets
import 'package:flutter/material.dart';
//Audio recording package
import 'package:record/record.dart';
//Storage file for deployment in flask
import 'package:path_provider/path_provider.dart';
//HTTP request for flask
import "package:http/http.dart" as http;
//io packages
import 'dart:io';
//import typing page
import 'package:my_app/typing_page.dart';

//layout of stateful widget 
class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  _AudioPageState createState () => _AudioPageState();

}

//Defining class and functions 
class _AudioPageState extends State<AudioPage>{
  //Create recorder object
  final _record = AudioRecorder();

  ///List for users to record
  final List<String> _phrases = [
    "Hi, I am Jack and I feel fine today",
    "The quick brown fox jumps over the lazy dog",
    "Please call Stella to ask about the park",
    "My voice is important for this assessment"
  ];

  //store the recorded audio in another List 
  final List<String> _recordings= [];
  //int index for placeholder
  int _currentIndex = 0;
  //Variable to store audio file path
  String? _filePath;


  //FUNCTION TO START RECORDING
  Future<void> _startRecording () async{
    //check if microphone permission has been granted from permission page
    if (await _record.hasPermission()){
    //Get device's document directory to store the recording
    final dir = await getApplicationDocumentsDirectory();
    //define file name and path 
    //keeping track of the current index as well
    final path = '${dir.path}/pd_audio_${_currentIndex}.wav';

    //Creating recording configuration
    final config = RecordConfig(
      //save in a .wav form
      encoder: AudioEncoder.wav,
      //quality of sound
      bitRate: 128000,
      //sample rate
      sampleRate: 44100,
      );

    //start recording
    await _record.start(
      //calling the config above
      config,
       //save at this path variable
      path: path, 
    );

    //Updating  the path state 
    setState(() => _filePath = path);

  } 
  }


  //FUNCTION TO STOP RECORDING
  Future<void> _stopRecording() async{
    //Stop and finalize recording
    await _record.stop();
    //append recorded file path to list
    if(_filePath != null){
      _recordings.add(_filePath!);

      //move to the next phrase if exist
      if (_currentIndex < _phrases.length -1 ) {
        //Update UI 
    setState(() {
      //increment index and continue
      _currentIndex++;
     
    });
      }
    }
  }

  
  ///FUNCTION TO SEND RECORDED FILE TO FLASK API
  Future<void> _sendToServer() async  {
    //check if there exist a recorded file 
    if(_filePath != null){
      //if there exist, send it to the backend
      await sendAudio(File(_filePath!));
    }

  }

  //HELPER FUNCTION  TO SEND AUDIO TO BACKEND
  Future<void> sendAudio(File audioFile) async{
    //Prepare a multipart POST request
    var request = http.MultipartRequest(
      "POST",
      Uri.parse('http:/127.0.0.1:5000/predict_audio')
    );

    //Attach the audio file with the field name file
    request.files.add(await http.MultipartFile.fromPath("file", audioFile.path));

    //Send the request 
    var response = await request.send();

    //Handle response
    ///if the request is sucesful,
    if(response.statusCode == 200){
      //read the reponse
      final resp = await response.stream.bytesToString();
      print("Prediction: $resp");

    }
    else{
      //print error message 
      print("Error: ${response.statusCode}");
    }
  }
  
  

  // UI layout

@override
Widget build(BuildContext context){
  return Scaffold(
    //background color
    backgroundColor: Color.fromARGB(255, 218, 210, 239),
    //basic appbar for display
    appBar: AppBar(
      centerTitle: true,
      title: const Text("PD Audio Assessment")
    ),
    //body with layout
    body: Center(
      //columns child with centered test
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //children list with several buttons
        children: [
          //show current phrase and progress indicator
          Text("Phrase ${_currentIndex + 1} of ${_phrases.length}",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10), 
          ///phrases display for the user to record the voice 
          Text(
            _phrases[_currentIndex], 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 20 ),
          //Start button with recording function
          ElevatedButton(onPressed: _startRecording, 
          child: const Text("Start Recording")),
          //Stop button 
          ElevatedButton(onPressed: _stopRecording, 
          child: const Text("Stop Recording"),
          ),
          //Send to server button
          ElevatedButton(onPressed: _sendToServer, child: const Text("Click for Prediction")),
          //Another elevatedbutton for sending to the typing dataset
          ElevatedButton(onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => TypingPage()));
              },
              child: const Text("Continue to Typing Page")
                 
          ),
      


        ],),

    )
  );
}


}




