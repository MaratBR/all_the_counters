import 'dart:async';

import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/widgets/counter_value_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void CounterCallback(Counter counter);

class EditCounterForm extends StatefulWidget {
  final CounterCallback callback;
  final Counter initialValue;


  const EditCounterForm({
    Key? key,
    required this.callback,
    required this.initialValue}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditCounterFormState();
  }
}

class _EditCounterFormState extends State<EditCounterForm> {
  late Counter _currentValue;
  final _formKey = GlobalKey<FormState>();
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: CounterValueDisplay(
                value: _currentValue.value,
                type: _currentValue.type, showSign: false
            ),
          ),
          TextFormField(
            initialValue: _currentValue.label,
            decoration: InputDecoration(
                hintText: "Label",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25)))
            ),
            validator: (value) {
              if (value != null) {
                if (value.length > 30)
                  return "Label is too long (must be 30 characters or less)";
              }
            },
            onChanged: (v) {
              if (!_formKey.currentState!.validate())
                return;
              v = v.trim();
              final label = v.isEmpty ? null : v;

              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _onChange(_currentValue.copyWith(label: label));
              });
            },
          ),
          Padding(
              padding: EdgeInsets.all(12),
              child: Text("Type", style: Theme.of(context).textTheme.subtitle2)
          ),


          for (var v in CounterType.values.where((element) => element != CounterType.unset))
            Row(
              children: [
                Radio<bool>(
                  value: widget.initialValue.type == v,
                  groupValue: true,
                  onChanged: (value) {
                    _onChange(_currentValue.copyWith(type: v));
                  },
                ),
                Text(v.toString().substring(v.toString().indexOf('.') + 1).toUpperCase())
              ],
            ),
        ],
      ),
    );
  }

  void _onChange(Counter newValue) {
    setState(() {
      _currentValue = newValue;
    });
    widget.callback(_currentValue);
  }

}