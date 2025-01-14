import 'package:flutter/material.dart';

class FloatingPage extends StatelessWidget {
  const FloatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Arka planı şeffaf yapar
      body: Container(
        margin: EdgeInsets.only(top: 50), // Üst kısımdan boşluk bırak
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Bu bir yüzen sayfadır!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Burada kullanıcıdan istediğiniz bilgiyi alabilirsiniz. Modal sayfa yüzer şekilde gösterilecektir.',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Modalı kapatır
                  },
                  child: Text('Kapat'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // İlgili işlemi burada gerçekleştirin
                  },
                  child: Text('Devam Et'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
