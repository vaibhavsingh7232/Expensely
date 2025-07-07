// ✅ UPDATED FILE: lib/widgets/step1_setup.dart

import 'package:flutter/material.dart';
import '../app_colors.dart';

class Step1Setup extends StatefulWidget {
  final int numPeople;
  final double totalAmount;
  final ValueChanged<int> onNumPeopleChanged;
  final ValueChanged<double> onTotalAmountChanged;
  final VoidCallback onNext;
  final ValueChanged<String>? onGroupNameChanged;

  const Step1Setup({
    super.key,
    required this.numPeople,
    required this.totalAmount,
    required this.onNumPeopleChanged,
    required this.onTotalAmountChanged,
    required this.onNext,
    this.onGroupNameChanged,
  });

  @override
  State<Step1Setup> createState() => _Step1SetupState();
}

class _Step1SetupState extends State<Step1Setup> {
  String groupName = '';

  bool get isValid => widget.totalAmount > 0 && groupName.trim().isNotEmpty;

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
                  'Create Group',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: dark100,
                  ),
                ),
                const SizedBox(height: 20),

                // Group Name Input
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Group Name',
                    hintStyle: TextStyle(color: dark100.withOpacity(0.5)),
                    fillColor: light100,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: purple100, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => groupName = v);
                    widget.onGroupNameChanged?.call(v);
                  },
                ),

                const SizedBox(height: 20),

                // Number of People Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Number of People:',
                        style: TextStyle(fontSize: 18, color: dark100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: widget.numPeople > 1
                              ? () => widget.onNumPeopleChanged(widget.numPeople - 1)
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: purple100,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                          child: const Icon(Icons.remove, size: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${widget.numPeople}',
                            style: const TextStyle(fontSize: 18, color: dark100),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => widget.onNumPeopleChanged(widget.numPeople + 1),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: purple100,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Total Amount Input
                TextFormField(
                  initialValue: widget.totalAmount == 0.0 ? '' : widget.totalAmount.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Total Amount',
                    hintStyle: TextStyle(color: dark100.withOpacity(0.5)),
                    fillColor: light100,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: purple100, width: 2),
                    ),
                  ),
                  onChanged: (v) => widget.onTotalAmountChanged(double.tryParse(v) ?? 0),
                ),

                const SizedBox(height: 24),

                // Next Button
                ElevatedButton(
                  onPressed: isValid ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? purple100 : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
