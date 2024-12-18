import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İlaç Hatırlatma')),
      body: Center(
        child: Text('İlaç listeniz burada görünecek'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addMedicine');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
