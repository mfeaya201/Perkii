import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, '/favorites');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/notifications');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _allUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  bool _isBusinessDoc(Map<String, dynamic> data) {
    final isBizFlag = data['isBusiness'] == true;
    final role = (data['role'] ?? data['accountType'] ?? data['userType'])
        ?.toString()
        .toLowerCase();
    final isBizRole =
        role == 'business' || role == 'merchant' || role == 'vendor';
    return isBizFlag || isBizRole;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Perkii',
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
        stream: _allUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading businesses.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final all = snapshot.data?.docs ?? [];
          final bizDocs = all.where((d) => _isBusinessDoc(d.data())).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              
              Container(
                margin: const EdgeInsets.all(20),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, color: Colors.grey[700], size: 48),
                      const SizedBox(height: 15),
                      Text(
                        'Your Rewards',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Businesses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (bizDocs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: Text(
                      'No businesses available yet.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),

              
              ...List.generate(bizDocs.length, (index) {
                final doc = bizDocs[index];
                final data = doc.data();
                final businessId = doc.id;
                final name =
                    (data['businessName'] ?? data['name'] ?? 'Business').toString();
                final logoUrl = data['logoUrl']?.toString();

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/business-details',
                      arguments: {
                        'businessId': businessId,
                        'businessName': name,
                        'businessIndex': index,
                      },
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: (logoUrl != null && logoUrl.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(logoUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (logoUrl == null || logoUrl.isEmpty)
                              ? const Icon(Icons.store,
                                  color: Colors.black, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 15),

                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              
                              
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                )._rowWithName(name);
              }),
            ],
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

extension _CardHelpers on Widget {
  
  Widget _rowWithName(String name) {
    
    if (this is! GestureDetector) return this;
    final g = this as GestureDetector;
    if (g.child is! Container) return this;
    final c = g.child as Container;
    if (c.child is! Row) return this;
    final row = c.child as Row;

    final children = <Widget>[];
    for (final w in row.children) {
      if (w is Expanded) {
        children.add(
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Tap to view rewards',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(w);
      }
    }

    return GestureDetector(
      onTap: g.onTap,
      child: Container(
        margin: c.margin,
        padding: c.padding,
        decoration: c.decoration,
        child: Row(children: children),
      ),
    );
  }
}
