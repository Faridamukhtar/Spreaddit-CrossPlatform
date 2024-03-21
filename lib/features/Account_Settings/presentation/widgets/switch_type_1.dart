import 'package:flutter/material.dart';

class SwitchBtn1 extends StatefulWidget {
  const SwitchBtn1(
      {Key? key,
      required this.iconData,
      required this.mainText,
      required this.onPressed,
      this.switchActiveClr = const Color.fromARGB(255, 7, 116, 205),
      this.thumbActiveClr = Colors.white,
      this.tertiaryText = ""})
      : super(key: key);

  final IconData iconData;
  final Function onPressed;
  final Color switchActiveClr;
  final Color thumbActiveClr;
  final String mainText;
  final String tertiaryText;

  @override
  State<SwitchBtn1> createState() => SwitchBtn1State();
}

class SwitchBtn1State extends State<SwitchBtn1> {
  bool lightVal = false;

  bool getCurrentState() {
    return lightVal;
  }

  void changeState() {
    setState(() {
      lightVal = !lightVal;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (() {
        changeState();
      }),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
        overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 0, bottom: 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  widget.iconData,
                  color: Color.fromARGB(255, 136, 136, 136),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: widget.mainText,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.25),
                      ),
                    ]),
                    softWrap: true,
                  ),
                ),
                Switch(
                  value: lightVal,
                  activeColor: widget.switchActiveClr,
                  activeTrackColor: widget.switchActiveClr,
                  thumbColor:
                      MaterialStatePropertyAll<Color>(widget.thumbActiveClr),
                  onChanged: (bool val) {
                    changeState();
                  },
                )
              ],
            ),
            if (widget.tertiaryText != "")
              Row(
                children: [
                  Icon(
                    widget.iconData,
                    color: Colors.transparent,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: RichText(
                        text: TextSpan(
                          text: widget.tertiaryText,
                          style: TextStyle(
                              fontSize: 15,
                              color: const Color.fromARGB(255, 91, 91, 91),
                              height: 1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
