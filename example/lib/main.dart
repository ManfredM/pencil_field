import 'package:flutter/material.dart';
import 'package:pencil_field/pencil_field.dart';

import 'pencil_field_with_tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencil Field Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pencil Field Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pencilController = PencilFieldController();
  PencilDrawing _pencilDrawing = const PencilDrawing(strokes: []);
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            _PencilDisplay(controller: pencilController),
            const SizedBox(height: 100),
            PencilFieldWithTools(
              controller: pencilController,
              onPencilDrawingChanged: _drawingChanged,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _drawingChanged(PencilDrawing pencilDrawing) {
    setState(() {
      _pencilDrawing = pencilDrawing.scale(scale: scale);
    });
  }
}

class _PencilDisplay extends StatefulWidget {
  final PencilFieldController controller;

  const _PencilDisplay({super.key, required this.controller});

  @override
  State<_PencilDisplay> createState() => _PencilDisplayState();
}

class _PencilDisplayState extends State<_PencilDisplay> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black38,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey[200]!,
      ),
      child: Column(
        children: [
          const Text('Scaled drawing'),
          Slider(
            min: 0.25,
            max: 4,
            value: scale,
            onChanged: (value) {
              setState(() {
                scale = value;
              });
            },
          ),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: PencilDisplay(
              pencilDrawing: widget.controller.drawing.scale(
                scale: scale,
              ),
              decoration: PencilDecoration(backgroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
