import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart';

class CalendarPage extends StatefulWidget {
  final String userEmail;

  const CalendarPage({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final Store _store = Store(); // Use the existing Store instance

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _loadEventsForDay(_selectedDay);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    try {
      final todos = await _store.getTodoList(widget.userEmail);

      if (todos != null) {
        // Filter todos for the selected date and check completion status
        final completedTodos = todos
            .where((todo) =>
        todo.date.toDate().year == day.year &&
            todo.date.toDate().month == day.month &&
            todo.date.toDate().day == day.day &&
            todo.is_completed)
            .map((todo) => Event(todo.categori, Colors.green)) // Convert to Event
            .toList();

        _selectedEvents.value = completedTodos;
      } else {
        _selectedEvents.value = [];
      }
    } catch (e) {
      print('Error loading events for day: $e');
      _selectedEvents.value = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('캘린더'),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
              });
              _loadEventsForDay(selectedDay);
            },
            eventLoader: (day) => _selectedEvents.value,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              return Expanded(
                child: ListView(
                  children: events
                      .map((event) => ListTile(
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final Color color;

  Event(this.title, this.color);
}





