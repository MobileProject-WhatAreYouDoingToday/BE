import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart';

class Task {
  String name; // todo 제목
  String? description; // 메모는 선택적
  String category; // 카테고리
  Timestamp date; // 날짜
  bool isNotification; // todo 알림 여부
  int priority; // todo 우선순위
  bool is_completed; // todo 완료 여부
  bool isShowingDescription; // 메모 표시 여부

  Task({
    required this.name,
    required this.category,
    this.description, // 선택적이므로 required에서 제외
    required this.date,
    this.isNotification = false, // 기본값으로 false 설정
    this.priority = 1, // 기본값으로 1 설정
    this.is_completed = false, // 기본값으로 false 설정
    this.isShowingDescription = false, // 기본값으로 메모 표시 안 함
  });

  // copyWith 메서드 추가
  Task copyWith({
    String? name,
    String? description,
    String? category,
    Timestamp? date,
    bool? isNotification,
    int? priority,
    bool? is_completed,
    bool? isShowingDescription,
  }) {
    return Task(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      isNotification: isNotification ?? this.isNotification,
      priority: priority ?? this.priority,
      is_completed: is_completed ?? this.is_completed,
      isShowingDescription: isShowingDescription ?? this.isShowingDescription,
    );
  }
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = []; // 작업 목록

  List<Task> get tasks => _tasks;

  /// 새로운 작업 추가
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // 상태가 변경되었음을 알립니다.
  }

  /// 작업 완료 상태 토글
  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].is_completed = !_tasks[index].is_completed;
      notifyListeners(); // 상태가 변경되었음을 알립니다.
    }
  }

  /// 작업 삭제
  void removeTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index); // 리스트에서 해당 인덱스의 항목을 삭제합니다.
      notifyListeners(); // 상태가 변경되었음을 알립니다.
    }
  }

  /// 작업 순서 변경
  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1; // 새로운 인덱스가 oldIndex보다 클 경우 인덱스 조정
    }
    final Task task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task); // oldIndex에서 항목을 제거하고 newIndex 위치에 삽입

    // 우선 순위 업데이트: 현재 리스트의 인덱스에 따라 우선 순위를 재설정
    for (int i = 0; i < _tasks.length; i++) {
      _tasks[i].priority = i + 1; // 우선 순위를 1부터 시작하도록 설정
    }

    notifyListeners(); // 상태가 변경되었음을 알립니다.
  }

  /// 작업을 완료 상태로 바꾸고 맨 아래로 이동
  void moveTaskToBottom(int index) {
    if (index >= 0 && index < _tasks.length) {
      final Task completedTask = _tasks.removeAt(index);
      _tasks.add(completedTask); // 완료된 태스크를 맨 아래로 이동

      // 우선 순위 업데이트
      for (int i = 0; i < _tasks.length; i++) {
        _tasks[i].priority = i + 1; // 우선 순위를 1부터 시작하도록 설정
      }

      notifyListeners(); // 상태가 변경되었음을 알립니다.
    }
  }

  /// 작업 메모 업데이트
  void updateTaskDescription(int index, String newDescription) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index] = _tasks[index].copyWith(description: newDescription); // 메모 업데이트
      notifyListeners(); // 상태가 변경되었음을 알립니다.
    }
  }
}