import 'package:flutter/material.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String buttonName='click me';
  int currentIndex= 0;
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("App Title of Sineth"),
          backgroundColor: Color.fromARGB(159, 33, 182, 3),
        ),

        body : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed:(){
                  setState(() {
                    buttonName='hey';
                  });
                
                },
              
              
              
              child: Text(buttonName),
                      ),
            
            ],
            
          ),
          ),
        


        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home)
            ),
            BottomNavigationBarItem(
              label: "Settings",
              icon: Icon(Icons.settings)
            ),
            BottomNavigationBarItem(
              label: "Options",
              icon: Icon(Icons.settings)
            ),
          ],
          currentIndex: currentIndex,
          onTap: (int index){
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}