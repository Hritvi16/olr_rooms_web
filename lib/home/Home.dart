import 'package:flutter/material.dart';
import 'package:olr_rooms_web/home/HomeM.dart';
import 'package:olr_rooms_web/home/HomeW.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            print(width);
            if (constraints.maxWidth < 600) {
              return HomeM();
            } else if (constraints.maxWidth > 600) {
              return HomeW();
            }

            throw Text('Illegal');
          },
        ));
  }

  Widget getRows() {
    return Row(
      children: [
        Flexible(flex: 1, child: getRowCards()),
        Flexible(flex: 1, child: getRowCards()),
        Flexible(flex: 1, child: getRowCards()),
        Flexible(flex: 1, child: getRowCards()),
      ],
    );
  }

  Widget getColums() {
    return Column(children: [
      Expanded(flex: 1, child: getColumnCards()),
      Expanded(flex: 1, child: getColumnCards()),
      Expanded(flex: 1, child: getColumnCards()),
      Expanded(flex: 1, child: getColumnCards()),
    ]);
  }

  Widget getCenterContainder() {
    return Center(
      child: Text('Center'),
    );
  }

  Widget getRowCards() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Card(
        child: Column(
          children: [
            Image.network('https://source.unsplash.com/user/c_v_r/1900x800'),
            SizedBox(
              height: 5,
            ),
            ListTile(
              leading:Icon(Icons.bubble_chart),
              title: Text('List Tile'),
              subtitle: Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
              trailing: ElevatedButton(
                onPressed: ()=>print('Button Pressed'),
                child: Text('View'),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget getColumnCards() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        child: Column(
          children: [
            Image.network('https://source.unsplash.com/user/c_v_r/1900x800'),
            SizedBox(
              height: 5,
            ),
            ListTile(
              leading:Icon(Icons.bubble_chart),
              title: Text('List Tile'),
              trailing: ElevatedButton(
                onPressed: ()=>print('Button Pressed'),
                child: Text('View'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
