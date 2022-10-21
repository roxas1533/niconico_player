

// @pragma(
//     'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case simplePeriodicTask:
//         print("$simplePeriodicTask was executed");
//         break;
//       case simplePeriodic1HourTask:
//         print("$simplePeriodic1HourTask was executed");
//         break;
//       case Workmanager.iOSBackgroundTask:
//         print("The iOS background fetch was triggered");
//         break;
//     }

//     return Future.value(true);
//   });
// }
