# M5StackChan StickS3 Remote

This repository contains firmware assets and source patches for using an M5StickS3 with a Unit Joystick2 as an ESP-NOW remote controller for StackChan.

The physical controller enclosure is based on this MakerWorld model:

[M5 StickC 遥控附件摇杆灯 - MakerWorld](https://makerworld.com.cn/zh/models/2418504-m5-stickc-yao-kong-fu-jian-yao-gan-deng#profileId-2752841)

## Firmware

```text
StackChan-RemoteControl-StickS3-Joystick2_0x0.bin
```

This is the current tested StickS3 + Unit Joystick2 firmware image. It is a merged `0x0` image for M5Burner `User Custom`.

The repository keeps firmware binaries so users can flash directly without rebuilding.

## What This Adds

The patch adapts the upstream StackChan remote firmware for:

* M5StickS3 target (`esp32s3`)
* Unit Joystick2 on StickS3 PORT.A
* ESP-NOW control packet compatibility with StackChan's `ESPNOW.REMOTE` app
* M5Burner-friendly merged `0x0` firmware packaging
* Direct ESP-IDF flash helper scripts
* 8MB StickS3 flash partition layout
* StickS3 ST7789 display initialization
* StickS3 PORT.A Unit Joystick2 support (`SDA=G9`, `SCL=G10`, address `0x63`)

## Source Patch

```text
patches/stackchan-remote-sticks3-joystick2.patch
```

The patch targets the fixed upstream submodule commit
`51a06177f7a820762c63c845bb4fe2a563be3eb4`. It includes the StickS3 display setup,
Joystick2 support, build configuration, helper scripts, and the application
control fields used by the official StackChan receiver.

Start from a fresh clone with its pinned submodule and apply the patch once:

```cmd
git clone --recurse-submodules https://github.com/OXOOOOX/StackChan-Remote-StickS3-Joystick2.git
cd StackChan-Remote-StickS3-Joystick2
git -C StackChan-official rev-parse HEAD
git -C StackChan-official apply --check ..\patches\stackchan-remote-sticks3-joystick2.patch
git -C StackChan-official apply ..\patches\stackchan-remote-sticks3-joystick2.patch
```

The printed submodule SHA must match the commit above. Do not apply the patch
again to a working tree that already contains these changes.

The 2026-09-03 archive review found that the published patch referenced two local
files without including their contents:

* `remote/code/main/ui/ui_joystick_settings_screen.c`
* `remote/code/main/ui/ui_joystick_settings_screen.h`

This source packaging correction adds those two new-file hunks and preserves all
previous hunks unchanged. A forward `git apply --check` and an actual application
to an isolated copy of the fixed upstream commit both passed; the required
project sources and headers were checked there. No firmware was rebuilt or
flashed for this correction, and the existing `.bin` files are unchanged.

## ESP-NOW Transport Compatibility

The source published at `b61fae0` uses the `espressif/esp-now` high-level
`espnow_send(ESPNOW_DATA_TYPE_DATA, ...)` transport. Its application control buffer
is 8 bytes, but the component adds its own framing before calling the native
ESP-NOW API. This is the route used with the official receiver component.

The older `2ce2b47` patch instead changed the transport to native `esp_now_send`
for raw payloads. That transport change is absent from the later published
patch; the later display and joystick fixes must not be treated as proof that
raw 8-byte UIFlow2 reception also works. For a UIFlow2 receiver, first verify the
actual received payload length and wire format with a monitor. Reconciling these
two transport routes remains separate work; this correction changes no device
logic.

The old local `patches/fix-joystick-output-clamp.patch` is not part of the current
rebuild sequence. The main patch already contains the packet packing and range
guards, and the old supplemental patch does not apply to the current sources.

## Build M5Burner Firmware

Open an ESP-IDF 5.4 Command Prompt, then run:

```cmd
cd /d <repo-root>
package_sticks3_m5burner.cmd
```

The final generated M5Burner image used by this repository is:

```text
<repo-root>\StackChan-RemoteControl-StickS3-Joystick2_0x0.bin
```

## Flash With ESP-IDF

Open an ESP-IDF 5.4 Command Prompt, connect the StickS3, then run:

```cmd
cd /d <repo-root>
flash_sticks3_monitor.cmd
```

If automatic port detection fails, specify the COM port from Device Manager:

```cmd
cd /d <repo-root>
flash_sticks3_monitor.cmd -p COM5
```

## Hardware

* M5StickS3
* Unit Joystick2 connected to PORT.A
* StackChan running firmware with the `ESPNOW.REMOTE` app

The remote defaults to receiver ID `0`, which broadcasts to any StackChan receiver on the same ESP-NOW channel.

## Controls

* `BtnA` click: switch `Setup -> Running -> IMU`
* `BtnA` hold on `Running`: open joystick settings
* `BtnA` click in joystick settings: return to `Running`
* `BtnB` in `Setup`: select Channel or Receiver ID
* `BtnB` in `Running` / `IMU`: toggle the laser flag
* `BtnB` in joystick settings: select `Invert X` or `Invert Y`
* Joystick up/down in joystick settings: toggle the selected inversion option

Joystick inversion settings are saved to NVS and restored after reboot.

## StackChan Setup

On StackChan:

1. Open `ESPNOW.REMOTE`.
2. Choose `Receiver`.
3. Use the same Wi-Fi channel as the StickS3 remote.
4. Use receiver ID `0` for broadcast, or match the remote's configured receiver ID.
