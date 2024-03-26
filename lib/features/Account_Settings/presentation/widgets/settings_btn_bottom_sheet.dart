import 'package:flutter/material.dart';

/// A button widget that opens a bottom modal sheet when pressed.
class BottomModalBtn extends StatefulWidget {
  /// Creates a custom button widget.
  /// 
  /// This button is used to open bottom sheets and display the selected option on the right side of the bottom
  ///
  /// Parameters:
  /// - [iconData] : [IconData] The icon data for the button [required].
  /// - [mainText] : [String] The main text displayed on the button [required].
  /// - [onPressed] : [Function] Callback function invoked when the button is pressed [required].
  /// - [selection] : [String] The optional text displayed on the right side of the button (default is an empty string) [required].
  /// - [secondaryText] : [String] The optional secondary text displayed below the main text (default is an empty string).
  /// - [tertiaryText] : [String] The optional tertiary text displayed below the secondary text (default is an empty string).
  const BottomModalBtn(
      {Key? key,
      required this.iconData,
      required this.mainText,
      required this.onPressed,
      required this.selection,
      this.secondaryText = "",
      this.tertiaryText = ""})
      : super(key: key);

  final IconData iconData;
  final Function onPressed;
  final String mainText;
  final String secondaryText;
  final String tertiaryText;
  final String? selection;

  @override
  State<BottomModalBtn> createState() => BottomModalBtnState();
}

/// [BottomModalBtn] state.
class BottomModalBtnState extends State<BottomModalBtn> {
  @override
  Widget build(BuildContext context) {
    String optionalText = widget.secondaryText;

    return TextButton(
      onPressed: (() {
        setState(() {
          widget.onPressed();
        });
      }),
      style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
          overlayColor:
              MaterialStateProperty.all(Colors.grey.withOpacity(0.5))),
      child: Padding(
        padding: EdgeInsets.only(top: 7, bottom: 7),
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
                      if (optionalText != "")
                        TextSpan(
                          text: "\n$optionalText",
                          style: TextStyle(
                              fontSize: 15,
                              color: const Color.fromARGB(255, 91, 91, 91),
                              height: 1.25),
                        ),
                    ]),
                    softWrap: true,
                  ),
                ),
                Text(
                  widget.selection ?? "",
                  style: TextStyle(
                      fontSize: 15,
                      color: const Color.fromARGB(255, 91, 91, 91),
                      height: 1.25),
                ),
                Icon(
                  Icons.expand_more_outlined,
                  color: Color.fromARGB(255, 104, 103, 103),
                ),
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
                              height: 1),
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
