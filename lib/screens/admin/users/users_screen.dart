import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_users.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/admin/user_tile.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _filteredUsers = DummyUsers.users;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final String query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = DummyUsers.users;
        return;
      }

      _filteredUsers =
          DummyUsers.users
              .where(
                (user) =>
                    user.name.toLowerCase().contains(query) ||
                    user.email.toLowerCase().contains(query) ||
                    user.location.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openUserDetails(UserModel user) {
    Navigator.pushNamed(context, AppRoutes.userDetails, arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    final int activeUsers =
        DummyUsers.users.where((user) => user.active).length;

    final int inactiveUsers =
        DummyUsers.users.where((user) => !user.active).length;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Users'),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Text('User Management', style: AppTextStyles.heading2),

          const SizedBox(height: 5),

          Text(
            'View and manage registered Reccly users.',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 20),

          // ==================================================
          // USER SUMMARY
          // ==================================================
          Row(
            children: [
              Expanded(
                child: _UserSummaryCard(
                  title: 'Total',
                  value: '${DummyUsers.users.length}',
                  icon: Icons.people_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _UserSummaryCard(
                  title: 'Active',
                  value: '$activeUsers',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _UserSummaryCard(
                  title: 'Inactive',
                  value: '$inactiveUsers',
                  icon: Icons.person_off_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==================================================
          // SEARCH
          // ==================================================
          TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name, email or location',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                      : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // RESULT COUNT
          // ==================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Registered Users', style: AppTextStyles.heading3),
              Text(
                '${_filteredUsers.length} users',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ==================================================
          // USER LIST
          // ==================================================
          if (_filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_search_rounded,
                    size: 50,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text('No users found', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 5),
                  Text(
                    'Try searching with another name, email or location.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._filteredUsers.map(
              (user) => UserTile(
                user: user,
                onTap: () {
                  _openUserDetails(user);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// USER SUMMARY CARD
// ============================================================

class _UserSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _UserSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 9),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
