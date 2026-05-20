import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/routes/app_routes.dart';

class RoleSwitcherDialog extends StatefulWidget {
  final List<String> availableRoles;
  final String currentRole;

  const RoleSwitcherDialog({
    super.key,
    required this.availableRoles,
    required this.currentRole,
  });

  @override
  State<RoleSwitcherDialog> createState() => _RoleSwitcherDialogState();
}

class _RoleSwitcherDialogState extends State<RoleSwitcherDialog> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

  void _handleSwitchRole() async {
    if (_selectedRole == null || _selectedRole == widget.currentRole) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.switchRole(_selectedRole!);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success']) {
        // Close dialog
        Navigator.pop(context);

        // Navigate to appropriate dashboard
        String route;
        if (_selectedRole == AppConstants.roleAdmin) {
          route = AppRoutes.adminMain;
        } else if (_selectedRole == AppConstants.roleProvider) {
          route = AppRoutes.providerMain;
        } else {
          route = AppRoutes.userMain;
        }

        // Navigate and remove all previous routes
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleAddRole() {
    Navigator.pop(context);
    _showAddRoleDialog();
  }

  void _showAddRoleDialog() {
    final allRoles = [
      AppConstants.roleUser,
      AppConstants.roleProvider,
      AppConstants.roleAdmin,
    ];
    final availableToAdd = allRoles.where((role) => !widget.availableRoles.contains(role)).toList();

    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have all available roles!'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddRoleDialog(availableRoles: availableToAdd),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Switch Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the role you want to use:',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...widget.availableRoles.map((role) {
            return RadioListTile<String>(
              title: Text(_getRoleDisplayName(role)),
              subtitle: Text(_getRoleDescription(role)),
              value: role,
              groupValue: _selectedRole,
              onChanged: _isLoading ? null : (value) {
                setState(() => _selectedRole = value);
              },
              activeColor: AppColors.primary,
            );
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isLoading ? null : _handleAddRole,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Add Another Role'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSwitchRole,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Switch'),
        ),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleProvider:
        return 'Service Provider';
      case AppConstants.roleAdmin:
        return 'Admin';
      default:
        return 'User';
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case AppConstants.roleProvider:
        return 'Provide services to customers';
      case AppConstants.roleAdmin:
        return 'Manage platform and users';
      default:
        return 'Book and use services';
    }
  }
}

class AddRoleDialog extends StatefulWidget {
  final List<String> availableRoles;

  const AddRoleDialog({super.key, required this.availableRoles});

  @override
  State<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _selectedRole;

  void _handleAddRole() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    final result = await _authService.addRole(_selectedRole!);

    if (mounted) {
      setState(() => _isLoading = false);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? AppColors.success : AppColors.error,
        ),
      );

      if (result['success']) {
        // Ask if user wants to switch to new role
        _showSwitchConfirmation();
      }
    }
  }

  void _showSwitchConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Role Added!'),
        content: Text('Would you like to switch to ${_getRoleDisplayName(_selectedRole!)} now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await _authService.switchRole(_selectedRole!);
              if (result['success'] && mounted) {
                String route;
                if (_selectedRole == AppConstants.roleAdmin) {
                  route = AppRoutes.adminMain;
                } else if (_selectedRole == AppConstants.roleProvider) {
                  route = AppRoutes.providerMain;
                } else {
                  route = AppRoutes.userMain;
                }
                Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a role to add to your account:',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...widget.availableRoles.map((role) {
            return RadioListTile<String>(
              title: Text(_getRoleDisplayName(role)),
              subtitle: Text(_getRoleDescription(role)),
              value: role,
              groupValue: _selectedRole,
              onChanged: _isLoading ? null : (value) {
                setState(() => _selectedRole = value);
              },
              activeColor: AppColors.primary,
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedRole == null ? null : _handleAddRole,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Add Role'),
        ),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleProvider:
        return 'Service Provider';
      case AppConstants.roleAdmin:
        return 'Admin';
      default:
        return 'User';
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case AppConstants.roleProvider:
        return 'Provide services to customers';
      case AppConstants.roleAdmin:
        return 'Manage platform and users';
      default:
        return 'Book and use services';
    }
  }
}
