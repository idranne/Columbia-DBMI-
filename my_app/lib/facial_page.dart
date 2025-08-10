//Importing dependencies
import 'package:flutter/material.dart';
import "package:camera/camera.dart";
import 'dart:async';
import 'dart:io';
import "package:path_provider/path_provider.dart";
import "package:http/http.dart" as http;


//UI page and stateful class
class FacialPage extends StatefulWidget {
  const FacialPage({super.key});

  @override
  State<FacialPage> createState() => _FacialPageState();
}


class _FacialPageState extends State<FacialPage> {
  // --------------------------------DEFINING LOCAL VARIABLES -----------------------------------------//


  //camera preview and capture
  CameraController? _cameraController;
  //list of available cameras
  List<CameraDescription>? _cameras;
  //tracks if camera is ready
  bool _isCameraInitialized = false;
  //timer for picture intake
  int _countdown = 0;
  //resulst from backend 
  String? _predictionResults;

  @override
  //initialize state
  void initState(){
    //calling the super method
    super.initState();
    //calling function 
    _initCamera();

  }

//--------------------------------FUNCTIONS ------------------------//
  //Initialize the device camera (front-facing)

  Future<void> _initCamera() async{
    //fetches all list of cameras
     _cameras = await availableCameras();

     //Prefer front camera for facial capture
     //searches for  camera with front lens, else defaults to first 
     final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front, orElse: () => _cameras!.first,
     );

     //initialize the camera class so it can be good to go
     _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
     await _cameraController!.initialize();

//if not mounted
     if(!mounted){
      return;
     };
//set state to camera to be true
      setState(() {
        _isCameraInitialized = true;
      });
     
  }

  //5-second countdown and then takes a pictre
  Future<void> _startCountdownAndCapture() async {
    //set state each time the countddown goes down
    setState(() {
      _countdown = 5;
    });
  
  //loop for countdown 
  for (int i = 5; i >= 0; i--){
    //set state as well
    setState(() {
      _countdown = i;
    });
    //take picture at the last second 
    await Future.delayed(const Duration(seconds: 1));
  }
  //capture image / call function
  await _captureImage();

  }

  ///Capture image and send to Flask API /////
  Future<void> _captureImage() async{

    //if image / class has been initialized
    if(!_cameraController!.value.isInitialized){
      return ;
    }

    //Take picture
    final image = await _cameraController!.takePicture();

    //Save temporarily to apps's document directory 
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/clenched_teeth.jpg';
    await image.saveTo(filePath);

    //Send to backend by calling the function
    await _sendToServer(File(filePath));
  
  }

  //Send the captured image to Flask 
  Future<void> _sendToServer(File imageFile) async{
    //request and http
    var request = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1:5000/predict_facial"));

    //change to actual path 
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));
  
    //send reponse to sever
    var response = await request.send();
    
    //retrieve reponse to server
    if (response.statusCode == 200){
      final resp = await response.stream.bytesToString();
      setState(() {
        _predictionResults = resp;
      });
      //upate the current state and print predictions
      print("Facial prediction: $resp");
    }
    else{
      //else print the error
      print("Error ${response.statusCode}");
    }
  }





//-----------------------------------------UI/UX design -----------------------------------//

  Widget build(BuildContext context) {
    return Scaffold(
    //background color
    backgroundColor: Color.fromARGB(225, 218, 210, 239),
    //basic appBar
    appBar: AppBar(
      backgroundColor: Colors.deepPurple,
      centerTitle: true,
      title: Text("Facial Assesment"),
    ),

    //body 
    body _isCameraInitialized?Column(
      children: [
        //camera previe
        Expanded(
          flex:3, 
          child: CameraPreview(_cameraController!)),


          //Instructions for user
          Padding(
            padding: const EdgeInsets.all(16)),
            child: Text(
              _countdown > 0?
              "Get ready in  ${_countdown}" :
              "Clench your teeth and press 'Start Test'.", 
              style: const TextStyle(fontSize: 18)), 
              textAlign: TextAlign.center,
          
            ),

            //prediction
            if(_predictionResults != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Prediction: ${_predictionResults}", 
                style: const TextStyle(fontSize: 18, FontWeight: FontWeight.bold), 
                textAlign: TextAlign.center,
              ),
             

            //Start test button
            Padding(
              padding: const EdgeInesets.all(16.0), 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16))
                   onPressed; _startCountdownAndCapture,
                   onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Acceloremeter_GyrometerPage()));
                   }
                   child: const Text("Start Test"))
            ), 
            )
          
      ],
    ))
),



    )
  }




}