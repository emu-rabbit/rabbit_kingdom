import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';

class RDropdown<T> extends StatelessWidget {
  final RDropdownController<T> controller;
  final List<T> options;
  final String Function(T)? toDisplayString;
  final String? hintText;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const RDropdown({
    super.key,
    required this.controller,
    required this.options,
    this.toDisplayString,
    this.hintText,
    this.foregroundColor,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: DropdownButton<T>(
            iconEnabledColor: foregroundColor ?? AppColors.onPrimary,
            iconDisabledColor: (foregroundColor ?? AppColors.onPrimary).withAlpha(150),
            dropdownColor: backgroundColor ?? AppColors.primary,
            focusColor: backgroundColor ?? AppColors.primary,
            style: TextStyle(color: foregroundColor ?? AppColors.onPrimary),
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

  factory  RDropdown.primary({
    required RDropdownController<T> controller,
    required List<T> options,
    String Function(T)? toDisplayString,
    String? hintText,
  }) => RDropdown<T>(controller: controller, options: options, toDisplayString: toDisplayString, hintText: hintText,);

  factory  RDropdown.secondary({
    required RDropdownController<T> controller,
    required List<T> options,
    String Function(T)? toDisplayString,
    String? hintText,
  }) => RDropdown<T>(controller: controller, options: options, toDisplayString: toDisplayString, hintText: hintText,
      foregroundColor: AppColors.onSecondary, backgroundColor: AppColors.secondary,);

  factory  RDropdown.surface({
    required RDropdownController<T> controller,
    required List<T> options,
    String Function(T)? toDisplayString,
    String? hintText,
  }) => RDropdown<T>(controller: controller, options: options, toDisplayString: toDisplayString, hintText: hintText,
    foregroundColor: AppColors.onSurface, backgroundColor: AppColors.surface,);
}

class RDropdownController<T> extends GetxController {
  final Rx<T> selected;

  RDropdownController(T defaultValue) : selected = defaultValue.obs;

  void select(T value) => selected.value = value;
}

