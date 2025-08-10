//Importing necessary packages
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/audio_page.dart';



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
      backgroundColor: Colors.white, 
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 235, 188, 244),
        title: const Text("Permission Page", style: TextStyle(fontSize: 20.0),)

      ),
      //listing a body as a colunm and listview for the different metrics
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
        //ListTile will be used for all 3 parameters
        
        //Microphone for audio ML

        //Create a Card class to increase space and beauty

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 2,

        child: ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.mic)),
          title: const Text("Microphone Permission"),
          subtitle : const Text("Click to give microphone access"),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.microphone),
        ),
        
        ),
        const SizedBox(height: 12), 

        //Typing for typing ML 

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 2,
         child : ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.apps)),
          title: const Text("Keyboard Permission"),
          subtitle : const Text("Click to give keyboard access"),
          trailing: SizedBox(height: 40),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.microphone)
            
         ),
        ),

         const SizedBox(height: 12), 

        

        //Typing for facial CNN

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 2,

        child: ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.photo)),
          title: const Text("Camera Permission"),
          subtitle : const Text("Click to give camera access"),
          trailing: SizedBox(height: 40),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.camera)
        ),

        ),

        const SizedBox(height: 12),
         
        //settings just in case
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 2, 
        child: ListTile( 
          leading: const CircleAvatar(child: Icon(Icons.settings)),
          title: const Text("Open App Permission"),
          subtitle : const Text("Click to open app settings"),
          trailing: SizedBox(height: 40),
          //do something when tapped
          onTap: () => requestPermission(permission: Permission.storage),
        ), 

        ),

        const SizedBox(height: 12),

        //Acceloremter
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 2,
        child: ListTile(
            minVerticalPadding: 20, 
            leading: const CircleAvatar(child: Icon(Icons.sensors)),
            title: const Text("Accelerometer Permission"),
            subtitle: const Text("Click to enable motion detection"), 
            onTap : () => requestPermission(permission: Permission.sensors), 

          )
          ),

          const SizedBox(height: 12),

          //Gyrometer

          Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 2,
          child: ListTile(
            minVerticalPadding: 20, 
            leading: const CircleAvatar(child: Icon(Icons.sensors)),
            title: const Text("Gyroscope Permission"),
            subtitle: const Text("Click to enable device rotation detection"), 
            onTap : () => requestPermission(permission: Permission.sensors), 

          )
          ), 

          const SizedBox(height: 12),


        //Tap to start the first audio assesment

        Center(
          //title: const Text("Start Audio Assesment", style: TextStyle(color: Color.fromARGB(255, 209, 192, 237)),),
          child: ElevatedButton(
            //styling 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 188, 164, 229),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                ///styling with actual paramters
            
              )), 

            ///second onPressed parameter to take to the audi page

            onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> AudioPage()));
          },
          child: const Text("Start Audio Assesment", style: TextStyle(color: Color.fromARGB(255, 5, 1, 14))),)),
          
          const SizedBox(height: 12),

        
      
      
    
      ], 
    ), 
    );
    
  }
}


