import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merbabuaccess_app/screens/booking/riwayat_booking_screen.dart';
import '../../services/paket_service.dart';
import '../../models/paket_pendakian.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../profile/profile_screen.dart';
import '../weather/weather_screen.dart';
import 'home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PaketPendakian>> _paketFuture;
  final PaketService _paketService = PaketService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  
  // ✅ VARIABEL UNTUK BOTTOM NAVIGATION
  int _selectedIndex = 0;
  
  // ✅ LIST SCREEN UNTUK BOTTOM NAV
  final List<Widget> _widgetOptions = [
    const HomeContent(), // Home Content
    const RiwayatBookingScreen(), // Riwayat Screen
    const ProfileScreen(), // Profile Screen
  ];

  @override
  void initState() {
    super.initState();
    _paketFuture = _paketService.fetchPaketPendakian();
    _currentUser = _auth.currentUser;
  }

  Future<void> _logout() async {
    showDialog(
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
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ HANDLE BOTTOM NAV TAP
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.terrain, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'MerbabuAccess',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        actions: [
          // ✅ ICON CART
          IconButton(
            icon: Badge(
              label: Text('3'), // TODO: Get from cart provider
              backgroundColor: Colors.red,
              textColor: Colors.white,
              smallSize: 18,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
            tooltip: 'Keranjang',
          ),
          // ✅ NOTIFICATION ICON
          IconButton(
            icon: Badge(
              label: Text('2'), // TODO: Get from notification count
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              smallSize: 18,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fitur notifikasi akan segera hadir'),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            tooltip: 'Notifikasi',
          ),
        ],
      ),
      // ✅ DRAWER MENU (POLISHED)
      drawer: _buildDrawer(),
      
      // ✅ BODY BERDASARKAN BOTTOM NAV INDEX
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // ✅ FLOATING ACTION BUTTON FOR WEATHER
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.weather);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.cloud, size: 28),
        tooltip: 'Cuaca Merbabu',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // ✅ ENHANCED BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
            iconSize: 24,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  // ✅ ENHANCED DRAWER WIDGET
  Widget _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 16,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ✅ ENHANCED USER HEADER
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.terrain,
                    size: 120,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          (_currentUser?.displayName?.isNotEmpty == true 
                              ? _currentUser!.displayName![0].toUpperCase() 
                              : _currentUser?.email?.isNotEmpty == true
                                  ? _currentUser!.email![0].toUpperCase()
                                  : 'U'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.displayName ?? 'User Merbabu',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentUser?.email ?? 'user@merbabuaccess.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ✅ MENU ITEMS WITH BETTER STYLING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_filled,
                  label: 'Beranda',
                  isActive: _selectedIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'Riwayat Booking',
                  isActive: _selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil Saya',
                  isActive: _selectedIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.cloud_outlined,
                  activeIcon: Icons.cloud,
                  label: 'Cuaca Merbabu',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.weather);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Keranjang Saya',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.cart);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Pengaturan',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Fitur pengaturan akan segera hadir'),
                        backgroundColor: AppTheme.infoColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 20, thickness: 1),
          
          // ✅ LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _logout,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.red.withOpacity(0.05),
            ),
          ),
          
          // ✅ FOOTER DRAWER (ENHANCED)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Divider(height: 30),
                Text(
                  'MerbabuAccess v1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Gateway to Mount Merbabu',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER: DRAWER ITEM BUILDER
  Widget _buildDrawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppTheme.primaryColor : Colors.grey[800],
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: isActive ? AppTheme.primaryColor.withOpacity(0.1) : null,
    );
  }
}