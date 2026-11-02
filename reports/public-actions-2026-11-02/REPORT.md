# Veröffentlichung und weiterer Reparaturversuch

## Öffentlichschaltung abgeschlossen

https://github.com/Android-PowerUser/bus-simulator-evo-local-test

Am 2. November 2026 nach ausdrücklicher Auswahl von **„Bestehendes Repo vollständig öffentlich“** veröffentlicht. Vorher wurde auf die Veröffentlichung der Git-Historie, Spiel-APKs und des Test-Signierschlüssels hingewiesen. GitHub API meldet `private=false`; Zugriff ohne Anmeldung wurde geprüft.

**Der enthaltene Test-Signierschlüssel ist öffentlich/offengelegt. Er ist kein Produktionsschlüssel und darf nicht für vertrauenswürdige Original-Releases verwendet werden.** Der persönliche GitHub-Zugangstoken wurde nicht in den versionierten Dateibaum aufgenommen.

## Konkreter Fehler im bisherigen Host-Emulator korrigiert

Die echte native DT_INIT-Prozedur übergibt die **ELF-Ladebasis** als Argument an ExecuteProgram. Der Host-Emulator übergab fälschlich NULL. Diese Annahme wurde durch Ausführung der originalen 64 Maschinenbytes in Unicorn widerlegt und korrigiert. Der neue Test prüft die übergebene Basis, Asset-Adresse, Argumentanzahl und das reservierte Nullargument.

Die isolierte A/B-Prüfung zeigt jedoch:

| Host-VM-Konfiguration | Ergebnis |
|---|---|
| Alter NULL-Parameter | Stopp bei `0x45ca0`, 7.306.932 Instruktionen, 5.415 VM-Dispatches, 0 Zielzugriffe |
| Richtige ELF-Basis | Derselbe Stopp, dieselben Zähler, 0 Zielzugriffe |
| Mit Startup, Framework-Profil | Stopp am unveränderten Hash-Sicherheitslimit, 8.632.403 Instruktionen |
| Mit Startup, CoreComponentFactory-Profil | Derselbe Hash-Sicherheitsstopp, 8.745.827 Instruktionen |

Das Manifest bestätigt `androidx.core.app.CoreComponentFactory`. Kein Hash-Guard und kein VM-Kontrollfluss wurde erzwungen. Die Korrektur ist real, erklärt aber den APK-Absturz nicht allein. Vollständige Host-Logs liegen hier komprimiert bei.

## APK-Kandidat v18 tatsächlich in öffentlichem Actions-Lauf getestet

https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41484535040

Getesteter Commit: `1ef8f14`.

Quellcode-gestützte Hypothese: Der optionale `GetFullySharedInst`-Lookup liefert für nicht verfügbare Instanzen bereits NULL. Ein präziser Guard lehnt zusätzlich einen fehlenden GenericContainer ab, statt ihn zu dereferenzieren. Nichtleere gültige Eingaben laufen durch den ursprünglichen Prolog und Code. Drei Unicorn-Tests sichern dieses Verhalten ab. Keine Signale werden unterdrückt, keine Lizenzprüfung verändert.

**Ergebnis: Hypothese als vollständige Reparatur verworfen.** Kontroll-App und alle Spiel-Splits installieren sich; das Spiel stürzt nach sechs Sekunden weiterhin ab.

### Zusätzlich belegte ungültige Methodenreferenz

Die ursprünglichen ARM64-Register stehen diesmal bereits in Unitys eigenem Crash-Log vor der Signalweiterleitung:

- Fehler-PC: `libil2cpp.so + 0x2327f9c`.
- Instruktion: `ldr x19, [x20, w0, sxtw #3]`.
- Index `w0 = 0x0d4dcbfa = 223202298`.
- Tabellenbasis `x20 = 0x766690609310`.
- Fehleradresse `0x7666facef2e0`.
- Exakt nachgerechnet: **Tabellenbasis + 8 × Index = Fehleradresse**.

Dies ist ein ungültiger Zugriff im generischen Methodenauflösungspfad. Ein weiterer pauschaler Null-/Bereichs-Guard würde damit noch keine korrekten Methodenreferenzen erzeugen. Der experimentelle Guard bleibt ausdrücklich optional und ist **keine reparierte APK**.

## Tatsächlicher Stand

- Repository öffentlich: **erledigt**.
- Android-Emulator in Docker/Actions: **funktioniert**.
- Installation und Crash-Nachweise: **erfolgreich reproduziert**.
- Tests für Diagnose und Patchvertrag: **16 Unit-Tests erfolgreich**.
- Native APK-Reparatur / sichtbarer Spielstart / Gameplay: **nicht erreicht**.

Die Herkunft der ungültigen generischen Metadaten-/Methodenreferenzen muss weiter aufgeklärt werden. Der Originalvergleich bleibt durch den Google-Play-Lizenzdialog eingeschränkt; generische Unity-Symbole sind vorhanden, die konkreten OviLex-Spielquellen und generierten IL2CPP-Symbole wurden öffentlich nicht gefunden. Kein Erfolg wird aus einem grünen Liveness-Test oder schwarzen Bildschirm abgeleitet.
