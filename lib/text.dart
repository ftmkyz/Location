import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  const TextPage({Key? key, required this.value,required this.textIcon}) : super(key: key);

  final String value;
  final IconData textIcon;

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
                      Icon(widget.textIcon,
                      color: const Color.fromARGB(255, 5, 5, 5)),
                      Text(
                        widget.value,
                        style: const TextStyle(fontSize: 16),
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
