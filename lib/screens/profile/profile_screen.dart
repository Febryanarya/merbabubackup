import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    _currentUser = _auth.currentUser;
    
    if (_currentUser != null) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();
            
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data()!;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        currentUser: _currentUser,
        userData: _userData,
      ),
    );
    
    if (result == true) {
      await _loadUserData();
    }
  }

  Future<void> _verifyEmail() async {
    try {
      await _currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verifikasi telah dikirim'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim verifikasi: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String get _userInitial {
    final name = _userData['fullName'] ?? _currentUser?.displayName;
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    final email = _currentUser?.email;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  String get _userName {
    return _userData['fullName'] ?? 
           _currentUser?.displayName ?? 
           'User Merbabu';
  }

  String get _userEmail {
    return _currentUser?.email ?? 'user@merbabuaccess.com';
  }

  String get _userPhone {
    return _userData['phone'] ?? 'Belum diatur';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ PROFILE HEADER
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(
                                  _userInitial,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  onPressed: _updateProfile,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // User Name
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // User Email with verification badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_currentUser?.emailVerified ?? false)
                              Icon(
                                Icons.verified,
                                color: Colors.amber[300],
                                size: 16,
                              )
                            else
                              GestureDetector(
                                onTap: _verifyEmail,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Verifikasi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✅ PROFILE INFORMATION
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Profil',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildProfileInfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _userEmail,
                              ),
                              const Divider(height: 20),
                              _buildProfileInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                value: _userPhone,
                              ),
                              const Divider(height: 20),
                              _buildProfileInfoRow(
                                icon: Icons.person_outlined,
                                label: 'UID',
                                value: _currentUser?.uid.substring(0, 8) ?? '-',
                                showCopy: true,
                              ),
                              const Divider(height: 20),
                              _buildProfileInfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Bergabung',
                                value: _formatDate(_currentUser?.metadata.creationTime),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ MENU OPTIONS
                        Text(
                          'Pengaturan',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuOption(
                                icon: Icons.edit_outlined,
                                label: 'Ubah Profil',
                                onTap: _updateProfile,
                              ),
                              _buildMenuOption(
                                icon: Icons.lock_outlined,
                                label: 'Keamanan Akun',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Fitur keamanan akan segera hadir'),
                                      backgroundColor: AppTheme.infoColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              _buildMenuOption(
                                icon: Icons.notifications_outlined,
                                label: 'Notifikasi',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Pengaturan notifikasi akan segera hadir'),
                                      backgroundColor: AppTheme.infoColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              _buildMenuOption(
                                icon: Icons.privacy_tip_outlined,
                                label: 'Privasi',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Pengaturan privasi akan segera hadir'),
                                      backgroundColor: AppTheme.infoColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              _buildMenuOption(
                                icon: Icons.help_outline,
                                label: 'Bantuan & Dukungan',
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.weather);
                                },
                              ),
                              _buildMenuOption(
                                icon: Icons.info_outline,
                                label: 'Tentang Aplikasi',
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AboutDialog(
                                      applicationName: 'MerbabuAccess',
                                      applicationVersion: 'v1.0.0',
                                      applicationLegalese:
                                          '© 2024 MerbabuAccess\nYour Gateway to Mount Merbabu',
                                      children: [
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Aplikasi pemesanan paket pendakian Gunung Merbabu yang mudah dan terpercaya.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ✅ LOGOUT BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, size: 20),
                            label: const Text('Keluar Akun'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                              foregroundColor: AppTheme.errorColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ FOOTER
                        Column(
                          children: [
                            Text(
                              'MerbabuAccess v1.0.0',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textDisabled,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Gateway to Mount Merbabu',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textDisabled,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ✅ HELPER: PROFILE INFO ROW
  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showCopy = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (showCopy)
          IconButton(
            icon: Icon(
              Icons.content_copy,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {
              // Copy to clipboard functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('UID disalin ke clipboard'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
      ],
    );
  }

  // ✅ HELPER: MENU OPTION
  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

// ✅ EDIT PROFILE DIALOG
class EditProfileDialog extends StatefulWidget {
  final User? currentUser;
  final Map<String, dynamic> userData;

  const EditProfileDialog({
    super.key,
    required this.currentUser,
    required this.userData,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.userData['fullName'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _firestore
          .collection('users')
          .doc(widget.currentUser!.uid)
          .set({
            'fullName': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Update display name in Firebase Auth
      await widget.currentUser!.updateDisplayName(_fullNameController.text.trim());

      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Profil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}