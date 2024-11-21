class Task {
  final String title; // 할 일 제목
  final String? memo; // 메모 (선택적)
  bool isCompleted; // 완료 여부

  Task({required this.title, this.memo, this.isCompleted = false});
}
