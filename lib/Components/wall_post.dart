import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:social_media_app/Components/comment.dart';
import 'package:social_media_app/Components/comment_button.dart';
import 'package:social_media_app/Components/helper_methods.dart';
import 'package:social_media_app/Components/like_button.dart';
import 'package:social_media_app/delete_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    //access the document is firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      //if post is now liked, add the user's email to the 'likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
     } else {
      //if the post is now unliked, remove the user's email from the likes field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText){
    //write the comment to firestore under the comment collection of this post
    FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).collection("Comments").add(
        {
          "CommentText" : commentText,
          "CommentedBy" : currentUser.email,
          "CommentTime" : Timestamp.now()
        });
  }
  //show a dialog box for adding a comment
  void showCommentDialog(){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Add Comment"),
      content: TextField(
        controller: _commentTextController,
        decoration: const InputDecoration(hintText: "Write a comment..."),
      ),
      actions: [

        //cancel
        TextButton(onPressed: (){
          //add comment
          // addComment(_commentTextController.text);
          //pop box
          Navigator.pop(context);
          //clear comtroller
          _commentTextController.clear();
        }, child: const Text("Cancel")),
        //post
        // TextButton(onPressed: (){
        //   //add comment
        //   addComment(_commentTextController.text);
        //   //pop box
        //   Navigator.pop(context);
        //   //clear controller
        //   _commentTextController.clear();
        // }, child: const Text("Post")),

        //post
        TextButton(
          onPressed: () {
            // Get the text from the comment text field
            String commentText = _commentTextController.text.trim();

            // Check if the comment text is not empty
            if (commentText.isNotEmpty) {
              // Add comment
              addComment(commentText);

              // Pop the box
              Navigator.pop(context);

              // Clear the controller
              _commentTextController.clear();
            } else {
              // Show an error message or perform any appropriate action for empty comment.
              // For example, you could show a Snackbar or display an error message.
              // For simplicity, I'll just print a message here.
              print("Comment cannot be empty.");
            }
          },
          child: const Text("Post"),
        )



      ],
    ));
  }

  //delete a post
  void deletePost(){
    //show a dialog box asking for confirmation before deleting the post
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Delete Post"),
      content: const Text("Are you sure you want to delete this Post"),
      actions: [
        //cancel
        TextButton(onPressed: () => Navigator.pop(context),child: const Text("Cancel")),
        //delete
        TextButton(onPressed: () async{
          //delete the comments from firestore first
          //if you delete the post, the comments will still be in firestore
          final commentDocs = await FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comments")
              .get();
          for(var doc in commentDocs.docs){
            await FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .doc(doc.id)
                .delete();
          }

          //then delete the post
          FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .delete()
              .then((value) => print("Post Deleted"))
              .catchError((error)=>print("Failed to delete the post: $error"));
          //dismiss the dialog box
          Navigator.pop(context);
        },child: const Text("Delete")),

      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //WALL POST

          //profile pic
          // Container(
          //   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[400]),
          //   padding: EdgeInsets.all(10),
          //   child: Icon(Icons.person, color: Colors.white,),
          // ),
          const SizedBox(width: 20),
          const SizedBox(height: 10,),

          //message and user email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //group of text(message + user email )
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message
                  Text(widget.message),
                  const SizedBox(height: 5),
                  //user
                  Row(
                    children: [
                      Text(widget.user, style: TextStyle(color: Colors.grey[400]),),
                      Text(" . ", style: TextStyle(color: Colors.grey[400])),
                      Text(widget.time, style: TextStyle(color: Colors.grey[400])),
                    ],
                  )
                ],
              ),

              //delete button
              if(widget.user == currentUser.email)
                DeleteButton(onTap: deletePost)

            ],
          ),
          const SizedBox(height: 20),
          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //LIKE
              Column(
                children: [
                  //like button
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  const SizedBox(height: 5),
                  //like count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              //COMMENT
              Column(
                children: [
                  //comment button
                  CommentButton(onTap: showCommentDialog,),
                  const SizedBox(height: 5),
                  //comment count
                  const Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          //comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true).snapshots(),
              builder: (context, snapshot){
              //show loading circle if no data yet
                if(!snapshot.hasData){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    // Renamed the local variable 'snapshot' to 'commentData'
                    final commentData = doc.data() as Map<String, dynamic>;

                    return Comment(
                      text: commentData["CommentText"],
                      user: commentData["CommentedBy"],
                      time: formatDate(commentData["CommentTime"]),
                    );
                  }).toList(),
                );

              }),
        ],
      ),
    );
  }
}
