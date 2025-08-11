import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../providers/app_providers.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController();
  String _selectedBatch = 'Class 10';

  final List<String> _batches = ['Class 10', 'Class 11', 'Class 12'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        actions: [
          TextButton(
            onPressed: _saveStudent,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBatch,
                decoration: const InputDecoration(
                  labelText: 'Batch',
                  prefixIcon: Icon(Icons.class_),
                ),
                items: _batches.map((batch) => DropdownMenuItem(
                  value: batch,
                  child: Text(batch),
                )).toList(),
                onChanged: (value) => setState(() => _selectedBatch = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Fee',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Fee is required' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        batch: _selectedBatch,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        joinDate: DateTime.now(),
        monthlyFee: double.parse(_feeController.text),
      );
      
      ref.read(studentsProvider.notifier).addStudent(student);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    super.dispose();
  }
}