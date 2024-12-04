import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String name;
  final String uid;
  final String pw;

  UserData({
    required this.name,
    required this.uid,
    required this.pw,
  });

  factory UserData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return UserData(
      name: data?['name'],
      uid: data?['uid'],
      pw: data?['pw'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'uid': uid,
      'pw': pw,
    };
  }
}

class Todo {
  String? id; // Firestore 문서 ID (nullable, 나중에 설정 가능)
  String name;
  String category;
  String description;
  Timestamp date;
  bool isNotification;
  int priority;
  bool isCompleted;

  Todo({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.date,
    required this.isNotification,
    required this.priority,
    required this.isCompleted,
  });

  factory Todo.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Todo(
      id: snapshot.id,
      name: data?['name'],
      category: data?['category'] ?? "null",
      description: data?['description'],
      date: data?['date'],
      isNotification: data?['isNotification'],
      priority: data?['priority'],
      isCompleted: data?['isCompleted'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'date': date,
      'isNotification': isNotification,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }
}

class Store {
  final FirebaseFirestore store = FirebaseFirestore.instance;

  // 유저 데이터 가져오기
  Future<UserData?> getUser(String email) async {
    final ref = store.collection("users").doc(email).withConverter(
      fromFirestore: UserData.fromFirestore,
      toFirestore: (user, _) => user.toFirestore(),
    );

    final docSnap = await ref.get();
    return docSnap.data();
  }

  // 유저 데이터 저장
  Future<void> setUser(String email, String uid, String name, String pw) async {
    final ref = store.collection("users").doc(email).withConverter(
      fromFirestore: UserData.fromFirestore,
      toFirestore: (user, _) => user.toFirestore(),
    );

    final userData = UserData(name: name, uid: uid, pw: pw);
    await ref.set(userData);
  }

  // Todo 저장
  Future<void> setTodo(String email, Todo todo) async {
    final ref = store
        .collection("users")
        .doc(email)
        .collection("todo")
        .withConverter<Todo>(
      fromFirestore: Todo.fromFirestore,
      toFirestore: (todo, _) => todo.toFirestore(),
    );

    if (todo.id != null) {
      // ID가 존재하면 업데이트
      await ref.doc(todo.id).set(todo);
    } else {
      // ID가 없으면 새로 추가
      final newDoc = await ref.add(todo);
      todo.id = newDoc.id; // 새로 생성된 문서 ID 저장
    }
  }

  // 전체 Todo 가져오기
  Future<List<Todo>> getTodoList(String email) async {
    final ref = store.collection("users").doc(email).collection("todo").
        orderBy('priority', descending: false).
        withConverter(
          fromFirestore: Todo.fromFirestore,
          toFirestore: (todo, _) => todo.toFirestore(),
        );

    final querySnapshot = await ref.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // 특정 날짜의 Todo 가져오기
  Future<List<Todo>> getSelectedDateTodoList(String email, Timestamp selectedDate) async {
    final todoList = await getTodoList(email);
    final selectedDateTime = selectedDate.toDate();

    return todoList.where((todo) {
      final todoDate = todo.date.toDate();
      return todoDate.year == selectedDateTime.year &&
          todoDate.month == selectedDateTime.month &&
          todoDate.day == selectedDateTime.day;
    }).toList();
  }

  // Todo 삭제
  Future<void> removeTodo(String email, Todo todo) async {
    if (todo.id == null) return;

    final ref = store.collection("users").doc(email).collection("todo").doc(todo.id);
    await ref.delete();
  }
}
