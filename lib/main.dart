import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todoapphive/todo_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

const String todoBoxName = "todo";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final Document = await getApplicationDocumentsDirectory();
  Hive.init(Document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Box<TodoModel>todoBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
            showDialog(
              context: context,
              child: Dialog(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Title",
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: detailController,
                        decoration: InputDecoration(
                          hintText: "Details",
                        ),
                      ),
                      SizedBox(height: 10.0),
                      FlatButton(
                          onPressed: (){
                            final String title = titleController.text;
                            final String detail = detailController.text;

                            TodoModel todo = TodoModel(title: title,detail: detail,isCompleted: false);
                            todoBox.add(todo);

                            titleController.clear();
                            detailController.clear();
                            Navigator.pop(context);
                          },
                          child: Text("ADD TASK"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        
      ),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context,Box<TodoModel>todos,_){

          List<int> keys = todos.keys.cast<int>().toList();
          return ListView.separated(
              itemBuilder: (_,index){
                final int key = keys[index];
                final TodoModel todo  = todos.get(key);
                return ListTile(

                  title: Text(todo.title),
                  subtitle: Text(todo.detail),
                  leading: Text("$key"),
                  trailing: Icon(Icons.check,color: todo.isCompleted? Colors.green:Colors.red,size: 18.0,),
                  onLongPress: (){
                    showDialog(
                      context: context,
                      child: Dialog(
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FlatButton(
                                  onPressed: (){
                                    TodoModel mtodo = TodoModel(title: todo.title,detail: todo.detail,isCompleted: true);
                                    todoBox.put(key, mtodo);
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                      msg: "You Have Completed A Task",
                                      toastLength: Toast.LENGTH_SHORT,
                                      textColor: Colors.white,
                                    );
                                  },
                                  child: Text("Mark As Complete"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_,index)=>Divider(),
              itemCount: keys.length,
            shrinkWrap: true,
          );
        },
      ),
    );
  }
}

