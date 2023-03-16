import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String labelText;
  final Color primaryColor;
  final Color textColor;
  final TextEditingController textEditingController;
  final Widget? suffixIcon;
  const CustomFormField({
    super.key,
    required this.labelText,
    required this.primaryColor,
    required this.textColor,
    required this.textEditingController,
    this.suffixIcon,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  @override
  @override
  void dispose() {
    super.dispose();
    widget.textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      //cuz the textfeild's border radius is also the same
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
      elevation: 1.5,
      // shadowColor: AppColors.bodyTextColor.withOpacity(0.8),
      shadowColor: Colors.black.withOpacity(0.8),
      child: TextFormField(
        controller: widget.textEditingController,
        obscureText: false,
        style: TextStyle(
          color: widget.textColor,
          fontSize: 16,
        ),
        cursorColor: widget.primaryColor.withOpacity(0.5),
        decoration: InputDecoration(
          suffixIcon: widget.suffixIcon,
          contentPadding: const EdgeInsets.only(left: 12, right: 12),
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: widget.textColor.withOpacity(0.5),
              ),
          floatingLabelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: widget.textColor.withOpacity(0.5),
              ),
          label: Text(
            widget.labelText,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.primaryColor,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.primaryColor,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
