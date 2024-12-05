import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store.dart'; // Firestore 관련 클래스 포함

class AchievePage extends StatelessWidget {
  final String userEmail;

  const AchievePage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    backgroundColor: Colors.white;
    final currentMonth = DateTime.now().month;
    final monthNames = [
      '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    final currentMonthName = monthNames[currentMonth - 1];

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCategoryAchievements(userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final achievements = snapshot.data ?? [];

        return SizedBox(
          width: 375,
          height: 812,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                '$currentMonthName 달성률',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              centerTitle: true,
            ),
            body: achievements.isEmpty
                ? const Center(child: Text('데이터가 없습니다'))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 막대 그래프
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 240,
                    child: CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: AchieveBarChartPainter(
                        achievementRates: achievements
                            .map((achievement) => achievement['rate'] as double)
                            .toList(),
                        colors: achievements
                            .map((achievement) => achievement['color'] as Color)
                            .toList(),
                      ),
                    ),
                  ),
                ),
                // 막대 아래 텍스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: achievements
                        .map((achievement) => Text(
                      '${(achievement['rate'] * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // 하단 카테고리별 세부 정보
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '세부 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              // 원형 이미지
                              Container(
                                width: 48,
                                height: 48,
                                child: ClipOval(
                                  child: Image.asset(
                                    achievement['imagePath'] as String,
                                    fit: BoxFit.contain, // 이미지 비율 유지
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement['category'] as String,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '목표 ${achievement['total']}개 중 ${achievement['completed']}개 완료',
                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(achievement['rate'] * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategoryAchievements(String email) async {
    final store = Store();
    final todos = await store.getTodoList(email) ?? [];

    // Get the current month and year
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    const categories = ['독서', '운동', '공부', '취미'];
    const colors = [
      Color(0xFFFF9692),
      Color(0xFFFFD465),
      Color(0xFF61E4C5),
      Color(0xFFDBBEFC),
    ];
    const imagePaths = [
      'assets/images/readingbtn.png', // 독서
      'assets/images/healthbtn.png', // 운동
      'assets/images/studybtn.png', // 공부
      'assets/images/hobbybtn.png', // 취미
    ];

    // Filter todos for the current month
    final filteredTodos = todos.where((todo) {
      final todoDate = todo.date.toDate();
      return todoDate.year == currentYear && todoDate.month == currentMonth;
    }).toList();

    return categories.asMap().entries.map((entry) {
      final categoryIndex = entry.key;
      final category = entry.value;

      final categoryTodos = filteredTodos.where((todo) => todo.category == category).toList();
      final completedCount = categoryTodos.where((todo) => todo.isCompleted).length;
      final totalCount = categoryTodos.length;
      final rate = totalCount > 0 ? completedCount / totalCount : 0.0;

      return {
        'category': category,
        'completed': completedCount,
        'total': totalCount,
        'rate': rate,
        'color': colors[categoryIndex],
        'imagePath': imagePaths[categoryIndex], // 이미지 경로 추가
      };
    }).toList();
  }
}

class AchieveBarChartPainter extends CustomPainter {
  final List<double> achievementRates;
  final List<Color> colors;

  AchieveBarChartPainter({required this.achievementRates, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = size.width / (achievementRates.length * 2);
    final space = barWidth;

    for (int i = 0; i < achievementRates.length; i++) {
      final barHeight = achievementRates[i] * size.height;
      final xOffset = i * (barWidth + space) + (space / 2);

      paint.color = colors[i];
      canvas.drawRect(
        Rect.fromLTWH(xOffset, size.height - barHeight, barWidth, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


