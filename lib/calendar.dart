import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final Map<DateTime, List<Event>> _events;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;

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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 정렬
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/MainWidget'); // MainWidget.dart로 이동
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 30), // 좌측에서 30만큼 떨어짐
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    child: Image.asset("assets/images/chart.png"),
                  ),
                ),
              ),
              const Text(
                '캘린더',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/list'); // list.dart로 이동
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 30), // 우측에서 30만큼 떨어짐
                  child: Image.asset(
                    'assets/images/todobutton.png',
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
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
                      todayDecoration: BoxDecoration(), // 오늘의 데코레이션 제거 (숫자는 유지)
                      selectedDecoration: BoxDecoration(), // 선택된 날짜 데코레이션 제거
                      markerDecoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      cellMargin: EdgeInsets.symmetric(vertical: 8), // 날짜 간 간격 설정
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextFormatter: (date, locale) =>
                          DateFormat.MMMM(locale).format(date), // 년도 제거
                    ),
                    daysOfWeekHeight: 55, // 요일과 날짜 사이 간격
                    rowHeight: 80, // 각 날짜 간의 간격 설정
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          final eventList = events.cast<Event>(); // events를 Event 타입으로 캐스팅
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
              bottom: 40, // 하단에서 40 떨어짐
              left: MediaQuery.of(context).size.width / 2 - 327 / 2, // 중앙 정렬
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
