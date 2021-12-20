# Mega65 Hypervisor Tests


## :warning: Under hiatus

Further work on this is unlikely to happen, at least in its current form.
See [mega65-core/issues/492](https://github.com/MEGA65/mega65-core/issues/492).


## Introduction

This is a collection of [Mega65](https://mega65.org/) programs that test out
the Hypervisor services.

These are in no way meant to be comprehensive tests. They are more like demonstrations.
They were created to exercise the Hypervisor on [xemu](https://github.com/lgblgblgb/xemu).


## Test results

These test were performed using:
- Mega65 MegaOS Hypervisor v00.16; git: jim,20211220.16,7770cf7
- Mega65 ROM 920269
- xemu custom-build hyppo@88222f

The Hypervisor includes these pull requests:
- [Return the file descriptor in A from trap_dos_openfile](https://github.com/MEGA65/mega65-core/pull/491)


### General services

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $00 | $00 | Get Hypervisor Version | [hyppo-ver.prg](hyppo-ver.c) | :white_check_mark: Passes |
| $00 | $38 | Get Current Error Code | [transfer-area.prg](transfer-area.c) | :white_check_mark: Passes |
| $00 | $3a | Setup Transfer Area for Other Calls | [transfer-area.prg](transfer-area.c) | :white_check_mark: Passes |


### Disk/storage hypervisor calls

Tested using [hdos-shell.prg](hdos-shell.c).

| Trap | Func | Service | Status |
| --- | --- | --- | --- |
| $00 | $02 | Get Default Drive (SD card Partition) | :white_check_mark: Passes |
| $00 | $04 | Get Current Drive (SD card Partition) | :white_check_mark: Passes |
| $00 | $06 | Select Drive (SD card Partition) | :white_check_mark: Passes |
| $00 | $08 | Get Disk Size | Not implemented |
| $00 | $0A | Get Current Working Directory | Not implemented |
| $00 | $0C | Change Working Directory | :white_check_mark: Passes |
| $00 | $0E | Create Directory | Not implemented |
| $00 | $10 | Remove Directory | Not implemented |
| $00 | $12 | Open Directory | :white_check_mark: Passes |
| $00 | $14 | Read Next Directory Entry | :white_check_mark: Passes |
| $00 | $16 | Close Directory | :white_check_mark: Passes |
| $00 | $18 | Open File | :white_check_mark: Passes |
| $00 | $1A | Read From a File | :white_check_mark: Passes |
| $00 | $1C | Write to a File | Not implemented |
| $00 | $1E | Create File | Not implemented |
| $00 | $20 | Close File | :white_check_mark: Passes |
| $00 | $22 | Close All Open Files | :white_check_mark: Passes |
| $00 | $24 | Seek to a Given Offset in a File | Not implemented |
| $00 | $26 | Delete a File | Not implemented |
| $00 | $28 | Get Information About a File | Not implemented |
| $00 | $2A | Rename a File | Not implemented |
| $00 | $2C | Set time stamp of a file | Not implemented |
| $00 | $2E | Set the current filename | :white_check_mark: Passes |
| $00 | $30 | Find first matching file | :white_check_mark: Passes |
| $00 | $32 | Find subsequent matching file | :white_check_mark: Passes |
| $00 | $34 | Find matching file (one only) | :white_check_mark: Passes |
| $00 | $36 | Load a File into Main Memory | :white_check_mark: Passes |
| $00 | $3C | Change Working Directory to Root Directory of Selected Partition | :white_check_mark: Passes |
| $00 | $3E | Load a File into Attic Memory | :white_check_mark: Passes |


### Disk image management

| Trap | Func | Service | Status |
| --- | --- | --- | --- |
| $00 | $40 | Attach a D81 Disk Image to Drive 0 | :x: Fails ¹ |
| $00 | $42 | Detach All D81 Disk Images | :white_check_mark: Passes |
| $00 | $44 | Write Enable All Currently Attached D81 Disk Images | :question: See [mega65-core/issues/494](https://github.com/MEGA65/mega65-core/issues/494) |
| $00 | $46 | Attach a D81 Disk Image to Drive 1 | :x: Fails ² |

¹ The hypervisor code works, but CBDOS seems to get out sync reporting either 74 drive not ready or the previously mounted image.

² The hypervisor code works, but CBDOS always reports a 74 drive not ready. This happens with BASIC's MOUNT command as well.


### Task and process management

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $00 | $50 | Get Task List | Not written | Not implemented |
| $00 | $52 | Send Message to Another Task | Not written | Not implemented |
| $00 | $54 | Receive Messages From Other Tasks | Not written | Not implemented |
| $00 | $56 | Write Into Memory of Another Task | Not written | Not implemented |
| $00 | $58 | Read From Memory of Another Task | Not written | Not implemented |
| $00 | $60 | Terminate Another Task | Not written | Not implemented |
| $00 | $62 | Create a Native MEGA65 Task | Not written | Not implemented |
| $00 | $64 | Load File Into Task | Not written | Not implemented |
| $00 | $66 | Create a C64-Mode Task | Not written | Not implemented |
| $00 | $68 | Create a C65-Mode Task | Not written | Not implemented |
| $00 | $6A | Exit and Switch to Another Task | Not written | Not implemented |
| $00 | $6C | Context-Switch to Another Task | Not written | Not implemented |
| $00 | $6E | Exit This Task | Not written | Not implemented |
| $00 | $70 | Toggle Write Protection of ROM Area | Not written | Not tested |
| $00 | $72 | Toggle 4510 vs 6502 Processor Mode | Not written | Not tested |
| $00 | $74 | Get current 4510 memory MAPping | Not written | Not tested |
| $00 | $76 | Set 4510 memory MAPping | Not written | Not tested |
| $00 | $7C | Write Character to Serial Monitor/Matrix Mode Interface | Not written | Not tested |
| $00 | $7E | Reset MEGA65 | Not written | Not tested |
| $01 | $00 | Enable Write Protection of ROM Area | Not written | Not tested |
| $01 | $02 | Disable Write Protection of ROM Area | Not written | Not tested |


### System partition & freezing

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $02 | $00 | Read System Config Sector Into Memory | Not written | Not tested |
| $02 | $02 | Write System Config Sector From Memory | Not written | Not tested |
| $02 | $04 | Apply System Config Sector Current Loaded Into Memory | Not written | Not tested |
| $02 | $06 | Set DMAgic Revision Based On Loaded ROM | Not written | Not tested |
| $02 | $10 | Locate First Sector of Freeze Slot | Not written | Not tested |
| $02 | $12 | Unfreeze From Freeze Slot | Not written | Not tested |
| $02 | $14 | Read Freeze Region List | Not written | Not tested |
| $02 | $16 | Get Number of Freeze Slots | Not written | Not tested |
| $03 | | Write Character to Serial Monitor/Matrix Mode Interface | Not written | Not tested |


### Secure mode

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $11 | | Request Enter Secure Mode | Not written | Not tested |
| $12 | | Request Exit Secure Mode | Not written | Not tested |
| $32 | | Set Protected Hardware Configuration | Not written | Not tested |
| $3F | | Freeze Self | Not written | Not tested |


## License

Except for the git submodules cc65 and mega65-libc,
your usage of this code is subject to [LICENSE](LICENSE).

Copyright &copy; 2021, Jim Nicholls<br>
All rights reserved.
