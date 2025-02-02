// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:flutter/material.dart';

double getRelativeWidth(BuildContext context, double ratio) {
  return MediaQuery.of(context).size.width * ratio;
}

double getRelativeHeight(BuildContext context, double ratio) {
  return MediaQuery.of(context).size.height * ratio;
}

class FloatingPage extends StatelessWidget {
  const FloatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0, // Sayfanın altına sabitlemek için
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: getRelativeWidth(context, 0.94),
          height: getRelativeHeight(context, 0.22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                blurRadius: 40,
                offset: Offset(0, 15),
                color: Colors.black,
              )
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff77E2FE),
                Color(0xff46BDFA),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getRelativeWidth(context, 0.03)),
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 1.0,
                        top: 2.0,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.black54,
                          size: getRelativeHeight(context, 0.1),
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: getRelativeHeight(context, 0.1),
                      ),
                      Icon(
                        Icons.healing,
                        color: Colors.white,
                        size: getRelativeHeight(context, 0.05),
                      ),
                    ],
                  ),
                  SizedBox(width: getRelativeWidth(context, 0.012)),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "İlaçlar Önemlidir",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: getRelativeWidth(context, 0.055),
                          ),
                        ),
                        SizedBox(height: getRelativeHeight(context, 0.02)),
                        Row(
                          children: [
                            SizedBox(width: getRelativeWidth(context, 0.03)),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.all(
                                  getRelativeWidth(context, 0.012)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
