// private 값들은 불러올 수 없다.
import 'dart:io';

import 'package:calendar_scheduler/model/category_color.dart';
import 'package:calendar_scheduler/model/schedule.dart';
import 'package:calendar_scheduler/model/schedule_with_color.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// private 값까지 불러올 수 있다.
part 'drift_database.g.dart';

// 괄호 없이 사용
@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);
    query.where(schedules.date.equals(date));
    query.orderBy([
      OrderingTerm.asc(schedules.startTime),
    ]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduleWithColor(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
              )
              .toList(),
        );
  }
  // 1.
  // final query = select(schedules);
  // query.where((tbl) => tbl.date.equals(date));
  // return query.watch();

  // 2.
  // .. -> where 를 실행한 대상인 select 가 리턴되므로 watch()를 가능할 수 있게한다.
  // Stream -> watch
  // (select(schedules)..where((tbl) => tbl.date.equals(date))).watch();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    // dbFolder 에 기기의 저장공간을 할당받은 다음 실제경로를 가져와서 db.sqlite 라는 파일을 생성
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
