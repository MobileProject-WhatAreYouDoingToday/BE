import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:whatareyoudoingtoday/auth.dart';
import 'package:whatareyoudoingtoday/store.dart';
import 'list.dart';

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
      home: CalendarPage(auth: auth,),
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
  late final Map<DateTime, List<Event>> _events;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  String email = "";
  List<Todo> todoList = [];

  @override
  Future<void> initState() async {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    todoList = (await Store().getTodoList(email))!;


    // 샘플 데이터로 이벤트 초기화
    _events = <DateTime, List<Event>>{
      DateTime(2024, 10, 1): [
        Event("독서", const Color(0xFFFF9692)),
        Event("공부", const Color(0xFF61E4C5))
      ],
      DateTime(2024, 10, 2): [
        Event("취미", const Color(0xFFDBBEFC)),
        Event("운동", const Color(0xFFFFD465))
      ],
      DateTime(2024, 10, 3): [
        Event("독서", const Color(0xFFFF9692)),
      ],
    };

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375, // 고정된 너비
      height: 812, // 고정된 높이
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(125.0),
          child: Padding(
            padding: EdgeInsets.only(left: 25.0, top: 40.0),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => /*TodoListPage*/LoginWidget()),
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
              centerTitle: true, // 제목을 중앙으로 설정
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalendarPage(auth: authe,)),
                      );
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      child: Image.asset("assets/images/calender.png"),
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