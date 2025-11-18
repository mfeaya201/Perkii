import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _selectedIndex = 1;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/notifications');
    }
  }

  

  
  Stream<QuerySnapshot<Map<String, dynamic>>> _favoritesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchBusinessesByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const [];
    final col = FirebaseFirestore.instance.collection('users');

    
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> out = [];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snap = await col.where(FieldPath.documentId, whereIn: chunk).get();
      out.addAll(snap.docs);
    }
    return out;
  }

  
  Future<void> _removeFavoriteByFavDocId(String favDocId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(favDocId)
        .delete();
  }

  
  Future<void> _removeFavoriteByBusinessId(String businessId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');

    final q = await col.where('businessId', isEqualTo: businessId).get();
    for (final d in q.docs) {
      await d.reference.delete();
    }
  }

  

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 20),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add businesses to see them here',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _favoritesStream(),
        builder: (context, favSnap) {
          if (favSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favSnap.hasError) {
            return _errorBox('Error loading favorites.\n${favSnap.error}');
          }

          final favDocs = favSnap.data?.docs ?? [];
          if (favDocs.isEmpty) return _emptyState();

          
          final businessIds = <String>[];
          final favDocByBusinessId = <String, String>{};
          for (final d in favDocs) {
            final data = d.data();
            final businessId = (data['businessId'] as String?)?.trim();
            if (businessId != null && businessId.isNotEmpty) {
              businessIds.add(businessId);
              favDocByBusinessId[businessId] = d.id;
            }
          }

          if (businessIds.isEmpty) return _emptyState();

          return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            future: _fetchBusinessesByIds(businessIds),
            builder: (context, bizSnap) {
              if (bizSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bizSnap.hasError) {
                return _errorBox('Error loading businesses.\n${bizSnap.error}');
              }

              final bizDocs = bizSnap.data ?? [];
              if (bizDocs.isEmpty) return _emptyState();

              
    
              final byId = {for (final d in bizDocs) d.id: d};
              final ordered = businessIds
                  .map((id) => byId[id])
                  .where((d) => d != null)
                  .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: ordered.length,
                itemBuilder: (context, index) {
                  final doc = ordered[index];
                  final data = doc.data();

                  final businessId = doc.id;
                  final businessName =
                      (data['businessName'] ?? data['name'] ?? 'Business').toString();
                  final logoUrl = data['logoUrl']?.toString();

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/business-details',
                        arguments: {
                          'businessId': businessId,
                          'businessName': businessName,
                        
                          
                          'businessIndex': 0,
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
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
                                ? const Icon(Icons.store, color: Colors.black, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 15),
                        
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  businessName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Tap to view rewards',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          IconButton(
                            tooltip: 'Remove from favorites',
                            onPressed: () async {
                              final favDocId = favDocByBusinessId[businessId];
                              try {
                                if (favDocId != null) {
                                  await _removeFavoriteByFavDocId(favDocId);
                                } else {
                                  await _removeFavoriteByBusinessId(businessId);
                                }
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Removed from favorites'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.grey[900],
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to remove: $e'),
                                    backgroundColor: Colors.red[700],
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.favorite, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
