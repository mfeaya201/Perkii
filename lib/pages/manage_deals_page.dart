import 'package:flutter/material.dart';

class ManageDealsPage extends StatefulWidget {
  const ManageDealsPage({super.key});

  @override
  State<ManageDealsPage> createState() => _ManageDealsPageState();
}

class _ManageDealsPageState extends State<ManageDealsPage> {
  int _selectedIndex = 1;

  // Placeholder deals
  final List<Map<String, dynamic>> deals = [
    {
      'id': '1',
      'title': 'Summer Special',
      'description': 'Get 20% off on all items',
      'points': 250,
      'isActive': true,
    },
    {
      'id': '2',
      'title': 'New Customer Offer',
      'description': 'First purchase discount',
      'points': 100,
      'isActive': true,
    },
    {
      'id': '3',
      'title': 'Loyalty Reward',
      'description': 'Exclusive for loyal customers',
      'points': 500,
      'isActive': false,
    },
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/business/home');
    }
  }

  void _toggleDealStatus(int index) {
    setState(() {
      deals[index]['isActive'] = !deals[index]['isActive'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deals[index]['isActive'] ? 'Deal activated' : 'Deal deactivated',
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  void _deleteDeal(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Delete Deal',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${deals[index]['title']}"?',
            style: TextStyle(color: Colors.grey[400]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  deals.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deal deleted'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.grey[900],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
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
        title: Text(
          'Manage Deals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/business/create-deal');
            },
          ),
        ],
      ),
      body: deals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_outlined, size: 80, color: Colors.grey[800]),
                  SizedBox(height: 20),
                  Text(
                    'No Deals Yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create your first deal to get started',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/business/create-deal');
                    },
                    icon: Icon(Icons.add),
                    label: Text('Create Deal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.all(20),
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
                                Text(
                                  deal['title'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  deal['description'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.stars, color: Colors.grey[600], size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      '${deal['points']} points',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: deal['isActive'] ? Colors.green[900] : Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              deal['isActive'] ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: deal['isActive'] ? Colors.green[300] : Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Divider(color: Colors.grey[800], height: 1),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/business/edit-deal',
                                  arguments: deal,
                                );
                              },
                              icon: Icon(Icons.edit_outlined, size: 18),
                              label: Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey[800]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _toggleDealStatus(index),
                              icon: Icon(
                                deal['isActive'] ? Icons.toggle_on : Icons.toggle_off,
                                size: 18,
                              ),
                              label: Text(deal['isActive'] ? 'Disable' : 'Enable'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: deal['isActive'] ? Colors.orange[400] : Colors.green[400],
                                side: BorderSide(
                                  color: deal['isActive'] ? Colors.orange[900]! : Colors.green[900]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            onPressed: () => _deleteDeal(index),
                            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/business/create-deal');
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.black, size: 28),
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
          items: [
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