import 'package:flutter/material.dart';

class Member {
  String name;
  String email;
  String number;
  String membership;
  String role; // 'Member' or 'Trainer'
  bool checkedInToday;

  Member({
    required this.name,
    required this.email,
    required this.number,
    required this.membership,
    this.role = 'Member',
    this.checkedInToday = false,
  });

  bool get isTrainer => role == 'Trainer';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Member> members = [];
  int _selectedBottomIndex =
      0; // 0: Dashboard, 1: Attendance, 2: Plans, 3: Settings
  String _searchQuery = '';
  bool _expiryRemindersEnabled = true;

  void addmember(Member member) {
    setState(() {
      members.add(member);
    });
  }

  void _openAllMembersScreen(
    BuildContext context, {
    bool trainersOnly = false,
  }) {
    final filteredList = trainersOnly
        ? members.where((m) => m.isTrainer).toList()
        : members;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllMembersScreen(
          members: filteredList,
          title: trainersOnly ? 'All Trainers' : 'All Members',
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _openMemberDetailScreen(BuildContext context, Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
    ).then((_) {
      setState(() {});
    });
  }

  void _showMemberDialog(
    BuildContext dialogParentContext, {
    Member? existingMember,
  }) {
    final isEditing = existingMember != null;
    final nameController = TextEditingController(
      text: existingMember?.name ?? '',
    );
    final numberController = TextEditingController(
      text: existingMember?.number ?? '',
    );
    final emailController = TextEditingController(
      text: existingMember?.email ?? '',
    );
    final membershipController = TextEditingController(
      text: existingMember?.membership ?? '',
    );
    String selectedRole = existingMember?.role ?? 'Member';

    showDialog(
      context: dialogParentContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Person' : 'Add New Person'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role (Trainer or Member)',
                        prefixIcon: Icon(
                          selectedRole == 'Trainer'
                              ? Icons.fitness_center
                              : Icons.person,
                        ),
                      ),
                      items: const ['Member', 'Trainer'].map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),
                    TextField(
                      controller: membershipController,
                      decoration: InputDecoration(
                        labelText: selectedRole == 'Trainer'
                            ? 'Specialty / Shift'
                            : 'Membership Plan',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    if (isEditing) {
                      setState(() {
                        existingMember.name = nameController.text.trim();
                        existingMember.number = numberController.text.trim();
                        existingMember.email = emailController.text.trim();
                        existingMember.membership = membershipController.text
                            .trim();
                        existingMember.role = selectedRole;
                      });
                    } else {
                      addmember(
                        Member(
                          name: nameController.text.trim(),
                          number: numberController.text.trim(),
                          email: emailController.text.trim(),
                          membership: membershipController.text.trim(),
                          role: selectedRole,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(235, 25, 20, 40),
      selectedItemColor: Colors.amberAccent,
      unselectedItemColor: Colors.white70,
      onTap: (index) {
        setState(() {
          _selectedBottomIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_membership),
          label: 'Plans',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Widget _buildDashboardView(
    BuildContext context,
    int trainerCount,
    int memberCount,
  ) {
    final visibleMembers = _searchQuery.trim().isEmpty
        ? members
        : members
              .where(
                (m) =>
                    m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    m.membership.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 160),
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openAllMembersScreen(context),
                  child: Card(
                    color: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            '${470 + memberCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Total members',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.people, color: Colors.white),
                        Text(
                          '411',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Active Members',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () =>
                      _openAllMembersScreen(context, trainersOnly: true),
                  child: Card(
                    color: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            color: Colors.amberAccent,
                          ),
                          Text(
                            '${25 + trainerCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Trainers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.people, color: Colors.white),
                        Text(
                          '25',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'WebTech',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                    child: Text(
                      'Member Manegment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showMemberDialog(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 3),
                        Text('Add Person', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search member ',
                  hintStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              ...visibleMembers.map((member) {
                final isTrainer = member.isTrainer;
                return Card(
                  color: isTrainer
                      ? const Color.fromARGB(255, 46, 125, 118)
                      : const Color.fromARGB(255, 145, 112, 235),
                  child: ListTile(
                    onTap: () => _openMemberDetailScreen(context, member),
                    leading: CircleAvatar(
                      backgroundColor: isTrainer
                          ? Colors.amber
                          : Colors.deepPurple.shade100,
                      child: Icon(
                        isTrainer ? Icons.fitness_center : Icons.person,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isTrainer ? Colors.amber : Colors.deepPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            member.role.toUpperCase(),
                            style: TextStyle(
                              color: isTrainer ? Colors.black : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.membership,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 242, 242, 243),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!isTrainer) ...[
                          const SizedBox(width: 10),
                          const Text(
                            'Expires 30 nov',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showMemberDialog(
                            context,
                            existingMember: member,
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              members.remove(member);
                            });
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          const Text(
            'Today\'s Attendance',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            const Text(
              'Add members or trainers on the Dashboard to mark check-ins.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            )
          else
            ...members.map(
              (m) => Card(
                color: Colors.deepPurple.withValues(alpha: 0.88),
                child: SwitchListTile(
                  value: m.checkedInToday,
                  activeThumbColor: Colors.amberAccent,
                  title: Text(
                    m.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${m.role} • ${m.checkedInToday ? 'Checked In' : 'Not Checked In'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onChanged: (val) {
                    setState(() {
                      m.checkedInToday = val;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlansView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          const Text(
            'Membership Plans',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.deepPurple.withValues(alpha: 0.88),
            child: const ListTile(
              leading: Icon(Icons.star, color: Colors.amberAccent),
              title: Text(
                'Monthly Standard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Full gym floor & cardio access • Renews monthly',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color.fromARGB(225, 46, 125, 118),
            child: const ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.amberAccent),
              title: Text(
                'Personal Training + Access',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '1-on-1 trainer sessions & custom workout schedule',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(int trainerCount, int memberCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.deepPurple.withValues(alpha: 0.88),
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.amberAccent),
              title: const Text(
                'Gym Totals',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${470 + memberCount} Members • ${25 + trainerCount} Trainers',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.deepPurple.withValues(alpha: 0.88),
            child: SwitchListTile(
              value: _expiryRemindersEnabled,
              activeThumbColor: Colors.amberAccent,
              secondary: const Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
              title: const Text(
                'Expiry Reminders',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Alert before membership renewal dates',
                style: TextStyle(color: Colors.white70),
              ),
              onChanged: (val) {
                setState(() {
                  _expiryRemindersEnabled = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    int trainerCount,
    int memberCount,
  ) {
    switch (_selectedBottomIndex) {
      case 1:
        return _buildAttendanceView();
      case 2:
        return _buildPlansView();
      case 3:
        return _buildSettingsView(trainerCount, memberCount);
      case 0:
      default:
        return _buildDashboardView(context, trainerCount, memberCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerCount = members.where((m) => m.isTrainer).length;
    final memberCount = members.where((m) => !m.isTrainer).length;

    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, color: Colors.deepPurple, size: 30),
                SizedBox(width: 8),
                Text(
                  'Fit',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  'Track',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 254, 255),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  debugPrint('BUTTON PRESSED!');
                },
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/gym-membership-system.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: _buildTabContent(context, trainerCount, memberCount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllMembersScreen extends StatelessWidget {
  final List<Member> members;
  final String title;

  const AllMembersScreen({
    super.key,
    required this.members,
    this.title = 'All Members',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('$title (${members.length})'),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/gym-membership-system.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: members.isEmpty
                ? const Center(
                    child: Text(
                      'No records added yet.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isTrainer = member.isTrainer;
                      return Card(
                        color: isTrainer
                            ? const Color.fromARGB(235, 46, 125, 118)
                            : const Color.fromARGB(235, 103, 58, 183),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isTrainer
                                ? Colors.amber
                                : Colors.white,
                            child: Icon(
                              isTrainer ? Icons.fitness_center : Icons.person,
                              color: Colors.deepPurple.shade900,
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  member.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isTrainer
                                      ? Colors.amber
                                      : Colors.deepPurple.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  member.role.toUpperCase(),
                                  style: TextStyle(
                                    color: isTrainer
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${member.membership} • ${member.number}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MemberDetailScreen(member: member),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MemberDetailScreen extends StatelessWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTrainer = member.isTrainer;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(member.name),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/gym-membership-system.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isTrainer
                                ? Colors.amber
                                : Colors.deepPurple.shade100,
                            child: Icon(
                              isTrainer ? Icons.fitness_center : Icons.person,
                              color: Colors.deepPurple.shade900,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  member.role,
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _detailRow(Icons.phone, 'Phone Number', member.number),
                      _detailRow(Icons.email, 'Email Address', member.email),
                      _detailRow(
                        Icons.card_membership,
                        isTrainer ? 'Specialty / Shift' : 'Membership Plan',
                        member.membership,
                      ),
                      _detailRow(
                        Icons.how_to_reg,
                        'Today\'s Check-In',
                        member.checkedInToday ? 'Checked In' : 'Not Checked In',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
