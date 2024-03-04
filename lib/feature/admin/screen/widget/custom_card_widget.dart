// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  final Function onTap;
  final String imgae;
  final double height;
  final double width;
  final String name;
  final Color color;

  const CustomCardWidget({
    Key? key,
    required this.onTap,
    required this.imgae,
    required this.height,
    required this.width,
    required this.name,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // height: 100,
          // width: 200,
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 3,
            ),
          ),
          child: InkWell(
            onTap: () {
              onTap();
            },
            child: Image.asset(
              imgae,
              height: height,
              width: width,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          name,
          style: TextStyle(fontSize: 30, fontFamily: "chewy", color: color),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
