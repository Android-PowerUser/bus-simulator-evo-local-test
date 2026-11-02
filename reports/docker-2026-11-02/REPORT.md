# Android-Docker-Test — 2. November 2026

## Implementiert

- GitHub Actions: `.github/workflows/android-docker.yml`.
- Docker-Umgebung: `ci/docker/Dockerfile` und `ci/docker/run.sh`.
- Android 15/API35, x86_64 mit KVM und `libndk_translation.so` für ARM64. Dies ist kein nativer ARM64-Gerätetest.
- Getrennte Matrix-Jobs für Original und v17, unabhängige Kontroll-App, Installation aller drei APK-Splits, Screenshots und Crash-/Tombstone-Sicherung als Actions-Artefakte.
- Laufzeitbewertung mit acht Unit-Tests. Ein `am start`-Erfolg oder ein Lizenzdialog ist kein erfolgreicher Spielstart.

## Tatsächlich beobachtet

Lauf: https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41447624214

| Prüfung | Original | v17 + v9-Basis |
|---|---|---|
| Android/Kontroll-App | erfolgreich | erfolgreich |
| Spielinstallation, drei Splits | erfolgreich | erfolgreich |
| Android-Launch meldet `Status: ok` | ja | ja |
| Nativer Crash im Test | nein im Crash-Puffer | SIGSEGV, nach etwa 10 Sekunden |
| Stabiler Spielprozess | nein, PID 4307 → 4516 → 4825 | nein, vor 15 Sekunden beendet |
| Sichtbarer Zustand | Google-Play-Lizenzfehler | Rückkehr zum Launcher |
| Erfolgreicher Spielstart belegt | **nein** | **nein** |

**Achtung:** `stock-status-original-harness.json` enthält das unveränderte Ergebnis des damals verwendeten Skripts, einschließlich des falschen `runtime_start_verified: true`. Der Screenshot, die wechselnden PIDs und die Lizenz-Activity widerlegen diesen Erfolg. Die nachfolgende Auswertung lehnt diesen Zustand ausdrücklich ab.

## Crash-Befund

Der aktuelle v17-Lauf zeigt `SIGSEGV / SEGV_ACCERR` im Thread `UnityMain`, mit der letzten sichtbaren IL2CPP-Aufrufstelle `0x2327b48`. Die Fault-Adresse liegt im nicht zugreifbaren `dalvik-linear-alloc shadow map`-Bereich. Der `system_server` bleibt stabil. Ein früherer v17-Lauf zeigte dagegen einen Nullpointer bei Adresse `0xc`; statisch passt dazu die IL2CPP-Instruktion `ldr w8, [x0, #0xc]` bei `0x2329068`.

Die Unity-Frames `0x9d6d20`/`0x9e1ff8` gehören zur Signalweiterleitung. Aus ihrem Auftauchen darf nicht geschlossen werden, dass ein einfacher Patch dort den eigentlichen Fehler beseitigt. Die genaue Ursache der inkonsistenten IL2CPP-Daten ist noch nicht bewiesen.

## Offene Grenzen

- **Keine reparierte APK verifiziert.** Es wurden weder Fehlerstellen blind übersprungen noch Originaldateien als reparierte Modifikation ausgegeben.
- Das Original ist kryptografisch geprüft, bleibt jedoch an seiner Google-Play-Lizenzprüfung hängen. Der Emulator enthält das Google-APIs-Image, keine angemeldete Play-Store-Installation mit nachgewiesener Lizenz.
- Ein lizenzierter Original-Vergleich auf einem unterstützten Play-Gerät bzw. eine autorisierte Debug-/Testversion und native Symbole/Quellen wären die belastbare Grundlage für die weitere Reparatur.
- Kein Gameplay-Test bestanden.

## Wiederholen

In GitHub unter **Actions → Android Docker crash regression → Run workflow**, Release `local-test-242-v8-lifecycle` auswählen. Zugang zu den Release-Dateien erfolgt über den kurzlebigen `github.token` des Runners; ein persönlicher Token wird weder im Docker-Image noch im Workflow gespeichert.

## Abschließender Lauf mit korrigierter Bewertung

https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41448714075

Ausgeführt mit Commit `312c291`. Alle acht Unit-Tests und die Einrichtung der Docker-Emulatoren waren erfolgreich. Beide Spieleinstallationen waren erfolgreich.

- **Original:** `state=license_blocked`, `license_check_blocked=true`, `app_process_restarted=true`, `runtime_start_verified=false`.
- **v17:** `state=app_crashed`, `game_fatal_crash_seen=true`, `runtime_start_verified=false`. Erneut `SIGSEGV / SEGV_ACCERR`, Prozesslaufzeit im Tombstone 17 Sekunden.
- Beide Actions-Jobs sind deshalb bewusst **rot**. Das ist das korrekte Testergebnis und kein fehlgeschlagener Docker-Aufbau.

Die Dateien `*-final-status.json` und `*-final-crash.txt` sind unveränderte Nachweise dieses abschließenden Laufs. Vollständige Logs und Tombstones liegen in dessen Actions-Artefakten und lokal unter `latest-evidence/41448714075/`.
