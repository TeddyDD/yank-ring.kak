# Yank Ring

[![IRC][IRC Badge]][IRC]

###### [Usage](#usage) | [Documentation](#commands) | [Contributing](CONTRIBUTING)

> [Kakoune] extension with record of previous yanks.

[![asciicast](https://asciinema.org/a/219306.svg)](https://asciinema.org/a/219306)

## Dependencies

- [Select]

## Installation

### [Pathogen]

``` kak
pathogen-infect /home/user/repositories/github.com/alexherbo2/yank-ring.kak
```

## Configuration

``` kak
map global normal Y ':<space>yank-ring<ret>'
```

## Usage

```
yank-ring
```

- Yank some things and open the Yank Ring with the `yank-ring` command
- Select a previous yank and type <kbd>Return</kbd> to validate (See [Select] for commands)
- Yank Ring closes and copies to the copy register

## Commands

- `yank-ring`: Open the Yank Ring to copy a previous yank

## Options

- `yank_ring_size` `int`: Maximum number of entries in the Yank Ring (Default: 60)

[Kakoune]: http://kakoune.org
[IRC]: https://webchat.freenode.net?channels=kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[Pathogen]: https://github.com/alexherbo2/pathogen.kak
[Select]: https://github.com/alexherbo2/select.kak
