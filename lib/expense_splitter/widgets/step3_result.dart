import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/pdf_service.dart';

class Step3Result extends StatelessWidget {
  final List<(String, String, double)> transactions;
  final VoidCallback onBack;
  final VoidCallback onStartOver;
  final String groupName;


  const Step3Result({
    super.key,
    required this.groupName,
    required this.transactions,
    required this.onBack,
    required this.onStartOver,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.3),
      child: SizedBox(
        width: 340,
        child: Card(
          elevation: 16,
          shadowColor: Colors.black.withOpacity(0.25),
          color: purple20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Settlement Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: dark100,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: dark100.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),


                // 🧾 Transaction list
                ...transactions.map((t) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: t.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: red100,
                            ),
                          ),
                          const TextSpan(
                            text: ' owes ',
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextSpan(
                            text: t.$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: purple100,
                            ),
                          ),
                          TextSpan(
                            text: ' ₹${t.$3.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // ✅ Responsive Single Row Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: light40,
                          foregroundColor: dark100,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("Back"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => PdfService.generateAndOpenPdf(transactions, groupName),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple100,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("View PDF"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onStartOver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red100,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("New Split"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
