# Mega65 Hypervisor Tests

This is a collection of [Mega65](https://mega65.org/) programs that test out
the Hypervisor services.

These are in no way meant to be comprehensive tests. They are more like demonstrations.
They were created to exercise the Hypervisor on [xemu](https://github.com/lgblgblgb/xemu).


## Test results

These test were performed using:
- Mega65 MegaOS Hypervisor v00.16; git: hwsc,20211208.20,A390DFE
- Mega65 ROM 920265
- xemu custom-build hyppo@c22886

### General services

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $00 | $00 | Get Hypervisor Version | Not written | Not tested |
| $00 | $38 | Get Current Error Code | Not written | Not tested |
| $00 | $38 | Setup Transfer Area for Other Calls | Not written Not tested |


### Disk/storage hypervisor calls

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $00 | $02 | Get Default Drive (SD card Partition) | Not written | Not tested |
| $00 | $04 | Get Current Drive (SD card Partition) | Not written | Not tested |
| $00 | $06 | Select Drive (SD card Partition) | Not written | Not tested |
| $00 | $08 | Get Disk Size | Not written | Not implemented |
| $00 | $0A | Get Current Working Directory | Not written | Not implemented |
| $00 | $0C | Change Working Directory | Not written | Not tested |
| $00 | $0E | Create Directory | Not written | Not implemented |
| $00 | $10 | Remove Directory | Not written | Not implemented |
| $00 | $12 | Open Directory | Not written | Not tested |
| $00 | $14 | Read Next Directory Entry | Not written | Not tested |
| $00 | $16 | Close Directory | Not written | Not tested |
| $00 | $18 | Open File | Not written | Not tested |
| $00 | $1A | Read From a File | Not written | Not tested |
| $00 | $1C | Write to a File | Not written | Not implemented |
| $00 | $1E | Create File | Not written | Not implemented |
| $00 | $20 | Close File | Not written | Not tested |
| $00 | $22 | Close All Open Files | Not written | Not tested |
| $00 | $24 | Seek to a Given Offset in a File | Not written | Not implemented |
| $00 | $26 | Delete a File | Not written | Not implemented |
| $00 | $28 | Get Information About a File | Not written | Not implemented |
| $00 | $2A | Rename a File | Not written | Not implemented |
| $00 | $2C | Set time stamp of a file | Not written | Not implemented |
| $00 | $2E | Set the current filename | Not written | Not tested |
| $00 | $30 | Find first matching file | Not written | Not tested |
| $00 | $32 | Find subsequent matching file | Not written | Not tested |
| $00 | $34 | Find matching file (one only) | Not written | Not tested |
| $00 | $36 | Load a File into Main Memory | Not written | Not tested |
| $00 | $3C | Change Working Directory to Root Directory of Selected Partition | Not written | Not tested |
| $00 | $3E | Load a File into Attic Memory | Not written | Not tested |


### Disk image management

| Trap | Func | Service | Program | Status |
| --- | --- | --- | --- | --- |
| $00 | $40 | Attach a D81 Disk Image to Drive 0 | Not written | Not tested |
| $00 | $42 | Detach All D81 Disk Images | Not written | Not tested |
| $00 | $44 | Write Enable All Currently Attached D81 Disk Images | Not written | Not tested |
| $00 | $46 | Attach a D81 Disk Image to Drive 1 | Not written | Not tested |


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
this code is [licensed](https://github.com/jimnicholls/hyppo-test/blob/main/LICENSE)
and is

Copyright &copy; 2021, Jim Nicholls<br>
All rights reserved.
