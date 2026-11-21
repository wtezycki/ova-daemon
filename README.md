# ova-capture-daemon

Demon dla Linuxa, który na żywo przechwytuje dźwięk z mikrofonu i z wyjścia audio jako dwa osobne strumienie i bez utraty próbek przekazuje je do lokalnego rozpoznawania mowy (O.V.A). Korzysta z szeregowania czasu rzeczywistego, blokady pamięci, pamięci współdzielonej i odcięcia od sieci.

**Stan:** etap 1, czyli środowisko i uruchomienie gotowych przykładów.

## Start

```bash
scripts/check-env.sh   # co jest, a czego brakuje
make                   # buduje przykłady do build/
```

Instalacja i konfiguracja: [docs/setup.md](docs/setup.md).

## Uruchomienie przykładów

```bash
build/tutorial1                        # wersje bibliotek PipeWire
build/tutorial2                        # lista obiektów w grafie PipeWire
build/tutorial4                        # odtwarza ton 440 Hz
build/audio-capture                    # nagrywa mikrofon, wypisuje poziom
PIPEWIRE_PROPS='{ stream.capture.sink = true }' build/audio-capture   # to samo dla dźwięku z wyjścia (monitor)

build/pshm_ucase_bounce /myshm & build/pshm_ucase_send /myshm hello

build/seccomp 41 0xC000003E 1 /usr/bin/curl https://example.com   # socket() zablokowany

examples/run-tools.sh record | latency | netns
```
