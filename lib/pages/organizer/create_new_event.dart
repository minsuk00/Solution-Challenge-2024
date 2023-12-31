import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/services.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:test/cloud_functions/test_firestore.dart';

class CreateNewEventPage extends StatefulWidget {
  const CreateNewEventPage({super.key});

  @override
  State<CreateNewEventPage> createState() => _CreateNewEventPageState();
}

class _CreateNewEventPageState extends State<CreateNewEventPage> {  
  TextEditingController startDateInput = TextEditingController();
  TextEditingController endDateInput = TextEditingController();
  TextEditingController eventNameInput = TextEditingController();
  late String eventCode; // Variable to store the generated event code
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add a form key

  @override
  void initState() {
    startDateInput.text = "";
    endDateInput.text = "";
    eventCode = generateEventCode();
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Create New Event"),
      ),
      body: Container(
        padding: const EdgeInsets.all(250),
        child: Form(
          key: _formKey, // Set the key to the form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: eventNameInput,
                autofocus: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Event Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: startDateInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "Start Date",
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);

                    if (endDateInput.text.isNotEmpty &&
                        pickedDate.isAfter(
                            DateTime.parse(endDateInput.text))) {
                      // Selected start date is after the end date
                      // Show error message
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Start date should be before end date!"),
                        ),
                      );
                    } else {
                      setState(() {
                        startDateInput.text = formattedDate;
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: endDateInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "End Date",
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);

                    if (startDateInput.text.isNotEmpty &&
                        pickedDate.isBefore(
                            DateTime.parse(startDateInput.text))) {
                      // Selected end date is before the start date
                      // Show error message
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("End date should be after start date!"),
                        ),
                      );
                    } else {
                      setState(() {
                        endDateInput.text = formattedDate;
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an end date';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    generateAndShowEventCode(context);
                  }
                },
                child: const Text('Submit Event and Create Event Code'),
              )
            ]
          )
        )
      )
    );
  }

  void generateAndShowEventCode(BuildContext context) {
    // Show the event code in a pop-up message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Event Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your event code is: $eventCode'),
              ElevatedButton(
                onPressed: () {
                  copyToClipboard(eventCode);
                  Navigator.of(context).pop();
                },
                child: const Text('Copy'),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(8),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  String generateEventCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random rnd = Random();
    String code = '';
    for (int i = 0; i < 7; i++) {
      code += chars[rnd.nextInt(chars.length)];
    }
    return code;
  }
}