import 'package:flutter/material.dart';
import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../logger.dart';
import '../providers/budget_provider.dart';
import '../providers/receipt_provider.dart';

class SummaryPage extends StatefulWidget {
  static const String id = 'summary_page';

  const SummaryPage({super.key});

  @override
  SummaryPageState createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  String _currencySymbolToDisplay = ' ';

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      final receiptProvider = Provider.of<ReceiptProvider>(context, listen: false);

      budgetProvider.loadUserBudgets();
      receiptProvider.fetchAllReceipts();
      setState(() {
        _currencySymbolToDisplay = receiptProvider.currencySymbolToDisplay!;
      });

      receiptProvider.groupReceiptsByCategoryOneMonth(_month, _year);
      receiptProvider.calculateTotalSpending(receiptProvider.groupedReceiptsByCategoryOneMonth!);
    });
  }

  void _loadDataForSelectedDate() {
    final receiptProvider = Provider.of<ReceiptProvider>(context, listen: false);
    logger.i("Loading data for Month: $_month, Year: $_year");

    receiptProvider.groupReceiptsByCategoryOneMonth(_month, _year);
    receiptProvider.calculateTotalSpending(receiptProvider.groupedReceiptsByCategoryOneMonth!);
  }

  void _showMonthYearPicker() {
    showMonthPicker(
      context,
      onSelected: (month, year) {
        setState(() {
          _month = month;
          _year = year;
        });
        _loadDataForSelectedDate();
      },
      initialSelectedMonth: _month,
      initialSelectedYear: _year,
      selectButtonText: 'OK',
      cancelButtonText: 'CANCEL',
      highlightColor: purple60,
    );
  }

  Color getColor(double ratio) {
    if (ratio < 0.75) return Colors.green;
    if (ratio < 1.0) return const Color(0xFFF0C808);
    return Colors.red;
  }

  Future<void> _generateReport(BuildContext context) async {
    final receiptProvider = Provider.of<ReceiptProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    final expenses = receiptProvider.groupedReceiptsByCategoryOneMonth;
    final totalSpending = receiptProvider.totalSpending;
    final budgets = budgetProvider.budgets;

    if (expenses == null || budgets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to generate report')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Generating Report...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your spending data...'),
          ],
        ),
      ),
    );

    try {
      final report = await _analyzeData(budgets, expenses, totalSpending);
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Spending Report for ${months[_month - 1]} $_year'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(report['summary'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Key Insights:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(report['insights'] as List<String>).map((i) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $i'),
                )),
                const SizedBox(height: 16),
                const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(report['recommendations'] as List<String>).map((r) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $r'),
                )),
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
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> _analyzeData(
      List<Map<String, dynamic>> budgets,
      Map<String, Map<String, dynamic>> expenses,
      double totalSpending,
      ) async {
    final topCategories = expenses.entries.toList()
      ..sort((a, b) => b.value['total'].compareTo(a.value['total']));

    final exceededBudgets = budgets.where((budget) {
      final categoryId = budget['categoryId'];
      final spent = expenses[categoryId]?['total'] ?? 0.0;
      return spent > budget['amount'];
    }).toList();

    final unusedBudgets = budgets.where((budget) {
      final categoryId = budget['categoryId'];
      final spent = expenses[categoryId]?['total'] ?? 0.0;
      return spent == 0;
    }).toList();

    final summary = "In ${months[_month - 1]} $_year, you spent a total of "
        "$_currencySymbolToDisplay${totalSpending.toStringAsFixed(2)} "
        "across ${expenses.length} categories. "
        "${topCategories.isNotEmpty ? 'Your top spending category was ${topCategories.first.value['categoryName']}.' : ''}";

    final insights = <String>[
      if (topCategories.isNotEmpty)
        "Top spending: ${topCategories.first.value['categoryName']} ($_currencySymbolToDisplay${topCategories.first.value['total'].toStringAsFixed(2)})",
      if (exceededBudgets.isNotEmpty)
        "Budget exceeded in ${exceededBudgets.length} categor${exceededBudgets.length > 1 ? 'ies' : 'y'}",
      if (unusedBudgets.isNotEmpty)
        "${unusedBudgets.length} budget categor${unusedBudgets.length > 1 ? 'ies' : 'y'} had no spending",
      "Average spending per category: $_currencySymbolToDisplay${(totalSpending / expenses.length).toStringAsFixed(2)}",
    ];

    final recommendations = <String>[
      if (exceededBudgets.isNotEmpty)
        "Review spending in ${exceededBudgets.take(3).map((b) => b['categoryName']).join(', ')}",
      if (unusedBudgets.isNotEmpty)
        "Consider reallocating unused ${unusedBudgets.length > 1 ? 'budgets' : 'budget'} from ${unusedBudgets.take(3).map((b) => b['categoryName']).join(', ')}",
      "Track small expenses - they often add up significantly",
      "Set specific goals for top spending categories to reduce costs",
    ];

    return {
      'summary': summary,
      'insights': insights,
      'recommendations': recommendations,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: light90,
      appBar: AppBar(
        title: const Text('Monthly Summary', style: TextStyle(color: Colors.black)),
        backgroundColor: light90,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer2<ReceiptProvider, BudgetProvider>(
        builder: (context, receiptProvider, budgetProvider, _) {
          final budgets = budgetProvider.budgets;
          final expenses = receiptProvider.groupedReceiptsByCategoryOneMonth;
          final totalSpending = receiptProvider.totalSpending;

          return Column(
            children: [
              Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: purple60),
                  ),
                ),
                onPressed: _showMonthYearPicker,
                child: Text(
                  '${months[_month - 1]} $_year ▾',
                  style: const TextStyle(fontSize: 18, color: purple60),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _generateReport(context),
                icon: const Icon(Icons.analytics, size: 20),
                label: const Text("Generate AI Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple60,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Spending: ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$_currencySymbolToDisplay ${totalSpending.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Note: Total includes uncategorized expenses.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final categoryId = budget['categoryId'];
                    final categoryName = budget['categoryName'];
                    final categoryIcon = budget['categoryIcon'];
                    final budgetAmount = budget['amount'];
                    final spent = (expenses?[categoryId]?['total'] ?? 0.0) as double;

                    double ratio = budgetAmount == 0
                        ? (spent > 0 ? 1.0 : 0.0)
                        : spent / budgetAmount;
                    String ratioText = budgetAmount == 0
                        ? (spent > 0 ? '∞%' : '0.0%')
                        : '${(ratio * 100).toStringAsFixed(1)}%';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        leading: SizedBox(
                          width: 16,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: 8,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 8,
                                  height: 50 * ratio.clamp(0.0, 1.0),
                                  color: getColor(ratio),
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(categoryIcon, style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 8),
                            Text(categoryName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Budget:', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                Text(
                                  '$_currencySymbolToDisplay ${budgetAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Spent:', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                Text(
                                  '$_currencySymbolToDisplay ${spent.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 15, color: getColor(ratio)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Percentage:', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                Text(
                                  ratioText,
                                  style: TextStyle(fontSize: 15, color: getColor(ratio)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
