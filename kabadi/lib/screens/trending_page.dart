import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kabadi/screens/edit_profile.dart';
import 'package:kabadi/screens/edit_profileplayer.dart';
import 'package:kabadi/screens/edit_profileteam.dart';
import 'package:kabadi/screens/explore_page.dart';
import 'package:kabadi/screens/landing_page.dart';
import 'package:kabadi/screens/navigationbar.dart';
import 'package:kabadi/screens/team_details.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Trending extends StatefulWidget {
  const Trending({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending>
    with SingleTickerProviderStateMixin {
  Future<Uint8List?> getUserProfilePicture(String userId) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('UserProfilePictures/$userId');
      String downloadURL = await ref.getDownloadURL();
      HttpClientRequest request =
          await HttpClient().getUrl(Uri.parse(downloadURL));
      HttpClientResponse response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      return bytes;
    } catch (error) {
      print("Error fetching user profile picture: $error");
      return null;
    }
  }

  final int _selectedIndex = 0;
  late TabController _tabController;
  bool _isSearching = false;
  //bool _showDeleteButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? const TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(color: Colors.black),
              )
            : const Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
        actions: [
          IconButton(
            color: Colors.grey,
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching; // Toggle search state
              });
            },
          ),
          IconButton(
            color: Colors.grey,
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          const SizedBox(
            width: 10,
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: Text('Edit Profile'),
                value: 'edit_profile',
                onTap: () async {
                  // Retrieve current user
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Access user's document in Firestore
                    DocumentSnapshot<Map<String, dynamic>> snapshot =
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user.uid)
                            .get();
                    // Retrieve user's role
                    String? role = snapshot.data()?['role'];
                    // Route to edit profile page based on role
                    if (role == 'player') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EditPlayerProfilePage()),
                      );
                    } else if (role == 'team') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditTeamProfilePage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditUserProfilePage()),
                      );
                    }
                  }
                },
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit_profile') {
                // Handle edit profile action
              } else if (value == 'logout') {
                // Handle logout action
                _showLogoutConfirmationDialog(); // Call the logout confirmation dialog
              }
            },
            // child: const CircleAvatar(
            //   radius: 12.0,
            //   backgroundImage: AssetImage('images/cricket.jpg'),
            // ),
            child: const Icon(
              Icons.more_vert_outlined,
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),

      //Menu Bar
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('ABCD'),
              accountEmail: const Text(''),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(child: Image.asset('images/profile.jpg')),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFfc5607),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NavigationBarWidget()),
                    )),
            ListTile(
                leading: const Icon(Icons.person_2_rounded),
                title: const Text('My Account'),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditUserProfilePage()),
                    )),
            ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Explore'),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExplorePage()),
                    )),
            ListTile(
                leading: const Icon(Icons.people_outline_rounded),
                title: const Text('Know Your Team'),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeamDetails()),
                    )),
            const ListTile(
              leading: Icon(Icons.live_tv),
              title: Text('LiveScore'),
              /*onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LiveScore()),
                    )*/
            ),
            const ListTile(
              leading: Icon(Icons.sports_kabaddi_rounded),
              title: Text('Matches'),
              /*onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  PointsTablePage()),
                    )*/
            ),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditUserProfilePage()),
                    )),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Account'),
              onTap: () => _dialogBuilder(context),
            )
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('images/profile.jpg'),
                                radius: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Tassy Omah',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.alarm,
                                  size: 20,
                                ),
                                color: Colors.grey,
                                onPressed: () {},
                              ),
                              const Text(
                                '6 hrs ago',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'The Raptors Don\'t Need Leonard To be in that game! They really don\'t!',
                        style: TextStyle(fontSize: 19.0),
                      ),
                      const SizedBox(height: 10.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius as needed
                        child: Image.asset(
                          'images/play1.jpg',
                          width: 610,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                ),
                                color: Colors.red,
                                onPressed: () {},
                              ),
                              const Text(
                                '334',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              const Icon(
                                Icons.comment,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 5.0),
                              const Text(
                                '23440',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 10.0),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 0.0),
            TabBar(
              controller: _tabController,
              indicatorSize:
                  TabBarIndicatorSize.tab, // or TabBarIndicatorSize.tab
              tabs: [
                Tab(
                  child: Text(
                    'For you',
                    style: TextStyle(
                      // fontSize: 20,
                      color: _selectedIndex == 0
                          ? Colors.black
                          : const Color(0xFFfc5607),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Adjust the padding as per your requirement
                    child: Text(
                      'Bookmarks',
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? Colors.black
                            : const Color(0xFFfc5607),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // First tab content (For you)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Scrollbar(
                      child: ListView(
                        children: const [
                          Text(
                            'For you Content',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Add your For you content here
                        ],
                      ),
                    ),
                  ),
                  // Second tab content (Bookmarks)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Scrollbar(
                      child: GridView.count(
                        crossAxisCount: 2, // 2 columns
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        children: [
                          // First image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                            child: Image.asset(
                              'images/play2.jpg',
                              width: 610,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Second image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                            child: Image.asset(
                              'images/play1.jpg',
                              width: 610,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Third image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                            child: Image.asset(
                              'images/play2.jpg',
                              width: 610,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Fourth image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                            child: Image.asset(
                              'images/play1.jpg',
                              width: 610,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'images/delete.png',
                  width: 150,
                ),
                const SizedBox(height: 16),
                const Text('Once you Delete your account \n'
                    'There is no getting it back\n'
                    'Make sure you want to do this'),
              ],
            ),
            actions: [
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge),
                  child: const Text('Yes, Delete My Account'),
                ),
              ),
              const SizedBox(
                height: 10,
                width: double.infinity,
              ),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge),
                  child: const Text('No, Stop it'),
                ),
              )
            ],
          );
        });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen or any other screen you want after logout
      Get.offAll(() => LandingPage());
    } catch (e) {
      print("Error signing out: $e");
      // Show an error message or handle the error as needed
    }
  }

  // Show the confirmation dialog for logout
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _signOut();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _handlePopupMenuSelection(String value) {
    if (value == 'logout') {
      _showLogoutConfirmationDialog();
    }
  }
}
