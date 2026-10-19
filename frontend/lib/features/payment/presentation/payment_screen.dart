import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/payment_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _api = ApiService();
  List<HmsPayment> _payments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  double _totalCollected = 0.0;
  double _todayCollected = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final raw = await _api.getPayments(search: _searchQuery, status: _selectedStatus);
      if (!mounted) return;
      final list = raw.map((e) => HmsPayment.fromJson(e)).toList();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      double total = 0.0;
      double today = 0.0;
      for (var p in list) {
        if (p.status == 'Paid') {
          total += p.amount;
          if (p.paymentDate.startsWith(todayStr)) {
            today += p.amount;
          }
        }
      }

      setState(() {
        _payments = list;
        _totalCollected = total;
        _todayCollected = today;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payments: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showPaymentDialog([HmsPayment? pay]) {
    final isEdit = pay != null;
    final patientNameCtrl = TextEditingController(text: pay?.patientName ?? '');
    final amountCtrl = TextEditingController(text: pay != null ? pay.amount.toStringAsFixed(0) : '500');
    final dateCtrl = TextEditingController(text: pay?.paymentDate ?? DateTime.now().toIso8601String().split('T')[0]);
    final notesCtrl = TextEditingController(text: pay?.notes ?? '');
    String mode = pay?.paymentMode ?? 'Cash';
    String paymentFor = pay?.paymentFor ?? 'Doctor Consultation';
    String status = pay?.status ?? 'Paid';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Payment Receipt' : 'Record Patient Billing Payment',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: patientNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Patient Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount (₹) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dateCtrl,
                          decoration: InputDecoration(
                            labelText: 'Date (YYYY-MM-DD)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: paymentFor,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Payment For',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      'Doctor Consultation',
                      'OPD Procedure / Panchakarma',
                      'Physiotherapy Session',
                      'Pharmacy & Medicines',
                      'Diagnostic Lab Tests',
                      'IPD Room Stay & Nursing'
                    ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => paymentFor = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: mode,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            labelText: 'Payment Mode',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Cash', 'UPI / QR', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Insurance / TPA']
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => mode = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: status,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Paid', 'Pending', 'Refunded']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => status = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Transaction Reference / Notes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (patientNameCtrl.text.trim().isEmpty || amountCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient name and amount are compulsory')),
                  );
                  return;
                }

                final payload = {
                  'patient_name': patientNameCtrl.text.trim(),
                  'amount': double.tryParse(amountCtrl.text.trim()) ?? 0.0,
                  'payment_date': dateCtrl.text.trim(),
                  'payment_for': paymentFor,
                  'payment_mode': mode,
                  'status': status,
                  'notes': notesCtrl.text.trim(),
                };

                try {
                  if (isEdit) {
                    await _api.updatePayment(pay.id, payload);
                  } else {
                    await _api.createPayment(payload);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadPayments();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Payment receipt updated' : 'Payment recorded successfully'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Record Payment', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePayment(HmsPayment pay) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Payment Record'),
        content: Text('Delete receipt "${pay.receiptNo}" for ₹${pay.amount.toStringAsFixed(0)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deletePayment(pay.id);
        _loadPayments();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment record deleted'), backgroundColor: AppColors.warning),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payments & Invoicing Master',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Manage patient billing, consultation fees, procedure payments, lab receipts, and daily collection totals.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(),
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: const Text('Record Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Financial Metric Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Collected', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('₹${_totalCollected.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.today_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Collection", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('₹${_todayCollected.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.receipt_long_rounded, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Receipts', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('${_payments.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                      hintText: 'Search receipt, patient, mode...',
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _loadPayments();
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox(),
                  items: ['all', 'Paid', 'Pending', 'Refunded'].map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s == 'all' ? 'All Statuses' : s),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                      _loadPayments();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Receipt No', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Payment For', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _payments.map((p) {
                    final isPaid = p.status == 'Paid';

                    return DataRow(cells: [
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(p.receiptNo, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
                      )),
                      DataCell(Text(p.patientName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(p.paymentFor)),
                      DataCell(Text('₹${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
                      DataCell(Text(p.paymentMode)),
                      DataCell(Text(p.paymentDate)),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid ? AppColors.successLight : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.status,
                          style: TextStyle(
                            color: isPaid ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () => _showPaymentDialog(p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => _deletePayment(p),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
