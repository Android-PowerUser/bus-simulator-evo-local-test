# Kontrollierte Startup-Experimente, 2026-11-02

## Geldpatch: als alleinige Startup-Ursache ausgeschlossen

Actions 41490083575 (ad92949): beide Kandidaten installieren alle drei APKs,
Kontroll-App startet, Spielprozess stürzt vor der 15-Sekunden-Probe ab.
Sowohl vollständig zurückgesetzter Originalwert als auch ABI-korrigierter
Millionenwert erreichen denselben ursprünglichen Unity-Fehlerpfad
`libil2cpp+0x2327f9c` (generischer Methodenindex 223202298).
Keine Nullguard-Instrumentierung aktiv. Somit erklärt das verlorene
`mov x1,xzr` den beobachteten Startup-Fehler nicht allein.
Keine Variante ist eine reparierte APK.

## Offizielles Google-Play-Image: erster Versuch nicht auswertbar

Actions 41490423615 (61e3546) bootet das offizielle API35 Play-Store-Image.
Während des Starts verschwindet die ADB-Verbindung kurzzeitig; Harness
bricht bei `device emulator-5554 not found` ab. Noch keine Kontroll-App
und keine Spielinstallation! Das ist weder ein APK-Crash noch ein
Lizenznachweis. emulator.log meldet anschließend abgeschlossenen Boot.
Boot-Schleife toleriert jetzt ausschließlich vorübergehende ADB-Transport-
Fehler innerhalb der bestehenden Deadline. Strenge Installations-,
Prozessgenerations-, Lizenz- und Gameplay-Prüfungen bleiben unverändert.
Wiederholung erforderlich; kein Google-Konto und kein Lizenzbypass.

## Statische Daten-/Relokationsprüfung

Unverändertes Original enthält an VA 0x553e028 den 64-Bit-Wert
0xcf1f3359da9b97f5. An dieser Adresse liegt keine dynamische Relokation.
Die verweisende Zelle 0x5413018 hat dagegen eine AARCH64_RELATIVE-
Relokation mit Addend 0x553e028: sie verweist wirklich auf diese Daten.
Die Nachbarwörter wirken ebenfalls hochentropisch. Das spricht dafür,
die fehlende Dateninitialisierung weiter zu prüfen, beweist jedoch
weder einen bestimmten Cipher noch eine ausführbare Entschlüsselung.
Keine erfundenen Methodenindizes und keine weiteren blinden Guards.
