import 'package:flutter/material.dart';

class PostTitle extends StatefulWidget {
  
  final GlobalKey<FormState> formKey;
  final Function(String) onChanged;

  const PostTitle({
    required this.formKey,
    required this.onChanged,
  });

  @override
  State<PostTitle> createState() => _PostTitleState();
}

class _PostTitleState extends State<PostTitle> {

  late TextEditingController _controller;

   @override
  void initState() {
    super.initState();
    print('PostContent initState');
    _controller = TextEditingController();
    print(_controller);
    print('controller initialized');
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
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          child:SingleChildScrollView(
            child: Form(
              key: widget.formKey,
              child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
                hintStyle: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                  ),
              ),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              controller: _controller,
              ),
            ),
          ),
        );
  }
}

/*
TODOs:
1) ashouf 7war el kalam el underlined da 
2) a7ot el controller wel kalam da
*/