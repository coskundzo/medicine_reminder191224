import 'package:flutter/material.dart';
import 'db/medicine.dart';
import 'database_helper.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _time;
  int _frequency = 1; // Varsayılan günlük alınma sayısı

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İlaç Ekle')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'İlaç Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan zorunludur';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dozaj'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                  }
                },
                child: Text('Başlangıç Tarihini Seç'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _time = pickedTime;
                    });
                  }
                },
                child: Text('Zamanı Seç'),
              ),
              DropdownButtonFormField<int>(
                value: _frequency,
                decoration: InputDecoration(labelText: 'Günlük Alım Sayısı'),
                items: List.generate(5, (index) => index + 1)
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value kez'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final medicine = Medicine(
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      startDate: _startDate!,
                      time: _time!,
                      frequency: _frequency,
                    );

                    await DatabaseHelper.instance.insertMedicine(medicine);

                    // Başarı mesajı
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('İlaç kaydedildi!')),
                    );

                    Navigator.pop(context);
                  }
                },
                child: Text('Kaydet'),
              ),
              // İlaç Listesi Butonu
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/medicines');
                },
                child: Text('İlaç Listesine Git'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
