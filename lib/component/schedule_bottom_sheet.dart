import 'package:calendar_scheduler/component/calendar.dart';
import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:calendar_scheduler/model/category_color.dart';
import 'package:drift/drift.dart' show Value; // Value 라는 클래스만 drift 패키지에서 불러옴.
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:calendar_scheduler/database/drift_database.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet({
    required this.selectedDate,
    this.scheduleId,
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();
  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom; // 키보드가 차지하는 영역

    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .requestFocus(FocusNode()); // 현재 포커스가 되어있는 텍스트필드에서 포커스를 없앨 수 있다.
      },
      child: FutureBuilder<Schedule>(
          future: null,
          builder: (context, snapshot) {
            return FutureBuilder<Schedule>(
                future: widget.scheduleId == null
                    ? null
                    : GetIt.I<LocalDatabase>()
                        .getScheduleById(widget.scheduleId!),
                builder: (context, snapshot) {
                  print(snapshot.data);

                  if (snapshot.hasError) {
                    return const Center(child: Text('스케줄을 불러올 수 없습니다'));
                  }

                  // FutureBuilder 처음 실행됐고 로딩중일때
                  if (snapshot.connectionState != ConnectionState.none &&
                      !snapshot.hasData) {
                    return Center(child: const CircularProgressIndicator());
                  }

                  // Future 가 실행이 되고 값이 있는데
                  // 단 한번도 startTime이 세팅되지 않았을 때
                  if (snapshot.hasData && startTime == null) {
                    startTime = snapshot.data!.startTime;
                    endTime = snapshot.data!.endTime;
                    content = snapshot.data!.content;
                    selectedColorId = snapshot.data!.colorId;
                  }

                  return SafeArea(
                    child: Container(
                      color: Colors.white,
                      height:
                          MediaQuery.of(context).size.height * .5 + bottomInset,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            right: 8.0,
                            left: 8.0,
                          ),
                          child: Form(
                            key: formKey,
                            autovalidateMode: AutovalidateMode.always,
                            // 자동으로 밸리데이션 작동.
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Time(
                                  onStartSaved: (String? val) {
                                    startTime = int.parse(val!);
                                  },
                                  onEndSaved: (String? val) {
                                    endTime = int.parse(val!);
                                  },
                                  startInitialValue:
                                      startTime?.toString() ?? '',
                                  endInitialValue: endTime?.toString() ?? '',
                                ),
                                const SizedBox(height: 16.0),
                                _Content(
                                  onSaved: (String? val) {
                                    content = val;
                                  },
                                  initialValue: content ?? '',
                                ),
                                const SizedBox(height: 16.0),
                                FutureBuilder<List<CategoryColor>>(
                                    future: GetIt.I<LocalDatabase>()
                                        .getCategoryColors(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          selectedColorId == null &&
                                          snapshot.data!.isNotEmpty) {
                                        selectedColorId = snapshot.data![0].id;
                                      }
                                      return _ColorsPicker(
                                        colors: snapshot.hasData
                                            ? snapshot.data!
                                            : [],
                                        selectedColorId: selectedColorId,
                                        colorIdSetter: (int id) {
                                          setState(() {
                                            selectedColorId = id;
                                          });
                                        },
                                      );
                                    }),
                                const SizedBox(height: 8.0),
                                _SaveButton(onPressed: onSavedPressed),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }

  void onSavedPressed() async {
    // formKey 는 생성을 했는데
    // Form 위젯과 결합을 안했을 때
    if (formKey.currentState == null) {
      return;
    }

    if (formKey.currentState!.validate()) {
      print('에러가 없습니다.');
      formKey.currentState!.save();
      print('-------');
      print('startTime : ${startTime}');
      print('endTime : ${endTime}');
      print('content : ${content}');

      if (widget.scheduleId == null) {
        await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      } else {
        await GetIt.I<LocalDatabase>().updateScheduleById(
            widget.scheduleId!,
            SchedulesCompanion(
                date: Value(widget.selectedDate),
                startTime: Value(startTime!),
                endTime: Value(endTime!),
                content: Value(content!),
                colorId: Value(selectedColorId!)));
      }

      Navigator.of(context).pop();
    } else {
      print('에러가 있습니다.!');
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _Time({
    required this.onStartSaved,
    required this.onEndSaved,
    required this.startInitialValue,
    required this.endInitialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            isTime: true,
            label: '시작시간',
            onSaved: onStartSaved,
            initialValue: startInitialValue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextField(
            isTime: true,
            label: '마감시간',
            onSaved: onEndSaved,
            initialValue: endInitialValue,
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const _Content({
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        isTime: false,
        label: '내용',
        onSaved: onSaved,
        initialValue: initialValue,
      ),
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorsPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorsPicker(
      {required this.colors,
      required this.selectedColorId,
      required this.colorIdSetter,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 10.0,
      children: colors
          .map(
            (e) => GestureDetector(
              onTap: () {
                colorIdSetter(e.id);
              },
              child: renderColor(e, selectedColorId == e.id),
            ),
          )
          .toList(),
      // [
      //   renderColor(Colors.red),
      //   renderColor(Colors.orange),
      //   renderColor(Colors.yellow),
      //   renderColor(Colors.green),
      //   renderColor(Colors.blue),
      //   renderColor(Colors.indigo),
      //   renderColor(Colors.purple),
      // ],
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(
            int.parse(
              'FF${color.hexCode}',
              radix: 16,
            ),
          ),
          border:
              isSelected ? Border.all(color: Colors.black, width: 4.0) : null),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: PRIMARY_COLOR,
            ),
            onPressed: onPressed,
            child: Text('저장'),
          ),
        ),
      ],
    );
  }
}
