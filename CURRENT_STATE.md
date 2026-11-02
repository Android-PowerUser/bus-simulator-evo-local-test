# Aktuell: Play-Kontrolle nicht reproduzierbar ohne Lizenzumgebung

- 41491251617 zeigte echte Driving-Mode-Auswahl, aber 41492637268 erreicht mit identischen signierten Original-Splits die LicenseActivity und nicht angemeldeten Play Store.
- Kein reproduzierbarer Spielerfolg, keine reparierte modifizierte APK. Keine zufälligen Lizenzfehler als Abnahme verwenden.
- Ereignispuffer verhindert falsches license_check_blocked=false nach Weiterleitung. 29 Regressionstests.
- Details/Nachweise: `reports/controlled-startup-2026-11-02/REPORT.md`.

---

# Original startet im offiziellen Play-Image

- Actions 41491251617: originale signierte Version 1.27.42 installiert, native Initialisierung läuft; echte Driving-Mode-Selection sichtbar. Kein Account/Lizenzbypass.
- Hauptprozess 4652 bleibt, Kindprozess5556 ist kein Neustart. Strenge Elternprozess-Auswahl und 4 Regressionstests ergänzt.
- Bericht `reports/controlled-startup-2026-11-02/REPORT.md`; UI-Smoke-Wiederholung folgt.
- 25 Tests grün. Noch kein Fahrbetrieb, keine reparierte modifizierte APK.

---

# Neuester Kontrollstand: v19 und Play-Image

- Bericht: `reports/controlled-startup-2026-11-02/REPORT.md`.
- v19 Originalgeld und ABI-korrigierter Millionenwert: gleicher Startup-Crash; Geldpatch nicht allein ursächlich.
- Offizielles Play-Image zuerst durch vorübergehenden ADB-Disconnect vor Installation abgebrochen; gezielte Boot-Recovery ergänzt, Wiederholung ausstehend.
- 21 Unit-Tests grün. Kein verifizierter Spielstart, keine reparierte APK.

---

# Aktuell: öffentliches Repository, v18-Hypothese verworfen

- Repository am 2026-11-02 nach ausdrücklicher Zustimmung einschließlich Historie/Release-APKs/Testschlüssel öffentlich geschaltet; unauthentifizierten Zugriff geprüft. Testschlüssel ist offengelegt, nicht produktiv verwenden.
- Neuester Android-Lauf: https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41484535040 (getesteter Commit `1ef8f14`).
- v18-nullguard ist eine optionale, quellcode-gestützte Hypothese, **keine Reparatur**. Installation erfolgreich, danach SIGSEGV bei `libil2cpp+0x2327f9c` mit generischem Methodenindex `223202298`.
- Original-Gastregister belegen: `x20+8*w0` ist exakt die Fehleradresse. Ein Nullguard allein repariert die inkonsistenten Methodenreferenzen nicht.
- Tatsächlichen Host-Emulatorfehler korrigiert: DT_INIT übergibt ELF-Basis statt NULL. A/B belegt bisher keinen Einfluss auf den gestoppten VM-Pfad. Keine Hash-Guards erzwungen oder entfernt.
- Bericht mit Nachweisen: `reports/public-actions-2026-11-02/REPORT.md`.
- 16 Unit-Tests grün; **kein sichtbarer Spielstart und keine reparierte APK belegt**.

---

# Ergänzung: ARM64-Fehlerkontext belegt (2026-11-02)

Neuester Diagnose-Lauf: https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41476111893

- Aktueller Code und kleine Nachweise: `reports/guest-context-2026-11-02/REPORT.md`.
- Instrumentierung sichert den ursprünglichen ARM64-ucontext vor Unitys Signalweiterleitung. Der ursprüngliche SIGSEGV bleibt unverändert erhalten.
- Tatsächlicher PC `libil2cpp+0x2329068`: `ldr w8,[x0,#0xc]`, mit **x0=0**. Rücksprung `+0x235e6f4`. Null-GenericContainer im GetFullySharedInst/GetGenericParameterFromIndex-Pfad jetzt durch ursprüngliche Register und ELF geprüft.
- Decoder berücksichtigt doppelte native-bridge-Mappings. ARM64-ELF-Ausführbarkeit wurde trotz `r--`-Hostmapping geprüft.
- **Kein reparierter Spielstart, kein Gameplay-Erfolg.** Die Herkunft des ungültigen GenericContainers bleibt zu klären. Es wurde kein RET-Patch als Fix ausgegeben.
- Erster Diagnoselauf 41474270941 zeigte nur einen schwarzen Bildschirm mit Androids Vollbild-Einführungshinweis. Sein damaliger Liveness-Erfolg ist kein Spielerfolg. Hinweisbehandlung und diagnostische Erfolgskriterien sind korrigiert.
- **12 Unit-Tests erfolgreich.** Diagnostische Variante nur über Workflow-Input `diagnostic_context=true`, nicht als reparierte APK verteilen.
- Internetbeschaffung exakter Unity-Symbole und Nachweis gleicher GNU Build ID: `reports/internet-symbols-2026-11-02/RESEARCH.md`.

---

# Neuester Stand: Docker/GitHub Actions — 2026-11-02

**Diese Ergänzung ersetzt für den aktuellen Teststand die darunterliegende historische lokale TCG-Zusammenfassung.**

- Workflow: `.github/workflows/android-docker.yml`; Dockerfile und Startskript: `ci/docker/`.
- KVM-beschleunigter Android-15/API35-Emulator läuft in Docker. ARM64 über `libndk_translation.so`, kein nativer ARM64-Beweis.
- Aktuellster abgeschlossener Lauf: https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41448714075 (getesteter Commit `312c291`).
- Beide Kontroll- und Spielinstallationen erfolgreich; drei Splits verifiziert.
- v17 + v9-Basis: reproduzierter nativer SIGSEGV in UnityMain/IL2CPP. **Nicht repariert.**
- Kryptografisch geprüftes Original: Google-Play-Lizenzdialog und Prozessneustarts. **Kein erfolgreicher Spielstart.**
- Alter Stock-Job aus Run 41447624214 meldete falsch Erfolg. Das Testharness wurde korrigiert: gleiche App-PID und gleiche system_server-Generation erforderlich; Lizenz-Activity wird explizit abgelehnt. Acht Unit-Tests erfolgreich.
- Aktueller vollständiger Bericht mit kleinen versionierten Nachweisen: `reports/docker-2026-11-02/REPORT.md`. Vollständige Logs, Screenshots und Tombstones in den Actions-Artefakten.
- Persönlicher Token wird weder versioniert noch in den Container eingebaut. Actions nutzt `github.token` nur zum Download privater Release-Eingaben.

## Nächster belastbarer Reparaturschritt

Native Debug-/Entwicklerversion mit Symbolen/Quellen oder ein lizenzierter Original-Vergleich auf unterstützter Play-Installation. Die Ursache der inkonsistenten IL2CPP-Daten des modifizierten Kandidaten ist noch nicht bewiesen. Keine Nullpointer-RET-Patches als Reparatur ausgeben, keine Lizenzfehler als Spielerfolg zählen.

---

## Historischer lokaler Stand (unverändert)

# Aktueller Arbeitsstand — Bus Simulator EVO 1.27.42

Stand der Sicherung: 2026-11-02. Dieses Dokument beschreibt den tatsächlichen Teststand; es wird kein Spielergebnis behauptet, das nicht in den Logs belegt ist.

## Original und Ergebnisumfang

- Getestet werden soll das unveränderte **Bus Simulator EVO 1.27.42** XAPK.
- SHA-256 des Original-XAPK: `ae537b3874e50f0b8953c29c85f1bd46e8cab2be1c6b66c950225a675f652bfb`.
- Das XAPK liegt nur im flüchtigen Cache außerhalb dieses Repositorys. `ci/local_x86_stock.sh` stellt es bei Bedarf wieder her und prüft den Hash vor jedem Lauf.
- Keine APK-Neusignierung, keine Spielkonfigurationsänderung und kein Ersatz des Originalspiels durch eine Stock-Kontrolle.
- Ein natives ARM64-Ergebnis konnte auf diesem Host nicht erreicht werden. Die aktive Vergleichsumgebung ist **x86_64 Android 15/API 35 unter TCG**, mit ARM64-Ausführung durch die im Image nachgewiesene `libndk_translation.so`. Das ist ausdrücklich kein nativer ARM64-Beweis.

## Was bereits verlässlich funktioniert

Auf x86_64/API 35 wurde mit `ro.hw_timeout_multiplier=60` vor dem Zygote-/Frameworkstart erreicht:

1. vollständiger Android-Boot inklusive benötigter Framework-Dienste;
2. Installation des kleinen unabhängigen Kontroll-APK;
3. erfolgreicher Kontroll-Launch mit `Status: ok`;
4. Prozessüberleben der Kontrolle und Screenshot;
5. unveränderte `system_server`-Generation während der geprüften Kontrollinstallation.

Der erste vollständige Kontrolldurchlauf verwendete `system_server` PID 681; die Kontrollinstallation dauerte 83,468 Sekunden. Der zuletzt abgebrochene Wiederholungslauf nutzte PID 684, verwendete die bereits installierte Kontrolle erneut und bestätigte Launch und Überleben erneut.

Nachweise liegen in `runtime-results/` sowie in:

- `reverse/logs/x8635-control-success-game-install-outer-timeout/`
- `reverse/logs/x8635-control-success-game-install-outer-timeout.tar.gz`
- älteren, ebenfalls gesicherten Fehler- und Diagnosearchive unter `reverse/logs/`

## Letzter, vom Nutzer angehaltener Lauf

- Voller Boot und Kontrolle waren erfolgreich.
- `pm path com.Ovilex.BusSimulator2023` vor der Spielinstallation lieferte keine Pfade. Die frühere, durch das äußere 29-Minuten-Limit unterbrochene Installation war daher **nicht dauerhaft registriert** und wurde korrekt nicht als Installation übernommen.
- Das Harness begann am 2026-11-01 um **16:06:29 UTC** erneut mit `adb install-multiple --no-streaming` der drei originalen APKs.
- Der Lauf wurde anschließend für diese Repository-Sicherung angehalten. `runtime-results/status.json` steht deshalb weiterhin auf `installing_game` mit `game_installed=false`.
- Es gibt weiterhin **kein abgeschlossenes Spielinstallations-, Launch-, 120-Sekunden-Survival- oder Crash-Urteil**. Kein Frameworkfehler ist dem Spiel zuzuordnen.

## Wichtige technische Erkenntnisse

- Native ARM64/API-28-Versuche scheiterten wiederholt am Host/Gast-Framework vor der Spielinstallation; die bekannten fehlerhaften Varianten nicht unverändert wiederholen.
- API 35 darf nicht vor StorageManager-Phase 600 zur Installation verwendet werden; ein früher Versuch erzeugte den nachgewiesenen `PackageManagerInternal.freeStorage()`-NPE.
- Der korrekte Settings-Schlüssel ist `system_server_watchdog_timeout_ms`. Eine Änderung auf 3.600.000 ms allein reicht nicht, wenn die aktuelle 60-Sekunden-Watchdog-Prüfung bereits überfällig ist.
- Der experimentelle OAT-`ret`-Patch an `Watchdog.run()` war nicht als wirksam belegt und wurde entfernt.
- Passive JDWP-Verbindungen zu `system_server` wurden vom Image mit EOF während des Handshakes abgelehnt; dieser Guardian ist nicht aktiv.
- AOSP 15 bestätigt `Build.HW_TIMEOUT_MULTIPLIER` über `ro.hw_timeout_multiplier` ausdrücklich für langsamere Systeme. Der Readback-Wert 60 und der anschließende Kontrollerfolg sind im aktuellen Orchestrator verankert.
- Das Harness prüft nun unmittelbar vor Kontroll- und Spielinstallation Boot-Flag, Framework-Dienste und dieselbe `system_server`-Generation erneut. Optionale Wiederverwendung einer Spielinstallation verlangt drei APK-Pfade und Version 1.27.42; andernfalls wird aus dem hash-geprüften Original neu installiert.

## Nächster sinnvoller Schritt

Den vorhandenen AVD ohne externes 29-Minuten-Prozesslimit erneut verwenden:

```bash
REUSE_AVD=true bash ci/local_x86_stock.sh
```

Der Orchestrator selbst und `ANDROID_INSTALL_TIMEOUT=1800` bleiben aktiv. Nicht wieder das bisherige äußere `timeout 1740` um den gesamten Lauf legen: Die drei originalen APKs umfassen zusammen etwa 1,19 GB (`UnityDataAssetPack.apk` allein etwa 1,087 GB), und genau dieses äußere Limit unterbrach den bisher weitesten Installationsversuch.

Erst nach `pm path`-Verifizierung darf `game_installed=true` gesetzt werden. Danach sind die bereits implementierten Schritte Launch, Screenshots nach 15/45/120 Sekunden, PID-Überleben, Foreground-Prüfung und Crash-Logauswertung erforderlich.

## Enthaltene Sicherung

Das Repository enthält den gesamten sichtbaren Arbeitsordner einschließlich CI-/Laufzeitskripten, Reverse-Engineering-Dateien, Werkzeugen, Logarchiven, aktuellem Status und Screenshots. Flüchtige SDK-/AVD-Caches und das große Original-XAPK außerhalb des Arbeitsordners sind nicht eingebettet; Wiederherstellung und kryptografische Identität sind im Skript dokumentiert. Zugangstoken oder Git-Credentials gehören nicht zur Sicherung.
