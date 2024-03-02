import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  const TextPage({Key? key, required this.value}) : super(key: key);

  final String value;

  @override
  State<TextPage> createState() => _TextState();
}

class _TextState extends State<TextPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.value,
                        style: const TextStyle(fontSize: 20 ,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
