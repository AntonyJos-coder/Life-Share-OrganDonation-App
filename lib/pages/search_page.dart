import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/organ_provider.dart';
import '../models/organ.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _selectedBloodGroup;
  String? _selectedOrgan;
  final _locationController = TextEditingController();

  // Add hospital list
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
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((group) => DropdownMenuItem(
                              value: group,
                              child: Text(group),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodGroup = value;
                        _search();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedOrgan,
                    decoration: const InputDecoration(
                      labelText: 'Organ',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items: Organ.availableOrgans
                        .map((organ) => DropdownMenuItem(
                              value: organ.name,
                              child: Text(organ.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOrgan = value;
                        _search();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital/Location',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    readOnly: true,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.6,
                          minChildSize: 0.3,
                          maxChildSize: 0.8,
                          expand: false,
                          builder: (context, scrollController) => Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Select Hospital',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Expanded(
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemCount: _suggestedHospitals.length,
                                  itemBuilder: (context, index) => ListTile(
                                    leading: const Icon(Icons.local_hospital),
                                    title: Text(_suggestedHospitals[index]),
                                    onTap: () {
                                      setState(() {
                                        _locationController.text = _suggestedHospitals[index];
                                        _search();
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<OrganProvider>(
              builder: (context, provider, child) {
                return _buildSearchResults();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final organProvider = context.read<OrganProvider>();
    final results = organProvider.searchDonors(
      bloodGroup: _selectedBloodGroup,
      organ: _selectedOrgan,
      location: _locationController.text.isNotEmpty ? _locationController.text : null,
    );

    if (results.isEmpty) {
      return const Center(
        child: Text('No donors found matching your criteria'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final donor = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(donor['full_name'] ?? ''),
            subtitle: Text(
              'Blood Group: ${donor['blood_group'] ?? ''}\n'
              'Hospital: ${donor['hospital_location'] ?? ''}\n'
              'Available Organs: ${(donor['organs_donated'] as Map?)?.keys.join(", ") ?? ""}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _search() {
    setState(() {}); // Trigger rebuild to update search results
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
} 