import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

part 'main.g.dart';

@HiveType(typeId: 0)
class Vehicle extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String vin;
  @HiveField(2)
  String motor;
  @HiveField(3)
  int kw;
  @HiveField(4)
  String fuel;
  @HiveField(5)
  String drive;
  @HiveField(6)
  String color;
  @HiveField(7)
  String note;

  Vehicle({
    required this.name,
    required this.vin,
    required this.motor,
    required this.kw,
    required this.fuel,
    required this.drive,
    required this.color,
    required this.note,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(VehicleAdapter());
  await Hive.openBox<Vehicle>('vehicles');
  runApp(MojeGarazApp());
}

class MojeGarazApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moje Garáž',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey.shade300,
          secondary: Colors.tealAccent,
          surface: Colors.blueGrey.shade900,
          background: Colors.blueGrey.shade800,
        ),
        scaffoldBackgroundColor: Colors.blueGrey.shade800,
        appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey.shade700),
      ),
      home: VehicleListScreen(),
    );
  }
}

class VehicleListScreen extends StatefulWidget {
  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late Box<Vehicle> vehicleBox;

  @override
  void initState() {
    super.initState();
    vehicleBox = Hive.box<Vehicle>('vehicles');
  }

  void _addOrEditVehicle({Vehicle? vehicle}) async {
    final isNew = vehicle == null;
    final nameController = TextEditingController(text: vehicle?.name ?? '');
    final vinController = TextEditingController(text: vehicle?.vin ?? '');
    final motorController = TextEditingController(text: vehicle?.motor ?? '');
    final kwController = TextEditingController(
        text: vehicle != null ? vehicle.kw.toString() : '');
    final fuelController = TextEditingController(text: vehicle?.fuel ?? '');
    final driveController = TextEditingController(text: vehicle?.drive ?? '');
    final colorController = TextEditingController(text: vehicle?.color ?? '');
    final noteController = TextEditingController(text: vehicle?.note ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isNew ? 'Přidat vozidlo' : 'Upravit vozidlo'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Název')),
              TextField(controller: vinController, decoration: InputDecoration(labelText: 'VIN')),
              TextField(controller: motorController, decoration: InputDecoration(labelText: 'Motor')),
              TextField(controller: kwController, decoration: InputDecoration(labelText: 'kW'), keyboardType: TextInputType.number),
              TextField(controller: fuelController, decoration: InputDecoration(labelText: 'Palivo')),
              TextField(controller: driveController, decoration: InputDecoration(labelText: 'Pohon')),
              TextField(controller: colorController, decoration: InputDecoration(labelText: 'Barva (kód)')),
              TextField(controller: noteController, decoration: InputDecoration(labelText: 'Poznámka')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Zrušit'),
          ),
          ElevatedButton(
            onPressed: () {
              final newVehicle = Vehicle(
                name: nameController.text,
                vin: vinController.text,
                motor: motorController.text,
                kw: int.tryParse(kwController.text) ?? 0,
                fuel: fuelController.text,
                drive: driveController.text,
                color: colorController.text,
                note: noteController.text,
              );
              if (isNew) {
                vehicleBox.add(newVehicle);
              } else {
                vehicle!
                  ..name = newVehicle.name
                  ..vin = newVehicle.vin
                  ..motor = newVehicle.motor
                  ..kw = newVehicle.kw
                  ..fuel = newVehicle.fuel
                  ..drive = newVehicle.drive
                  ..color = newVehicle.color
                  ..note = newVehicle.note
                  ..save();
              }
              Navigator.pop(context);
            },
            child: Text('Uložit'),
          ),
        ],
      ),
    );
    setState(() {});
  }

  void _deleteVehicle(int index) {
    vehicleBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = vehicleBox.values.toList();
    return Scaffold(
      appBar: AppBar(title: Text('Moje Garáž')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditVehicle(),
        child: Icon(Icons.add),
      ),
      body: vehicles.isEmpty
          ? Center(child: Text('Zatím žádná vozidla'))
          : ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (_, index) {
                final v = vehicles[index];
                return Card(
                  child: ListTile(
                    title: Text(v.name),
                    subtitle: Text('${v.motor} | ${v.kw} kW | ${v.fuel}'),
                    onTap: () => _addOrEditVehicle(vehicle: v),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteVehicle(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
