import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessId; // required (users/{businessId})
  final String businessName;
  final int businessIndex; // kept for compatibility

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
  bool _busy = false;

  // -------- OWNER CHECK --------
  bool get _isOwner =>
      FirebaseAuth.instance.currentUser?.uid == widget.businessId;

  // -------------------- Favorites (Firestore) --------------------
  Stream<bool> _isFavoritedStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream<bool>.value(false);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .where('businessId', isEqualTo: widget.businessId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

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
      _toast('Added to favorites', success: true);
    } catch (e) {
      _toast('Failed to add favorite: $e', error: true);
    }
  }

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
      _toast('Removed from favorites', success: true);
    } catch (e) {
      _toast('Failed to remove favorite: $e', error: true);
    }
  }

  // -------------------- Business profile stream --------------------
  Stream<DocumentSnapshot<Map<String, dynamic>>> _businessProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.businessId)
        .snapshots();
  }

  // -------------------- Deals listing --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> _dealsForBusiness() {
    return FirebaseFirestore.instance
        .collection('deals')
        .where('businessId', isEqualTo: widget.businessId)
        .where('kind', isEqualTo: 'deal')
        .snapshots();
  }

  // -------------------- Redeem logic --------------------
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

    final usersRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(
          usersRef,
          {'points': FieldValue.increment(points)},
          SetOptions(merge: true),
        );
      });

      _toast('Redeemed "$title". +$points points!', success: true);
    } catch (e) {
      _toast('Redemption failed: $e', error: true);
    }
  }

  // -------------------- Edit helpers --------------------
  Future<String?> _promptText({
    required String title,
    String initial = '',
    String hint = '',
    String label = '',
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) async {
    final ctrl = TextEditingController(text: initial);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label.isNotEmpty ? label : null,
              labelStyle: TextStyle(color: Colors.grey[500]),
              hintText: hint.isNotEmpty ? hint : null,
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[850],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            validator: validator ??
                (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(context, ctrl.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  Future<void> _updateBusinessProfile({
    required String uid,
    String? name,
    String? email,
    String? phone,
  }) async {
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (email != null) patch['email'] = email;
    if (phone != null) patch['phone'] = phone;
    if (patch.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(patch, SetOptions(merge: true));
  }

  Future<void> _editBusinessName(String currentName) async {
    if (!_isOwner) return;
    final newName = await _promptText(
      title: 'Change Business Name',
      label: 'Business name',
      initial: currentName,
    );
    if (newName == null || newName == currentName) return;
    setState(() => _busy = true);
    try {
      await _updateBusinessProfile(uid: widget.businessId, name: newName);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == widget.businessId) {
        await user.updateDisplayName(newName);
      }
      _toast('Business name updated', success: true);
    } catch (e) {
      _toast('Failed to update name: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editBusinessEmail(String currentEmail) async {
    if (!_isOwner) return;
    final newEmail = await _promptText(
      title: 'Change Email',
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      initial: currentEmail == 'No email' ? '' : currentEmail,
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Required';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
          return 'Invalid email';
        }
        return null;
      },
    );
    if (newEmail == null || newEmail == currentEmail) return;

    setState(() => _busy = true);
    try {
      await _updateBusinessProfile(uid: widget.businessId, email: newEmail);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == widget.businessId) {
        await user.verifyBeforeUpdateEmail(newEmail);
        _toast('Verification link sent to $newEmail. Open it to finish updating.', success: true);
      } else {
        _toast('Email updated', success: true);
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Failed to update login email.';
      if (e.code == 'requires-recent-login') {
        msg = 'Please sign in again, then try updating your email.';
      }
      _toast(msg, error: true);
    } catch (e) {
      _toast('Failed to update email: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editBusinessPhone(String? currentPhone) async {
    if (!_isOwner) return;
    final newPhone = await _promptText(
      title: 'Change Phone',
      label: 'Phone',
      keyboardType: TextInputType.phone,
      initial: (currentPhone ?? ''),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Required';
        if (t.length < 7) return 'Too short';
        return null;
      },
    );
    if (newPhone == null || newPhone == currentPhone) return;

    setState(() => _busy = true);
    try {
      await _updateBusinessProfile(uid: widget.businessId, phone: newPhone);
      _toast('Phone updated', success: true);
    } catch (e) {
      _toast('Failed to update phone: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // -------------------- Logout (bottom button) --------------------
  Future<void> _confirmAndLogout() async {
    if (!_isOwner || _busy) return;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Log out', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
    } catch (e) {
      _toast('Failed to log out: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // -------------------- UI helpers --------------------
  void _toast(String msg,
      {bool error = false, bool warn = false, bool success = false}) {
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

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: disabled ? 0.65 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: disabled ? Colors.grey[700] : Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    final showSpinner = _busy;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: showSpinner ? null : () => Navigator.pop(context),
        ),
        title: Text(
          widget.businessName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // NOTE: Removed the power icon. Keeping favorites icon only.
        actions: [
          if (showSpinner)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
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
                onPressed: showSpinner
                    ? null
                    : () => isFav ? _removeFavorite() : _addFavorite(),
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
            // ---------- Header ----------
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
                    Text('Loyalty Partner',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ),

            // ---------- Business Info (editable if owner) ----------
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _businessProfile(),
              builder: (context, snap) {
                final data = snap.data?.data();
                final name =
                    (data?['name'] as String?)?.trim().isNotEmpty == true
                        ? (data!['name'] as String)
                        : widget.businessName;
                final email =
                    (data?['email'] as String?)?.trim().isNotEmpty == true
                        ? (data!['email'] as String)
                        : 'No email';
                final phone =
                    (data?['phone'] as String?)?.trim().isNotEmpty == true
                        ? (data!['phone'] as String)
                        : 'No phone';

                final loading = snap.connectionState == ConnectionState.waiting;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.business_outlined,
                        title: 'Business Name',
                        subtitle: loading ? 'Loading...' : name,
                        onTap: (_isOwner && !loading && !_busy)
                            ? () => _editBusinessName(name)
                            : null,
                      ),
                      Divider(color: Colors.grey[800], height: 30),
                      _buildProfileItem(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: loading ? 'Loading...' : email,
                        onTap: (_isOwner && !loading && !_busy)
                            ? () => _editBusinessEmail(email)
                            : null,
                      ),
                      Divider(color: Colors.grey[800], height: 30),
                      _buildProfileItem(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        subtitle: loading ? 'Loading...' : phone,
                        onTap: (_isOwner && !loading && !_busy)
                            ? () => _editBusinessPhone(phone == 'No phone' ? '' : phone)
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ---------- Deals Heading ----------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Available Rewards',
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // ---------- Deals list ----------
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
                    final am =
                        (ta is Timestamp) ? ta.microsecondsSinceEpoch : -1;
                    final bm =
                        (tb is Timestamp) ? tb.microsecondsSinceEpoch : -1;
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
                    final title =
                        (data['title'] as String?) ?? 'Untitled Deal';
                    final description =
                        (data['description'] as String?) ?? '';
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              color:
                                  isActive ? Colors.black : Colors.grey[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.green[900]
                                            : Colors.grey[800],
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Not Available',
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.green[300]
                                              : Colors.grey[500],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(pointsLabel,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 13)),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(description,
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13)),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
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
                              foregroundColor: redeemEnabled
                                  ? Colors.black
                                  : Colors.grey[500],
                              backgroundColor: redeemEnabled
                                  ? Colors.white
                                  : Colors.grey[800],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              'Redeem',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // ---------- BOTTOM LOG OUT BUTTON ----------
            if (_isOwner)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _busy ? null : _confirmAndLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[900]!, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
