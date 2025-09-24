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

---

### 📦 `SOKOBAN`
**Box-pushing Puzzle Game**  
- A Sokoban clone similar to classic Unix/Linux versions  
- Supports custom levels

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

---

### 🧮 `MEFORTH`
**Forth Interpreter: 86eForth 2.02 Port**  
- Port of 86eForth to MenuetOS  

---

### 🗜 `@RCHER`
**Deflate Archive Extractor**  
- Unpacks `.ZIP`, `.GZ`, and `.PNG` files  
- Custom DEFLATE implementation in pure assembly  

---

### 🧩 `MEGAMAZE`

**Grid-Based Game Framework Featuring 13 Puzzles**

* A modular game engine for grid-based logic and puzzle games
* Includes 13 mini-games: mazes, chase games, line-pushing puzzles, switch toggles, timed movement traps, and more

**Highlights:**

* Shared game loop and input handling across all variants
* Extensible architecture — new puzzle types can be added by modifying game state functions

## 🧠 Historical Note

These applications demonstrate what was possible in the early 2000s on constrained systems using only raw assembly. They remain useful for exploring GUI programming, graphics rendering, and data compression without operating system overhead.
