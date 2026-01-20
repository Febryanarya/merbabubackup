// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/detail_paket_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/riwayat_booking_screen.dart';
import 'screens/booking/cart_screen.dart';
import 'screens/booking/checkout_screen.dart';
import 'screens/booking/ticket_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'models/paket_pendakian.dart';
import 'models/booking_model.dart';
import 'services/cart_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MerbabuAccessApp());
}

class MerbabuAccessApp extends StatelessWidget {
  const MerbabuAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CartService>(
      create: (_) => CartService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MerbabuAccess',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.detailPaket: (context) {
            final paket = ModalRoute.of(context)!.settings.arguments as PaketPendakian;
            return DetailPaketScreen(paket: paket);
          },
          AppRoutes.bookingForm: (context) {
            final paket = ModalRoute.of(context)!.settings.arguments as PaketPendakian;
            return BookingFormScreen(paket: paket);
          },
          AppRoutes.riwayatBooking: (context) => const RiwayatBookingScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.weather: (context) => const WeatherScreen(),
          AppRoutes.cart: (context) => const CartScreen(),
          AppRoutes.checkout: (context) => const CheckoutScreen(),
          AppRoutes.ticket: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args == null || args is! Booking) {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Data tiket tidak valid')),
              );
            }
            return TicketScreen(booking: args);
          },
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text('Route ${settings.name} tidak ditemukan'),
              ),
            ),
          );
        },
      ),
    );
  }
}