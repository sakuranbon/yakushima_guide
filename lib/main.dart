import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'screens/new_post/new_post_screen.dart';
import 'screens/post_detail/post_detail_screen.dart';
import 'screens/my_page/my_page_screen.dart';
import 'models/post_model.dart';
import 'config/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void ensureLogin() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: YakushimaApp()));
}

class YakushimaApp extends StatelessWidget {
  const YakushimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
            path: '/new', builder: (context, state) => const NewPostScreen()),
        GoRoute(
            path: '/mypage', builder: (context, state) => const MyPageScreen()),
        GoRoute(
          path: '/post_detail',
          builder: (context, state) {
            final post = state.extra as PostModel;
            return PostDetailScreen(post: post, postId: '');
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: '屋久島ガイド',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'), // 日本語をサポート
        Locale('en'), // 英語も追加
      ],
    );
  }
}
