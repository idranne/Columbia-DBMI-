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
//Progress indicator package
import 'package:percent_indicator/percent_indicator.dart';

//layout of stateful widget 
class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  _AudioPageState createState() => _AudioPageState();
}

//Defining class and functions 
class _AudioPageState extends State<AudioPage> {
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
  final List<String> _recordings = [];
  //int index for placeholder
  int _currentIndex = 0;
  //Variable to store audio file path
  String? _filePath;
  //bool variable for recording status
  bool _isRecording = false;

  //FUNCTION TO START RECORDING
  Future<void> _startRecording() async {
    //check if microphone permission has been granted from permission page
    if (await _record.hasPermission()) {
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

      //Updating the path and status
      setState(() {
        _filePath = path;
        _isRecording = true;
      });
    }
  }

  //FUNCTION TO STOP RECORDING
  Future<void> _stopRecording() async {
    //Stop and finalize recording
    await _record.stop();
    //append recorded file path to list
    if (_filePath != null) {
      _recordings.add(_filePath!);

      //move to the next phrase if exist
      if (_currentIndex < _phrases.length - 1) {
        //Update UI 
        setState(() {
          //increment index and continue
          _currentIndex++;
          _isRecording = false;
        });
      } else {
        //If all phrases are done
        setState(() => _isRecording = false);
      }
    }
  }

  ///FUNCTION TO SEND RECORDED FILE TO FLASK API
  Future<void> _sendToServer() async {
    //check if there exist a recorded file 
    if (_filePath != null) {
      //if there exist, send it to the backend
      await sendAudio(File(_filePath!));
    }
  }

  //HELPER FUNCTION  TO SEND AUDIO TO BACKEND
  Future<void> sendAudio(File audioFile) async {
    //Prepare a multipart POST request
    var request = http.MultipartRequest(
      "POST",
      Uri.parse('http://127.0.0.1:5000/predict_audio'),
    );

    //Attach the audio file with the field name file
    request.files.add(await http.MultipartFile.fromPath("file", audioFile.path));

    //Send the request 
    var response = await request.send();

    //Handle response
    ///if the request is sucesful,
    if (response.statusCode == 200) {
      //read the reponse
      final resp = await response.stream.bytesToString();
      print("Prediction: $resp");
    } else {
      //print error message 
      print("Error: ${response.statusCode}");
    }
  }

  // UI layout
  @override
  Widget build(BuildContext context) {
    //Calculate progress for round tracker
    double progress = (_currentIndex + 1) / _phrases.length;

    return Scaffold(
      //background color
      backgroundColor: const Color.fromARGB(255, 218, 210, 239),
      //basic appbar for display
      appBar: AppBar(
        centerTitle: true,
        title: const Text("PD Audio Assessment"),
        backgroundColor: const Color.fromARGB(255, 166, 137, 226),
      ),
      //body with layout
      body: Center(
        //columns child with centered test
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //children list with several buttons
          children: [
            //Circular progress tracker for phrases
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 10.0,
              percent: progress,
              center: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 40,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
              progressColor: Colors.purple,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
            const SizedBox(height: 20),
            //show current phrase and progress indicator
            Text(
              "Phrase ${_currentIndex + 1} of ${_phrases.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ///phrases display for the user to record the voice 
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _phrases[_currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 30),
            //Start and Stop buttons in row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: _startRecording,
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: _stopRecording,
                ),
              ],
            ),
            const SizedBox(height: 20),
            //Send to server button
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Send for Prediction"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: _sendToServer,
            ),
            const SizedBox(height: 20),
            //Another elevatedbutton for sending to the typing dataset
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TypingPage()),
                );
              },
              child: const Text("Continue to Typing Page"),
            ),
          ],
        ),
      ),
    );
  }
}
