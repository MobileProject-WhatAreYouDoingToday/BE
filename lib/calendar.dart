import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth를 사용
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:whatareyoudoingtoday/auth.dart';
import 'package:whatareyoudoingtoday/store.dart';

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

    // 데이터를 가져오는 비동기 작업 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeEmailAndFetchTodos();
    });
  }

  /// FirebaseAuth를 사용하여 현재 사용자의 이메일 설정
  Future<void> initializeEmailAndFetchTodos() async {
    final currentUser = FirebaseAuth.instance.currentUser; // 현재 사용자 가져오기
    if (currentUser != null && currentUser.email != null) {
      email = currentUser.email!;
      await getTodoList(); // Todo 리스트 가져오기
    } else {
      print("현재 로그인된 사용자가 없습니다.");
    }
  }

  /// Store에서 Todo 데이터를 가져와 이벤트로 변환
  Future<void> getTodoList() async {
    todoList = await Store().getTodoList(email) ?? []; // null 방지

    setState(() {
      _events = {}; // 초기화
      for (var todo in todoList) {
        if (todo.is_completed) { // 완료된 Todo만 처리
          final todoDate = todo.date.toDate(); // Timestamp를 DateTime으로 변환
          final eventDate = DateTime(todoDate.year, todoDate.month, todoDate.day);

          // 카테고리에 따른 색상 매핑
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
              eventColor = Colors.grey; // 기본 색상
          }

          final event = Event(todo.categori, eventColor);
          if (_events[eventDate] == null) {
            _events[eventDate] = [event];
          } else {
            _events[eventDate]!.add(event);
          }
        }
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay); // 현재 선택된 날짜 업데이트
    });
  }

  /// 특정 날짜의 이벤트를 가져오는 함수
  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375, // 고정된 너비
      height: 812, // 고정된 높이
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
                    MaterialPageRoute(builder: (context) => LoginWidget()),
                  );
                },
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  child: Image.asset("assets/images/chart.png"),
                ),
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
                        MaterialPageRoute(builder: (context) => CalendarPage(auth: auth)),
                      );
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      child: Image.asset("assets/images/todobutton.png"),
                    ),
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
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(),
                      selectedDecoration: BoxDecoration(),
                      todayTextStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      selectedTextStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      defaultTextStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      weekendTextStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      disabledTextStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      cellMargin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextFormatter: (date, locale) =>
                          DateFormat.MMMM(locale).format(date),
                    ),
                    daysOfWeekHeight: 55,
                    rowHeight: 80,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          final eventList = events.cast<Event>();
                          return Column(
                            children: eventList.map((event) {
                              return Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: event.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, events, _) {
                      return Column(
                        children: events
                            .map((event) => ListTile(
                          title: Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                    // 버튼 클릭 시 동작 정의
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
