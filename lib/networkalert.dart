import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor extends StatefulWidget {
  final Widget child;

  const NetworkMonitor({required this.child});

  @override
  _NetworkMonitorState createState() => _NetworkMonitorState();
}

class _NetworkMonitorState extends State<NetworkMonitor> {
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isDialogVisible = false;

  void initState() {
    super.initState();

    // 연결 상태 스트림 초기화
    _connectivity.onConnectivityChanged.listen((dynamic result) {
      if (result is ConnectivityResult) {
        _handleConnectivityResult(result);
      } else if (result is List<ConnectivityResult>) {
        for (var connectivityResult in result) {
          _handleConnectivityResult(connectivityResult);
        }
      } else {
        debugPrint("알 수 없는 네트워크 상태: $result");
      }
    });
  }

  void _handleConnectivityResult(ConnectivityResult result) {
    debugPrint("네트워크 상태 변경: $result");
    if (result == ConnectivityResult.none) {
      _showNetworkErrorDialog();
    } else {
      _hideNetworkErrorDialog();
    }
  }



  void _showNetworkErrorDialog() {
    if (!_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false, // 다이얼로그 외부를 눌러도 닫히지 않음
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF7F7), // 배경 색상
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 따라 다이얼로그 높이 제한
            children: [
              Text(
                '네트워크 연결 상태가\n좋지 않습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20, // 텍스트 크기 조정
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10), // 위 텍스트와 아이콘 간격 축소
              Container(
                child: Image.asset("assets/images/warning.png"),
              ),
              const SizedBox(height: 1), // 아이콘과 설명 텍스트 간격 축소
              Text(
                '네트워크 연결 상태를 확인하거나 아래 버튼 클릭 후 다시 접속을 시도해주시기 바랍니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15), // 설명 텍스트와 버튼 간격 축소
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isDialogVisible = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8), // 버튼 크기 조정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }



  void _hideNetworkErrorDialog() {
    if (_isDialogVisible) {
      Navigator.of(context).pop();
      _isDialogVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
