// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class NetworkMonitor extends StatefulWidget {
//   final Widget child;
//
//   const NetworkMonitor({required this.child});
//
//   @override
//   _NetworkMonitorState createState() => _NetworkMonitorState();
// }
//
// class _NetworkMonitorState extends State<NetworkMonitor> {
//   late final Connectivity _connectivity;
//   late Stream<ConnectivityResult> _connectivityStream;
//   bool _isSnackbarVisible = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _connectivity = Connectivity();
//     _connectivityStream = _connectivity.onConnectivityChanged;
//     _connectivityStream.listen((ConnectivityResult result) {
//       if (result == ConnectivityResult.none) {
//         _showNetworkErrorSnackbar();
//       } else {
//         _hideNetworkErrorSnackbar();
//       }
//     });
//   }
//
//   void _showNetworkErrorSnackbar() {
//     if (!_isSnackbarVisible) {
//       _isSnackbarVisible = true;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('네트워크 연결 상태가 좋지 않습니다.'),
//           duration: Duration(days: 1),
//           action: SnackBarAction(
//             label: '다시 시도하기',
//             onPressed: () {
//               // 재시도 로직 추가
//             },
//           ),
//         ),
//       );
//     }
//   }
//
//   void _hideNetworkErrorSnackbar() {
//     if (_isSnackbarVisible) {
//       _isSnackbarVisible = false;
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
