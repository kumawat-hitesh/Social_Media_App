import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Components/button.dart';
import '../Components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign user up
  void signUp() async{
    //show loading circle
    showDialog(context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        )
    );
    //make sure password match
    if(passwordTextController.text != confirmPasswordController.text){
      //pop loading message
      Navigator.pop(context);
      //show error to user
      displayMessage("Password don't match!");
      return;
    }
    //try creating the user
    try{
      //create the user
      UserCredential userCredential =  await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text
      );
      //after creating the user, create a new document in cloud firestore called users
      FirebaseFirestore.instance.collection("Users")
          .doc(userCredential.user!.email)
          .set({
            'username': emailTextController.text.split('@')[0], //initial user name
            'bio': 'Empty bio...' //initial bio
        //add any additional fields as needed
      });

      //pop loading circle
      if(context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e){
      //pop loading message
      Navigator.pop(context);
      //show error to urse
      displayMessage(e.code);
    }
  }
  //display a dialog message
  void displayMessage(String message){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  //logo
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  const SizedBox(height: 50),
                  //welcome back message
                  const Text(
                    "Lets create an account for you",
                  ),
                  const SizedBox(height: 25),
                  //email text field
                  MyTextField(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 10),
                  //password text field
                  MyTextField(
                      controller: passwordTextController,
                      hintText: 'Password',
                      obscureText: true),
                  const SizedBox(height: 10),
                  //confirm password text field
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true),
                  const SizedBox(height: 25),
                  //sign up button
                  MyButton(onTap: signUp, text: 'Sign Up'),
                  const SizedBox(height: 25),
                  //go to register page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
