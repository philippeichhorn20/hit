import 'package:flutter/material.dart';
import 'package:hitstorm/backend/Comment.dart';
import 'package:hitstorm/backend/Subcomment.dart';

class SubcommentView extends StatefulWidget {
  Comment comment;
  SubcommentView({Key key, @required this.comment}) : super(key: key);

  @override
  _SubcommentViewState createState() => _SubcommentViewState();
}

class _SubcommentViewState extends State<SubcommentView> {
  void dropComment(){}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(

        ),
        body: Column(
          children: [
            widget.comment.getCommentListTile(context, dropComment, setState, -1),
            Divider(thickness: 3,),

          ],
        )
      ),
    );
  }
}
