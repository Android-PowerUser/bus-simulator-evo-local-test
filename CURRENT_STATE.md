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
