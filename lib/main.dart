//import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socket_whiteboard/Screens/main_whiteboard_screen.dart';
//import 'package:socket_whiteboard/config/config.dart';
import 'Screens/pentab_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp( const MaterialApp(
    debugShowCheckedModeBanner: false,
    home:  MyApp(),
  ));
}

class MyApp extends StatefulWidget {
   const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _fbap = Firebase.initializeApp(
    name: kIsWeb?null:"my-app",
    options: const FirebaseOptions(
        apiKey: "AIzaSyBt3A1J0Ez_CE6JmPN-UNgPhaBIXh-qGrE",
        appId: "com.example.socket_whiteboard",
        messagingSenderId: "737683896184",
        projectId: "socket-whiteboard",
      databaseURL: "https://socket-whiteboard-default-rtdb.firebaseio.com/"
    ),
  );

  bool isBroadcasting = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: FutureBuilder(
        future: _fbap,
        builder: (context,snapshot){
      if (snapshot.hasError) {
        return const Center(
          child: Text('Something Went wrong :'),
        );
      }
      else if (snapshot.hasData) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const WhiteBoards() ));
                  },
                  child: Card(
                    child: SizedBox(
                      height: screenSize.height * 0.25,
                      width: screenSize.height * 0.25,
                      child: const Center(
                          child: Text('Screen',style: TextStyle(fontSize: 25.0),)
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> PenScreen(broadCasting: isBroadcasting,) ));
                  },
                  child: Card(
                    child: SizedBox(
                      height: screenSize.height * 0.25,
                      width: screenSize.height * 0.25,
                      child:  Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                            const Padding(
                               padding: EdgeInsets.all(8.0),
                               child:  Text('Pentab',style: TextStyle(fontSize: 25.0),),
                             ),
                              isBroadcasting?const Text("Live BroadCasting : ON"): const Text("Live BroadCasting : OFF")
                            ],
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.amberAccent,
              onTap: (int num){
                  if(num==0){
                    setState((){
                      isBroadcasting?isBroadcasting = false : isBroadcasting = true;
                    });
                  }
              },
              items:  [
                BottomNavigationBarItem(icon: Icon(Icons.offline_bolt,color: isBroadcasting?Colors.red:Colors.black),label: "Live"),
                const BottomNavigationBarItem(icon: Icon(Icons.settings),label: "Settings",)
                ]),
        );
      }
      else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },)
    );
  }
}
