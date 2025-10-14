import "package:flutter/material.dart";

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const ListTile(
                title: Text('Name'),
                subtitle: Text('User\'s name'),
                leading: Icon(Icons.person),
                trailing: Icon(Icons.arrow_forward, color: Colors.grey),
                tileColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const ListTile(
              title: Text('Email'),
              subtitle: Text('User\'s email'),
              leading: Icon(Icons.email_outlined),
              trailing: Icon(Icons.arrow_forward, color: Colors.grey),
              tileColor: Colors.white,
            ),
            const SizedBox(height: 20),
            const ListTile(
              title: Text('Password'),
              subtitle: Text('********'),
              leading: Icon(Icons.lock),
              trailing: Icon(Icons.arrow_forward, color: Colors.grey),
              tileColor: Colors.white,
            ),

            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
