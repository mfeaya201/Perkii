import 'package:flutter/material.dart' ; 

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              'Perkii',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'cursive',
                color: Colors.deepOrangeAccent,
              ),
              ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              'Ready to join the loyalty rewards world?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'cursive',
                color: Colors.amberAccent,
              ),
              ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              'Sign up below, get ready to be Perkii',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'cursive',
                color: Colors.amberAccent,
              ),
              ),
          ),
          GestureDetector(
            onTap: () {
              //Goes to login
            },
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20), 

          GestureDetector(
            onTap: () {
              //Goes to login
            },
            child: const Text(
              'Already have an account?',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
          
          
          
        ] 
      ),
    );
  }
}