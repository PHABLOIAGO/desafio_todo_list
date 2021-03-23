import 'package:flutter/material.dart';

class TimeComponent extends StatefulWidget {
  DateTime date;
  ValueChanged<DateTime> onSelectedTime;
  
  TimeComponent({
    Key key,
    this.date,
    this.onSelectedTime,
  }) : super(key: key);

  
  @override
  _TimeComponentState createState() => _TimeComponentState();
}

class _TimeComponentState extends State<TimeComponent> {
  List<String> _hours = List.generate(24, (index) => index++).map((h) => '${h.toString().padLeft(2, '0')}').toList();
  List<String> _minutes = List.generate(60, (index) => index++).map((m) => '${m.toString().padLeft(2, '0')}').toList();
  List<String> _seconds = List.generate(60, (index) => index++).map((s) => '${s.toString().padLeft(2, '0')}').toList();

  String _hourSelected = "00";
  String _minuteSelected = "00";
  String _secondSelected = "00";

  void invokeCallBack(){
    var newDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(_hourSelected),
      int.parse(_minuteSelected),
      int.parse(_secondSelected),
    );
    widget.onSelectedTime(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBox(_hours, (String value){
          setState(() {
            _hourSelected = value;
            invokeCallBack();
          });
        }),
        _buildBox(_minutes,(String value){
          setState(() {
            _minuteSelected = value;
            invokeCallBack();
          });
        }),
        _buildBox(_seconds,(String value){
          setState(() {
            _secondSelected = value;
            invokeCallBack();
          });
        }),
      ],
    );
  }

  Widget _buildBox(List<String> options, ValueChanged<String> onChange) {
    return Container(
      height: 100,
      width: 80,
      decoration:
          BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(spreadRadius: 0, blurRadius: 10, color: Theme.of(context).primaryColor, offset: Offset(2, 5)),
      ]),
      child: ListWheelScrollView(
        onSelectedItemChanged: (value) => onChange(value.toString().padLeft(2,'0')),
        perspective: 0.007,
        itemExtent: 60,
        physics: FixedExtentScrollPhysics(),
        children: options
            .map<Text>((e) => Text(
                  e,
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ))
            .toList(),
      ),
    );
  }
}
