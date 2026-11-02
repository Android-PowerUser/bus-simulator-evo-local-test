# ARM64-Fehlerkontext erfolgreich gesichert

## Ergebnis der Diagnose

Lauf: https://github.com/Android-PowerUser/bus-simulator-evo-local-test/actions/runs/41476111893

Die diagnostische Probe hat erstmals den **ursprünglichen ARM64-Registerkontext vor der Unity-Signalweiterleitung** in einer 4096-Byte-Datei gesichert. Der Absturz wird anschließend unverändert weitergeleitet; der Prozess beendet sich weiter mit SIGSEGV.

Der Kontext ist gegen Tombstone-Mappings und die tatsächlich getestete ARM64-ELF-Datei geprüft:

- Tatsächlicher Fehler-PC: `libil2cpp.so + 0x2329068`.
- Fehlerhafte Instruktion: **`ldr w8, [x0, #0xc]`**.
- Originalregister: **`x0 = 0`**, `x20 = 0`.
- Daraus folgende Zugriffsadresse: **`0xc`**, identisch mit dem SIGSEGV-Tombstone.
- Rücksprungadresse: `libil2cpp.so + 0x235e6f4`.
- Dies bestätigt die bisherige Quellcode-Zuordnung zu einem Null-GenericContainer im Pfad `GetFullySharedInst → GetGenericParameterFromIndex`.

Die genaue **Ursache**, weshalb eine nichtleere generische Instanz einen Null-Container besitzt, ist damit noch nicht bewiesen. Ein pauschaler RET-/Nullwert-Patch würde nur den unmittelbaren Zugriff überspringen; er repariert nicht nachgewiesenermaßen die generierten Metadaten oder Methodenreferenzen und wurde deshalb nicht als Fix eingesetzt.

## Was geändert wurde

- `ci/build_context_probe.py`: hash-geprüfte, rein diagnostische Instrumentierung von `ChainedSignalHandlers::ForwardSignal` in der exakten Unity-Bibliothek. Originalregister/NZCV werden wiederhergestellt, der ursprüngliche Prolog und Handler laufen danach weiter.
- Die Probe wurde zusätzlich mit Unicorn überprüft: Erhalt aller 31 GPRs und NZCV; nur openat/write/close; ursprünglicher Stack-Prolog ausgeführt.
- `reverse/decode_guest_context.py`: ARM64-ucontext-Decoder. Berücksichtigt doppelte native-bridge-ELF-Mappings und stellt nicht fälschlich die zuerst gemappte vollständige Datei als Ladebasis dar.
- Übersetzter ARM64-Code ist auf dem x86-Host teilweise `r--` gemappt. Seine Ausführbarkeit wurde zusätzlich am **ARM64-ELF-PF_X** geprüft; Host-Permissions allein wären hier irreführend.
- Vor dem Launch wird Androids eigener Vollbild-Einführungshinweis bestätigt. Ein Lizenzdialog wird nicht angeklickt oder umgangen.
- Diagnostische Prozess-Liveness gilt ausdrücklich **nicht** als reparierter Spielstart.

## Vorherigen grünen Diagnoselauf nicht missverstehen

Lauf 41474270941 blieb 120 Sekunden mit derselben PID aktiv. Sein Screenshot zeigt jedoch einen schwarzen Hintergrund und den Android-Hinweis „Viewing full screen“. Es gab weder ein Spielmenü noch einen gesicherten Fehlerkontext. Sein damaliges `runtime_passed` ist **kein Reparaturnachweis**. Nach Korrektur und Entfernung des Android-Hinweises wurde der eigentliche native Fehler wieder reproduziert und der Kontext erfolgreich gesichert.

## Aktueller Stand

**Diagnoseziel erreicht; APK-Reparatur weiterhin offen. Kein Gameplay-Erfolg.** Beide bisherigen Fehlerbilder (Nullcontainer bzw. ungültiger generischer Methodenindex) deuten auf inkonsistente generische Laufzeit-/Metadaten hin; diese gemeinsame Ursache ist eine Hypothese, kein bewiesener Fix.

Die gespeicherten Dateien sind kleine, unveränderte Laufzeitnachweise plus deren nachvollziehbare Dekodierung. Vollständige Tombstones und Logs liegen in den privaten Actions-Artefakten und lokal unter `latest-evidence/41476111893/`.
