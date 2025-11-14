import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_details_page.dart'; // import your BusinessDetailsPage

class BusinessHomeDashboard extends StatefulWidget {
  const BusinessHomeDashboard({super.key});

  @override
  State<BusinessHomeDashboard> createState() => _BusinessHomeDashboardState();
}

class _BusinessHomeDashboardState extends State<BusinessHomeDashboard> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, '/business/deals');
    }
  }

  Future<void> _openBusinessDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final businessName = (doc.data()?['name'] as String?) ?? 'My Business';

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessDetailsPage(
          businessId: user.uid,
          businessName: businessName,
          businessIndex: 0,
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _dealsStreamForCurrentBusiness() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('deals')
        .where('businessId', isEqualTo: uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // No back button on this page
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Business Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: _openBusinessDetails,
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _dealsStreamForCurrentBusiness(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading dashboard.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final int totalDeals = docs.length;
          final int activeDeals = docs.where((d) {
            final data = d.data();
            final isActive = (data['isActive'] == true);
            final status = (data['status'] as String?)?.toLowerCase();
            return isActive || status == 'active';
          }).length;

          final int totalViews = docs.fold<int>(0, (sum, d) {
            final v = d.data()['views'];
            if (v is int) return sum + v;
            if (v is num) return sum + v.toInt();
            return sum;
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your deals and grow your business',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Deals',
                          totalDeals.toString(),
                          Icons.card_giftcard,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          activeDeals.toString(),
                          Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildStatCard(
                    'Total Views',
                    totalViews.toString(),
                    Icons.visibility_outlined,
                    fullWidth: true,
                  ),

                  const SizedBox(height: 30),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    'Create New Deal',
                    'Add a new reward or offer',
                    Icons.add_circle_outline,
                    () => Navigator.pushNamed(context, '/business/create-deal'),
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    'Manage Deals',
                    'View and edit your existing deals',
                    Icons.edit_outlined,
                    () => Navigator.pushNamed(context, '/business/deals'),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[900]!, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              activeIcon: Icon(Icons.card_giftcard),
              label: 'Deals',
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _buildStatCard(String label, String value, IconData icon, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(20), // fixed
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 126, 125, 125), size: 16),
          ],
        ),
      ),
    );
  }
}
