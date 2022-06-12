import 'package:flutter/material.dart';

class ScrollableText extends StatelessWidget {
  const ScrollableText(
    this.text, {
    Key? key,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.style,
    this.scrollDirection = Axis.horizontal,
  }) : super(key: key);

  final String text;

  final int? maxLines;

  final TextAlign? textAlign;

  final TextOverflow? overflow;

  final TextStyle? style;

  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: Tooltip(
        message: text,
        child: Text(
          text,
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
          style: style,
        ),
      ),
    );
  }
}
