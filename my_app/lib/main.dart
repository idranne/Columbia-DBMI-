import 'package:flutter/material.dart';
import 'package:my_app/permission_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // ✅ Root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white, // White background
        // ✅ AppBar at the top
        appBar: AppBar(
          centerTitle: true,
          title: Text("ParkAssist", style: TextStyle(fontSize: 20.0),),
          backgroundColor: Colors.purple[200], // Light purple app bar
          elevation: 0,
          leading: Icon(Icons.menu, color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.logout, color: Colors.white),
            )
          ],
        ),

        // ✅ Body layout
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Main welcome container
              Container(
                height: 300,
                width: 500,
                decoration: BoxDecoration(
                  color: Colors.purple[100], // Light purple foreground
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(25),
                child: Text(
                  "Welcome to ParkAssist, a mobile application used for early detection of Parkinson Disease. "
                  "The app collects important metrics such as voice patterns, handwritten dataset, and typing patterns "
                  "that can determine your risk of getting PD. Embedded in the app is a genetic component used for "
                  "any gene expression profile.",
                  style: TextStyle(
                    color: Colors.black, // Text readable on light purple
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40), // Spacing before button

              // ✅ Centered Start Assessment button
              Builder(
                builder:(context) => 
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300], // Button color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Start Assessment",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PermissionPage()),
                  );
                },
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
