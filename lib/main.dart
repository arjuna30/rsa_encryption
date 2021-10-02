import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:public_key_encryption/src/model/encryption.dart';
import 'package:public_key_encryption/src/page/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => Encryption())],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blueGrey),
        home: const HomePage(),
      ),
    );
  }
}
