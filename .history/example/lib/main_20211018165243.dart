import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework_example/providers.dart';
import 'package:clean_framework_example/routes.dart';
import 'package:flutter/material.dart';

void main() {
  loadProviders();
  runApp(ExampleApp(providersContext: providersContext));
}

class ExampleApp extends StatelessWidget {
  final ProvidersContext providersContext;

  const ExampleApp({Key? key, required this.providersContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppProvidersContainer(
      providersContext: providersContext,
      onBuild: (context, _) {
        providersContext().read(featureStatesProvider.featuresMap).load({
          'features': [
            {'name': 'last_login', 'state': 'ACTIVE'},
          ]
        });
      },
      child: CFRouterScope(
        initialRoute: Routes.home,
        routeGenerator: Routes.generate,
        builder: (context) {
          return MaterialApp.router(
            routeInformationParser: CFRouteInformationParser(),
            routerDelegate: CFRouterDelegate(context),
          );
        },
      ),
    );
  }
}