import "package:flutter/material.dart";

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // ---- SAMPLE DATA (replace later with data from MySQL) ----
  final List<Map<String, String>> notifications = const [
    {
      'image': 'assets/images/businesspfp.png',
      'title': 'KFC Chips Sale!',
      'time': '5 mins ago',
    },
    {
      'image': 'assets/images/businesspfp.png',
      'title': 'McDonald\'s New Burger Deal!',
      'time': '10 mins ago',
    },
    {
      'image': 'assets/images/businesspfp.png',
      'title': 'Nike has dropped a new sneaker!',
      'time': '30 mins ago',
    },
  ];

  Widget buildNotificationTile(Map<String, String> notification) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(notification['image']!),
            ),
            title: Text(notification['title']!),
            subtitle: Text(notification['time']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ BODY CONTENT
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),
            const Center(
              child: Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(
              thickness: 2,
              color: Colors.black,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return buildNotificationTile(notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),

     
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue, 
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // 0 = home, 1 = favorites, 2 = notifications
        onTap: (index) {
          // Example navigation logic:
          if (index == 0) {
            // Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Navigator.pushReplacementNamed(context, '/favorites');
          } else if (index == 2) {
            // We’re already on notifications
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active), // Highlighted icon
            label: '',
          ),
        ],
      ),
    );
  }
}
