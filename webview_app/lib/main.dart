import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'navigation_controls.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
    ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WebView'),
          actions: [
            NavigationControls(controller: _controller,),
            Menu(controller: _controller,),
          ],
        ),
        body: WebViewStack(controller: _controller,),
    );
  }
}

class WebViewStack extends StatefulWidget {
  const WebViewStack({super.key, required this.controller});
  final WebViewController controller;
  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  // late final WebViewController _controller;
  var _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller..setNavigationDelegate(
      NavigationDelegate(onPageStarted: (url) {
        setState(() {
          _loadingPercentage = 0;
        });
      }, onProgress: (progress) {
        setState(() {
          _loadingPercentage = progress;
        });
      }, onPageFinished: (url) {
        setState(() {
          _loadingPercentage = 100;
        });
      }, onNavigationRequest: (navigation) {
        final host = Uri.parse(navigation.url).host;
        if (host.contains('youtube.com')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Blocking navigation to $host',
              ),
            ),
          );
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      }),
    )..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel('SnackBar', onMessageReceived: (message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.message)));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: widget.controller),
        if (_loadingPercentage < 100)
          LinearProgressIndicator(value: _loadingPercentage / 100.0,)
      ],
    );
  }
}


