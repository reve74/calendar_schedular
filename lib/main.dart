import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screen/home_screen.dart';
import 'package:calendar_scheduler/database/drift_database.dart';

const DEFAULT_COLORS = [
  // 빨강
  'F44336',
  // 주황
  'FF9800',
  // 노랑
  'FFEB3B',
  // 초록
  'FCAF50',
  // 파랑
  '2196F3',
  // 남
  '3F51B5',
  // 보라
  '9C27B0',
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러터 프레임워크가 준비가 된 상태인지 확인.

  await initializeDateFormatting(); // 날짜에 관련된 intl 패키지 사용 가능.

  final database = LocalDatabase();

  GetIt.I.registerSingleton<LocalDatabase>(database);

  final colors = await database.getCategoryColors();

  if(colors.isEmpty){
    for(String hexCode in DEFAULT_COLORS){
      await database.createCategoryColor(
        CategoryColorsCompanion(
          hexCode: Value(hexCode),
        ),
      );
    }
  }


  print(await database.getCategoryColors());

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: HomeScreen(),
    ),
  );
}
