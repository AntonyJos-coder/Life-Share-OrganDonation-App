import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/organ_provider.dart';
import '../models/organ.dart';

class DonorRegistrationPage extends StatefulWidget {
  const DonorRegistrationPage({super.key});

  @override
  State<DonorRegistrationPage> createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBloodGroup;
  final Set<String> _selectedOrgans = {};

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

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
              'Register as Donor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                border: OutlineInputBorder(),
              ),
              items: _bloodGroups.map((String group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBloodGroup = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your blood group';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Hospital/Location',
                border: OutlineInputBorder(),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a hospital';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
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
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Select Organs to Donate:'),
            ...Organ.availableOrgans.map((organ) {
              return CheckboxListTile(
                title: Text(organ.name),
                subtitle: Text(organ.description),
                value: _selectedOrgans.contains(organ.name),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedOrgans.add(organ.name);
                    } else {
                      _selectedOrgans.remove(organ.name);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Register as Donor'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedOrgans.isNotEmpty) {
      final donor = {
        'name': _nameController.text,
        'bloodGroup': _selectedBloodGroup,
        'location': _locationController.text,
        'organs': _selectedOrgans.toList(),
        'phone': _phoneController.text,
      };
      
      context.read<OrganProvider>().addDonor(donor);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      
      // Clear form
      _nameController.clear();
      _locationController.clear();
      _phoneController.clear();
      setState(() {
        _selectedBloodGroup = null;
        _selectedOrgans.clear();
      });
    } else if (_selectedOrgans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one organ to donate')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 