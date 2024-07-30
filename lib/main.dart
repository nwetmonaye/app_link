import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('Received deep link: $uri');
      openAppLink(uri);
    }, onError: (err) {
      print('Error receiving deep link: $err');
    });

    // Handle the initial link when the app is launched
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      print('Initial deep link: $initialLink');
      openAppLink(initialLink);
    }
  }

  void openAppLink(Uri uri) {
    final routeName = uri.path;
    if (uri.queryParameters['id'] != null) {
      final bookId = uri.queryParameters['id'];
      _navigatorKey.currentState?.pushNamed('/book/$bookId');
    } else {
      _navigatorKey.currentState?.pushNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        Widget routeWidget = defaultScreen();

        final routeName = settings.name;
        print('Generating route for: $routeName');
        if (routeName != null) {
          if (routeName.startsWith('/book/')) {
            final bookId = routeName.split('/').last;
            routeWidget = customScreen(bookId);
          } else if (routeName == '/book') {
            routeWidget = customScreen("None");
          }
        }

        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('App Link')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText('Show Link'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget customScreen(String bookId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(child: Text('Opened with parameter: $bookId')),
    );
  }
}
