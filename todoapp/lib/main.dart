import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final collectionPath = 'item';
  final doCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do List App'),
        actions: [
          IconButton(
            onPressed: addToDoDialog, 
            icon: Icon(Icons.add),),
        ],
      ),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(future: FirebaseFirestore.instance.collection(collectionPath).get(), builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          var document = snapshot.data?.docs;
          return ListView.builder(itemCount: snapshot.data?.size,itemBuilder: (context, index) {
            var item = document![index];
            return Dismissible(
              key: UniqueKey(),
              onDismissed: (direction)async {
                await FirebaseFirestore.instance.collection(collectionPath).doc(item.id).delete();
                setState(() {
                  
                });
              },
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}'),),
                  title: Text('${item['item']}'),
                ),
              ),
            );
          },);
        },),
      )
    );
  }



  //show add dialog
    void addToDoDialog(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('Add To Do'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                label: Text('I want to do...'),
                border: OutlineInputBorder(
                ),
              ),
              controller: doCtrl,
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: doAdd, child: Text('Add'),),
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text('Cancel'),),
        ],
      );
    });
  }

  void doAdd() async {
    await FirebaseFirestore.instance.collection(collectionPath).add({
      'item': doCtrl.text
    });
    Navigator.of(context).pop();
    setState(() {
      doCtrl.clear();
    });
  }
}