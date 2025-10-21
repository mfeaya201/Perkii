import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<QuerySnapshot<Map<String, dynamic>>> _dealsStreamForCurrentBusiness() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If somehow no user (shouldn’t happen here), return an empty stream
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return FirebaseFirestore.instance
        .collection('deals')
        .where('businessId', isEqualTo: user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _dealsStreamForCurrentBusiness(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error state
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

          // ---- Compute stats (defensive against missing fields) ----
          final int totalDeals = docs.length;

          final int activeDeals = docs.where((d) {
            final data = d.data();
            final isActive = (data['isActive'] == true); // <-- tweak here if needed
            final status = (data['status'] as String?)?.toLowerCase();
            return isActive || status == 'active'; // support both schemas
          }).length;

          final int totalViews = docs.fold<int>(0, (sum, d) {
            final v = d.data()['views'];
            if (v is int) return sum + v;
            if (v is num) return sum + v.toInt();
            return sum; // default to 0 if missing/wrong type
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
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
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Stats Cards
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
                  const SizedBox(height: 15),

                  _buildActionButton(
                    'Business Profile',
                    'Update your business information',
                    Icons.business_outlined,
                    () => Navigator.pushNamed(context, '/profile'),
                  ),

                  const SizedBox(height: 30),

                  // Recent Deals Section
                  const Text(
                    'Recent Deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Show last 3 deals (by createdAt desc if present, else as-is)
                  ..._buildRecentDeals(docs),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[900]!, width: 1),
          ),
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

  List<Widget> _buildRecentDeals(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    // Sort by createdAt (desc) if provided
    docs.sort((a, b) {
      final aTs = a.data()['createdAt'];
      final bTs = b.data()['createdAt'];
      final aMicros = (aTs is Timestamp) ? aTs.microsecondsSinceEpoch : -1;
      final bMicros = (bTs is Timestamp) ? bTs.microsecondsSinceEpoch : -1;
      return bMicros.compareTo(aMicros);
    });

    final recent = docs.take(3).toList();

    if (recent.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: Text(
            'No deals yet. Create your first one!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ];
    }

    return recent.map((d) {
      final data = d.data();
      final title = (data['title'] as String?) ?? 'Untitled Deal';
      final points = (data['points'] as int?)?.toString() ??
          (data['points']?.toString() ?? '—');
      final isActive = (data['isActive'] == true) ||
          ((data['status'] as String?)?.toLowerCase() == 'active');

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildRecentDealCard(title, '$points points', isActive),
      );
    }).toList();
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 126, 125, 125), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDealCard(String title, String points, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_offer,
              color: isActive ? Colors.black : Colors.grey[600],
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  points,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[900] : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green[300] : Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
