import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  // 24h 기준으로 기획하기 때문에 int type
  // 정확한 시간을 넣으려면 DateTime 사용

  final int startTime;
  final int endTime;
  final String content;
  final Color color;

  const ScheduleCard(
      {required this.startTime,
      required this.endTime,
      required this.content,
      required this.color,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 1.0,
        ),
      ),
      child: IntrinsicHeight( // Row 에서 가장 높은 사이즈만큼 높이를 차지해주는 위젯
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Time(
              startTime: startTime,
              endTime: endTime,
            ),
            const SizedBox(width: 16.0),
            _Content(content: content),
            const SizedBox(width: 16.0),
            _Category(color: color),
          ],
        ),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  final int startTime;
  final int endTime;

  const _Time({required this.startTime, required this.endTime, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontWeight: FontWeight.w600, color: PRIMARY_COLOR, fontSize: 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00',
          style: textStyle,
        ),
        Text(
          '${endTime.toString().padLeft(2, '0')}:00',
          style: textStyle.copyWith(fontSize: 10.0),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content;
  const _Content({required this.content, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(content),
    );
  }
}

class _Category extends StatelessWidget {
  final Color color;
  const _Category({required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      width: 16.0,
      height: 16.0,
    );
  }
}
