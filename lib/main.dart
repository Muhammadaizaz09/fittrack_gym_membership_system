import 'package:flutter/material.dart';

class Member {
  String name;
  String email;
  String number;
  String membership;

  Member({
    required this.name,
    required this.email,
    required this.number,
    required this.membership,
  });
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
  void addmember(Member member) {
    setState(() {
      members.add(member);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,

            title: Row(
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
                  print('BUTTON PRESSED!');
                },
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),

          body: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/gym-membership-system.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Dashboard content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 160),

                    Text(
                      'Dashboard Overview',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 20,
                                  ),

                                  Text(
                                    '470',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
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
                        SizedBox(height: 10),
                        Expanded(
                          child: Card(
                            color: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
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

                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(20),
                            ),
                            child: Padding(
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
                        SizedBox(height: 10),
                        Expanded(
                          child: Card(
                            color: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(20),
                            ),
                            child: Padding(
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
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                          children: [
                            Expanded(
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
                              onPressed: () {
                                TextEditingController nameController =
                                    TextEditingController();
                                TextEditingController numberController =
                                    TextEditingController();
                                TextEditingController emailController =
                                    TextEditingController();
                                TextEditingController membershipController =
                                    TextEditingController();

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Add New Member'),

                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Full Name',
                                              ),
                                            ),

                                            TextField(
                                              controller: numberController,
                                              decoration: InputDecoration(
                                                labelText: 'Phone Number',
                                              ),
                                            ),

                                            TextField(
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                labelText: 'Email Address',
                                              ),
                                            ),

                                            TextField(
                                              controller: membershipController,
                                              decoration: InputDecoration(
                                                labelText: 'Membership Plan',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),

                                        ElevatedButton(
                                          onPressed: () {
                                            Member newMember = Member(
                                              name: nameController.text,
                                              number: numberController.text,
                                              email: emailController.text,
                                              membership:
                                                  membershipController.text,
                                            );
                                            addmember(newMember);
                                            Navigator.pop(context);
                                          },

                                          child: Text('Save Member'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },

                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 3),
                                  Text(
                                    'Add Members',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search member ',

                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        ...members.map((member) {
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text(member.name),
                              subtitle: Text(
                                '${member.email}\n${member.number}\n${member.membership}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit button
                                  IconButton(
                                    onPressed: () {
                                      // We'll add edit functionality next.
                                    },
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                  ),

                                  // Delete button
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        members.remove(member);
                                      });
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
