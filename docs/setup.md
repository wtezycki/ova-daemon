# Środowisko deweloperskie

Instrukcja dla Ubuntu 24.04 z PipeWire. Po każdym kroku sprawdź stan skryptem:

```bash
scripts/check-env.sh
```

## Maszyna referencyjna

| | |
|---|---|
| CPU / RAM | Intel Core i5-10400F (6C/12T), 16 GB |
| System | Ubuntu 24.04.4 LTS, jądro 7.0.0-43-generic (`PREEMPT_DYNAMIC`, bez `PREEMPT_RT`) |
| Audio | PipeWire 1.0.5 + pipewire-pulse + WirePlumber, zestaw słuchawkowy USB |
| Kompilator | gcc 13.3, GNU make, pkg-config |

## 1. Pakiety

```bash
sudo apt install build-essential pkg-config libpipewire-0.3-dev rt-tests stress-ng
```

| Pakiet | Do czego |
|---|---|
| `build-essential`, `pkg-config` | kompilator, make, flagi bibliotek |
| `libpipewire-0.3-dev` | nagłówki i `.pc` do budowania klientów PipeWire |
| `rt-tests` | `cyclictest`: pomiar opóźnień wybudzeń |
| `stress-ng` | sztuczne obciążenie CPU i pamięci |

Narzędzia PipeWire (`pw-record`, `pw-cli`, `pw-top`) są w systemie domyślnie (pakiet `pipewire-bin`).

## 2. Uprawnienia czasu rzeczywistego

Domyślnie `ulimit -r` = 0, więc zwykły użytkownik nie może ustawić `SCHED_FIFO`. Nadaj limit grupie `audio` i dodaj się do niej:

```bash
printf '@audio - rtprio 95\n@audio - memlock unlimited\n' | sudo tee /etc/security/limits.d/99-audio-rt.conf
sudo usermod -aG audio $USER
```

Wyloguj się i zaloguj ponownie. Sprawdź:

```bash
ulimit -r    # 95
ulimit -l    # unlimited
```

## 3. Budowanie przykładów

```bash
make            # wszystko
make manpages   # tylko przykłady z man pages (nie wymagają libpipewire)
```

Binarki trafiają do `build/`.
