
# EmulOS  

* [What is it and what is it for?](#what-is-it-and-what-is-it-for)
* [Emulated Systems](#emulated-systems)
* [Download .img file](#download-img-file)
* [Manual Installation](#manual-installation)
* [File Transfer – games, demos, programs, etc.](#file-transfer--games-demos-programs-etc)
* [Emulators Used in this version](#emulators-used-in-this-version)
* [Contributing and Thanks](#contributing-and-thanks)
* [About BIOS files](#aboutbios)
* [Acknowledgments](#acknowledgments)




## What is it and what is it for?

EmulOS is a distro and a front-end for the Raspberry Pi, focusing on computer emulators rather than games.

The goal is to emulate as many systems as possible without worrying about the ROMs, Bios or other boring stuff. More than just a front-end, EmulOS is a complete distro for the Raspberry Pi and a minimal desktop environment.

EmulOS is being developed with the Raspberry Pi 400 in mind, as its form factor is the one I find most appealing compared to computers from the 80s/90s.

![screenshot](https://github.com/fg1998/emulOS/blob/main/emulos.png)



## Emulated Systems

More than 50 systems are emulated, with their respective BIOS and operating systems, ready to run with a single click.

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




## Download .img file

The ready-to-use `.img` file, suitable for writing to an SD card and running on a Raspberry Pi 4 series, is available at the link below.  

SD card image: (https://archive.org/details/emulOS_033_img)


Use your preferred SD card writing tool for Raspberry Pi according to your operating system (such as Balena Etcher, Win32 Disk Imager, etc.).




## Manual Installation

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



## File Transfer – games, demos, programs, etc.

To transfer your programs, games, and other files directly to your Raspberry Pi running EmulOS, you can use SSH.  
Use your preferred file transfer tool to connect from your main PC to the Pi running EmulOS using the following credentials:

**Username:** `emulos`  
**Password:** `emulos`

These are also the default login credentials for direct access to the Raspberry Pi in case you get stuck on the Raspberry Pi OS login screen.



## Emulators used in this version
* [ZEsarUX (Spectrum and Amstrad)](https://github.com/chernandezba/zesarux)
* [Vice (Commodore 8 bit)](https://vice-emu.sourceforge.io)
* [Linapple (Apple 8 Bits)](https://github.com/dabonetn/linapple-pie.git)
* [MinivMac (Macintosh)](https://github.com/vanfanel/minivmac_sdl2.git)
* [BasiliskII (Mac Performa)](https://github.com/cebix/macemu)
* [openMSX (MSX)](https://github.com/openMSX/openMSX.git)
* [SdlTRS (TRS-80)](https://gitlab.com/jengun/sdltrs.git)
* [hatari (Atari ST/Falcon)](https://www.hatari-emu.org)
* [Atari800 (atari 8 bit)](https://github.com/atari800/atari800/)
* [Xroar (Coco & Dragon)](https://www.6809.org.uk/xroar/)
* [DosBox (Windows 1, 2 and 3)](https://www.dosbox-staging.org)
* [DosBox-x (Windows 95)](https://dosbox-x.com)



## Contributing and Thanks

Found something wrong or have a suggestion? Open an issue on this repo.  
If you're feeling hands-on, feel free to submit a pull request with your improvements!

If you'd like to support this project financially, you can visit my [Patreon page](https://www.patreon.com/c/fg1998) or check out the donation links of the emulator creators listed below.

🇧🇷 Se você for brasileiro como eu e deseja fazer uma contribuição, pode enviar qualquer valor via pix para a chave fg1998@gmail.com


Special thanks to

* [Cesar Hernandez](https://github.com/chernandezba/zesarux)
* [Vice team](https://vice-emu.sourceforge.io/index.html#developers)
* [dabonetn](https://github.com/dabonetn)
* [Manuel Alfayate Corchete](https://github.com/vanfanel)
* [Christian Bauer](https://github.com/cebix)
* [openMSX Team](https://openmsx.org)
* [Jens Guenther](https://gitlab.com/jengun)
* [Hatari Team](https://www.hatari-emu.org)
* [Atari800 emulator team](https://github.com/atari800)
* [6809 org](https://www.6809.org.uk/xroar/)
* [DOSBox Staging team](https://www.dosbox-staging.org/about/)
* [DOSBox-X Team](https://dosbox-x.com)
* [Raspberry PI fundation](https://www.raspberrypi.com)
* [ChatGPT](https://chatgpt.com)




## About BIOS

Please note: Emulators often require BIOS files, operating system images, or other assets to function properly. Many of these files are in the public domain or originate from companies that no longer exist. However, some may still belong to existing companies or are in a legal status that is unclear.

If you opt for manual installation, you may choose to download only public domain BIOS files (even though the term "BIOS" here may also include other types of files used by older systems in emulOS), or files whose copyright status could not be clearly determined. Be aware that in most cases, you should only use full versions of these files if you own the rights or possess the original hardware.

The ready-to-use .img file includes all BIOS, operating systems, and other necessary files to run emulOS. Download it only if you meet the same conditions described above regarding full file usage.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
