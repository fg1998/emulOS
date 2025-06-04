
# EmulOS  

<br>
EmulOS is an upcoming front-end for the Raspberry Pi, focusing on computer emulators rather than games.

The ROMs will not be displayed, only the systems and their variations. The goal is to emulate as many systems as possible without worrying about the ROMs. More than just a front-end, EmulOS is a complete distro for the Raspberry Pi and a full desktop environment.

![screenshot](https://github.com/fg1998/emulOS/blob/main/screenshot.png)

EmulOS is being developed with the Raspberry Pi 400 in mind, as its form factor is the one I find most appealing compared to computers from the 80s/90s.

More than 50 systems are emulated, with their respective BIOS and operating systems, ready to run with a single click.


## Systems
### Sinclair
* Sinclair ZX81
* Sinclair ZX Spectrum
* Sinclair QL
* Microdigital TK90x
* Microdigital TK95
* Sinclair Spectrum 128
* Sinclair Cambridge Z88
* Sam Coupe
* ZX Uno
* Zx Spectrum NEXT
### Amstrad
* Amstrad CPC 464
* Amstrad CPC 6128
* Amstrad CPC 664
### Apple
* Apple ][ Plus
* Apple //e
* Macintosh 128 System 2.2
* Macintosh 128 System 3.2
* Mac Performa System 7.5.5 with HD
### Commodore
* PET
* VIC 20
* Commodore 64
* Commodore 128
* Amiga 1000 (Workbench 1.3)
* Amiga 500 (Workbench 1.3)
* Amiga 500+ (Workbench 2)
* Amiga 1200 HD (Workbench 3.1, 2Mb Chip, 1Mb Fast, 100Gb HD)
* Amiga 4000 HD with ClassicWB (2 Mb Chio, 8Mb Fast, 100Gb HD)
* Amiga 600 HD (Workbench 2.1)
### MSX
* Philips VG8000
* Gradiente Expert 1.1
* National FS-5500 F2
* Sharp Hotbit 1.2
* Panasonic FS-A1WSX
* Panasonic FS-A1GT (Turbo R)
* Boosted MSX2 with 2Mb Ram, SCC+, FMPac, MSX AUdio, Moonsound, GFX9000, Basic compiler
* Booster MSX2+ with Kanji ROM, 2Mb Ram, SCC+, FMPac, MSX AUdio, Moonsound, GFX9000, Basic compiler
* Boosted Turbo R with MIDI, megaram IDE, 100Mb HD and CD-ROM
* Nextor IDE Expert 3 MSX2 with 100Mb Hard Disk and NextorOS
### Tandy/Radio Shack
* TRS-80 Model III
* TRS Color Computer 1
* Dragon 32
* Prológica CP-500
* Dragon 64
* TRS Color Computer 2
* Prológica CP-400 with Disk Dos
### Atari
* Atari 800
* Atari 1200XL
* Atari 520ST TOS 1.04
* Atari STe TOS 2.06
* Falcon 030 HD
### IBM-PC
* IBM-PC with Windows 1.04
* IBM-PC VGA with Windows 2.0
* IBM-PC VGA with Windows 3.11
* IBM-PC VGA with Windows 95 OSR2
### MISC
* Texas TI-99/4A
* BBC Micro

## Emulators used in this version
* ZEsarUX (Spectrum and Amstrad)
* Vice (Commodore 8 bit)
* Linapple (Apple 8 Bits)
* MinivMac (Macintosh)
* BasiliskII (Mac Performa)
* openMSX (MSX)
* SdlTRS (TRS-80)
* hatari (Atari ST/Falcon)
* Atari800 (atari 8 bit)
* Xroar (Coco & Dragon)
* DosBox (Windows 1, 2 and 3)
* DosBox-x (Windows 95)

## Key Features

1. **As many computers as possible**  
   Support for a wide range of computer systems, from 8-bit to modern retro machines.

2. **Emphasis only on computers, not consoles**  
   The focus is exclusively on computer emulation, not gaming consoles.

3. **Direct boot into chosen systems**  
   You can boot directly into the selected computer system, skipping menus.

4. **Complete desktop environment**  
   EmulOS is a full desktop environment where you will spend all your time, not just an application launcher.

5. **Self-updating**  
   Automatic updates to keep your system up-to-date.

## Getting Started

To run EmulOS FrontEnd, follow these steps:

1. Clone this repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the root folder of the project:
   ```bash
   cd EmulOS
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Start the application:
   ```bash
   npm start
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
