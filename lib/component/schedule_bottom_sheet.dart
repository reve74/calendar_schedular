import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';

class ScheduleBottomSheet extends StatelessWidget {
  const ScheduleBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom; // 키보드가 차지하는 영역

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode()); // 현재 포커스가 되어있는 텍스트필드에서 포커스를 없앨 수 있다.
      },
      child: SafeArea(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * .5 + bottomInset,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                right: 8.0,
                left: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Time(),
                  const SizedBox(height: 16.0),
                  _Content(),
                  const SizedBox(height: 16.0),
                  _ColorsPicker(),
                  const SizedBox(height: 8.0),
                  _SaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(isTime: true,label: '시작시간'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextField(isTime: true,label: '마감시간'),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(isTime: false,label: '내용'),
    );
  }
}

class _ColorsPicker extends StatelessWidget {
  const _ColorsPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 10.0,
      children: [
        renderColor(Colors.red),
        renderColor(Colors.orange),
        renderColor(Colors.yellow),
        renderColor(Colors.green),
        renderColor(Colors.blue),
        renderColor(Colors.indigo),
        renderColor(Colors.purple),
      ],
    );
  }

  Widget renderColor(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: PRIMARY_COLOR,
            ),
            onPressed: () {},
            child: Text('저장'),
          ),
        ),
      ],
    );
  }
}
