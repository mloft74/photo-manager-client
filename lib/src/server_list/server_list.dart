import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/bottom_app_bar_title.dart';

const _fakeServers = [
  'https://10.0.0.12',
  'http://10.0.0.170',
  'https://192.168.0.12',
];

class ServerList extends StatelessWidget {
  const ServerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [
            BackButton(),
            BottomAppBarTitle('Settings'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          reverse: true,
          itemCount: _fakeServers.length,
          itemBuilder: (context, index) {
            final item = _fakeServers[index];
            return ListTile(
              title: Text(item),
              onTap: () {
                debugPrint('set selected server');
              },
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  debugPrint('edit server');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
