import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'core/service_locator.dart';

void main() {
  initServiceLocator();
  runApp(const ChatDemoApp());
}
