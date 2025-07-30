import 'package:flutter/material.dart';
import 'package:newapp/pages/permission_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //This is the home --> basic layout
      home: Scaffold(
        backgroundColor: Colors.deepPurple[200],
        //little appbar at top
        appBar: AppBar(
          title: Text("ParkAssist"),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          leading: Icon(Icons.menu),
          actions [IconButton(onPressed: () {}, icon: Icon{Icons.logout})]
        ),

        //create a body layout with a container layout 
        body: Center(
          //container --> think of this like div in html
          child: Container(
            height: 400, 
            width: 500,
            decoration: BoxDecoration(
              color : Color.deepPurple,
              borderRadius: borderRadius.circular(20)
            ),
            padding: EdgeInsets.all(25),
            title: Text("Welcome to ParkAssist, a mobile application used for early detectionm of Parkinson Disease. The app collects important metrics such as voice patterns, handwritten dataset and typing patterns that can determine tour risk of getting PD. Embedded in the app is a genetic component used for any gene expression profile", 
            style: TextStyle{
              color: Colors.white,
              fontSize : 28, 
              fontWeight: FontWeight.bold
        
            })


          )
        )

        //create another widget (container for "Start Asssesment") which equally carries me to the permission page for permission in user
        body: Column(
          //children for several modifications
          children: [
          //expanded class
            Expanded(
              child: Container(
                color: Colors.deepPurple[100],
                height: 200,
                width : 200,
                title : Text("
                Start assessment here", color: Colors.white, fontSize : 24, fontWeight: FontWeight.bold
              )
              )/
            )
            //padding attribute 
            Padding(
              padding: EdgeInsets.all(25),
              //when ever the button is pressed, 
              child: ElevatedButton(
                child: Text("Start assessment here")
                onPressed: (){
                  //the user goes to the permission page
                  Navigator.push(context,  
                  MaterialPageRoute(builder: (context) => PermissionPage()))
                }
              )

            )
          ]
        )
      ),

      

    );
  }
}

