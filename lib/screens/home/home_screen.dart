// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merbabuaccess_app/screens/booking/riwayat_booking_screen.dart';
import '../../services/paket_service.dart';
import '../../models/paket_pendakian.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart'; // ✅ IMPORT THEME
import '../profile/profile_screen.dart';
import '../weather/weather_screen.dart';
import 'home_content.dart'; // ✅ IMPORT HOME CONTENT

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
        title: const Text('MerbabuAccess'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          // ✅ ICON RIWAYAT BOOKING
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur notifikasi akan segera hadir')),
              );
            },
            tooltip: 'Notifikasi',
          ),
        ],
      ),
      // ✅ DRAWER MENU
      drawer: _buildDrawer(),
      
      // ✅ BODY BERDASARKAN BOTTOM NAV INDEX
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // ✅ BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  // ✅ BUILD DRAWER WIDGET
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _currentUser?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              _currentUser?.email ?? 'user@email.com',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (_currentUser?.displayName?.isNotEmpty == true 
                    ? _currentUser!.displayName![0].toUpperCase() 
                    : _currentUser?.email?.isNotEmpty == true
                        ? _currentUser!.email![0].toUpperCase()
                        : 'U'),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, Colors.green[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.green),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0; // Pindah ke beranda
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.orange),
            title: const Text('Riwayat Booking'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1; // Pindah ke riwayat
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Profil Saya'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2; // Pindah ke profil
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.lightBlue),
            title: const Text('Cuaca Merbabu'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.weather);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur pengaturan akan segera hadir')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar'),
            onTap: _logout,
          ),
          const Divider(),
          // ✅ FOOTER DRAWER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'MerbabuAccess v1.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}