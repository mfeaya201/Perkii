import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDealsPage extends StatefulWidget {
  const ManageDealsPage({super.key});

  @override
  State<ManageDealsPage> createState() => _ManageDealsPageState();
}

class _ManageDealsPageState extends State<ManageDealsPage> {
  int _selectedIndex = 1;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/business/home');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _dealsStreamForCurrentBusiness() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    
    return FirebaseFirestore.instance
        .collection('deals')
        .where('businessId', isEqualTo: user.uid)
        .snapshots();
  }

  Future<void> _toggleDealStatus(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data() ?? {};
    final current = (data['isActive'] == true) ||
        ((data['status'] as String?)?.toLowerCase() == 'active');
    final nextIsActive = !current;

    try {
      await doc.reference.update({
        'isActive': nextIsActive,
        'status': nextIsActive ? 'active' : 'inactive',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nextIsActive ? 'Deal activated' : 'Deal deactivated'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _deleteDeal(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final title = (doc.data()?['title'] as String?) ?? 'this deal';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Deal', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$title"?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await doc.reference.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deal deleted'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.grey[900],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
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
          'Manage Deals',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _dealsStreamForCurrentBusiness(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading deals.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          
          final docs = (snapshot.data?.docs ?? [])
              .where((d) => (d.data()['kind'] ?? 'deal') == 'deal')
              .toList()
            ..sort((a, b) {
              final aTs = a.data()['createdAt'];
              final bTs = b.data()['createdAt'];
              final aMicros = aTs is Timestamp ? aTs.microsecondsSinceEpoch : -1;
              final bMicros = bTs is Timestamp ? bTs.microsecondsSinceEpoch : -1;
              return bMicros.compareTo(aMicros); 
            });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_outlined, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 20),
                  Text(
                    'No Deals Yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text('Create your first deal to get started',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/business/create-deal'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Deal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final title = (data['title'] as String?) ?? 'Untitled Deal';
              final description = (data['description'] as String?) ?? '';
              final points = (data['points'] is int)
                  ? data['points'] as int
                  : int.tryParse('${data['points']}') ?? 0;
              final isActive = (data['isActive'] == true) ||
                  ((data['status'] as String?)?.toLowerCase() == 'active');

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (description.isNotEmpty)
                                Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.stars, color: Colors.grey[600], size: 16),
                                  const SizedBox(width: 5),
                                  Text('$points points',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green[900] : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive ? Colors.green[300] : Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Divider(color: Colors.grey[800], height: 1),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/business/edit-deal',
                                arguments: {
                                  'id': doc.id,
                                  ...data,
                                },
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey[800]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _toggleDealStatus(doc),
                            icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off, size: 18),
                            label: Text(isActive ? 'Disable' : 'Enable'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isActive ? Colors.orange[400] : Colors.green[400],
                              side: BorderSide(
                                color: isActive ? Colors.orange[900]! : Colors.green[900]!,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _deleteDeal(doc),
                          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/business/create-deal'),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
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
}
