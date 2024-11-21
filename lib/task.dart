class Task {
  String title;
  String? memo; // 메모는 선택적
  bool isCompleted; // 완료 여부

  Task({
    required this.title,
    this.memo,
    this.isCompleted = false,
  });
}
