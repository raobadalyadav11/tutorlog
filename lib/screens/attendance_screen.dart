import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/attendance.dart';
import '../providers/app_providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedBatch = 'All Batches';
  final List<String> batches = ['All Batches', 'Class 10', 'Class 11', 'Class 12'];
  Map<String, bool> attendanceMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedBatch,
                  items: batches.map((batch) => DropdownMenuItem(
                    value: batch,
                    child: Text(batch),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedBatch = value!),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final students = ref.watch(studentsProvider);
              final attendance = ref.watch(attendanceProvider);
              
              final filteredStudents = selectedBatch == 'All Batches' 
                  ? students 
                  : students.where((s) => s.batch == selectedBatch).toList();
              
              final todayAttendance = attendance.where((a) => 
                a.date.year == selectedDate.year &&
                a.date.month == selectedDate.month &&
                a.date.day == selectedDate.day
              ).toList();
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  final existingAttendance = todayAttendance.firstWhere(
                    (a) => a.studentId == student.id,
                    orElse: () => Attendance(
                      id: '',
                      studentId: student.id,
                      date: selectedDate,
                      isPresent: false,
                    ),
                  );
                  
                  final isPresent = attendanceMap[student.id] ?? existingAttendance.isPresent;
                  final isMarked = attendanceMap.containsKey(student.id) || existingAttendance.id.isNotEmpty;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text('Batch: ${student.batch}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color: isPresent ? AppTheme.secondaryColor : Colors.grey,
                            ),
                            onPressed: () => _markAttendance(student.id, true),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: !isPresent && isMarked ? AppTheme.errorColor : Colors.grey,
                            ),
                            onPressed: () => _markAttendance(student.id, false),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAttendance,
        label: const Text('Save Attendance'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  void _markAttendance(String studentId, bool present) {
    setState(() {
      attendanceMap[studentId] = present;
    });
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void _saveAttendance() {
    final attendanceNotifier = ref.read(attendanceProvider.notifier);
    
    attendanceMap.forEach((studentId, isPresent) {
      final attendance = Attendance(
        id: '${studentId}_${selectedDate.millisecondsSinceEpoch}',
        studentId: studentId,
        date: selectedDate,
        isPresent: isPresent,
      );
      attendanceNotifier.markAttendance(attendance);
    });
    
    setState(() {
      attendanceMap.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully')),
    );
  }
}