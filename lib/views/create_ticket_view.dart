import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../models/ticket.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/priority_badge.dart';

class CreateTicketView extends StatefulWidget {
  final ValueChanged<String> onTicketCreated;
  final VoidCallback onCancel;

  const CreateTicketView({
    super.key,
    required this.onTicketCreated,
    required this.onCancel,
  });

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _siteLocationController = TextEditingController();
  final _assetDetailsController = TextEditingController();

  String? _selectedDepartmentId;
  String _selectedCategory = 'Infrastructure';
  String _selectedSubcategory = 'Server & Storage';
  ImpactLevel _selectedImpact = ImpactLevel.medium;
  UrgencyLevel _selectedUrgency = UrgencyLevel.medium;

  final Map<String, List<String>> _categoryMap = {
    'Infrastructure': ['Server & Storage', 'Database Services', 'Cloud Hosting', 'Backups'],
    'Networking': ['VPN & Remote Access', 'Firewall Rules', 'LAN/Wi-Fi', 'DNS & Routing'],
    'Enterprise Applications': ['ERP & Accounting', 'CRM System', 'Payroll & HRIS', 'Email & Calendar'],
    'Facilities': ['Climate Control & HVAC', 'Access Badges & Physical Security', 'Electrical Power'],
    'Identity & Access': ['SSO & MFA', 'Account Provisioning', 'Privileged Access'],
  };

  @override
  void initState() {
    super.initState();
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    if (ticketProvider.departments.isNotEmpty) {
      _selectedDepartmentId = ticketProvider.departments.first.id;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _siteLocationController.dispose();
    _assetDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final calculatedPriority = PriorityMatrix.calculate(_selectedImpact, _selectedUrgency);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.add_task_rounded, color: AppTheme.primary, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Register New Enterprise Ticket',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: widget.onCancel,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Submitting on behalf of: ${auth.currentUser.name} (${auth.currentUser.role.displayName})',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const Divider(height: 28),

                      // Department Selection
                      const Text('Target Department*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartmentId,
                        decoration: const InputDecoration(hintText: 'Select Department'),
                        items: ticketProvider.departments.map((d) {
                          return DropdownMenuItem(value: d.id, child: Text('${d.name} (${d.code})'));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDepartmentId = val),
                        validator: (val) => val == null ? 'Please select a department' : null,
                      ),
                      const SizedBox(height: 18),

                      // Category and Subcategory
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Service Category*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  items: _categoryMap.keys.map((cat) {
                                    return DropdownMenuItem(value: cat, child: Text(cat));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedCategory = val;
                                        _selectedSubcategory = _categoryMap[val]!.first;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Subcategory*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _selectedSubcategory,
                                  items: (_categoryMap[_selectedCategory] ?? []).map((sub) {
                                    return DropdownMenuItem(value: sub, child: Text(sub));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedSubcategory = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Priority Matrix (Impact x Urgency)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.tune_rounded, size: 16, color: AppTheme.primary),
                                    SizedBox(width: 6),
                                    Text(
                                      'Dynamic Impact & Urgency Matrix (FR-006)',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Calculated Priority: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    PriorityBadge(priority: calculatedPriority),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Business Impact:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      const SizedBox(height: 6),
                                      SegmentedButton<ImpactLevel>(
                                        segments: const [
                                          ButtonSegment(value: ImpactLevel.low, label: Text('Low')),
                                          ButtonSegment(value: ImpactLevel.medium, label: Text('Medium')),
                                          ButtonSegment(value: ImpactLevel.high, label: Text('High')),
                                        ],
                                        selected: {_selectedImpact},
                                        onSelectionChanged: (val) => setState(() => _selectedImpact = val.first),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Service Urgency:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      const SizedBox(height: 6),
                                      SegmentedButton<UrgencyLevel>(
                                        segments: const [
                                          ButtonSegment(value: UrgencyLevel.low, label: Text('Low')),
                                          ButtonSegment(value: UrgencyLevel.medium, label: Text('Medium')),
                                          ButtonSegment(value: UrgencyLevel.high, label: Text('High')),
                                        ],
                                        selected: {_selectedUrgency},
                                        onSelectionChanged: (val) => setState(() => _selectedUrgency = val.first),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Subject Line
                      const Text('Subject / Title*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Database cluster heartbeat timeout on Node 2',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a ticket subject' : null,
                      ),
                      const SizedBox(height: 18),

                      // Description
                      const Text('Detailed Description*', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe the symptom, steps to reproduce, affected users or transaction impact...',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please describe the issue' : null,
                      ),
                      const SizedBox(height: 18),

                      // Optional Location and Asset Details
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Site / Physical Location (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _siteLocationController,
                                  decoration: const InputDecoration(hintText: 'e.g. Bldg B - Server Room 2'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Related Asset / Configuration Item', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _assetDetailsController,
                                  decoration: const InputDecoration(hintText: 'e.g. SRV-DB-02, AP-WIFI-04'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Form Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: widget.onCancel,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final newTicket = await ticketProvider.createTicket(
                                subject: _subjectController.text.trim(),
                                description: _descriptionController.text.trim(),
                                category: _selectedCategory,
                                subcategory: _selectedSubcategory,
                                impact: _selectedImpact,
                                urgency: _selectedUrgency,
                                departmentId: _selectedDepartmentId ?? ticketProvider.departments.first.id,
                                requester: auth.currentUser,
                                siteLocation: _siteLocationController.text.trim().isNotEmpty
                                    ? _siteLocationController.text.trim()
                                    : null,
                                assetDetails: _assetDetailsController.text.trim().isNotEmpty
                                    ? _assetDetailsController.text.trim()
                                    : null,
                              );
                              widget.onTicketCreated(newTicket.id);
                            },
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Register Ticket'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
