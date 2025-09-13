
// // lib/main.dart - COMPLETE CORRECTED VERSION
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'presentation/viewmodels/auth_viewmodel.dart';
// import 'presentation/viewmodels/dashboard_viewmodel.dart';
// import 'presentation/viewmodels/project_viewmodel.dart';
// import 'presentation/viewmodels/task_viewmodel.dart';
// import 'presentation/viewmodels/user_viewmodel.dart';
// import 'routes/app_routes.dart';
// import 'routes/route_generator.dart';
// import 'core/constants/app_colors.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => DashboardViewModel()),
//         ChangeNotifierProvider(create: (_) => ProjectViewModel()),
//         ChangeNotifierProvider(create: (_) => TaskViewModel()),
//         ChangeNotifierProvider(create: (_) => UserViewModel()),
//       ],
//       child: MaterialApp(
//         title: 'Flowence - Project Manager',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           primaryColor: AppColors.primaryBlue,
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: AppColors.primaryBlue,
//             brightness: Brightness.light,
//           ),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: AppColors.primaryBlue,
//             foregroundColor: Colors.white,
//             elevation: 2,
//             centerTitle: true,
//           ),
//           cardTheme: CardThemeData(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             color: AppColors.surface,
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryBlue,
//               foregroundColor: Colors.white,
//               elevation: 2,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           outlinedButtonTheme: OutlinedButtonThemeData(
//             style: OutlinedButton.styleFrom(
//               foregroundColor: AppColors.primaryBlue,
//               side: const BorderSide(color: AppColors.primaryBlue),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: AppColors.borderLight),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: AppColors.borderLight),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: AppColors.error),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: AppColors.error, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//             fillColor: AppColors.surface,
//             filled: true,
//           ),
//           bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//             backgroundColor: AppColors.surface,
//             selectedItemColor: AppColors.primaryBlue,
//             unselectedItemColor: AppColors.textSecondary,
//             type: BottomNavigationBarType.fixed,
//             elevation: 8,
//           ),
//           floatingActionButtonTheme: const FloatingActionButtonThemeData(
//             backgroundColor: AppColors.primaryBlue,
//             foregroundColor: Colors.white,
//             elevation: 4,
//           ),
//           chipTheme: ChipThemeData(
//             backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//             labelStyle: const TextStyle(color: AppColors.primaryBlue),
//             side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//           dividerTheme: const DividerThemeData(
//             color: AppColors.borderLight,
//             thickness: 1,
//           ),
//           scaffoldBackgroundColor: AppColors.background,
//           useMaterial3: true,
//         ),
//         initialRoute: AppRoutes.splash,
//         onGenerateRoute: RouteGenerator.generateRoute,
//       ),
//     );
//   }
// }


//2



// lib/main.dart - Updated with Time Tracking Provider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/project_viewmodel.dart';
import 'presentation/viewmodels/task_viewmodel.dart';
import 'presentation/viewmodels/user_viewmodel.dart';
import 'presentation/viewmodels/time_tracking_viewmodel.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => TimeTrackingViewModel()),
      ],
      child: MaterialApp(
        title: 'Flowence - Project Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primaryBlue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: AppColors.surface,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            fillColor: AppColors.surface,
            filled: true,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            labelStyle: const TextStyle(color: AppColors.primaryBlue),
            side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.borderLight,
            thickness: 1,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}