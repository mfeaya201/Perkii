import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessId; // required
  final String businessName;
  final int businessIndex; // no longer used for favorites (kept for compatibility)

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
  // -------------------- Favorites (Firestore) --------------------

  /// Stream that emits `true` if this business is in the user's favorites.
  Stream<bool> _isFavoritedStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream<bool>.value(false);
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .where('businessId', isEqualTo: widget.businessId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  /// Adds this business to the user's favorites.
  Future<void> _addFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('You must be signed in to favorite.', error: true);
      return;
    }
    try {
      final favs = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites');

      // Avoid duplicates: check if exists first
      final exists = await favs
          .where('businessId', isEqualTo: widget.businessId)
          .limit(1)
          .get();

      if (exists.docs.isEmpty) {
        await favs.add({
          'businessId': widget.businessId,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      _toast('Added to favorites');
    } catch (e) {
      _toast('Failed to add favorite: $e', error: true);
    }
  }

  /// Removes this business from the user's favorites.
  Future<void> _removeFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('You must be signed in to change favorites.', error: true);
      return;
    }
    try {
      final favs = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites');

      final q = await favs
          .where('businessId', isEqualTo: widget.businessId)
          .get();

      for (final d in q.docs) {
        await d.reference.delete();
      }

      _toast('Removed from favorites');
    } catch (e) {
      _toast('Failed to remove favorite: $e', error: true);
    }
  }

  // -------------------- Deals listing --------------------

  // No orderBy to avoid needing a composite index; sort client-side.
  Stream<QuerySnapshot<Map<String, dynamic>>> _dealsForBusiness() {
    return FirebaseFirestore.instance
        .collection('deals')
        .where('businessId', isEqualTo: widget.businessId)
        .where('kind', isEqualTo: 'deal')
        .snapshots();
  }

  // -------------------- Redeem logic (adds points to user) --------------------

  Future<void> _redeemDeal({
    required String dealId,
    required String title,
    required int points,
    required bool isActive,
  }) async {
    if (!isActive) {
      _toast('This deal is inactive and cannot be redeemed.', warn: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('You must be signed in to redeem.', error: true);
      return;
    }

    // Confirm
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Redeem', style: TextStyle(color: Colors.white)),
        content: Text(
          'Redeem "$title" for $points points?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(
          usersRef,
          {'points': FieldValue.increment(points)},
          SetOptions(merge: true),
        );

        // (Optional) audit trail or per-deal counters can be added here.
      });

      _toast('Redeemed "$title". +$points points!', success: true);
    } catch (e) {
      _toast('Redemption failed: $e', error: true);
    }
  }

  // -------------------- UI helpers --------------------

  void _toast(String msg, {bool error = false, bool warn = false, bool success = false}) {
    final color = error
        ? Colors.red[700]
        : warn
            ? Colors.orange[800]
            : success
                ? Colors.green[700]
                : Colors.grey[900];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Heart button driven by Firestore
          StreamBuilder<bool>(
            stream: _isFavoritedStream(),
            builder: (context, snap) {
              final isFav = snap.data == true;
              return IconButton(
                tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.white,
                ),
                onPressed: () => isFav ? _removeFavorite() : _addFavorite(),
              );
            },
          ),
        ],
      ),

      // ----- BODY -----
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
                    Text('Loyalty Partner', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Available Rewards',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // Deals list (client-side sort by createdAt desc)
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

                final docs = [...(snapshot.data?.docs ?? [])]..sort((a, b) {
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
                    final doc = docs[index];
                    final data = doc.data();
                    final title = (data['title'] as String?) ?? 'Untitled Deal';
                    final description = (data['description'] as String?) ?? '';
                    final pointsAny = data['points'];
                    final intPoints = (pointsAny is int)
                        ? pointsAny
                        : int.tryParse(pointsAny?.toString() ?? '') ?? 0;
                    final isActive = (data['isActive'] == true) ||
                        ((data['status'] as String?)?.toLowerCase() == 'active');

                    final pointsLabel = '$intPoints points';
                    final redeemEnabled = isActive && intPoints > 0;

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
                          // Icon / status
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
                                const SizedBox(height: 6),
                                Text(pointsLabel, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Redeem button
                          TextButton(
                            onPressed: redeemEnabled
                                ? () => _redeemDeal(
                                      dealId: doc.id,
                                      title: title,
                                      points: intPoints,
                                      isActive: isActive,
                                    )
                                : null,
                            style: TextButton.styleFrom(
                              foregroundColor: redeemEnabled ? Colors.black : Colors.grey[500],
                              backgroundColor: redeemEnabled ? Colors.white : Colors.grey[800],
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              'Redeem',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
