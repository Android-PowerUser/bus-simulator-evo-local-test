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


## v20: Rückkehr zur Originalinitialisierung allein genügt nicht

Run41495056787, Commit56261bf: sogar komplett unveränderte App-Inhalte
mit bloßer Neusignierung stürzen nach4s in PairIP+0x55b3c ab. Geld-only-
Variante mit intaktem DT_INIT erreicht exakt denselben ARM64-Fehlerpfad.
Wieder gleiche ungültige Pfadvariable0x9bfa61445886b4d9 und Hashlänge
0xffffaa4a wie im Hostemulator. Kein Unity-/IL2CPP-Start in diesen Varianten.

### Neue konkrete Verpackungsdifferenz gefunden

Lokale Neusignierung mit dem identischen Release-Testschlüssel produziert
**exakt denselben Basis-APK-SHA256** wie beide Actions-Jobs:
df3b9610c4500b2ddde955329ab54ac489552be65fd48e21eaede10501550675.
Alle1660 gemeinsamen Nicht-META-INF-Payloads sind unverändert. Entfernt
wurden aber stamp-cert-sha256 und drei Signing-Block-Einträge, darunter
**0xfa1cfabe,41938Bytes**. Exakt diese ID liegt in BEIDEN Original-VM-Assets
als32bitLiteral vor (ERz+0x1de4a,AYum+0xdaa3). Das ist eine konkrete,
vorher nicht getrennt untersuchte Laufzeitdaten-Differenz.

V21 erhält ausschließlich den opaken App-Datensatz0xfa1cfabe. Keine
Original-v2/v3-Signatur, kein SourceStamp und kein anderer Authentisierungs-
Datensatz wird übernommen. APK-Überprüfung nach Wiederherstellung besteht
weiter mit genau EINEM neuen Test-Signer44bc8662…; kein Original-Signer
und SourceStamp=false. Dies ist kein positiver Lizenznachweis.

Offline-Roundtrip und37Tests grün. Android-Ergebnis für v21 noch offen;
fehlende Metadaten sind eine Hypothese, keine bereits bewiesene Reparatur.
Audit-JSONs dokumentieren entfernte Blöcke und echte APK-Signerprüfung.


## v21 abgelehnt; weitere Diagnose sauber getrennt

41496478857 aufcf987db: in allen3Splits fa1cfabe exakt erhalten
(Basis41938Bytes,ARM-Config40995Bytes,Assetpack200Bytes). Installation
und Neusignerprüfung erfolgreich, beide Appvarianten trotzdem nach4s
am identischen PairIP+0x55b3c mit identischen ungültigen Operanden.
Die erhaltenen Metadaten allein beheben den Crash also NICHT.

Neuer echter Hostmodellfehler: VMRunner.invoke hat im verifizierten
Stock-Smali die executeVM-Aufrufzeile69 statt der bisher simulierten49.
Modellvertrag mit Regressiontest korrigiert. Zusätzlich entdeckt:
Unicorns Instruktionsbudget wurde als normales Funktionsende ausgegeben.
Jetzt wird vor jeder Folgephase ausdrücklich das Rückkehr-Sentinel geprüft.
Zwei erste49/69-Läufe mit20M-Budget/proc-v11/konstantemClock sind daher
**nicht als erfolgreich abgeschlossene Startup-Läufe auswertbar**.
Korrigierter kontrollierter Vergleich mit synthetischem Procmodell und
monotoner Uhr läuft separat; unveränderte VM-Guards.

Parallel wird ein zweites, unverändertes Android-Nativemodell mit Unidbg
aufgebaut, um Fehler der handgeschriebenen libc/JNI-Stubs zu isolieren.
API23-Resolver ist eine Einschränkung, kein Android15-Nachweis.

## v22: Originalsignatur trennt Metadatenverlust von Neusignierung

Run **41499191685**, Commit5358b50: drei APK-Sets erfolgreich installiert,
aber alle am selben PairIP+55b3c-Pfad abgestürzt. Gleiche X1=9bfa61445886b4d9,
X23=6aeced7847b53da3; kein Unity-/Gameplaynachweis.

1. Unveränderte Originalinhalte neu signiert, fa1cfabe diesmal korrekt VOR
   abschließendem Verity-Padding: Crash.
2. Geld-only mit ursprünglichem Initializer und derselben Metadatenfolge: Crash.
3. **Nur fa1cfabe aus allen drei authentischen Original-APKs entfernt**:
   ebenfalls derselbe Crash. Original-v2/v3-Signaturdaten und SourceStamp bleiben
   unverändert; apksigner bestätigt sie. Keine neue Signeridentität in Kontrolle3.

Damit genügt Metadatenentfernung für diesen Fehler, ohne Neusignierung oder
Geldänderung. Umgekehrt ist Wiederherstellen dieses Records in anders gepackte,
neu signierte Dateien noch keine Reparatur. Weitere Verpackungsunterschiede
bleiben zu kontrollieren. Insbesondere V21s Platzierung NACH Padding war kein
sauberer Ausschluss der Metadatenhypothese; V22 korrigiert diesen Teil.

### V23: Noch eine reale Verpackungsdifferenz entdeckt

Bisheriger apksigner-Aufruf aktiviert v1 und richtet Dateien neu aus.
Beim exakten Offline-Nachbau unterscheiden sich deshalb nicht nur Signaturen,
sondern ab Dateioffset14057 auch ZIP-Header/Payloadpositionen. Das Wiederherstellen
von dekomprimierten Dateiinhalten beweist keine unveränderte rohe ZIP-Struktur.

`--alignment-preserved true --v1-signing-enabled false` lässt beim Original-Basis-
APK dagegen den **gesamten 60,309,504Byte langen Präfix vor dem Signing-Block
bytegleich**, einschließlich sämtlicher lokaler Header und Originaldatei-
positionen. SHA256=7556a007a75c1bc4c81a70a9494b324a3f6165ac0dff42a0d14dea58b5f215b2.
Fa1cfabe wird anschließend wieder vor Padding eingesetzt. APK-v2/v3 prüft
korrekt mit dem neuen Testschlüssel; keine alten Authentisierungsrecords kopiert.

Run41500435000 auf62f3b67 vergleicht diesen kontrollierten Neu-Signer mit dem
unveränderten Original im selben offiziellen Play-Systemimage. Prüfung bricht
ab, falls in IRGENDEINEM der3Splits der rohe Präfix nicht bytegleich bleibt.
**Android-Ergebnis noch ausstehend.** Keine Geldvariante in dieser Isolation.

### Hostmodell: gültiger Zeilenvergleich und unabhängiger Loader

Der streng geprüfte 49/69-A/B mit monotoner Uhr/synthetischem Procmodell endet
beidseits nach8,751,970Instruktionen und7459VM-Schritten an55b3c, Ziel-R/W0.
Zeilenkorrektur allein löst diesen Modellfehler nicht.

Unidbg e0d88a900ae9d197c325af8d6a5875ee9958b724 baut mit SHA-geprüftem
Temurin17.0.21+9. Alte SLF4J-Bindings entfernt, konsistentesAPI/Simple1.7.36.
**JNI_OnLoad erreicht wirklich Rückkehr-PC7ffff0000** und registriert executeVM
an+6a61c. ERz-Startup dagegen erreicht nach fork=-ENOSYS/proc-JNI einen anderen
unmapped-read-Fehler beiPairIP+8d188 (Adressec3ca6da6208a374d), NICHT Rückkehr.
Der neue PC-Sentinelvertrag verweigert ausdrücklich STARTUP_RETURNED.

API23-Bionic ist unterhalb des Original-minSdk24 und nicht Android15:
Dieser unabhängige Loader ist nur Bootstrap-/Modell-Diagnose, kein Beweis
für die Android-Ursache und keine Reparatur. Vollständiges Log und komprimierte
streng geprüfte Host-A/B-Logs liegen im Unterordnerindependent-native-model.

## V23 hat die geplante Android-Isolation NICHT erreicht

41500435000: Der rohe Basispräfix war korrekt bytegleich. Bei der ARM-Config
entfernt das offizielle apksigner-CLI aber trotz Alignment-Erhaltung alte
META-INF/MANIFEST.MF, BNDLTOOL.SF, BNDLTOOL.RSA und stamp-cert-sha256.
Alle29 erhaltenen lokalen Header bleiben zwar am selben Offset, aber der
Signing-Block rückt von39067648 nach39063552. Die harte Präfixprüfung hat
**vor Appinstallation abgebrochen**. Deshalb kein neuer nativer APK-Befund.

### V24: unveränderte ZIP-Sektionen direkt mit Googles Engine signieren

`ci/RawZipSigner.java` nutzt die offizielle DefaultApkSignerEngine aus dem
SDK35-apksigner.jar, nicht eine selbst implementierte Signatur. Es erzeugt
neue reguläre v2/v3-Signaturen über die UNVERÄNDERTEN ZIP-Sektionen und ersetzt
nur den kompletten APK Signing Block. Keine Original-v2/v3/SourceStamp-Records
werden kopiert oder nachträglich als authentisch ausgegeben. Alte JAR-Metadaten
bleiben als unveränderte ZIP-Dateien stehen; sie sind nicht der neue APK-Signer.

Diese Verpackungsisolation unterstützt ausdrücklich **API24+**, das minSdk des
verifizierten Basis-APKs. UnterhalbAPI24 ist sie NICHT gültig: der Standardprüfer
über die ältere Split-minSdk-Reichweite meldet zurecht unterschiedliche alte
JAR-/neuev2-Signer. Mit der tatsächlichen App-Untergrenze24 prüft Googles Tool
v2/v3 korrekt, **genau EINEN neuen Signer44bc8662…**, kein SourceStamp. Diese
Einschränkung ist ausdrücklich Teil der Kontrolle und wird nicht versteckt.

Offline ARM-Config: Präfix39067648Bytes vollständig bytegleich,
SHAb62e5738a1c4414a8cb2f3623c572cc2e507623935d0d03f22c9c951a4a65e67.
Danach fa1cfabe40995Bytes vorPadding restauriert und Signatur nochmals geprüft.
Run41501612127 aufd893f5b testet das aufAndroid35 gegen unverändertes Original;
Ergebnis ausstehend.47UnitTests bestanden. Keine APK- oder Gameplayfreigabe.
