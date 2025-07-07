import 'package:flutter/material.dart';
import '../app_colors.dart';

class Step2PeopleInput extends StatefulWidget {
  final int numPeople;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> amountControllers;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const Step2PeopleInput({
    super.key,
    required this.numPeople,
    required this.nameControllers,
    required this.amountControllers,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<Step2PeopleInput> createState() => _Step2PeopleInputState();
}

class _Step2PeopleInputState extends State<Step2PeopleInput> {
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
    _validateFields();
  }

  void _addListeners() {
    for (var controller in widget.nameControllers) {
      controller.addListener(_validateFields);
    }
    for (var controller in widget.amountControllers) {
      controller.addListener(_validateFields);
    }
  }

  void _validateFields() {
    bool allValid = true;

    for (var controller in widget.nameControllers) {
      if (controller.text.trim().isEmpty) {
        allValid = false;
        break;
      }
    }

    for (var controller in widget.amountControllers) {
      if (controller.text.trim().isEmpty ||
          double.tryParse(controller.text.trim()) == null ||
          double.tryParse(controller.text.trim())! <= 0) {
        allValid = false;
        break;
      }
    }

    if (isValid != allValid) {
      setState(() {
        isValid = allValid;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in widget.nameControllers) {
      controller.removeListener(_validateFields);
    }
    for (var controller in widget.amountControllers) {
      controller.removeListener(_validateFields);
    }
    super.dispose();
  }

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
                  'Enter Contributions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: dark100,
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic input fields
                ...List.generate(widget.numPeople, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.nameControllers[i],
                            decoration: InputDecoration(
                              hintText: 'Name ${i + 1}',
                              hintStyle: TextStyle(color: dark100.withOpacity(0.5)),
                              filled: true,
                              fillColor: light100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: purple100, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: widget.amountControllers[i],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              hintStyle: TextStyle(color: dark100.withOpacity(0.5)),
                              filled: true,
                              fillColor: light100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: purple100, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: light40,
                        foregroundColor: dark100,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: isValid ? widget.onSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isValid ? purple100 : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
