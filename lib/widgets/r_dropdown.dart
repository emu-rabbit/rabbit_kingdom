import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';

class RDropdown<T> extends StatelessWidget {
  final RDropdownController<T> controller;
  final List<T> options;
  final String Function(T)? toDisplayString;
  final String? hintText;

  const RDropdown({
    super.key,
    required this.controller,
    required this.options,
    this.toDisplayString,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: DropdownButton<T>(
            iconEnabledColor: AppColors.onPrimary,
            iconDisabledColor: AppColors.onPrimary.withAlpha(150),
            dropdownColor: AppColors.primary,
            focusColor: AppColors.primary,
            style: TextStyle(color: AppColors.onPrimary),
            isExpanded: true,
            value: controller.selected.value,
            onChanged: (T? newValue) {
              if (newValue != null) {
                controller.select(newValue);
              }
            },
            hint: hintText != null ? Text(hintText!) : null,
            items: options.map((T value) {
              final display = toDisplayString?.call(value) ?? value.toString();
              return DropdownMenuItem<T>(
                value: value,
                child: Text(display),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}

class RDropdownController<T> extends GetxController {
  final Rx<T> selected;

  RDropdownController(T defaultValue) : selected = defaultValue.obs;

  void select(T value) => selected.value = value;
}

