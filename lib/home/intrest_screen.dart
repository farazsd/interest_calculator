// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:math';
import 'package:flutter/material.dart';

class CompoundInterestForm extends StatefulWidget {
  final Map<String, dynamic> fieldConfig;

  const CompoundInterestForm({super.key, required this.fieldConfig});

  @override
  State<CompoundInterestForm> createState() => _CompoundInterestFormState();
}

class _CompoundInterestFormState extends State<CompoundInterestForm> {
  int _selectedRate = 1;
  int _selectedCompound = 1;
  int _selectedYear = 1;
  bool isTextResult = false;
  var rateOfInterestConfig;
  var principalAmountConfig;
  var compoundsPerYearConfig;
  var yearsConfig;
  var outputConfig;
  TextEditingController principalController = TextEditingController();
  double _futureValue = 0.0;

  @override
  void initState() {
    super.initState();
    rateOfInterestConfig = widget.fieldConfig['rate_of_interest'] ?? {};
    principalAmountConfig = widget.fieldConfig['principal_amount'] ?? {};
    compoundsPerYearConfig = widget.fieldConfig['compounds_per_year'] ?? {};
    yearsConfig = widget.fieldConfig['years'] ?? {};
    outputConfig = widget.fieldConfig['output'] ?? {};
    if (rateOfInterestConfig.isEmpty ||
        principalAmountConfig.isEmpty ||
        compoundsPerYearConfig.isEmpty ||
        yearsConfig.isEmpty ||
        outputConfig.isEmpty) {
      return null;
    }

    _selectedCompound = getCompoundsPerYearValues().first['value'];
    _selectedYear = getYearsValues().first['value'];
  }

  List<dynamic> getCompoundsPerYearValues() {
    if (_selectedRate == 12) {
      return compoundsPerYearConfig['values']['12'];
    } else if (_selectedRate == 6) {
      return compoundsPerYearConfig['values']['6'];
    } else if (_selectedRate == 3) {
      return compoundsPerYearConfig['values']['3'];
    } else {
      return compoundsPerYearConfig['values']['default'];
    }
  }

  List<dynamic> getYearsValues() {
    if (_selectedCompound == 1) {
      return yearsConfig['values']['1'];
    } else if (_selectedCompound == 2) {
      return yearsConfig['values']['2'];
    } else {
      return yearsConfig['values']['4'];
    }
  }

  double getMinAmount(int rate) {
    if (rate >= 1 && rate <= 3) {
      return 10000;
    } else if (rate >= 4 && rate <= 7) {
      return 10001;
    } else if (rate >= 8 && rate <= 12) {
      return 50001;
    } else {
      return 75001;
    }
  }

  List<DropdownMenuItem<int>> getDropdownItems(List<dynamic> values) {
    return values.map((value) {
      return DropdownMenuItem<int>(
        value: value['value'],
        child: Text(value['label']),
      );
    }).toList();
  }

  void calculateFutureValue() {
    if (principalController.text.isNotEmpty) {
      if ((double.tryParse(principalController.text) ?? 0) <= 10000000) {
        double principal = double.tryParse(principalController.text) ?? 0.0;
        double rate = _selectedRate / 100;
        int compounds = _selectedCompound;
        int years = _selectedYear;
        print("principal Amount==>>$principal");
        print("rate==>>$rate");
        print("compounds==>>$compounds");
        print("years==>>$years");
        setState(() {
          _futureValue =
              principal * pow((1 + rate / compounds), compounds * years);
          print("_futureValue==>>$_futureValue");
        });
        if (outputConfig['mode_of_display'] == 'snack-bar message') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              '${outputConfig['label_text']}: ₹ ${_futureValue.toStringAsFixed(2)}',
              style: TextStyle(
                color: ColorClass(outputConfig['text_color']),
                fontSize: outputConfig['text_size'].toDouble(),
              ),
            )),
          );
        } else if (outputConfig['mode_of_display'] == 'pop-up dialog') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(outputConfig['label_text']),
                content: Text(
                  "₹ ${_futureValue.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: ColorClass(outputConfig['text_color']),
                    fontSize: outputConfig['text_size'].toDouble(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (outputConfig['mode_of_display'] == 'text-field') {
          setState(() {
            isTextResult = true;
            print("isTextResult==>>$isTextResult");
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(principalAmountConfig['error_message']['max'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Amount')),
      );
      setState(() {
        _futureValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // Principal Amount
          Text(
            principalAmountConfig['label_text'],
            style: TextStyle(
              color: ColorClass(rateOfInterestConfig['text_color']),
              fontSize: rateOfInterestConfig['text_size'].toDouble(),
            ),
          ),
          TextFormField(
            controller: principalController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
              counterText: "",
              hintText: principalAmountConfig['hint_text'],
              errorText: principalController.text.isNotEmpty
                  ? (double.tryParse(principalController.text) ?? 0) <
                          getMinAmount(_selectedRate)
                      ? principalAmountConfig['error_message']['min']
                      : (double.tryParse(principalController.text) ?? 0) >
                              10000000
                          ? principalAmountConfig['error_message']['max']
                          : null
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          // Rate of Interest
          Text(
            rateOfInterestConfig['label_text'],
            style: TextStyle(
              color: ColorClass(rateOfInterestConfig['text_color']),
              fontSize: rateOfInterestConfig['text_size'].toDouble(),
            ),
          ),
          DropdownButton<int>(
            value: _selectedRate,
            onChanged: (int? newValue) {
              setState(() {
                _selectedRate = newValue!;
                _selectedCompound = getCompoundsPerYearValues().first['value'];
                _selectedYear = getYearsValues().first['value'];
              });
            },
            items: getDropdownItems(rateOfInterestConfig['values']),
          ),
          const SizedBox(height: 15),
          // // Compounds Per Year
          Text(
            compoundsPerYearConfig['label_text'],
            style: TextStyle(
              color: ColorClass(compoundsPerYearConfig['text_color']),
              fontSize: compoundsPerYearConfig['text_size'].toDouble(),
            ),
          ),
          DropdownButton<int>(
            value: _selectedCompound,
            onChanged: (int? newValue) {
              setState(() {
                _selectedCompound = newValue!;
                _selectedYear = getYearsValues().first['value'];
              });
            },
            items: getDropdownItems(getCompoundsPerYearValues()),
          ),
          const SizedBox(height: 15),
          // // Years
          Text(
            yearsConfig['label_text'],
            style: TextStyle(
              color: ColorClass(yearsConfig['text_color']),
              fontSize: yearsConfig['text_size'].toDouble(),
            ),
          ),
          DropdownButton<int>(
            value: _selectedYear,
            onChanged: (int? newValue) {
              setState(() {
                _selectedYear = newValue!;
              });
            },
            items: getDropdownItems(getYearsValues()),
          ),
          const SizedBox(height: 15),
          // // Calculate Button
          Center(
            child: ElevatedButton(
              onPressed: calculateFutureValue,
              child: const Text('Calculate'),
            ),
          ),
          const SizedBox(height: 15),
          // Output
          isTextResult == true
              ? Center(
                  child: Text(
                    '${outputConfig['label_text']}: ₹ ${_futureValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: ColorClass(outputConfig['text_color']),
                      fontSize: outputConfig['text_size'].toDouble(),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class ColorClass extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  ColorClass(final String hexColor) : super(_getColorFromHex(hexColor));
}
