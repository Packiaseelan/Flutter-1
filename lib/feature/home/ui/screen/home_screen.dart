import 'package:flutter/material.dart';

import '../../blocs/home_bloc_provider.dart';
import '../widget/HomeWidget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: HomeBlocProvider(child: const HomeWidget()),
    );
  }
}