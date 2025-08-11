import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class ExportService {
  static Future<void> exportAttendanceToPDF({
    required List<Student> students,
    required List<Attendance> attendance,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Attendance Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: 'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Student Name', 'Batch', 'Present Days', 'Total Days', 'Percentage'],
              data: students.map((student) {
                final studentAttendance = attendance.where((a) => a.studentId == student.id).toList();
                final presentDays = studentAttendance.where((a) => a.isPresent).length;
                final totalDays = studentAttendance.length;
                final percentage = totalDays > 0 ? (presentDays / totalDays * 100).toStringAsFixed(1) : '0.0';
                
                return [
                  student.name,
                  student.batch,
                  presentDays.toString(),
                  totalDays.toString(),
                  '$percentage%',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(file.path)], text: 'Attendance Report');
  }

  static Future<void> exportAttendanceToExcel({
    required List<Student> students,
    required List<Attendance> attendance,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance Report'];
    
    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = 'Student Name';
    sheet.cell(CellIndex.indexByString('B1')).value = 'Batch';
    sheet.cell(CellIndex.indexByString('C1')).value = 'Date';
    sheet.cell(CellIndex.indexByString('D1')).value = 'Status';
    sheet.cell(CellIndex.indexByString('E1')).value = 'Note';

    int row = 2;
    final dateFormat = DateFormat('dd/MM/yyyy');

    for (final student in students) {
      final studentAttendance = attendance.where((a) => a.studentId == student.id).toList();
      studentAttendance.sort((a, b) => a.date.compareTo(b.date));

      for (final att in studentAttendance) {
        sheet.cell(CellIndex.indexByString('A$row')).value = student.name;
        sheet.cell(CellIndex.indexByString('B$row')).value = student.batch;
        sheet.cell(CellIndex.indexByString('C$row')).value = dateFormat.format(att.date);
        sheet.cell(CellIndex.indexByString('D$row')).value = att.isPresent ? 'Present' : 'Absent';
        sheet.cell(CellIndex.indexByString('E$row')).value = att.note ?? '';
        row++;
      }
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Attendance Report');
  }

  static Future<void> exportPaymentsToPDF({
    required List<Student> students,
    required List<Payment> payments,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Payment Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: 'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Student Name', 'Amount', 'Date', 'Mode', 'Status'],
              data: payments.map((payment) {
                final student = students.firstWhere((s) => s.id == payment.studentId);
                return [
                  student.name,
                  '₹${payment.amount.toInt()}',
                  dateFormat.format(payment.date),
                  payment.mode.toUpperCase(),
                  payment.status,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Collected: ₹${payments.where((p) => p.status == 'Paid').fold(0.0, (sum, p) => sum + p.amount).toInt()}'),
            pw.Text('Total Pending: ₹${payments.where((p) => p.status == 'Pending').fold(0.0, (sum, p) => sum + p.amount).toInt()}'),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/payment_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(file.path)], text: 'Payment Report');
  }

  static Future<void> exportPaymentsToExcel({
    required List<Student> students,
    required List<Payment> payments,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Payment Report'];
    
    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = 'Student Name';
    sheet.cell(CellIndex.indexByString('B1')).value = 'Batch';
    sheet.cell(CellIndex.indexByString('C1')).value = 'Amount';
    sheet.cell(CellIndex.indexByString('D1')).value = 'Date';
    sheet.cell(CellIndex.indexByString('E1')).value = 'Mode';
    sheet.cell(CellIndex.indexByString('F1')).value = 'Status';
    sheet.cell(CellIndex.indexByString('G1')).value = 'Note';

    int row = 2;
    final dateFormat = DateFormat('dd/MM/yyyy');

    for (final payment in payments) {
      final student = students.firstWhere((s) => s.id == payment.studentId);
      sheet.cell(CellIndex.indexByString('A$row')).value = student.name;
      sheet.cell(CellIndex.indexByString('B$row')).value = student.batch;
      sheet.cell(CellIndex.indexByString('C$row')).value = payment.amount;
      sheet.cell(CellIndex.indexByString('D$row')).value = dateFormat.format(payment.date);
      sheet.cell(CellIndex.indexByString('E$row')).value = payment.mode.toUpperCase();
      sheet.cell(CellIndex.indexByString('F$row')).value = payment.status;
      sheet.cell(CellIndex.indexByString('G$row')).value = payment.note ?? '';
      row++;
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/payment_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Payment Report');
  }
}