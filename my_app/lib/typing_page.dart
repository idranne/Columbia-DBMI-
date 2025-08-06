//Importing packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import "package:http/http.dart" as http;
import "package:my_app/facial_page.dart";

class TypingPage extends StatefulWidget {
  const TypingPage({super.key});

  @override
  State <TypingPage> createState() =>  TypingPageState();
}

class TypingPageState extends State <TypingPage> {

  //VARIABLES

  //Store timestamps for keydown events 
  final Map<String, int> _keyDownTime = {};

  //Store last key down and up time times for latency and flight calculaions since latency is difference between keyup / keydow
  int ? _lastKeyDownTime = 0;
  int ? _lastKeyUpTime = 0;

  //List to hold captured features for all keys
  final List<Map<String, dynamic>> _keystrokeData = [];

  //Controller for user input
  final TextEditingController _controller = TextEditingController();

  //List for multiple phrases
  final List<String> _phrases = [
    "The quick brown fox jumps over the lazy dog.",
    "Typing patterns can reveal neurological conditions.", 
    "Flutter makes building cross-platform apps easy."
  ];

  //index for currentPhrase reference 
  int _currentIndex = 0;


  //FUNCTION TO SAVE DATA TEMPORARY 
  Future <File> _saveKeystrokeData() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/keystroke_data.csv');

    //Prepare CSV file header / row
    final csvContent = StringBuffer("key, hold_time, flight_time, latency_time/n");
    //for each in keystroke daya list,
    for (var data in _keystrokeData) {
      //write in the csvfile like this 
      csvContent.writeln(
        "${data['key']},${data['hold']},${data['flight']},${data['latency']}"
      );

    }
  
      //return the csv file
      return file.writeAsString(csvContent.toString());
  }
    
  //FUNCTION TO SEND CSV TO FLASK BACKEND
  Future<void> _sendToServer() async {
    //calling the return value (file) of previous function
    final file = await _saveKeystrokeData();

    //request and apis
    var request = http.MultipartRequest("POST", Uri.parse("http://127.0.0.1:5000/predict_typing"));
    //add file to directory
    request.files.add(await http.MultipartFile.fromPath("file", file.path));
    //send to API in a variable
    var response = await request.send();

    //if the response has been recieved,
    if(response.statusCode == 200){
      //reponse from API
      final resp = await response.stream.bytesToString();
      print("Typing prediction: ${resp}");
    }
    else{
      print("Error: ${response.statusCode}");
    }
  }


  //FUNCTION TO CHECK PHRASE COMPLETION
  void _checkPhraseCompletion(){
    //if the text from the user is equivalent to the phrase at that index
    if(_controller.text.trim() == _phrases[_currentIndex]){
      //and if the index is valid 
      if(_currentIndex < _phrases.length - 1){
        //setState of stfl widget 
        setState(() {
          //increment index
          _currentIndex++;
          //clear controller for next word
          _controller.clear();
          
        });

      }//send to server if we have finally found something
      else{
        _sendToServer();

      }

    }
  }




  //UI/UX Layout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       //background color 
       backgroundColor: Color.fromARGB(225, 218, 210, 239),
       //basic appBar for assement layout
       appBar: AppBar(
        centerTitle: true,
        title: const Text("PD Typing Assessment"),
       ),

       //body for keystroke dynamics
       //class with params
       body: RawKeyboardListener(
        //receive input from user
        focusNode: FocusNode(),
        //callback function
        onKey: (RawKeyEvent event){

          //extract which key was pressed and find tim
          final key = event.logicalKey.keyLabel;
          final currentTime = DateTime.now().millisecondsSinceEpoch;

          //if the key was pressed, 
          if(event is RawKeyDownEvent){
            //store the key down timestamp in the dictionary
            _keyDownTime[key] = currentTime;

            //calculate latency time 
            int ? latency;
            //if lastkeyddowntime is null
            if(_lastKeyDownTime != null){
              //find difference
              latency = currentTime - _lastKeyDownTime!;
              print("Latency betwen keys: ${latency} ms");
              //
            }
            //update the lastkeytime 
            _lastKeyDownTime = currentTime;

             //Save data in List --> flight will be completed on key up
             _keystrokeData.add({"phrase": _phrases[_currentIndex], "key": key, "hold": null, "flight": null, "latency": latency});

          }

          //else if the eveny is keyup --> key up p
          else if(event is KeyUpEvent){
            //calculate holdtime based on the key
            if(_keyDownTime.containsKey(key)){
              //holdtime calc
              final holdTime = currentTime - _keyDownTime[key]!;
              print("HoldTime for ${key}: ${holdTime} ms");


            //Calculate Flight time 
            int ? flightTime;
            //if the keyup esist --> a key has been released,
            if(_lastKeyUpTime != null){
              flightTime = currentTime - _lastKeyDownTime!;
              print("Flight Time: ${flightTime})");

            }

            //update key 
            _lastKeyDownTime = currentTime;
            _keyDownTime.remove(key);


          //update the last inserted entry with hold and flight 
          if(_keystrokeData.isNotEmpty){
            _keystrokeData.last["hold"] = holdTime;
            _keystrokeData.last["flight"] = flightTime;
          }


            }
          }

        }, 


//UI layout wwith how stuff will be realigned
        child: Center(
          child: Padding(padding: const EdgeInsets.all(20.0),
          //child column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //text display 
              const Text(
                "Please type the following phrase",
                style: TextStyle(fontSize: 18),
              ),
              //box for spacing 
              const SizedBox(height: 10),

              Text(
                _phrases[_currentIndex], style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)), 
              
              //user input for controller field
              TextField(
                controller: _controller,
                onChanged: (_) => _checkPhraseCompletion(),
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Type here .."),

              ), 
              const SizedBox(height: 20,), 
              ElevatedButton(onPressed: _sendToServer, child: const Text("Send Typing Data"),),

              //Move to facial dataset

              ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FacialPage()),
                );
              },
              child: const Text("Continue to Facial Page"),
            )

          ],)
        ),
        )


       )

    


    );
   
    



  }
}


///Typing demain