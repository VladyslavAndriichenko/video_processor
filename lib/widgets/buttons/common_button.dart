import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String? buttonText;
  final Function? onClick;
  const CommonButton({Key? key, this.onClick, this.buttonText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onClick as void Function()?,
      child: Text(buttonText!),
      color: Colors.grey,
      disabledColor: Colors.black12,
      height: 50,
    );
  }
}
