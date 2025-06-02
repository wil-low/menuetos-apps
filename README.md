# 🧠 Applications for MenuetOS (2004–2005)

This repository contains a collection of desktop applications developed for **MenuetOS** (now known as **KolibriOS**) written entirely in **pure x86 assembly** using the [FASM (Flat Assembler)](https://flatassembler.net/) toolchain.

These apps showcase low-level GUI programming, custom file format parsers, and even vector font rendering — all in under 1 MB operating system environments.

## 💾 What is MenuetOS?

MenuetOS is a lightweight, GUI-based operating system written entirely in assembly language, designed to run directly from a floppy disk or small USB drive. It inspired the continued development of [KolibriOS](https://kolibrios.org/en/), which remains active today.

---

## 📦 Applications Included

### 🎲 `15`
**Classic Lloyd's Puzzle Game**  
- Sliding tile puzzle implementation with basic GUI  
- Written with native MenuetOS windowing system

---

### 📦 `SOKOBAN`
**Box-pushing Puzzle Game**  
- A Sokoban clone similar to classic Unix/Linux versions  
- Supports keyboard controls and custom levels

---

### 🖼 `GIF_LITE.INC`
**GIF Image Decoder + Viewer**  
- Decodes GIF image format (87a/89a)  
- Includes a minimal animation player  
- Designed for embedding in other assembly apps

---

### 🔠 `BGIFONT.INC`
**Borland Vector Font Renderer**  
- Processes Borland *.CHR vector fonts  
- Allows free scaling and rendering of fonts  
- Includes demo for scalable multilingual text display

---

### 🗓 `CALENDAR`
**Multilingual Desktop Calendar**  
- Displays Gregorian calendar with localization support  
- Integrates BGIFONT for scalable text rendering

---

### 📄 `RTFREAD`
**RTF (Rich Text Format) Reader**  
- Parses and renders basic RTF documents  
- Supports bold, italics, alignment, and font sizes  
- Uses BGIFONT for display output

---

### 🎵 `MIDAMP`
**MIDI Player (PC Speaker)**  
- Plays monophonic MIDI (.MID) files via PC speaker  
- No sound card required; supports tempo and note duration

---

### 🧮 `MEFORTH`
**Forth Interpreter: 86eForth 2.02 Port**  
- Port of 86eForth to MenuetOS  
- Implements a full Forth REPL environment for scripting

---

### 🗜 `@RCHER`
**Deflate Archive Extractor**  
- Unpacks `.ZIP`, `.GZ`, and `.PNG` files  
- Custom DEFLATE implementation in pure assembly  
- Can serve as a base for file viewers or loaders

Here’s the updated `README.md` section with the **MEGAMAZE** application included, highlighting its role as a game framework and emphasizing its extensibility and diversity:

---

### 🧩 `MEGAMAZE`

**Grid-Based Game Framework Featuring 13 Puzzles**

* A modular game engine for grid-based logic and puzzle games
* Includes 13 mini-games: mazes, chase games, line-pushing puzzles, switch toggles, timed movement traps, and more
* Acts as a sandbox for game logic experimentation under MenuetOS constraints

**Highlights:**

* Shared game loop and input handling across all variants
* Extensible architecture — new puzzle types can be added by modifying game state functions

---

## 🛠 Build Instructions

These programs are designed for **MenuetOS/KolibriOS**. You’ll need:

- [FASM](https://flatassembler.net/)
- A MenuetOS image or VM (Bochs, QEMU, or real hardware)
- Some apps may need file paths or font files placed in expected folders

```bash
fasm calendar.asm calendar
````

Place compiled binaries into the `FD` or `HD` image and run from the MenuetOS desktop.

---

## 📜 License

This repository is shared for archival and educational purposes. Contact the author for reuse beyond personal exploration.

---

## 🧠 Historical Note

These applications demonstrate what was possible in the early 2000s on constrained systems using only raw assembly. They remain useful for exploring GUI programming, graphics rendering, and data compression without operating system overhead.
