# SIP Calling Removal TODO

## Plan Summary
Keep SIP fields for hotel module (profile_model, profile_controller, hotel_user_controller). 
Remove sip_ua dependency and unused imports from everywhere else.

## Steps:
- [x] 1. Edit pubspec.yaml: Remove `  sip_ua: ^1.1.0`
- [x] 2. Edit lib/my_app.dart: Remove `import 'package:sip_ua/sip_ua.dart';`
- [x] 3. Edit lib/features/splash/screens/splash_screen.dart: Remove `import 'package:sip_ua/sip_ua.dart';`
- [ ] 4. Run `flutter pub get`
- [ ] 5. Test: `flutter analyze`
- [ ] 6. Mark complete, verify no errors

**Progress: Code edits complete, running pub get & analyze**

**Progress: Starting**
