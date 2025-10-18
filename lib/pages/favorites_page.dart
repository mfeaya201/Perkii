import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  // ---- SAMPLE DATA (replace with backend data later) ----
  final List<Map<String, String>> favorites = const [
    {
      'name': 'KFC',
      'image': 'assets/images/businesspfp.png',
    },
    {
      'name': 'McDonald\'s',
      'image': 'assets/images/businesspfp.png',
    },
    {
      'name': 'Nike',
      'image': 'assets/images/businesspfp.png',
    },
  ];

  Widget buildFavoriteCard(Map<String, String> business) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: CircleAvatar(
            backgroundImage: AssetImage(business['image']!),
            radius: 30,
          ),
          title: Text(
            business['name']!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.favorite,
            color: Colors.redAccent,
            size: 28,
          ),
          onTap: () {
            // Optional: navigate to business page later
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Favorites",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return buildFavoriteCard(favorites[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
