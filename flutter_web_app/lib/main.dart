import 'package:flutter/material.dart';
import 'home_page.dart';

void main() async{
  print("app main");
  WidgetsFlutterBinding.ensureInitialized();
  print("init started main");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: MyHomePage(title: 'Flutter Demo Home Page'),);
  }
}


