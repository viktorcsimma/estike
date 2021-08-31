import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'product.dart';

class User {
  static List<User> allUsers = [];
  String name;
  int id;
  int balance;
  late DateTime createdAt;
  late DateTime updatedAt;
  Map<int, int> productsBought = {}; // productId, timesBought

  User(this.id, this.name, this.balance,
      {DateTime? createdAt, DateTime? updatedAt}) {
    if (createdAt == null) {
      this.createdAt = DateTime.now();
    } else {
      this.createdAt = createdAt;
    }
    if (updatedAt == null) {
      this.updatedAt = DateTime.now();
    } else {
      this.updatedAt = updatedAt;
    }
  }
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['id'],
      map['name'],
      map['balance'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  String toString() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'created_at': DateFormat('MM-dd - kk:mm').format(createdAt),
      'updated_at': DateFormat('MM-dd - kk:mm').format(updatedAt),
    }.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Future<bool> insert() async {
    // Get a reference to the database.
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'users',
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  Future<bool> update() async {
    try {
      Database db = await DatabaseHelper.instance.database;
      await db
          .update('users', this.toMap(), where: 'id = ?', whereArgs: [this.id]);
      return true;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> delete() async {
    Database db = await DatabaseHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [this.id]);
    return true;
  }

  void addBoughProduct(Product product, {int number = 1}) {
    if (productsBought.containsKey(product.id)) {
      productsBought[product.id] = productsBought[product.id]! + number;
    } else {
      productsBought[product.id] = number;
    }
  }
}

Future<void> initUsers() async {
  User.allUsers = await queryUsers();
}

Future<List<User>> queryUsers() async {
  Database db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> users = await db.query('users');
  return users.map((e) => User.fromMap(e)).toList();
}

Future<bool> addUser(String name, int id, {int balance = 0}) async {
  User user = User(id, name, balance);
  await user.insert();
  User.allUsers.add(user);
  return true;
}
