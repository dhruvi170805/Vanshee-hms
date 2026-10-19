import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/room_model.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final ApiService _api = ApiService();
  List<HmsRoom> _rooms = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final raw = await _api.getRooms(search: _searchQuery, status: _selectedStatus);
      if (!mounted) return;
      setState(() {
        _rooms = raw.map((e) => HmsRoom.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rooms: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  int get _totalBeds => _rooms.fold(0, (sum, r) => sum + r.totalBeds);
  int get _occupiedBeds => _rooms.fold(0, (sum, r) => sum + r.occupiedBeds);
  int get _availableBeds => _totalBeds - _occupiedBeds;

  void _showRoomDialog([HmsRoom? room]) {
    final isEdit = room != null;
    final numCtrl = TextEditingController(text: room?.roomNumber ?? '');
    final wardCtrl = TextEditingController(text: room?.wardName ?? '');
    final bedsCtrl = TextEditingController(text: room != null ? room.totalBeds.toString() : '4');
    final occCtrl = TextEditingController(text: room != null ? room.occupiedBeds.toString() : '0');
    final floorCtrl = TextEditingController(text: room != null ? room.floorNumber.toString() : '1');
    final chargeCtrl = TextEditingController(text: room != null ? room.dailyCharge.toStringAsFixed(0) : '600');
    String roomType = room?.roomType ?? 'General';
    String status = room?.status ?? 'Available';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Room / Bed Details' : 'Add New Room / Ward Unit',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: numCtrl,
                    decoration: InputDecoration(
                      labelText: 'Room / Unit Number * (e.g. R-105, ICU-02)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: wardCtrl,
                    decoration: InputDecoration(
                      labelText: 'Ward Name * (e.g. Ayurvedic IPD Ward, Rehab Ward)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: roomType,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Room Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['General', 'Semi-Private', 'Private', 'ICU', 'Deluxe']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => roomType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: floorCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Floor No',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: chargeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Daily Rate (₹)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bedsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Total Beds',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: occCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Occupied Beds',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Current Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Available', 'Full', 'Maintenance']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => status = val);
                    },
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
                if (numCtrl.text.trim().isEmpty || wardCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room Number and Ward Name are required')),
                  );
                  return;
                }

                final payload = {
                  'room_number': numCtrl.text.trim(),
                  'ward_name': wardCtrl.text.trim(),
                  'room_type': roomType,
                  'floor_number': int.tryParse(floorCtrl.text.trim()) ?? 1,
                  'daily_charge': double.tryParse(chargeCtrl.text.trim()) ?? 0.0,
                  'total_beds': int.tryParse(bedsCtrl.text.trim()) ?? 1,
                  'occupied_beds': int.tryParse(occCtrl.text.trim()) ?? 0,
                  'status': status,
                };

                try {
                  if (isEdit) {
                    await _api.updateRoom(room.id, payload);
                  } else {
                    await _api.createRoom(payload);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadRooms();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Room updated' : 'Room created'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Create Room', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRoom(HmsRoom room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Room'),
        content: Text('Remove "${room.roomNumber}" from ward directory?'),
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
        await _api.deleteRoom(room.id);
        _loadRooms();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room removed'), backgroundColor: AppColors.warning),
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
                    Text('Patient Rooms & Wards Master',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Track IPD bed allocation, general and private wards, floor plans, and daily stay charges.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showRoomDialog(),
                icon: const Icon(Icons.meeting_room_rounded, size: 18),
                label: const Text('Add Room'),
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
          // KPI Metric cards
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
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.hotel_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Beds', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('$_totalBeds', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Beds', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('$_availableBeds', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
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
                        child: const Icon(Icons.person_pin_circle_outlined, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Occupied Beds', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('$_occupiedBeds', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent)),
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
                      hintText: 'Search room no, ward, type...',
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _loadRooms();
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox(),
                  items: ['all', 'Available', 'Full', 'Maintenance'].map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s == 'all' ? 'All Statuses' : s),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                      _loadRooms();
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
                    DataColumn(label: Text('Room No', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Ward Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Room Type', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Floor', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Total Beds', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Occupied', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Available', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Daily Charge', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _rooms.map((r) {
                    final isAvail = r.status == 'Available';
                    final isMaint = r.status == 'Maintenance';

                    return DataRow(cells: [
                      DataCell(Text(r.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(r.wardName)),
                      DataCell(Text(r.roomType)),
                      DataCell(Text('Floor ${r.floorNumber}')),
                      DataCell(Text('${r.totalBeds}')),
                      DataCell(Text('${r.occupiedBeds}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))),
                      DataCell(Text('${r.availableBeds}', style: TextStyle(color: isAvail ? AppColors.success : AppColors.danger, fontWeight: FontWeight.bold))),
                      DataCell(Text('₹${r.dailyCharge.toStringAsFixed(0)}/day')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvail
                              ? AppColors.successLight
                              : isMaint
                                  ? AppColors.warningLight
                                  : AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.status,
                          style: TextStyle(
                            color: isAvail
                                ? AppColors.success
                                : isMaint
                                    ? AppColors.warning
                                    : AppColors.danger,
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
                            onPressed: () => _showRoomDialog(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => _deleteRoom(r),
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
