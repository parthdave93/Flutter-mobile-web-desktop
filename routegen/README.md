# flutter_route_gen_example


#### Do not forget:
to run flutter upgrade and flutter pub upgrade before installing and using this lib as there was some issue with the build_runner or code generator which is not working for older versions.

---

Every time Flutter developer looks into his code it gives hard times, due to the default reactive pattern. Although there are architecture patterns like TDD in flutter which will help you it won't give much of a boost due to high pace development.

There's a single possibility to reduce this issue is by having code generation like Dagger in Android or dependency injection like every other platform.

I have developed this lib specifically for this as Routing in flutter gives a hard time when we scale our app.
```Dart
Navigator.of(context).pushNamed(ROUTE_NAME_HOMEPAGE, arguments: params);
```
Like take an example if we have 3 screens 
AScreen takes the id, BScreen takes the id, title and C screen takes the id, title, and description. In the near future if we have changed B screen to take description compulsory then what?

We will be getting runtime error mostly red screen because we missed parameter to passed somewhere due to this change and obviosly that parts can be list or array doesn't matter. What matters is if any of use makes this kind of mistake we need to have some compile-time error.

There is also another possibility to this lib which is modular programming,
Suppose you have 3-4 different modules in your app now you don't want to write all the navigation flow right? just fire the command and lib will do it for you.

> Serious Note: This lib will not handle the List or array cases as we might need to check for all codes in which the screen takes which arguments from the intent or parameters we have passed in.

### How to use this lib?
Pretty straight forward.
```YAML

dependencies:
  route_gen_lib:
    path: '../route_gen_lib' #your path or git path for one or more project support
  ...
dev_dependencies:
  build_runner: ^1.7.2
  routegen:
    path: '../routegen' #your path or git path for one or more project support
  ...
```
> I have not published this lib yet but I'm offering this lib so that anyone can modify and use it.

Now that we have added lib to ```pubspec.yaml``` file every time we are having a screen to route we just do this:
```Dart
@RouteGen(routeName: "HomePage16", paramClass: String)
class MyHomePage extends StatefulWidget {
```

and now either fire this command from the terminal:
```bash
"flutter packages pub run build_runner watch "
    " --delete-conflicting-outputs -v "
    "--define \"routegen=output_path=$routeFilePath\" "
    "--define \"routegen=class_name=$routeClassName\""
```
or you can use the dart script which I have added in the lib it self or example itself nammed route_script.dart
so 
```bash
dart route_script.dart
```

> If you use the file then you need to make changes in that file

where $routeFilePath is the path for the library to generate class by default it is lib/navigator but you can use lib/route or lib/routings/gen something like that at your convenience.
and $routeClassName is the name for the class which will be generated.

there's also the third option for modular code:
check the script
```
const modulesRouteFiles = [];//["flutter_anotherexample_module/route/example_route.dart"];
```
So here for reference, I have added flutter_anotherexample_module sorry for the bad naming convention as I didn't think of something else but you can add any module in which we are using this lib and then you can navigate to that something like this:

```
ExampleRoute.FlutterAnotherexampleModuleRoute.openScreen(context,param);
```

In the material app you can use something like this:
```
return MaterialApp(
  onGenerateRoute: (routeSettings)=>ExampleRoute.generateRoutes(routeSettings),
```

Voila, It will generate new methods based on your routeName and you can use right away due to watch command. if you use build command then you need to run that command after every change.

> I have not added anything for CupertinoApp but I didn't see any developer using it but you can make reference to this lib and generate for that also.

 