class Organ {
  final String name;
  final String description;
  final List<String> compatibleBloodGroups;

  const Organ({
    required this.name,
    required this.description,
    required this.compatibleBloodGroups,
  });

  static List<Organ> get availableOrgans => [
    const Organ(
      name: 'Kidney',
      description: 'Filters blood and maintains blood pressure',
      compatibleBloodGroups: ['A+', 'A-', 'O+', 'O-'],
    ),
    const Organ(
      name: 'Liver',
      description: 'Detoxifies chemicals and metabolizes drugs',
      compatibleBloodGroups: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    ),
    const Organ(
      name: 'Heart',
      description: 'Pumps blood throughout the body',
      compatibleBloodGroups: ['A+', 'A-', 'O+', 'O-'],
    ),
    const Organ(
      name: 'Lungs',
      description: 'Responsible for gas exchange in respiration',
      compatibleBloodGroups: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    ),
    const Organ(
      name: 'Pancreas',
      description: 'Produces insulin and other important hormones',
      compatibleBloodGroups: ['A+', 'A-', 'O+', 'O-'],
    ),
  ];
} 