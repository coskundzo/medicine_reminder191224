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
    return Stack(
      children: [
        Container(
          width: getRelativeWidth(context, 0.94),
          height: getRelativeHeight(context, 0.22),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: getRelativeWidth(context, 0.88),
                height: getRelativeHeight(context, 0.17),
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
                              SizedBox(
                                  height: getRelativeHeight(context, 0.02)),
                              Row(
                                children: [
                                  /*Flexible(
                                    child: Text(
                                      "Buradaki verdiğiniz bildirimler bir rapora kaydediliyor.",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize:
                                              getRelativeWidth(context, 0.033)),
                                    ),*/

                                  SizedBox(
                                      width: getRelativeWidth(context, 0.03)),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    padding: EdgeInsets.all(
                                        getRelativeWidth(context, 0.012)),
                                  )
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
            ],
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
                height: getRelativeWidth(context, 0.12),
                width: getRelativeWidth(context, 0.12),
                child: Image.asset("assets/images/virus.png")),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: getRelativeHeight(context, 0.035),
                  horizontal: getRelativeWidth(context, 0.16)),
              child: Container(
                  height: getRelativeWidth(context, 0.06),
                  width: getRelativeWidth(context, 0.06),
                  child: Image.asset("assets/images/virus.png")),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: getRelativeHeight(context, 0.01),
                  horizontal: getRelativeWidth(context, 0.07)),
              child: Container(
                  height: getRelativeWidth(context, 0.08),
                  width: getRelativeWidth(context, 0.08),
                  child: Image.asset("assets/images/virus.png")),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Al işlemi
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: Text('Al'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Ertele işlemi
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.orange,
                ),
                child: Text('Ertele'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
