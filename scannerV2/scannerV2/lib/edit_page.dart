import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditPage extends StatefulWidget {
  final String initialData;

  const EditPage({super.key, required this.initialData});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController brandController;
  late TextEditingController serialController;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedCategory;
  String? selectedAvailability;

  final List<String> categoryOptions = [
    "Event",
    "Others",
    "Demo",
    "Loan",
    "Rental",
    "Field ops",
  ];

  final List<String> availabilityOptions = [
    "In",
    "Out",
  ];

  final String googleSheetUrl =
      "https://script.google.com/macros/s/AKfycbw-lJzpxb5mLxevSbKoldkaNWIM7xCgXC5F0qAY3vZoJ_TSC0VMqlnZ4Pk2HKbqg53ajg/exec";

  @override
  void initState() {
    super.initState();

    String brand = "";
    String serial = "";
    String description = "";
    String remarks = "";

    try {
      final Map<String, dynamic> data = jsonDecode(widget.initialData);

      brand = data["brand"] ?? "";
      serial = data["serial"] ?? "";
      description = data["description"] ?? "";
      remarks = data["remarks"] ?? "";

      selectedCategory = data["purpose"];
      selectedAvailability = data["availability"];
    } catch (e) {
      serial = widget.initialData;
    }

    brandController = TextEditingController(text: brand);
    serialController = TextEditingController(text: serial);
    descriptionController.text = description;
    remarksController.text = remarks;
  }

  Future<void> saveData() async {
    final savedData = {
      "brand": brandController.text.trim(),
      "serialNo": serialController.text.trim(),
      "description": descriptionController.text.trim(),
      "purpose": selectedCategory ?? "Not selected",
      "availability": selectedAvailability ?? "Not selected",
      "remarks": remarksController.text.trim(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse(googleSheetUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(savedData),
      );

      if (mounted) Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("Saved to Google Sheet"),
            content: Text("Your data has been successfully saved."),
          ),
        );

        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save to Google Sheet.")),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  void dispose() {
    brandController.dispose();
    serialController.dispose();
    descriptionController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Edit Item")),

      /// Scrollable content
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: Column(
            children: [
              /// Brand
              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: "Brand",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// Serial Number
              TextField(
                controller: serialController,
                decoration: const InputDecoration(
                  labelText: "Serial No.",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// Description
              TextField(
                controller: descriptionController,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// Remarks
              TextField(
                controller: remarksController,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// Purpose Dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: categoryOptions.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Purpose",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// Availability Dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedAvailability,
                items: availabilityOptions.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAvailability = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Availability",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 100), // space for fixed button
            ],
          ),
        ),
      ),

      /// Fixed Save Button (always visible, above nav bar)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: saveData,
            child: const Text("Save"),
          ),
        ),
      ),
    );
  }
}