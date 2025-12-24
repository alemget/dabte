import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ClientSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const ClientSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade500),
          hintText: AppLocalizations.of(context)!.searchClients,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
