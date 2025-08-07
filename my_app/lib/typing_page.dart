//Importing packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import "package:http/http.dart" as http;
import "package:my_app/facial_page.dart";

class TypingPage extends StatefulWidget {
  const TypingPage({super.key});

  @override
  State<TypingPage> createState() => TypingPageState();
}

class TypingPageState extends State<TypingPage> {
  //------------------------------VARIABLES-------------------------------------//

  //gender for ML model
  String? _gender;

  //list of all genders
  final List<String> _genders = ["Male", "Female", "Other"];

  //Store timestamps for keydown events
  final Map<String, int> _keyDownTime = {};

  //Store last key down and up time times for latency and flight calculaions since latency is difference between keyup / keydow
  int? _lastKeyDownTime = 0;
  int? _lastKeyUpTime = 0;

  //List to hold captured features for all keys
  final List<Map<String, dynamic>> _keystrokeData = [];

  //Controller for user input
  final TextEditingController _controller = TextEditingController();

  //List for multiple phrases
  final List<String> _phrases = [
    "The quick brown fox jumps over the lazy dog.",
    "Typing patterns can reveal neurological conditions.",
    "Flutter makes building cross-platform apps easy.",
  ];

  //index for currentPhrase reference
  int _currentIndex = 0;

  ///----------------------------------------FUNCTIONS-------------------------------------------------------//

  //FUNCTION TO PREPARE FINAL METRIC FOR ML MODEL

  Map<String, dynamic> _prepareMetrics() {
    //each of those are kikst
    //loop over the keyStrokedData and if hold is 0, cast to the list for flightime, holdtime and latency
    final holds = _keystrokeData
        .map((e) => e["hold"] ?? 0)
        .cast<int>()
        .toList();
    final flights = _keystrokeData
        .map((e) => e["flight"] ?? 0)
        .cast<int>()
        .toList();
    final latencies = _keystrokeData
        .map((e) => e["latency"] ?? 0)
        .cast<int>()
        .toList();

    //compute engineered featured if list is not empty

    double avgHold = holds.isNotEmpty
        ? holds.reduce((a, b) => a + b) / holds.length
        : 0.0;
    double avgFlight = flights.isNotEmpty
        ? flights.reduce((a, b) => a + b) / flights.length
        : 0.0;
    double avgLatency = latencies.isNotEmpty
        ? latencies.reduce((a, b) => a + b) / latencies.length
        : 0.0;

    double ratio = avgFlight != 0 ? avgHold / avgFlight : 0.0;
    double latencyMinusHold = avgLatency - avgHold;

    //return key pair values
    return {
      "gender": _gender,
      "holdtime": avgHold,
      "flighttime": avgFlight,
      "latencytime": avgLatency,
      "ratio": ratio,
      "latency_minus_holdtime": latencyMinusHold,
    };
  }
  //----------------------FUNCTION TO SEND DATA AS JSON TO FLASK SERVER---------------------------------------//

  //FUNCTION TO SEND CSV TO FLASK BACKEND
  Future<void> _sendToServer() async {
    //cCheck if the gender has been filled
    if (_gender == null) {
      //send message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select gender before sending")),
      );
      return;
    }

    //metrics to be sent
    final metrics = _prepareMetrics();
    final response = await http.post(
      Uri.parse("http://127.0.0.1:5000/predict_typing"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(metrics),
    );

    //if the response has been recieved,
    if (response.statusCode == 200) {
      //reponse from API

      print("Typing prediction: ${response.body}");
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  //FUNCTION TO CHECK PHRASE COMPLETION
  void _checkPhraseCompletion() {
    //if the text from the user is equivalent to the phrase at that index
    if (_controller.text.trim() == _phrases[_currentIndex]) {
      //and if the index is valid
      if (_currentIndex < _phrases.length - 1) {
        //setState of stfl widget
        setState(() {
          //increment index
          _currentIndex++;
          //clear controller for next word
          _controller.clear();
        });
      } //send to server if we have finally found something
      else {
        _sendToServer();
      }
    }
  }

  //---------------------------------UI/UX Layout--------------------------------//

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
      body: KeyboardListener(
        //receive input from user
        focusNode: FocusNode(),
        //callback function
        onKeyEvent: (KeyEvent event) {
          //extract which key was pressed and find tim
          final key = event.logicalKey.keyLabel;
          final currentTime = DateTime.now().millisecondsSinceEpoch;

          //if the key was pressed,
          if (event is KeyDownEvent) {
            //store the key down timestamp in the dictionary
            _keyDownTime[key] = currentTime;

            //calculate latency time
            int? latency;
            //if lastkeyddowntime is null
            if (_lastKeyDownTime != null) {
              //find difference
              latency = currentTime - _lastKeyDownTime!;
              print("Latency betwen keys: ${latency} ms");
              //
            }
            //update the lastkeytime
            _lastKeyDownTime = currentTime;

            //Save data in List --> flight will be completed on key up
            _keystrokeData.add({
              "phrase": _phrases[_currentIndex],
              "key": key,
              "hold": null,
              "flight": null,
              "latency": latency,
            });
          }
          //-------------------------------------KEY UP ----------------------------------//
          //else if the eveny is keyup --> key up p
          else if (event is KeyUpEvent) {
            //calculate holdtime based on the key
            if (_keyDownTime.containsKey(key)) {
              //holdtime calc
              final holdTime = currentTime - _keyDownTime[key]!;
              print("HoldTime for ${key}: ${holdTime} ms");

              //Calculate Flight time
              int? flightTime;
              //if the keyup esist --> a key has been released,
              if (_lastKeyUpTime != null) {
                flightTime = currentTime - _lastKeyDownTime!;
                print("Flight Time: ${flightTime})");
              }

              //update key
              _lastKeyDownTime = currentTime;
              _keyDownTime.remove(key);

              //update the last inserted entry with hold and flight
              if (_keystrokeData.isNotEmpty) {
                _keystrokeData.last["hold"] = holdTime;
                _keystrokeData.last["flight"] = flightTime;
              }
            }
          }
        },

        //UI layout wwith how stuff will be realigned
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            //child column
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //---------------------Gender Dropdown -----------------//
                DropdownButtonFormField<String>(
                  //decoration and styleonh
                  decoration: const InputDecoration(
                    labelText: "Select Gender",
                    border: OutlineInputBorder(),
                  ),
                  value: _gender,
                  //dropdown menu
                  items: _genders
                      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(), //cast to list
                  ///change state to gender
                  onChanged: (val) => setState(() => _gender = val),
                ),
                const SizedBox(height: 20),

                //---------------text display  ----------------//
                const Text(
                  "Please type the following phrase",
                  style: TextStyle(fontSize: 18),
                ),
                //box for spacing
                const SizedBox(height: 10),

                Text(
                  _phrases[_currentIndex],
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),

                //----------------------------TEXT DISPLAY------------------//
                //user input for controller field
                TextField(
                  controller: _controller,
                  onChanged: (_) => _checkPhraseCompletion(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Type here ..",
                  ),
                ),
                const SizedBox(height: 20),

                ///-------------------SEND DATA BUTTON ----------------------------------//
                ElevatedButton(
                  onPressed: _sendToServer,
                  child: const Text("Send Typing Data"),
                ),

                //// --------------------------------FACIAL SCAN ----------------------------------//
                //Move to facial dataset
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FacialPage(),
                      ),
                    );
                  },
                  child: const Text("Continue to facial page to facial scan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


///Typing demain