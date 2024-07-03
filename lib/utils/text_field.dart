import 'package:flutter/material.dart';

class TextField1 extends StatelessWidget {
  final TextEditingController Tcontroller ;
  const TextField1({super.key, required this.Tcontroller});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          autofocus: true,
          autocorrect: true,
          controller: Tcontroller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
