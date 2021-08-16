import 'dart:async';

import 'package:bookapp_flutter/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'books_database.db'),


    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, description TEXT)',
      );
    },

    version: 1,
  );

  Future<void> insertBook(Book book) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  var fido = Book(
    id: 0,
    title: 'Metamorphosis',
    author: 'Franz Kafka',
    description: 'Existential crisis and depressed category',
  );

  await insertBook(fido);

  Future<List<Book>> books() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('books');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'],
        title: maps[i]['title'],
        author: maps[i]['author'],
        description: maps[i]['description'],
      );
    });
  }

  print(await books());

  Future<void> updateBook(Book book) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'books',
      book.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [book.id],
    );
  }

  var fido2 = Book(
    id: 0,
    title: 'Metamorphosis',
    author: 'Franz Kafka',
    description: 'Existential crisis and depressed category'+"really crazy",
  );

  await updateBook(fido2);

  print (await books());

  Future<void> deleteBook(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'books',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}