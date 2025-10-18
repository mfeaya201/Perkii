import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<bool> isSelected = [true, false]; // Customer by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text(
                'Welcome To Perkii - Register Now!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Toggle Buttons
            ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              fillColor: Colors.blueAccent,
              selectedColor: Colors.white,
              color: Colors.white70,
              borderColor: Colors.white54,
              selectedBorderColor: Colors.blueAccent,
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 120,
              ),
              isSelected: isSelected,
              onPressed: (int newIndex) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == newIndex;
                  }
                });
              },
              children: const [
                Text("Customer"),
                Text("Business"),
              ],
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const ListTile(
                  title: Text('username'),
                  leading: Icon(Icons.person),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(top:20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const ListTile(
                  title: Text('password'),
                  leading: Icon(Icons.lock),
                  trailing: Icon(Icons.remove_red_eye),
                ),
              ),
            ),
                 Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Register'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
