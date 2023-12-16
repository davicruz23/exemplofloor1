import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:flutter/material.dart';

part 'main.g.dart';

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String description;

  Task(this.id, this.name, this.description);
}

@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  TaskDao get taskDao;
}

@dao
abstract class TaskDao {
  @Query('SELECT * FROM Task')
  Future<List<Task>> findAllTasks();

  @Query('SELECT * FROM Task WHERE id = :id')
  Future<Task?> findTaskById(int id);

  @insert
  Future<void> insertTask(Task task);

  @update
  Future<void> updateTask(Task task);

  @delete
  Future<void> deleteTask(Task task);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Certifique-se de inicializar os widgets

  // Construa o banco de dados antes de passá-lo para o aplicativo
  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .build();

  runApp(MyApp(database: database));
}



class MyApp extends StatelessWidget {
  final AppDatabase database;

  MyApp({required this.database}); // Adicione o construtor que aceita 'database'

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor CRUD Example',
      home: MyHomePage(database),
    );
  }
}


class MyHomePage extends StatefulWidget {
  final AppDatabase database;

  MyHomePage(this.database);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floor CRUD Example'),
      ),
      body: FutureBuilder<List<Task>>(
        future: widget.database.taskDao.findAllTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No tasks found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];
              return ListTile(
                title: Text(task.name),
                subtitle: Text(task.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    widget.database.taskDao.deleteTask(task);
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Task Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newTask = Task(null, nameController.text, descriptionController.text);
                await widget.database.taskDao.insertTask(newTask);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
