import 'package:flutter/material.dart';
import 'package:tutorial_drive_flutter/app/src/presentation/views/create_view.dart';
import 'package:tutorial_drive_flutter/app/src/presentation/views/delete_view.dart';
import 'package:tutorial_drive_flutter/app/src/presentation/views/folder_view.dart';
import 'package:tutorial_drive_flutter/app/src/presentation/views/update_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    FolderView(),
    const CreateView(),
    const UpdateView(),
    const DeleteView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.drive_folder_upload),
          title: const Text('Tutorial Drive'),
          titleSpacing: 0.0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.upload_rounded),
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.update),
              label: 'Update',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete),
              label: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
