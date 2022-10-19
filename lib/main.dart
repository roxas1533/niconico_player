import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'content_wrapper.dart';
import 'footer.dart';
import 'header.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja_JP");
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        fontFamily: 'NotoSansCJKJp',
      ),
      home: const WholeWidget(),
    );
  }
}

class WholeWidget extends ConsumerWidget {
  const WholeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: Header(),
      body: Content(),
      bottomNavigationBar: Footer(),
    );
  }
}
