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


## Wichtiger neuer Gegenbeweis: Original startet mit Play-Image

Wiederholung 41491251617 auf a501b2b: offizielles Play-Store-Image,
Play Store 41.3.25, kein Account und keine Lizenzumgehung. Boot-
Transportwiederholung funktioniert. Originalsignaturen und SHA256 aller
Splits geprüft, Installation erfolgreich, system_server 553 unverändert.
Original-App-Hauptprozess 4652 bleibt über 120 Sekunden bestehen;
Native-IL2CPP-Initialisierung und verwalteter Unity-Code laufen!
Die 120s-Aufnahme zeigt echte **DRIVING MODE SELECTION** mit Buttons,
Tilt und Steering Wheel, keinen schwarzen Bildschirm und keinen Lizenzdialog.

Harness meldete fälschlich Prozessneustart, weil PairIP einen gleichnamigen
Kindprozess 5556 mit PPID 4652 erzeugt: `pidof` liefert jetzt zwei PIDs.
Es ist kein Ersatz des Hauptprozesses. Neue Prozessauswahl prüft die
Elternrelation; mehrere unabhängige Hauptprozesse werden weiter abgelehnt,
ein tatsächlich ersetzter Hauptprozess bekommt weiterhin eine andere PID.
Kein Spielerfolg wird daraus automatisch abgeleitet.

Es gibt verwaltete NullReferenceExceptions in WishWheel.CreatePersistentData
bei fehlenden Firebase-Remote-Config-Defaults. Ob diese die weitere Navigation
blockieren, ist noch ungeklärt. Ein vorlagengeprüfter, ausschließlich auf
Original angewandter UI-Smoke-Test wählt die kostenfreie Steuerungsart Buttons;
keine Käufe, Konten oder Lizenzdialoge werden angeklickt. Fahrbetrieb steht aus.

Dieser Befund legt nahe, zuerst den intakten Original-Initialisierungsweg
im funktionsfähigen Play-Image zu verwenden statt GOT-only-Patches und
Nullguards als Reparatur auszugeben.


## Reproduktion schränkt den Erfolg klar ein

UI-Smoke-Run 41492637268 (06887ea) installiert exakt dieselben drei
Original-Splits, läuft diesmal jedoch durch die echte LicenseActivity
in den nicht angemeldeten Google Play Store. Kein App-Prozess bei15s,
kein nativer Crash, keine UI-Testaktion ausgeführt. Die vorherige sichtbare
Driving-Mode-Auswahl ist echt, aber ohne Konto **nicht stabil reproduziert**.
Die damalige Play-Licensing-Service-Beendigung ist kein Nachweis einer
positiven Lizenzantwort. Deshalb keine belastbare Reparatur-/Spielerfolgsbehauptung.

Erweiterte Beobachtung liest den Ereignispuffer: eine kurz sichtbare
LicenseActivity wird jetzt auch nach Weiterleitung zu Play erkannt.
Keine Lizenzprüfung abgeschaltet, keine Antwort gefälscht, kein Account
injiziert. Blindes Wiederholen bis ein Lizenzfehler zufällig durchlässt
wird nicht als Reparatur oder Abnahmekriterium verwendet.

Stand: nativer Initialisierungsweg des Originals einmal erfolgreich
beobachtet; v17/v18/v19 weiter keine Reparaturen. Für eine regulär
reproduzierbare vollständige Spielprüfung ist eine berechtigte,
angemeldete Play-Umgebung beziehungsweise ein geeigneter autorisierter
Testbuild nötig. Die vorliegenden Werkzeuge besitzen diese nicht.
