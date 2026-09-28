import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/organ_provider.dart';
import '../models/organ.dart';

class RecipientRegistrationPage extends StatefulWidget {
  const RecipientRegistrationPage({super.key});

  @override
  State<RecipientRegistrationPage> createState() => _RecipientRegistrationPageState();
}

class _RecipientRegistrationPageState extends State<RecipientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedOrgan;
  bool _isUrgent = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Add this list of hospitals
  final List<String> _suggestedHospitals = [
    'AIIMS Delhi',
    'Apollo Hospitals',
    'Fortis Healthcare',
    'Max Healthcare',
    'Medanta Hospital',
    'Manipal Hospitals',
    'Narayana Health',
    'Tata Memorial Hospital',
    'Christian Medical College',
    'Kokilaben Hospital',
    'Lilavati Hospital',
    'Jaslok Hospital',
    'Sir Ganga Ram Hospital',
    'Artemis Hospital',
    'BLK Super Speciality Hospital',
    'Ruby Hall Clinic',
    'Hinduja Hospital',
    'Breach Candy Hospital',
    'Bombay Hospital',
    'Wockhardt Hospitals',
    'Columbia Asia Hospital',
    'Shalby Hospitals',
    'Sterling Hospitals',
    'Care Hospitals',
    'Global Hospitals',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Request Organ Donation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: _bloodGroups.map((group) {
                return DropdownMenuItem(value: group, child: Text(group));
              }).toList(),
              onChanged: (value) => setState(() => _selectedBloodGroup = value),
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedOrgan,
              decoration: const InputDecoration(
                labelText: 'Required Organ',
                prefixIcon: Icon(Icons.medical_services),
              ),
              items: Organ.availableOrgans.map((organ) {
                return DropdownMenuItem(value: organ.name, child: Text(organ.name));
              }).toList(),
              onChanged: (value) => setState(() => _selectedOrgan = value),
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Hospital/Location',
                prefixIcon: Icon(Icons.local_hospital),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Hospital'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _suggestedHospitals.map((hospital) => 
                          ListTile(
                            title: Text(hospital),
                            onTap: () {
                              _locationController.text = hospital;
                              Navigator.pop(context);
                            },
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                );
              },
              readOnly: true,
              validator: (value) => value?.isEmpty ?? true ? 'Please select a hospital' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicalHistoryController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Medical History',
                prefixIcon: Icon(Icons.history),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                hintText: 'Enter 10-digit mobile number',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                    _phoneController.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Only numbers are allowed'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Required';
                }
                if (value!.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Urgent Requirement'),
              value: _isUrgent,
              onChanged: (value) => setState(() => _isUrgent = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final request = {
        'name': _nameController.text,
        'bloodGroup': _selectedBloodGroup,
        'organ': _selectedOrgan,
        'location': _locationController.text,
        'medicalHistory': _medicalHistoryController.text,
        'isUrgent': _isUrgent,
        'status': 'Pending',
        'timestamp': DateTime.now().toIso8601String(),
        'phone': _phoneController.text,
      };

      final organProvider = context.read<OrganProvider>();
      organProvider.addRequest(request);

      // Find matching donors
      final matches = organProvider.findMatches(request);
      
      if (matches.isNotEmpty) {
        _showMatchDialog(matches);
      } else {
        var showSnackBar = ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request registered. No immediate matches found.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _locationController.clear();
      _medicalHistoryController.clear();
      _phoneController.clear();
      setState(() {
        _selectedBloodGroup = null;
        _selectedOrgan = null;
        _isUrgent = false;
      });
    }
  }

  void _showMatchDialog(List<Map<String, dynamic>> matches) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Potential Matches Found!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final donor = matches[index];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE53935),
                                radius: 24,
                                child: Icon(Icons.person, color: Colors.white, size: 24),
                              ),
                              title: Text(
                                donor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bloodtype, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Blood Group: ${donor['bloodGroup']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Hospital: ${donor['location']}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.phone, size: 18),
                                          label: const Text(
                                            'Call',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onPressed: () async {
                                            final phoneNumber = donor['phone'];
                                            // Clean and format the phone number
                                            final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
                                            final formattedNumber = cleanNumber.startsWith('+') 
                                                ? cleanNumber 
                                                : '+91$cleanNumber';
                                            
                                            try {
                                              // Directly launch phone dialer
                                              final Uri phoneUri = Uri(
                                                scheme: 'tel',
                                                path: formattedNumber,
                                              );
                                              
                                              if (await canLaunchUrl(phoneUri)) {
                                                await launchUrl(phoneUri, 
                                                  mode: LaunchMode.externalApplication
                                                );
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Could not launch phone dialer for $formattedNumber'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error launching phone dialer: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 120,
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.message, size: 18),
                                          label: const Text(
                                            'Message',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onPressed: () async {
                                            final phoneNumber = donor['phone'];
                                            // Clean and format the phone number
                                            final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
                                            final formattedNumber = cleanNumber.startsWith('+') 
                                                ? cleanNumber 
                                                : '+91$cleanNumber';
                                            
                                            try {
                                              // Directly launch messaging app
                                              final Uri smsUri = Uri(
                                                scheme: 'sms',
                                                path: formattedNumber,
                                              );
                                              
                                              if (await canLaunchUrl(smsUri)) {
                                                await launchUrl(smsUri, 
                                                  mode: LaunchMode.externalApplication
                                                );
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Could not launch messaging app for $formattedNumber'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error launching messaging app: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _medicalHistoryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 