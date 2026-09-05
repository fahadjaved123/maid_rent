import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/app.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/providers/household_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MaidRentApp());
}

class MaidRentApp extends StatelessWidget {
  const MaidRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MaidProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HouseholdProvider(),
        ),
      ],
      child: const App(),
    );
  }
}
