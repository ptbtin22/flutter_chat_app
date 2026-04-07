import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'core/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/local_storage/hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(ChatAdapter());
  Hive.registerAdapter(MessageAdapter());

  initServiceLocator();
  runApp(const ChatDemoApp());
}
