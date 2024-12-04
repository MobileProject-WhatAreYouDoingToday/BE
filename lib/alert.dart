import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkMonitor extends StatefulWidget {
  final Widget child;

  const NetworkMonitor({required this.child});

  @override
  _NetworkMonitorState createState() => _NetworkMonitorState();
}

class _NetworkMonitorState extends State<NetworkMonitor> {
  final Connectivity _connectivity = Connectivity();
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // 알림 권한 요청
    _listenToConnectivityChanges(); // 네트워크 상태 감지
  }

  // 네트워크 상태 감지
  void _listenToConnectivityChanges() {
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

  // 네트워크 상태 처리
  void _handleConnectivityResult(ConnectivityResult result) {
    debugPrint("네트워크 상태 변경: $result");
    if (result == ConnectivityResult.none) {
      _showNetworkErrorDialog();
    } else {
      _hideNetworkErrorDialog();
    }
  }

  // 알림 권한 요청
  void _requestNotificationPermissions() async {
    final status = await Permission.notification.request(); //기본 다이얼로그
    if (status.isDenied && context.mounted) {
      _showPermissionDialog();
    }
    else if(status.isPermanentlyDenied && context.mounted) {
      _showPermissionDialog();
    }
  }

  // 알림 권한 다이얼로그
  void _showPermissionDialog() {
    if (!_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF7F7), // 배경 색상
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '알림 권한을 허용해주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Image.asset("assets/images/warning.png"),
              ),
              const SizedBox(height: 10),
              Text(
                '알림을 받기 위해서는 권한을 허용해주셔야 됩니다.\n설정에서 이를 구성할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _isDialogVisible = false;
                        openAppSettings(); // 설정 화면 열기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 5), // 세로 패딩만 설정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '설정',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // 버튼 간의 간격
                  SizedBox(
                    width: 100,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _isDialogVisible = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 5), // 세로 패딩만 설정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // 네트워크 오류 다이얼로그
  void _showNetworkErrorDialog() {
    if (!_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF7F7), // 배경 색상
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '네트워크 연결 상태가\n좋지 않습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Image.asset("assets/images/warning.png"),
              ),
              const SizedBox(height: 10),
              Text(
                '네트워크 연결 상태를 확인 후 \n다시 접속을 시도해주시기 바랍니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 150,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _isDialogVisible = false;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 5), // 세로 패딩
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
