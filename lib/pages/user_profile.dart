import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Small holder used by the single password-change dialog
class _PwdChange {
  final String current;
  final String next;
  _PwdChange(this.current, this.next);
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  bool _isLoading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _userName = 'No user logged in';
          _userEmail = '';
          _isLoading = false;
        });
        return;
      }

      final fallbackEmail = user.email ?? '';
      final fallbackName = user.displayName;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!snap.exists) {
        setState(() {
          _userName = (fallbackName?.isNotEmpty == true) ? fallbackName! : 'No Name';
          _userEmail = fallbackEmail;
          _isLoading = false;
        });
        return;
      }

      final data = snap.data()!;
      setState(() {
        _userName = (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : (fallbackName ?? 'No Name');
        _userEmail = (data['email'] as String?)?.trim().isNotEmpty == true
            ? data['email'] as String
            : fallbackEmail;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userName = 'Error fetching data';
        _userEmail = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Log Out', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to log out?',
              style: TextStyle(color: Colors.grey[400])),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
    }
  }

  // ---------- Dialog helpers (kept for name/email prompts) ----------

  Future<String?> _promptText({
    required String title,
    String initial = '',
    String hint = '',
    String label = '',
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
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
            obscureText: obscure,
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

  Future<String?> _promptPassword({
    required String title,
    String label = 'Password',
  }) async {
    return _promptText(
      title: title,
      label: label,
      obscure: true,
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Required';
        if (t.length < 6) return 'Minimum 6 characters';
        return null;
      },
    );
  }

  Future<void> _updateFirestoreProfile({
    required String uid,
    String? name,
    String? email,
    String? phone,
  }) async {
    final update = <String, dynamic>{};
    if (name != null) update['name'] = name;
    if (email != null) update['email'] = email;
    if (phone != null) update['phone'] = phone;
    if (update.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(update, SetOptions(merge: true));
  }

  Future<void> _reauthenticateWithPassword(String email, String currentPassword) async {
    final user = FirebaseAuth.instance.currentUser!;
    final cred = EmailAuthProvider.credential(email: email, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
  }

  /// In auth v6, use providerData to detect if the 'password' provider is linked.
  bool _usesEmailPassword(User user) {
    return user.providerData.any((p) => p.providerId == 'password');
  }

  // ---------- Edit Name / Email / Password ----------

  Future<void> _editName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = await _promptText(
      title: 'Change Name',
      label: 'Name',
      initial: _userName == 'No Name' ? '' : _userName,
    );
    if (newName == null || newName == _userName) return;

    setState(() => _busy = true);
    try {
      await user.updateDisplayName(newName);
      await _updateFirestoreProfile(uid: user.uid, name: newName);
      await _fetchUserData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Name updated'), backgroundColor: Colors.green[700]),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name: ${e.message}'), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newEmail = await _promptText(
      title: 'Change Email',
      label: 'New email',
      initial: _userEmail,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Required';
        if (!t.contains('@')) return 'Invalid email';
        return null;
      },
    );
    if (newEmail == null || newEmail == _userEmail) return;

    setState(() => _busy = true);
    try {
      // v6: send verification link; the email changes after user confirms.
      await user.verifyBeforeUpdateEmail(newEmail);
      await _updateFirestoreProfile(uid: user.uid, email: newEmail);

      await _fetchUserData(); // UI may still show old email until verified.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification sent to the new email. Open the link to finish updating.'),
          backgroundColor: Colors.green[700],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final currentPassword =
            await _promptPassword(title: 'Re-authenticate', label: 'Current password');
        if (currentPassword != null && (user.email ?? '').isNotEmpty) {
          try {
            await _reauthenticateWithPassword(user.email!, currentPassword);
            await user.verifyBeforeUpdateEmail(newEmail);
            await _updateFirestoreProfile(uid: user.uid, email: newEmail);
            await _fetchUserData();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Verification sent to the new email. Open the link to finish updating.'),
                backgroundColor: Colors.green[700],
              ),
            );
          } on FirebaseAuthException catch (e2) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Re-auth failed: ${e2.message}'),
                  backgroundColor: Colors.red[700]),
            );
          }
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update email: ${e.message}'),
              backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// FIXED: single-dialog password flow to avoid nested dialog lifecycle issues.
  Future<void> _editPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final supportsPassword = _usesEmailPassword(user);
    if (!supportsPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password can’t be changed for this sign-in method.'),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    // One dialog with BOTH fields
    final change = await showDialog<_PwdChange>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        final currentCtrl = TextEditingController();
        final nextCtrl = TextEditingController();
        bool hideCurrent = true;
        bool hideNext = true;

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Change Password', style: TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentCtrl,
                      obscureText: hideCurrent,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        labelStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideCurrent ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[500],
                          ),
                          onPressed: () => setLocal(() => hideCurrent = !hideCurrent),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nextCtrl,
                      obscureText: hideNext,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'New password',
                        labelStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideNext ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[500],
                          ),
                          onPressed: () => setLocal(() => hideNext = !hideNext),
                        ),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Required';
                        if (t.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() == true) {
                      Navigator.pop(ctx, _PwdChange(
                        currentCtrl.text.trim(),
                        nextCtrl.text.trim(),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || change == null) return; // cancelled or page disposed

    setState(() => _busy = true);
    try {
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'no-email',
          message: 'This account has no email address.',
        );
      }

      // Re-auth then update
      await _reauthenticateWithPassword(email, change.current);
      await user.updatePassword(change.next);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Password updated'), backgroundColor: Colors.green[700]),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = e.message ?? 'Failed to update password';
      if (e.code == 'weak-password') msg = 'That password is too weak.';
      if (e.code == 'wrong-password') msg = 'Current password is incorrect.';
      if (e.code == 'requires-recent-login') msg = 'Please sign in again and retry.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _busy;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: disabled ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Picture (static placeholder)
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[900],
                    child: Icon(Icons.person, size: 70, color: Colors.grey[700]),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // User Info Section
              Container(
                padding: const EdgeInsets.all(20),
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
                      subtitle: _isLoading ? 'Loading...' : _userName,
                      onTap: disabled ? null : _editName,
                    ),
                    Divider(color: Colors.grey[800], height: 30),
                    _buildProfileItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: _isLoading ? 'Loading...' : _userEmail,
                      onTap: disabled ? null : _editEmail,
                    ),
                    Divider(color: Colors.grey[800], height: 30),
                    _buildProfileItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      subtitle: '+1 234 567 8900', // placeholder
                      onTap: () {}, // add phone update flow when you store it
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Security Section
              Container(
                padding: const EdgeInsets.all(20),
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
                      onTap: disabled ? null : _editPassword,
                    ),
                    Divider(color: Colors.grey[800], height: 30),
                    _buildProfileItem(
                      icon: Icons.security_outlined,
                      title: 'Two-Factor Authentication',
                      subtitle: 'Enabled',
                      onTap: () {}, // implement when you add 2FA
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Edit Profile (full-screen editor later)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: disabled ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 15),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: disabled ? null : _confirmAndLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: Colors.red[900]!, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),
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
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: disabled ? 0.6 : 1.0,
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
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
