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

    // 초기화 시 타입 명시
    _events = <DateTime, List<Event>>{};
    _selectedEvents = ValueNotifier(_events[_selectedDay] ?? []);
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM').format(_focusedDay), // 현재 월 이름만 표시
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
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
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  // 명시적으로 타입 변환
                  final firstEvent = events.first as Event;
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Text(
                      firstEvent.title, // title 접근 가능
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    event.title, // Event 타입으로 간주
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
                    .toList(),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_events[_selectedDay] == null) {
                  _events[_selectedDay] = [];
                }
                _events[_selectedDay]?.add(Event('독서'));
                _selectedEvents.value = _getEventsForDay(_selectedDay);
              });
            },
            child: const Text('Add Event'),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: TextButton(
          onPressed: () {
            // 버튼 클릭 시 동작 정의
          },
          child: const Text(
            '이번달 달성률 보러가기',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class Event {
  final String title; // Non-nullable로 변경
  Event(this.title);
}