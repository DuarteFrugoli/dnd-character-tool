gerar build:
- C:\develop\flutter\bin\flutter.bat build apk --release

gerar release AAB (Play Store):
- C:\develop\flutter\bin\flutter.bat build appbundle --release
- output: build\app\outputs\bundle\release\app-release.aab

gerar traduções arb:
- flutter gen-l10n

rodar testes:
- C:\develop\flutter\bin\flutter.bat test
