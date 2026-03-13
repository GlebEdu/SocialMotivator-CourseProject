import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class HabitBetApp extends ConsumerWidget {
  const HabitBetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HabitBet',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
