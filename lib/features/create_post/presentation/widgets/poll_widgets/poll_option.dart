import 'package:flutter/material.dart';

class PollOption extends StatefulWidget {

  final int optionNumber;
  final GlobalKey<FormState> formKey;
  final Function(String) onChanged;
  final VoidCallback? onIconPress;
  final String? initialBody;

  const PollOption({
    required this.optionNumber,
    required this.formKey,
    required this.onChanged,
    this.onIconPress,
    this.initialBody,
  });

  @override
  State<PollOption> createState() => _PollOptionState();
}

class _PollOptionState extends State<PollOption> {

  late TextEditingController _controller;

   @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text:widget.initialBody);
    _controller.addListener(() {
      setState(() {
        widget.onChanged(_controller.text);
      });
    });
  }

 @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child:Form(
        key: widget.formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'Option ${widget.optionNumber}',
            hintStyle: TextStyle(
              fontSize: 15,
              ),
            prefixIcon: Icon(Icons.more_vert),
            suffixIcon: widget.optionNumber > 2 ? IconButton(
              onPressed: widget.onIconPress,
              icon: Icon(Icons.cancel),
              ) : null
            ),
        ),
      )
    );
  }
}