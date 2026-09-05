import 'package:flutter/material.dart';
import 'package:maid_rent/config/routes.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/screens/auth/login_screen.dart';
import 'package:maid_rent/screens/auth/register_screen.dart';
import 'package:maid_rent/screens/auth/role_selection_screen.dart';
import 'package:maid_rent/screens/household/browse_maids_screen.dart';
import 'package:maid_rent/screens/household/household_dashboard.dart';
import 'package:maid_rent/screens/household/job_applicants_screen.dart';
import 'package:maid_rent/screens/household/maid_detail_screen.dart';
import 'package:maid_rent/screens/household/my_bookings_screen.dart';
import 'package:maid_rent/screens/household/my_posts_screen.dart';
import 'package:maid_rent/screens/household/post_hourly_job.dart';
import 'package:maid_rent/screens/maid/hourly_job_detail_screen.dart';
import 'package:maid_rent/screens/maid/hourly_jobs_screen.dart';
import 'package:maid_rent/screens/maid/maid_bookings_screen.dart';
import 'package:maid_rent/screens/maid/maid_dashboard.dart';
import 'package:maid_rent/screens/maid/maid_earnings_screen.dart';
import 'package:maid_rent/screens/maid/maid_profile_setup.dart';
import 'package:maid_rent/screens/maid/verification_upload_screen.dart';
import 'package:maid_rent/screens/shared/booking_detail_screen.dart';
import 'package:maid_rent/screens/shared/profile_screen.dart';
import 'package:maid_rent/screens/shared/review_screen.dart';
import 'package:maid_rent/screens/splash/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaidRent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // Auth Routes
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.roleSelection:
            return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

          // Maid Routes
          case AppRoutes.maidDashboard:
            return MaterialPageRoute(builder: (_) => const MaidDashboardScreen());
          case AppRoutes.maidProfileSetup:
            return MaterialPageRoute(builder: (_) => const MaidProfileSetupScreen());
          case AppRoutes.verifyMaid:
            return MaterialPageRoute(builder: (_) => const VerificationUploadScreen());
          case AppRoutes.maidBookings:
            return MaterialPageRoute(builder: (_) => const MaidBookingsScreen());
          case AppRoutes.maidEarnings:
            return MaterialPageRoute(builder: (_) => const MaidEarningsScreen());
          case AppRoutes.hourlyJobs:
            return MaterialPageRoute(builder: (_) => const HourlyJobsScreen());
          case AppRoutes.hourlyJobDetail:
            final post = settings.arguments as HourlyPostModel;
            return MaterialPageRoute(
              builder: (_) => HourlyJobDetailScreen(post: post),
            );

          // Household Routes
          case AppRoutes.householdDashboard:
            return MaterialPageRoute(builder: (_) => const HouseholdDashboardScreen());
          case AppRoutes.browseMaids:
            final initialService = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => BrowseMaidsScreen(initialService: initialService),
            );
          case AppRoutes.maidDetail:
            final maidId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => MaidDetailScreen(maidId: maidId),
            );
          case AppRoutes.myBookings:
            return MaterialPageRoute(builder: (_) => const MyBookingsScreen());
          case AppRoutes.postHourlyJob:
          case '/household/post-job':
            return MaterialPageRoute(builder: (_) => const PostHourlyJobScreen());
          case AppRoutes.myPosts:
            return MaterialPageRoute(builder: (_) => const MyPostsScreen());
          case AppRoutes.jobApplicants:
            final post = settings.arguments as HourlyPostModel;
            return MaterialPageRoute(
              builder: (_) => JobApplicantsScreen(post: post),
            );

          // Shared Routes
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case AppRoutes.bookingDetail:
            final bookingId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => BookingDetailScreen(bookingId: bookingId),
            );
          case AppRoutes.reviewScreen:
            final bookingId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ReviewScreen(bookingId: bookingId),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
