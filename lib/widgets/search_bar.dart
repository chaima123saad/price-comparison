// lib/widgets/search_bar.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;

  const CustomSearchBar({
    Key? key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          // Explicitly set font family to avoid issues
          fontFamily: null, // Use default system font
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: null, // Use default system font
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          isDense: true,
        ),
      ),
    );
  }
}