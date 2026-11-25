import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/ticket_provider.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_header.dart';
import 'views/dashboard_view.dart';
import 'views/ticket_list_view.dart';
import 'views/ticket_detail_view.dart';
import 'views/create_ticket_view.dart';
import 'views/reports_view.dart';
import 'views/admin_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
      ],
      child: const EnterpriseTicketApp(),
    ),
  );
}

class EnterpriseTicketApp extends StatelessWidget {
  const EnterpriseTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Ticket Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;
  bool _isCreatingTicket = false;
  bool _isViewingTicketDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketProvider>(context, listen: false).loadInitialData();
      Provider.of<AppSettingsProvider>(context, listen: false).checkConnection();
    });
  }

  String get _currentTitle {
    if (_isCreatingTicket) return 'New Ticket Registration';
    if (_isViewingTicketDetail) return 'Ticket Overview & Investigation';
    switch (_navIndex) {
      case 0:
        return 'Enterprise Operations Dashboard';
      case 1:
        return 'Ticket Management & Queues';
      case 2:
        return 'My Assigned Queue';
      case 3:
        return 'Team Support Queue';
      case 4:
        return 'SLA At-Risk & Escalations';
      case 5:
        return 'SLA & Governance Analytics';
      case 6:
        return 'System Administration';
      default:
        return 'Enterprise Ticket System';
    }
  }

  void _onNavigate(int index) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _navIndex = index;
      _isCreatingTicket = false;
      _isViewingTicketDetail = false;
    });

    if (index == 2) {
      ticketProvider.setActiveTab('MY_QUEUE', auth.currentUser);
    } else if (index == 3) {
      ticketProvider.setActiveTab('TEAM_QUEUE', auth.currentUser);
    } else if (index == 4) {
      ticketProvider.setActiveTab('AT_RISK', auth.currentUser);
    } else if (index == 1) {
      ticketProvider.setActiveTab('ALL', auth.currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);

    Widget body;
    if (_isCreatingTicket) {
      body = CreateTicketView(
        onTicketCreated: (id) async {
          await ticketProvider.selectTicket(id);
          setState(() {
            _isCreatingTicket = false;
            _isViewingTicketDetail = true;
          });
        },
        onCancel: () => setState(() => _isCreatingTicket = false),
      );
    } else if (_isViewingTicketDetail) {
      body = TicketDetailView(
        onBack: () => setState(() => _isViewingTicketDetail = false),
      );
    } else {
      switch (_navIndex) {
        case 0:
          body = DashboardView(
            onTicketSelected: (id) async {
              await ticketProvider.selectTicket(id);
              setState(() => _isViewingTicketDetail = true);
            },
            onViewAllTickets: () => setState(() => _navIndex = 1),
          );
          break;
        case 1:
        case 2:
        case 3:
        case 4:
          body = TicketListView(
            onTicketSelected: (id) async {
              await ticketProvider.selectTicket(id);
              setState(() => _isViewingTicketDetail = true);
            },
          );
          break;
        case 5:
          body = const ReportsView();
          break;
        case 6:
          body = const AdminView();
          break;
        default:
          body = const Center(child: Text('View not found'));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (!isDesktop) {
          // Mobile / Tablet Compact Layout with Drawer
          return Scaffold(
            appBar: AppBar(
              title: Text(_currentTitle, style: const TextStyle(fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'New Ticket',
                  onPressed: () {
                    setState(() {
                      _isCreatingTicket = true;
                      _isViewingTicketDetail = false;
                    });
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: AppSidebar(
                selectedIndex: _navIndex,
                onDestinationSelected: (idx) {
                  Navigator.pop(context);
                  _onNavigate(idx);
                },
              ),
            ),
            body: ticketProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : body,
          );
        }

        // High-Resolution Web Desktop Screen Layout (Responsive 1920x1080 / 1440x900)
        return Scaffold(
          body: Row(
            children: [
              // Left Fixed Enterprise Sidebar
              AppSidebar(
                selectedIndex: _navIndex,
                onDestinationSelected: _onNavigate,
              ),

              // Main Desktop Canvas
              Expanded(
                child: Column(
                  children: [
                    // Top Enterprise Navigation & Status Header
                    AppHeader(
                      title: _currentTitle,
                      onNewTicketPressed: () {
                        setState(() {
                          _isCreatingTicket = true;
                          _isViewingTicketDetail = false;
                        });
                      },
                    ),

                    // Active Viewport
                    Expanded(
                      child: ticketProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
