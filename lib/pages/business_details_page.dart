import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perkii/pages/favorites_manager.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessId;     // ✅ required
  final String businessName;
  final int businessIndex;     // used by your FavoritesManager

  const BusinessDetailsPage({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.businessIndex,
  });

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final FavoritesManager _favManager = FavoritesManager();

  // 🔧 TEMP: no orderBy here to avoid composite index requirement
  Stream<QuerySnapshot<Map<String, dynamic>>> _dealsForBusiness() {
    return FirebaseFirestore.instance
        .collection('deals')
        .where('businessId', isEqualTo: widget.businessId)
        .where('kind', isEqualTo: 'deal') // ignore any legacy/aggregate docs
        // .orderBy('createdAt', descending: true) // <-- put back after index is created
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = _favManager.isFavorite(widget.businessIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.businessName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _favManager.toggleFavorite(widget.businessIndex);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite ? 'Removed from favorites' : 'Added to favorites',
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.grey[900],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.store, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.businessName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loyalty Partner',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Available Rewards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Deals list from Firestore
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _dealsForBusiness(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Error loading deals.\n${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // ✅ Sort client-side by createdAt desc (so no index is required)
                final docs = [...(snapshot.data?.docs ?? [])];
                docs.sort((a, b) {
                  final ta = a.data()['createdAt'];
                  final tb = b.data()['createdAt'];
                  final am = (ta is Timestamp) ? ta.microsecondsSinceEpoch : -1;
                  final bm = (tb is Timestamp) ? tb.microsecondsSinceEpoch : -1;
                  return bm.compareTo(am);
                });

                if (docs.isEmpty) {
                  return Padding(
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
                        'No rewards yet. Check back soon!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final title = (data['title'] as String?) ?? 'Untitled Deal';
                    final description = (data['description'] as String?) ?? '';
                    final points = data['points'];
                    final isActive = (data['isActive'] == true) ||
                        ((data['status'] as String?)?.toLowerCase() == 'active');

                    final pointsLabel = (points is int)
                        ? '$points points'
                        : '${points?.toString() ?? '—'} points';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon / status color
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              color: isActive ? Colors.black : Colors.grey[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Texts
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Status chip
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
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
                                const SizedBox(height: 6),
                                Text(
                                  pointsLabel,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Redeem (placeholder)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Redeem',
                              style: TextStyle(
                                color: isActive ? Colors.black : Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
