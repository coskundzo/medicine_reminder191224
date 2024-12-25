import 'package:flutter/material.dart';
import 'db/medicine.dart';
import 'database_helper.dart';

class MedicineListScreen extends StatefulWidget {
  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    _medicines = DatabaseHelper.instance.getMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kayıtlı İlaçlar')),
      body: FutureBuilder<List<Medicine>>(
        future: _medicines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Hiç ilaç kaydedilmedi.'));
          } else {
            final medicines = snapshot.data!;
            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return ListTile(
                  title: Text(medicine.name),
                  subtitle: Text(
                      'Dozaj: ${medicine.dosage}, Saat: ${medicine.time.format(context)}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
