import 'package:flutter/material.dart';
import 'package:my_app/permission_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home page 
      home: Scaffold(
        backgroundColor: Colors.white,
        //basic appBar with name of the app 
        appBar: AppBar(
          centerTitle: true,
          title: const Text("ParkAssist", style: TextStyle(fontSize: 20.0)),
          backgroundColor: Colors.purple[200],
          elevation: 0,
          leading: const Icon(Icons.menu, color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.white),
            )
          ],
        ),

        //Body with ListView
        body: Column(
          //children with ListView with thesame properties
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Welcome Page Container with basic description of application
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      "Welcome to ParkAssist! This app collects different metrics "
                      "to help with early detection of Parkinson Disease. "
                      "Below are the features we’ll assess:",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Feature cards for each metric
                  _buildFeatureCard(Icons.mic, "Voice Analysis",
                      "Capture your voice to analyze speech patterns."),
                  _buildFeatureCard(Icons.keyboard, "Typing Pattern",
                      "Track typing speed and rhythm for motor assessment."),
                  _buildFeatureCard(Icons.face, "Facial Expression",
                      "Use the camera to detect facial movement changes."),
                  _buildFeatureCard(Icons.sensors, "Accelerometer",
                      "Monitor hand tremors and movement sensitivity."),
                  _buildFeatureCard(Icons.device_thermostat, "Gyroscope",
                      "Analyze hand rotation and balance metrics."),
                ],
              ),
            ),

            // Fixed Start Assessment button
            Padding(
              padding: const EdgeInsets.all(20),
              //builder with button page
              child: Builder(
                //styling of the button page 
                builder: (context) => ElevatedButton(
                  //styling of the button page
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  ///styling ends 
                  
                  //actual parameters of the elevatedbutton class
                  child: const Text(
                    "Click to give access",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                //when clicked, take us to the permission page for access to permission
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PermissionPage()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable feature card widget
  //Think of this like functions that build the UI
  static Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Card(
      //return a Card class with the following prop
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //this is littitle class for each metric
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.purple[300]),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {}, // Optional: Navigate to detail page
      ),
    );
  }
}
