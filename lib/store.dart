import 'package:cloud_firestore/cloud_firestore.dart';

/*
* users라는 컬렉션에 각 user의 문서를 배치함 이 때, uid보다 email로 접근하는 것이 더 나을 것 같음. 추후에 이메일로 비밀번호를 바꾸는 기능을 추가하기 위함.
* 그리고 각 user 문서 안에는 todolist라는 컬렉션을 배치해서 todo 들을 불러올 수 있게 할거임.
* 근데 문제는 특정 todo를 어케 불러오냐라는 거임
* 그래서 날짜 및 순서를 동일한 양식으로 만들어서 문서 id로 하는 것이 어떤지를 생각을 해봄
* 근데 그거는 만약에 순서를 바꾸거나 할 경웅 모든 문서들을 삭제하고 다시 만들어야 하기 때문에 기각
* 그러면 순서라는 필드를 문서에 넣고 그 모든 문서들을 다 찾아야 함 굉장히 비효율적이긴 하지만 문서를 지웠다가 만드는 것보다는 좋아보임
* */

/*
* 달성률은
*
* 카테고리
*
*
* */

class UserData {
  final String name;
  final String uid;
  final String pw;

  UserData({
    required this.name,
    required this.uid,
    required this.pw
  });

  factory UserData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return UserData(
        name: data?['name'],
        uid: data?['uid'],
        pw: data?['pw']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (uid != null) 'uid': uid,
      if (pw != null) 'pw' : pw
    };
  }
}

class Todo {
  final String name; // todo 제목
  final String categori; // 카테고리
  final String description; // todo 메모
  final Timestamp date; //  todo 생성날짜
  final bool isNotification; // todo 알림여부
  late int priority; // todo 우선순위, 오늘의 달성률에서 맨위에 있는거 보이게 하는용도
  late bool is_completed; //todo 완료여부

  Todo({
    required this.name,
    required this.categori,
    required this.date,
    required this.isNotification,
    required this.priority,
    required this.is_completed,
    required this.description,
  });

  factory Todo.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Todo(
      name: data?['name'],
      categori: data?['categori'],
      date: data?['date'],
      isNotification: data?['isNotification'],
      priority: data?['priority'],
      is_completed : data?['is_completed'],
      description: data?['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (categori != null) 'categori': categori,
      if (date != null) 'date': date,
      if (isNotification != null) 'isNotification': isNotification,
      if (priority != null) 'priority': priority,
      if (is_completed != null) 'is_completed': is_completed,
      if (description != null) 'description': description,
    };
  }
}

class Store {
  final FirebaseFirestore store = FirebaseFirestore.instance;

  Future<UserData?> getUser(String email) async { // 유저 데이터 불러오기
    final ref = store.collection("users").doc(email).withConverter( // UserData 클래스로 변환
      fromFirestore: (snapshot, options) => UserData.fromFirestore(snapshot, options),
      toFirestore: (user, options) => user.toFirestore(),
    );

    final docSnap = await ref.get();
    final user = docSnap.data();
    if (user != null) {

      return user;
    } else {
      print('유저 정보가 없음'); // await 문이므로 확인용으로 print
      return null;
    }
  }

  Future<void> setUser(String? email,String uid, String name, String pw) async { // 유저 데이터 설정 및 추가하기
    final ref = store.collection("users").doc(email).withConverter( // UserData 클래스로 변환
      fromFirestore: UserData.fromFirestore,
      toFirestore: (UserData user, _) => user.toFirestore(),
    );
    final docSnap = await ref.get();
    final user = docSnap.data();

    if(user == null) {
      final userData = UserData(name: name, uid: uid, pw: pw);
      await ref.set(userData);
      final todoListRef = store.collection("users").doc(email).collection("todo");
      await todoListRef.doc("placeholder").set({'placeholder': true, 'priority': null});
      print('유저 데이터 생성 성공'); // await 문이므로 확인용으로 print
    } else {
      final userData = UserData(name: name, uid: uid, pw: pw);
      await ref.set(userData);
      print('유저 데이터 변경 성공'); // await 문이므로 확인용으로 print
    }
  }

  Future<List<Todo>?> getTodoList(String email) async {
    final ref = store.collection("users").doc(email).collection("todo")
        .where("priority", isNotEqualTo: null)
        .orderBy("priority", descending: false)
        .withConverter(
      fromFirestore: (snapshot, options) => Todo.fromFirestore(snapshot, options),
      toFirestore: (todo, options) => todo.toFirestore(),
    );

    final querySnapshot = await ref.get();
    final todoList = querySnapshot.docs.map((doc) => doc.data()).toList();

    if (todoList.isNotEmpty) {
      // 쿼리 결과 출력
      print('전체 todolist 불러오기 성공');
      return todoList;
    } else {
      print('todolist 없음');
      return todoList;
    }
  }

  Future<List<Todo>?> getSelectedDateTodoList(String email, Timestamp select) async {
    List<Todo>? todoList = await getTodoList(email);
    List<Todo> tasks = [];

    DateTime selectedDate = select.toDate();
    for(int i =0;i<todoList!.length;i++){
      DateTime ListDate = todoList[i].date.toDate();
      if(ListDate.year == selectedDate.year && ListDate.month == selectedDate.month && ListDate.day == selectedDate.day){
        tasks.add(todoList[i]);
      }
    }

    return tasks;
  }


  Future<void> setTodoPriority(String email, Todo updatedTodo, int willchangep) async {
    final ref = FirebaseFirestore.instance.collection("users").doc(email).collection("todo");

    List<Todo>? todoList = await getTodoList(email);
    int currentIndex = todoList!.indexWhere((todo) => todo.priority == updatedTodo.priority);
    print("완료됨 ${todoList[currentIndex].is_completed}");

    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 우선순위 갱신
    for (int i = 0; i < todoList.length; i++) {
      if (willchangep > currentIndex && willchangep != -1) {
        if (todoList[i].priority > todoList[currentIndex].priority) {
          todoList[i].priority--;
          QuerySnapshot snapshot = await ref.where('priority', isEqualTo: todoList[i].priority + 1).get();
          if (snapshot.docs.isNotEmpty) {
            DocumentReference todoRef = snapshot.docs.first.reference;
            batch.update(todoRef, {'priority': todoList[i].priority});
          }
        }
      } else if (willchangep < currentIndex && willchangep != -1) {
        if (todoList[i].priority < todoList[currentIndex].priority) {
          todoList[i].priority++;
          QuerySnapshot snapshot = await ref.where('priority', isEqualTo: todoList[i].priority - 1).get();
          if (snapshot.docs.isNotEmpty) {
            DocumentReference todoRef = snapshot.docs.first.reference;
            batch.update(todoRef, {'priority': todoList[i].priority});
          }
        }
      } else if (willchangep == -1) {
        if (todoList[i].priority > todoList[currentIndex].priority) {
          todoList[i].priority--;
          QuerySnapshot snapshot = await ref.where('priority', isEqualTo: todoList[i].priority + 1).get();
          if (snapshot.docs.isNotEmpty) {
            DocumentReference todoRef = snapshot.docs.first.reference;
            batch.update(todoRef, {'priority': todoList[i].priority});
          }
        }
      }
    }

    todoList[currentIndex].priority = willchangep;
    QuerySnapshot snapshot = await ref.where('priority', isEqualTo: updatedTodo.priority).get();
    if (snapshot.docs.isNotEmpty) {
      DocumentReference updatedTodoRef = snapshot.docs.first.reference;
      batch.update(updatedTodoRef, {'priority': willchangep});
    }

    // 모든 작업을 한 번에 커밋
    await batch.commit();
    print('모든 배치 작업 커밋 성공');
  }



  Future<void> setTodo(String email, Todo todo) async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("todo")
        .withConverter<Todo>(
      fromFirestore: (snapshot, options) => Todo.fromFirestore(snapshot, options),
      toFirestore: (todo, options) => todo.toFirestore(),
    );

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 기존 항목 검색
      final querySnapshot = await ref
          .where('name', isEqualTo: todo.name)
          .where('date', isEqualTo: todo.date)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 기존 항목이 있으면 업데이트
        final docRef = querySnapshot.docs.first.reference;
        batch.update(docRef, todo.toFirestore());
        print('Todo 업데이트 배치 추가됨');
      } else {
        // 기존 항목이 없으면 새 항목 추가
        await ref.add(todo);
        print('Todo 추가 작업 추가됨');
      }

      // 배치 작업 커밋
      await batch.commit();
      print('모든 배치 작업 커밋 성공');
    } catch (e) {
      print('Todo 처리 실패: $e');
    }
  }




  Future<Todo?> getTodo(String email, Timestamp date, String category, int priority) async { // 특정 todo 불러오기
    final ref = store.collection("users").doc(email).collection("todolist")
        .where("date", isEqualTo: date)
        .where("priority", isEqualTo: priority)
        .where("category", isEqualTo: category)
        .withConverter(
      fromFirestore: Todo.fromFirestore,
      toFirestore: (Todo todo, _) => todo.toFirestore(),
    );

    final querySnapshot = await ref.get();
    final Todo todo = querySnapshot.docs.map((doc) => doc.data()).toList().first;
    if(todo != null){
      print('todo 불러오기 성공'); // await 문이므로 확인용으로 print
      return todo;
    } else {
      print('todo 없음'); // await 문이므로 확인용으로 print
      return null;
    }
  }

  Future<void> removeTodo(String email, Todo todo) async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("todo")
        .withConverter<Todo>(
      fromFirestore: (snapshot, options) => Todo.fromFirestore(snapshot, options),
      toFirestore: (todo, options) => todo.toFirestore(),
    );

    try {
      // 기존 항목 검색
      final querySnapshot = await ref.where('name', isEqualTo: todo.name).get();

      if (querySnapshot.docs.isNotEmpty) {
        // 기존 항목이 있으면 삭제
        final docRef = querySnapshot.docs.first.reference;
        await docRef.delete();
        print('Todo 삭제 성공');
      } else {
        print('삭제할 Todo 항목을 찾지 못했습니다.');
      }
    } catch (e) {
      print('Todo 삭제 실패: $e');
    }
  }

}