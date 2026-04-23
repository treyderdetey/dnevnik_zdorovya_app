import 'package:flutter/material.dart';

import '../../widgets/app_loader.dart';

/// A page route that shows the premium loader before revealing content.
/// Use this for all screen navigations to give a polished feel.
class LoaderPageRoute extends PageRouteBuilder {
  final Widget page;
  final String? loadingMessage;
  final Duration loadDuration;

  LoaderPageRoute({
    required this.page,
    this.loadingMessage,
    this.loadDuration = const Duration(milliseconds: 800),
  }) : super(
          pageBuilder: (_, __, ___) => LoaderPageWrapper(
            loadDelay: loadDuration,
            loadingMessage: loadingMessage,
            child: page,
          ),
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: curved,
                child: child,
              ),
            );
          },
        );
}
