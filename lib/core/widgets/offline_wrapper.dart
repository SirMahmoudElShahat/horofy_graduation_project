import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:horofy/core/widgets/no_internet_connection.dart';

class OfflineWrapper extends StatelessWidget {
  final Widget child;

  const OfflineWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (context, connectivity, _) {
        final isConnected =
            !connectivity.contains(ConnectivityResult.none);

        if (!isConnected) {
          return  NoInternetConnection();
        }

        return child;
      },
      child: const SizedBox(),
    );
  }
}
