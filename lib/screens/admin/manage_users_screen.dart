import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../models/app_user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Adminlikni o'zgartirish funksiyasi
  Future<void> _toggleUserRole(String uid, bool currentIsAdmin) async {
    try {
      final newRole = currentIsAdmin ? 'user' : 'admin';
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid) // BU YERDA: ID orqali topamiz
          .update({
        'role': newRole, // Faqat role ni o'zgartiramiz, isAdmin getter orqali ishlaydi
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentIsAdmin
                ? "Adminlik huquqi olib tashlandi"
                : "Admin etib tayinlandi"),
            backgroundColor: currentIsAdmin ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Foydalanuvchini o'chirish funksiyasi
  Future<void> _deleteUser(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirishni tasdiqlang"),
        content: const Text(
            "Bu foydalanuvchi va uning natijalari butunlay o'chiriladi. Ishonchingiz komilmi?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid) // BU YERDA: uid ishlatildi
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foydalanuvchi o'chirildi")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Pastdan chiqadigan menyu (Bottom Sheet)
  void _showUserOptions(BuildContext context, AppUser user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.isAdmin
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  child: Icon(
                    user.isAdmin ? Icons.shield : Icons.person,
                    color: user.isAdmin ? Colors.orange : Colors.blue,
                  ),
                ),
                title: Text(
                  user.name.isNotEmpty ? user.name : user.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Hozirgi roli: ${user.role.toUpperCase()}"),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  user.isAdmin ? Icons.remove_moderator : Icons.add_moderator,
                  color: user.isAdmin ? Colors.orange : Colors.green,
                ),
                title: Text(
                  user.isAdmin ? "Adminlikdan olish" : "Admin qilish",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleUserRole(user.uid, user.isAdmin); // user.uid ishlatildi
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  "Foydalanuvchini o'chirish",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteUser(user.uid); // user.uid ishlatildi
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header qismi
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foydalanuvchilar',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Qidiruv maydoni
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Ism yoki email orqali qidirish...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Ro'yxat qismi
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(AppConstants.usersCollection)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Ma'lumotlarni olish
                  final allUsers = snapshot.data!.docs.map((doc) {
                    // DIQQAT: doc.id ni map qilishda ishlatamiz
                    return AppUser.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id, // Bu avtomatik ravishda 'uid' ga o'tadi
                    );
                  }).toList();

                  // Filtrlash
                  final filteredUsers = allUsers.where((user) {
                    final name = user.name.toLowerCase();
                    final email = user.email.toLowerCase();
                    return name.contains(_searchQuery) ||
                        email.contains(_searchQuery);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return _buildEmptyState(
                        message: "Qidiruv bo'yicha natija topilmadi");
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({String message = 'Foydalanuvchilar yo\'q'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserOptions(context, user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Hero(
                  tag: 'avatar_${user.uid}', // BU YERDA: user.uid
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    backgroundColor: user.isAdmin
                        ? Colors.orange.withOpacity(0.1)
                        : AppConstants.primaryColor.withOpacity(0.1),
                    child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                        ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : user.email[0].toUpperCase(),
                      style: TextStyle(
                        color: user.isAdmin
                            ? Colors.orange
                            : AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name.isNotEmpty ? user.name : "Nomsiz",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isAdmin) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                size: 16, color: Colors.orange),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Tags row
                      Row(
                        children: [
                          _buildTag(
                            user.isAdmin ? "ADMIN" : "USER",
                            user.isAdmin ? Colors.orange : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildTag(
                            "Quiz: ${user.quizzesTaken}",
                            Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          _buildTag(
                            "Ball: ${user.totalScore}",
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit Icon
                Icon(Icons.more_vert, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}