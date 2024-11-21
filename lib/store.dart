import 'package:cloud_firestore/cloud_firestore.dart';

/*
* users라는 컬렉션에 각 user의 문서를 배치함 이 때, uid보다 email로 접근하는 것이 더 나을 것 같음. 추후에 이메일로 비밀번호를 바꾸는 기능을 추가하기 위함.
* 그리고 각 user 문서 안에는 todolist라는 컬렉션을 배치해서 todo 들을 불러올 수 있게 할거임.
* 근데 문제는 특정 todo를 어케 불러오냐라는 거임
* 그래서 날짜 및 순서를 동일한 양식으로 만들어서 문서 id로 하는 것이 어떤지를 생각을 해봄
* 근데 그거는 만약에 순서를 바꾸거나 할 경웅 모든 문서들을 삭제하고 다시 만들어야 하기 때문에 기각
* 그러면 순서라는 필드를 문서에 넣고 그 모든 문서들을 다 찾아야 함 굉장히 비효율적이긴 하지만 문서를 지웠다가 만드는 것보다는 좋아보임
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
    };
  }
}

class Todo {
  final String name; // todo 제목
  final String categori; // 카테고리
  final String description; // todo 메모
  final Timestamp date; //  todo 생성날짜
  final bool isNotification; // todo 알림여부
  final int priority; // todo 우선순위, 오늘의 달성률에서 맨위에 있는거 보이게 하는용도
  final bool is_completed; //todo 완료여부

  Todo({
    required this.name,
    required this.categori,
    required this.date,
    required this.isNotification,
    required this.priority,
    required this.is_completed,
    required this.description
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
      description: data?['description']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (categori != null) 'categori': categori,
      if (date != null) 'date': date,
      if (isNotification != null) 'isNotification': isNotification,
      if (priority != null) 'priority': priority
    };
  }
}


class Store {
  final FirebaseFirestore store = FirebaseFirestore.instance;

  Future<UserData?> getUser(String email) async { // 유저 데이터 불러오기
    final ref = store.collection("users").doc(email).withConverter( // UserData 클래스로 변환
      fromFirestore: UserData.fromFirestore,
      toFirestore: (UserData user, _) => user.toFirestore(),
    );

    final docSnap = await ref.get();
    final user = docSnap.data();
    if (user != null) {
      print('유저 데이터 불러오기 성공'); // await 문이므로 확인용으로 print
      return user;
    } else {
      print('유저 정보가 없음'); // await 문이므로 확인용으로 print
      return null;
    }
  }

  Future<void> setUser(String email,String uid, String name, String pw) async { // 유저 데이터 설정 및 추가하기
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
      await todoListRef.doc("placeholder").set({'placeholder': true});
      print('유저 데이터 저장 성공'); // await 문이므로 확인용으로 print
    }


  }

  Future<List<Todo>?> getTodoList(String email) async { // todolist 불러오기
    final ref = store.collection("users").doc(email).collection("todo").
    orderBy("date", descending: false).orderBy("priority", descending: false).withConverter( // 날짜 및 우선 순위 정렬 순으로 Todo 클래스로 변환
      fromFirestore: Todo.fromFirestore,
      toFirestore: (Todo todo, _) => todo.toFirestore(),
    );

    final querySnapshot = await ref.get();
    final todoList = querySnapshot.docs.map((doc) => doc.data()!).toList();
    if(todoList != null){
      print('todolist 불러오기 성공'); // await 문이므로 확인용으로 print
      return todoList;
    } else {
      print('todolist 없음'); // await 문이므로 확인용으로 print
      return null;
    }
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
      if(ref.doc("placeholder") != null){
        ref.doc("placeholder").delete();
      }
      await ref.add(todo);
      print('Todo 추가 성공');
    } catch (e) {
      print('Todo 추가 실패: $e');
    }
  }


  Future<Todo?> getTodo(String email, Timestamp date, String category,int priority) async { // 특정 todo 불러오기
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
}
