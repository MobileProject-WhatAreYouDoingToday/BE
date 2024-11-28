import 'package:flutter/material.dart';

class AchievePage extends StatelessWidget {
  const AchievePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375, // 고정된 너비
      height: 812, // 고정된 높이
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 정렬
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/calendar'); // calendar.dart로 이동
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 30), // 좌측에서 30만큼 떨어짐
                  child: Image.asset(
                    '../asset/calendar.png',
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
              const Text(
                '10월 달성률',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 막대그래프
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 240, // 높이를 살짝 더 높게 설정
                child: CustomPaint(
                  size: const Size(double.infinity, 200), // 캔버스 크기 설정
                  painter: AchieveBarChartPainter(
                    achievementRates: [0.6667, 0.3, 0.9, 0.8889], // 각 카테고리별 달성률
                    colors: [
                      const Color(0xFFFF9692),
                      const Color(0xFFFFD465),
                      const Color(0xFF61E4C5),
                      const Color(0xFFDBBEFC),
                    ], // 막대 색상
                  ),
                ),
              ),
            ),
            // 막대 아래 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('66.67%', style: TextStyle(fontSize: 12, color: Colors.black)),
                  Text('30%', style: TextStyle(fontSize: 12, color: Colors.black)),
                  Text('90%', style: TextStyle(fontSize: 12, color: Colors.black)),
                  Text('88.89%', style: TextStyle(fontSize: 12, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 하단 카테고리별 세부 정보
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Expense details',
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
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final achieved = achievedGoals[index];
                  final total = totalGoals[index];
                  final percentage = (achieved / total * 100).toStringAsFixed(2);
                  final icon = categoryIcons[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: categoryColors[index],
                            radius: 24,
                            child: Icon(icon, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '목표 $total번 중 $achieved번 완료했습니다',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$percentage%',
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
  }
}

// CustomPainter를 이용한 막대 그래프
class AchieveBarChartPainter extends CustomPainter {
  final List<double> achievementRates; // 0~1 범위의 달성률
  final List<Color> colors; // 막대 색상

  AchieveBarChartPainter({required this.achievementRates, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 막대 너비 및 간격 계산
    final barWidth = size.width / (achievementRates.length * 2); // 막대 너비 증가
    final space = barWidth; // 간격 조정

    for (int i = 0; i < achievementRates.length; i++) {
      final barHeight = achievementRates[i] * size.height; // 달성률에 따른 높이
      final xOffset = i * (barWidth + space) + (space / 2); // 막대 위치 수정

      // 막대 색상 설정
      paint.color = colors[i];

      // 막대 그리기
      canvas.drawRect(
        Rect.fromLTWH(
          xOffset, // x 위치
          size.height - barHeight, // y 위치
          barWidth, // 막대 너비
          barHeight, // 막대 높이
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 데이터 설정
final List<String> categories = ['독서', '운동', '공부', '취미'];
final List<int> achievedGoals = [10, 3, 9, 8];
final List<int> totalGoals = [15, 10, 10, 9];
final List<Color> categoryColors = [
  Color(0xFFFF9692),
  Color(0xFFFFD465),
  Color(0xFF61E4C5),
  Color(0xFFDBBEFC),
];
final List<IconData> categoryIcons = [
  Icons.menu_book,
  Icons.fitness_center,
  Icons.edit,
  Icons.mood,
];
