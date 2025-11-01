import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 2;

  Query<Map<String, dynamic>> _dealQuery() {
    // Simplified query to avoid index errors
    return FirebaseFirestore.instance
        .collection('deals')
        .orderBy('createdAt', descending: true)
        .limit(100);
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/favorites');
    }
  }

  String _relativeTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: null,
            child: Text('New Deals', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _dealQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Deals stream error: ${snapshot.error}');
            return _EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load deals',
              subtitle: '${snapshot.error}',
            );
          }

          // ✅ Filter active deals safely in Dart instead of in Firestore
          final allDocs = snapshot.data?.docs ?? [];
          final docs = allDocs.where((d) {
            final data = d.data();
            return data['isActive'] == true;
          }).toList();

          if (docs.isEmpty) {
            return _EmptyState(
              icon: Icons.notifications_none,
              title: 'No New Deals',
              subtitle: "You’re all caught up!",
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final d = docs[index].data();
              final title = (d['title'] as String?) ?? 'New Deal';
              final desc  = (d['description'] as String?) ?? '';
              final biz   = (d['businessName'] as String?) ?? 'Business';
              final ts    = d['createdAt'] as Timestamp?;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_offer, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$biz — ${desc.isNotEmpty ? desc : "New deal available"}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _relativeTime(ts),
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
