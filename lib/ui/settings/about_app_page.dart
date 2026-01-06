import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سياسة الخصوصية'), centerTitle: true),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('تطبيق DioMax - ديوماكس لإدارة الديون بينك وبين عملائك.'),
        ),
      ),
    );
  }
}
