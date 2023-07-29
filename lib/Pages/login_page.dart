import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Components/button.dart';
import 'package:social_media_app/Components/text_field.dart';
class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async{
    //show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        )
    );
    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text
      );
      //pop loading circle
      if(context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e){
        //pop loading circle
        Navigator.pop(context);
        //display error message
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
                const Icon(Icons.lock,
                size: 100,
                ),
                const SizedBox(height: 50),
                //welcome back message
                const Text(
                  "Welcome back You've been missed!",
                ),
                const SizedBox(height: 25),
                //email text field
                MyTextField(controller: emailTextController, hintText: 'Email', obscureText: false),
                const SizedBox(height: 10),
                //password text field
                MyTextField(controller: passwordTextController, hintText: 'Password', obscureText: true),
                const SizedBox(height: 10),
                //sign in button
                MyButton(onTap: signIn, text: 'Sign In'),
                const SizedBox(height: 25),
                //go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                          "Register Now",
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
      )
    );
  }
}

