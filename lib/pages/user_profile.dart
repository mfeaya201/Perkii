import "package:flutter/material.dart";

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // Profile Picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[900],
                    backgroundImage: AssetImage('assets/images/profile.png'),
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey[700],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // User Info Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.person_outline,
                      title: 'Name',
                      subtitle: 'John Doe',
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey[800], height: 30),
                    _buildProfileItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: 'john.doe@example.com',
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey[800], height: 30),
                    _buildProfileItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      subtitle: '+1 234 567 8900',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Security Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.lock_outline,
                      title: 'Password',
                      subtitle: '••••••••',
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey[800], height: 30),
                    _buildProfileItem(
                      icon: Icons.security_outlined,
                      title: 'Two-Factor Authentication',
                      subtitle: 'Enabled',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 15),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/onboarding',
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: Colors.red[900]!, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }
}