import 'dart:convert';
import 'dart:developer';
import 'package:calculator_app/home/intrest_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<Map<String, dynamic>> fieldConfig;

  @override
  void initState() {
    super.initState();
    fieldConfig = loadConfig();
  }

  Future<Map<String, dynamic>> loadConfig() async {
    final String response =
        await rootBundle.loadString('assets/rate_interest.json');
    log("loaded");
    print(fieldConfig);
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calculator'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fieldConfig,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            return CompoundInterestForm(fieldConfig: snapshot.data!);
          }
        },
      ),
    );
  }
}
