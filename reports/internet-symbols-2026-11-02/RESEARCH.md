# Internet-Recherche und verifizierte Symbole

## Erfolgreich beschafft

Exakt passende **Unity-Engine-Symbole** für Android/ARM64, Unity 2022.3.62f2:

- URL: https://github.com/NextBep/AndroidNativeLibraries/releases/download/2022.3.62f2/libunity.sym.so.arm64-v8a
- Größe: 10.787.416 Bytes.
- SHA-256: `0e0e970678e4993673b7ce70c1af658eadcdee24397e94978d3e879949b9acc6`.
- GNU Build ID: `78b0074646c115a2f68b3ef36fae57c676213fac`.
- Diese Build ID stimmt mit der **tatsächlich getesteten** `libunity.so` überein. Es wurde nicht nur die Unity-Versionsnummer verglichen.
- Lokal: `/home/user/research/libunity.sym.so`; Arbeitskopie unter `reverse/symbols/` (nicht in Git eingebettet).
- Reproduzierbarer Download und Symbolauflösung: `python3 reverse/symbolicate_unity.py --download`.

## Neue, verifizierte Symbolauflösung

| Frame | Symbol | Offset |
|---|---|---|
| `libunity.so+0x9d6d20` | `ChainedSignalHandlers::ForwardSignal(int, siginfo*, void*)` | `0xbc` |
| `libunity.so+0x9e1ff8` | `NativeRuntimeException::SignalHandler(int, siginfo*, void*)` | `0x394` |
| `libunity.so+0x965c58` | `InitializeIl2CppFromMain(...)` | `0x10c` |

Damit ist die frühere Vermutung über die Signalweiterleitungsframes nun durch passende Symbole belegt. Diese Frames sind **keine bewiesene eigentliche Absturzstelle**; dort einen Rücksprung einzubauen würde den eigentlichen Fehler nicht reparieren.

## Zusätzlich beschaffte Laufzeit-Referenzquellen

Öffentlich abrufbare IL2CPP-Referenzquellen aus **2022.3.8f1**, nicht als exakte Spielquellen ausgeben:

https://github.com/MlgmXyysd/libil2cpp/tree/master/libil2cpp/Unity_2022.3/2022.3.8f1

Lokal: `/home/user/research/il2cpp-reference/` mit GlobalMetadata.cpp, MetadataCache.cpp, Runtime.cpp, Reflection.cpp, Type.cpp, GenericMethod.cpp, GenericMetadata.cpp und Datenstruktur-Headern.

Der frühere Nullpointer-Frame `0x2329068` passt strukturell zu `GlobalMetadata::GetGenericParameterFromIndex`, dessen erster relevanter Zugriff `genericContainer->genericParameterStart` ist. Der Aufrufer `0x235e66c` passt zu `GetFullySharedInst` in MetadataCache.cpp. Das ist eine **Quellcode-/Assembler-Zuordnung anhand der Struktur**, keine Symbolauflösung mit exakten spielbezogenen IL2CPP-Symbolen. Die Ursache des ungültigen Containers ist weiterhin nicht nachgewiesen.

## Nicht gefunden / nicht verfügbar

- Die Spielquellen von Bus Simulator EVO 1.27.42 und seine generierten C++-/IL2CPP-Debugsymbole wurden in der öffentlichen Recherche nicht gefunden.
- Der geprüfte exakte Referenzpfad `Unity_2022.3/2022.3.62f2/vm/GlobalMetadata.cpp` liefert HTTP 404.
- Der Download `https://unity.bepinex.dev/libil2cpp-source/2022.3.62f2.zip` liefert hier HTTP 403.
- Die generischen Unity-Engine-Symbole ersetzen **nicht** die spielbezogene `libil2cpp`-Symboltabelle. Die heruntergeladenen Laufzeit-Referenzquellen sind **nicht** das Unity-Projekt von OviLex.
- Eine angemeldete, lizenzierte Play-Installation lässt sich nicht als Datei aus dem Internet beschaffen. Der vorherige Lizenzdialog bleibt daher ein eigenständiger Vergleichsblocker.

## Ergebnisgrenze

Die Symbolbeschaffung und die exakte Auflösung der Engine-Frames sind erfolgreich. **Kein neuer Spielstart und keine reparierte APK belegt.** Ohne eine begründete Änderung wurde kein kostenpflichtiger weiterer Emulatorlauf als Wiederholung gestartet. Keine Fremd-Mod-APK wurde als Reparatur oder als Original ausgegeben.
