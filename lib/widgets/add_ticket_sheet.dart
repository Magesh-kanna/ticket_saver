import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import 'custom_snackbar.dart';

class AddTicketSheet extends ConsumerStatefulWidget {
  const AddTicketSheet({super.key});

  @override
  ConsumerState<AddTicketSheet> createState() => _AddTicketSheetState();
}

class _AddTicketSheetState extends ConsumerState<AddTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _trainNameController = TextEditingController();
  final _fromStationController = TextEditingController();
  final _toStationController = TextEditingController();
  DateTime? _selectedDate;
  String? _pdfPath;
  String? _pdfName;
  bool _isSaving = false;

  @override
  void dispose() {
    _trainNameController.dispose();
    _fromStationController.dispose();
    _toStationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfPath = result.files.single.path;
        _pdfName = result.files.single.name;
      });
    }
  }

  Future<void> _saveTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      CustomSnackBar.showError(context, 'Please select travel date');
      return;
    }
    if (_pdfPath == null) {
      CustomSnackBar.showError(
        context,
        'Please select a Ticket (PDF or Image)',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Copy File to app directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final ticketsDir = Directory(p.join(appDir.path, 'tickets'));
      if (!await ticketsDir.exists()) {
        await ticketsDir.create(recursive: true);
      }

      final ext = p.extension(_pdfPath!);
      final fileName = 'ticket_${DateTime.now().millisecondsSinceEpoch}$ext';
      final newPath = p.join(ticketsDir.path, fileName);
      await File(_pdfPath!).copy(newPath);

      final ticket = Ticket(
        trainName: _trainNameController.text.trim().toUpperCase(),
        fromStation: _fromStationController.text.trim().toUpperCase(),
        toStation: _toStationController.text.trim().toUpperCase(),
        travelDate: _selectedDate!,
        filePath: newPath,
      );

      await ref.read(ticketActionsProvider.notifier).addTicket(ticket);

      if (mounted) {
        Navigator.pop(context);
        CustomSnackBar.showSuccess(context, 'Ticket saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error saving ticket: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Add New Ticket',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _trainNameController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Train Name',
                  prefixIcon: Icon(
                    Icons.train_outlined,
                    color: Color(0xFF2196F3),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter train name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fromStationController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _toStationController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        prefixIcon: Icon(
                          Icons.location_searching_outlined,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select Travel Date'
                            : DateFormat(
                                'EEE, MMM d, yyyy',
                              ).format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey[600]
                              : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _pdfPath == null
                        ? Colors.white
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pdfPath == null
                          ? const Color(0xFFBBDEFB)
                          : const Color(0xFF2196F3),
                      width: _pdfPath == null ? 1 : 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pdfName?.toLowerCase().endsWith('.pdf') == true
                            ? Icons.picture_as_pdf_outlined
                            : Icons.image_outlined,
                        color: _pdfPath == null
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pdfName ?? 'Upload Ticket (PDF or Image)',
                          style: TextStyle(
                            color: _pdfPath == null
                                ? Colors.grey[600]
                                : const Color(0xFF1565C0),
                            fontSize: 16,
                            fontWeight: _pdfPath == null
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_pdfPath != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SAVE TICKET',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
