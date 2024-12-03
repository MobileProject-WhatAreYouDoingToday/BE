import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'auth.dart';
import 'store.dart';
import 'MainWidget.dart'; // MainWidget을 정의한 파일 import
import 'list.dart'; // TodoListPage를 정의한 파일 import
import 'achieve.dart'; // AchievePage를 정의한 파일 import

class Calendar extends StatelessWidget {
  final Auth auth;
  const Calendar({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarPage(auth: auth),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final Auth auth;
  const CalendarPage({super.key, required this.auth});

  @override
  State<CalendarPage> createState() => _CalendarPageState(auth: auth);
}

class _CalendarPageState extends State<CalendarPage> {
  final Auth auth;
  _CalendarPageState({required this.auth});
  late final ValueNotifier<List<Event>> _selectedEvents;
  late Map<DateTime, List<Event>> _events;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  String email = ""; // 사용자 이메일
  List<Todo> todoList = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;

    _events = {}; // 이벤트 초기화
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeEmailAndFetchTodos();
    });
  }

  Future<void> initializeEmailAndFetchTodos() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email != null) {
      email = currentUser.email!;
      await getTodoList();
    } else {
      print("현재 로그인된 사용자가 없습니다.");
    }
  }

  Future<void> getTodoList() async {
    todoList = await Store().getTodoList(email) ?? [];

    setState(() {
      _events = {};
      for (var todo in todoList) {
        if (todo.is_completed) {
          final todoDate = todo.date.toDate();
          final eventDate = DateTime(todoDate.year, todoDate.month, todoDate.day);

          Color eventColor;
          switch (todo.categori) {
            case "독서":
              eventColor = const Color(0xFFFF9692);
              break;
            case "취미":
              eventColor = const Color(0xFFDBBEFC);
              break;
            case "운동":
              eventColor = const Color(0xFFFFD465);
              break;
            case "공부":
              eventColor = const Color(0xFF61E4C5);
              break;
            default:
              eventColor = Colors.grey;
          }

          final event = Event(todo.categori, eventColor);
          if (_events[eventDate] == null) {
            _events[eventDate] = [event];
          } else {
            _events[eventDate]!.add(event);
          }
        }
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375,
      height: 812,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(125.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 40.0),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainWidget(auth: auth,)),
                  );
                },
                child: Image.asset("assets/images/chart.png"),
              ),
              title: const Text(
                '캘린더',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TodoListPage()),
                      );
                    },
                    child: Image.asset("assets/images/todobutton.png"),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime(2020, 1, 1),
                    lastDay: DateTime(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedEvents.value = _getEventsForDay(selectedDay);
                      });
                    },
                    eventLoader: _getEventsForDay,
                    calendarStyle: const CalendarStyle(),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextFormatter: (date, locale) =>
                          DateFormat.MMMM(locale).format(date),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, events, _) {
                      return Column(
                        children: events
                            .map((event) => ListTile(
                          title: Text(event.title),
                        ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width / 2 - 327 / 2,
              child: SizedBox(
                width: 327,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AchievePage(userEmail: email,)),
                    );
                  },
                  child: const Text(
                    '이번 달 달성률 분석 >',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final Color color;
  Event(this.title, this.color);
}

