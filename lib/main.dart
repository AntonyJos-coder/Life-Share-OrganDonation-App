import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'providers/organ_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/donor_registration_page.dart';
import 'pages/recipient_registration_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import 'package:flutter/services.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'widgets/authentication_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable image caching
  PaintingBinding.instance.imageCache.maximumSize = 100;
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBEfypRIfp7MPZSWTRyJ-K0K-gvxbG9tcs",
        authDomain: "org-dont-app.firebaseapp.com",
        projectId: "org-dont-app",
        storageBucket: "org-dont-app.firebasestorage.app",
        messagingSenderId: "1079216154076",
        appId: "1:1079216154076:web:d04fc0f5a8f4d46fe05b19",
        measurementId: "G-JNK5YD1SB0",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Optimize error reporting
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  // Set up Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrganProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const OrganDonationApp(),
    ),
  );
}

class OrganDonationApp extends StatelessWidget {
  const OrganDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Share - Organ Donation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935), // Medical Red
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFF1B5E20), // Dark Green for life
          tertiary: const Color(0xFFFFCDD2), // Light Red
          error: const Color(0xFFB71C1C),
          background: Colors.white,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.grey[50], // Light grey for cards
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFE53935),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE53935).withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
          ),
          prefixIconColor: Color(0xFFE53935),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE53935),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE53935),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFF81C784),
          tertiary: const Color(0xFFFFCDD2).withOpacity(0.1),
          error: const Color(0xFFEF5350),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.grey[800], // Dark grey for cards in dark mode
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE53935).withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
          ),
        ),
      ),
      themeMode: context.watch<ThemeProvider>().themeMode,
      builder: (context, child) {
        return Container( // Added background gradient
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.background,
                Colors.grey[100]!,
              ],
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: const BouncingScrollPhysics(),
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: child!,
            ),
          ),
        );
      },
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasData) {
          return const HomePage();
        }
        
        return const LoginPage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = 'Guest User';
  bool _notificationsEnabled = true;

  int _selectedIndex = 0;
  
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const SearchPage(),
      const DonorRegistrationPage(),
      const RecipientRegistrationPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Share - Organ Donation'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Consumer<OrganProvider>(
          builder: (context, provider, child) {
            final authService = context.read<AuthService>();
            final userEmail = authService.currentUser?.email ?? 'Guest User';
            
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 35, color: Color(0xFFE53935)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userEmail,  // This will show 'Guest User' when not logged in
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFFE53935)),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => ProfilePage(
                        onUsernameChanged: (newName) {
                          setState(() {
                            _username = newName;
                          });
                        },
                      ),
                    );
                  },
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.dark_mode, color: Color(0xFFE53935)),
                      title: const Text('Dark Mode'),
                      trailing: Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) => themeProvider.toggleTheme(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Color(0xFFE53935)),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help, color: Color(0xFFE53935)),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Help & Support'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Contact Us:', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Email: support@lifeshare.com'),
                              Text('Phone: +1-800-LIFESHARE'),
                              SizedBox(height: 16),
                              Text('FAQs:', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Q: How do I register as a donor?'),
                              Text('A: Click on the "Donate" tab and fill out the registration form.'),
                              SizedBox(height: 8),
                              Text('Q: How do I request an organ?'),
                              Text('A: Use the "Request" tab to submit your requirements.'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Color(0xFFE53935)),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Privacy Policy'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Data Collection:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('We collect only essential medical and contact information necessary for organ donation matching.'),
                              SizedBox(height: 16),
                              Text('Data Usage:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Your information is used solely for matching donors with recipients and is not shared with third parties.'),
                              SizedBox(height: 16),
                              Text('Security:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('We implement industry-standard security measures to protect your personal information.'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFFE53935)),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About Life Share'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Version: 1.0.0'),
                              SizedBox(height: 16),
                              Text('Life Share is a platform dedicated to connecting organ donors with recipients, making the process of organ donation more accessible and efficient.'),
                              SizedBox(height: 16),
                              Text('Our mission is to save lives by facilitating organ donation matching and raising awareness about the importance of organ donation.'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Request',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

