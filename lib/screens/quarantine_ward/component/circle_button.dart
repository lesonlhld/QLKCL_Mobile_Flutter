import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;

  const CircleButton({required this.onTap, required this.iconData}) : super();

  @override
  Widget build(BuildContext context) {
    const double size = 20;

    return InkResponse(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }
}
