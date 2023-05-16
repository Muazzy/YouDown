import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String labelText;
  final Color primaryColor;
  final Color textColor;
  final TextEditingController textEditingController;
  final Widget? suffixIcon;

  final Widget? prefixIcon;
  const CustomFormField({
    super.key,
    required this.labelText,
    required this.primaryColor,
    required this.textColor,
    required this.textEditingController,
    this.suffixIcon,
    this.prefixIcon,
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
      borderRadius: BorderRadius.circular(50),

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
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          contentPadding:
              const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
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
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.primaryColor,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}
