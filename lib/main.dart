import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/dog.dart';

late final Future<Database> database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(
    join(await getDatabasesPath(), 'doggie_database.db'), // path
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },
    version: 1,
  );
  runApp(const LearnSqfLite());
}

class LearnSqfLite extends StatelessWidget {
  const LearnSqfLite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int count = 0;

  void addTableDog() async {
    var fido = Dog(
      id: count++,
      name: 'Fido',
      age: 35,
    );

    await insertDog(fido);
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> dogs() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  void readDogTable() async {
    List<Dog> list = await dogs();
    print(list);
  }

  Future<void> updateDog(Dog dog) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'dogs',
      dog.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [dog.id],
    );
  }

  void updateDatabase() async{
    var fido = const Dog(
      id: 0,
      name: 'Fido',
      age: 42,
    );

    await updateDog(fido);

// Print the updated results.
    print(await dogs()); // Prints Fido with age 42.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: addTableDog,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text("Add a dog"),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: readDogTable,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text("read all dogs"),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: updateDatabase,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text("update the dog"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> insertDog(Dog dog) async {
  final db = await database;

  await db.insert(
    'dogs',
    dog.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}