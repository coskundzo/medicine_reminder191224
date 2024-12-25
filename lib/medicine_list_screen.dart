import 'package:flutter/material.dart';
import 'db/medicine.dart'; // Medicine modelini import ettiniz
import 'database_helper.dart'; // Veritabanı işlemleri için

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

  Future<void> _deleteMedicine(int id) async {
    await DatabaseHelper.instance.deleteMedicine(id);
    _loadMedicines();
    setState(() {});
  }

  void _editMedicine(Medicine medicine) {
    // Düzenleme ekranına yönlendirme veya işlem
    print("İlaç düzenle: ${medicine.name}");
  }

  void _toggleNotification(Medicine medicine) {
    // Bildirim durumunu değiştirme (örneğin, veritabanında güncelleme)
    print("Bildirim kapat: ${medicine.name}");
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editMedicine(medicine),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.notifications_off, color: Colors.orange),
                        onPressed: () => _toggleNotification(medicine),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Silme Onayı'),
                                content: Text(
                                    '${medicine.name} isimli ilacı silmek istediğinizden emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('Sil'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            await _deleteMedicine(index);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
