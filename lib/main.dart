import 'package:flutter/material.dart';
import 'package:learn_sqflite/service/database.dart';
import 'package:sqflite/sqflite.dart';

import 'models/dog.dart';

late final Future<Database> database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqlDatabase.init();
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
  List<Dog> items = [];

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  void getAllData() async {
    items = await SqlDatabase.readAll();
    setState(() {});
  }

  void deleteData(int id) async {
    SqlDatabase.delete(id).then((_) => getAllData());
  }

  void goDetail({Dog? dog}) async {
    final data = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(dog: dog)));
    if(data != null) getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dogs")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final dog = items[index];
          return Card(
            child: ListTile(
              title: Text(dog.name),
              subtitle: Text(dog.age.toString()),
              style: Theme.of(context).listTileTheme.style,
              leading: CircleAvatar(backgroundColor: Colors.primaries[index % Colors.primaries.length],child: Text(dog.id.toString(),),),
              trailing: IconButton(onPressed: () => deleteData(dog.id), icon: const Icon(Icons.delete)),
              onLongPress: () => goDetail(dog: dog),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => goDetail(),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final Dog? dog;
  const DetailPage({Key? key, this.dog}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}


class _DetailPageState extends State<DetailPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  int count = 0;

  @override
  void initState() {
    super.initState();
    getOldDog();
  }

  void getOldDog() async {
    if(widget.dog != null) {
      nameController.text = widget.dog!.name;
      ageController.text = widget.dog!.age.toString();
    }
    final db = await SqlDatabase.database;
    count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM dogs')) ?? 0;
    setState(() {});
  }

  void pressSave() async {
    int id = (widget.dog != null) ? widget.dog!.id : count++;
    SqlDatabase.insert(Dog(id: id, name: nameController.text, age: int.tryParse(ageController.text) ?? 0)).then((_) {
      Navigator.pop(context, "Done");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Page"),),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Dog name"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(hintText: "Dog age"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pressSave,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
