import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


//main function to rn file
void main() {
  runApp(const PermissionPage());
}

//extending the stateful widget 
class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

//Function to check and request permission 
Future<void> requestPermission ({required Permission permission}) async{
  //creating a bool for permission access or not 
  final status = await permission.status;
  //conditions if permission have been granted or not
  if (status.isGranted){
    //print 
    debugPrint("Permisssion already granted");
  }
  //if the permission is not given,
  else if (status.isDenied){
    //and the request has been denined,
    if(await permission.request().isGranted){
      debugPrint("Permission granted");
    }
    //else if it has not been granted, 
    else{
      debugPrint("Permission denied");
    }

  }
  //if not of the conditions are true,
  else{
    debugPrint("Permission denied");
  }
  

  }

  //Maybe will need multiple permission after

 // Future<void>  requestMultiplePermission() async{
    //final statusMap = await [
      //Permission.microphone,
     // Permission.camera,
     // Permission.speech
    //].request();
   
  //}

  //Actual class with the UI interface


class _PermissionPageState extends State<PermissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //doing an AppBar page 
      appBar: AppBar(
        title: const Text("Permission Page")
      ),
      //listing a body as a colunm and listview for the different metrics
      body: Column(children: [
        //lis tIle will be used for all 3 parameters
        
        //Microphone for audio ML
        ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.mic)),
          title: const Text("Microphone Permission"),
          subtitle : const Text("Click to give microphone access"),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.microphone),
        ),

        //Typing for typing ML 
         ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.apps)),
          title: const Text("Keyboard Permission"),
          subtitle : const Text("Click to give keyboard access"),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.microphone)
            
          
         ),

        //Typing for facial CNN

         ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.photo)),
          title: const Text("Camera Permission"),
          subtitle : const Text("Click to give camera access"),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.camera)
        ),
         
        //settings just in case
         ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.settings)),
          title: const Text("Opn App Permission"),
          subtitle : const Text("Click to open app settings"),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.storage),
        )
      
         
    
      ],)
    );
  }
}