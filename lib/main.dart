import 'package:flutter/material.dart';
import 'Controller/data_handler.dart';
import 'view/facturePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataHandler.init();
  runApp(MaterialApp(home: FacturePage()));
}
