; ============================================================
; SNES LoROM HELLO WORLD
; self-contained
; no assets.bin
; based on the old DMA foundation style
; ============================================================

.MEMORYMAP
  DEFAULTSLOT 0
  SLOTSIZE $8000
  SLOT 0 $8000
.ENDME

.ROMBANKMAP
  BANKSTOTAL 1
  BANKSIZE $8000
  BANKS 1
.ENDRO

.SNESHEADER
  ID "SNES"
  NAME "HELLO WORLD DEMO     "
  LOROM
  SLOWROM
  CARTRIDGETYPE $00
  ROMSIZE $08
  SRAMSIZE $00
  COUNTRY $01
  LICENSEECODE $00
  VERSION $00
.ENDSNES

; ------------------------------------------------------------
; PPU registers
; ------------------------------------------------------------

INIDISP = $2100
BGMODE  = $2105
BG1SC   = $2107
BG12NBA = $210B
BG1HOFS = $210D
BG1VOFS = $210E
VMAIN   = $2115
VMADDL  = $2116
CGADD   = $2121
CGDATA  = $2122
TM      = $212C

; ------------------------------------------------------------
; DMA registers
; ------------------------------------------------------------

MDMAEN = $420B
DMAP0  = $4300
BBAD0  = $4301
A1T0L  = $4302
A1T0H  = $4303
A1B0   = $4304
DAS0L  = $4305
DAS0H  = $4306

; ------------------------------------------------------------
; data sizes
; ------------------------------------------------------------

CHR_BYTES = $0080     ; 8 tiles * 16 bytes each = 128 bytes
MAP_BYTES = $0800     ; full 32x32 tilemap = 2048 bytes

.BANK 0 SLOT 0
.ORG 0

Reset:
  sei
  clc
  xce

  .ACCU 16
  .INDEX 16
  rep #$38

  ldx #$1FFF
  txs

  .ACCU 8
  sep #$20

  ; screen off
  lda #$80
  sta INIDISP

  ; BG setup
  lda #$00
  sta BGMODE

  stz BG1HOFS
  stz BG1HOFS
  stz BG1VOFS
  stz BG1VOFS

  stz BG1SC          ; tilemap at VRAM $0000

  lda #$01
  sta BG12NBA        ; tile graphics at VRAM $1000

  ; ----------------------------------------------------------
  ; load palette to CGRAM
  ; ----------------------------------------------------------

  stz CGADD
  ldx #$0000

PalLoop:
  lda.w Palette,x
  sta CGDATA
  inx
  cpx #$0008
  bne PalLoop

  ; ----------------------------------------------------------
  ; load tile graphics to VRAM with DMA
  ; ----------------------------------------------------------

  lda #$80
  sta VMAIN

  .ACCU 16
  rep #$20
  lda #$1000
  sta VMADDL
  .ACCU 8
  sep #$20

  lda #$01
  sta DMAP0

  lda #$18
  sta BBAD0

  .ACCU 16
  rep #$20
  lda #AssetsTiles
  sta A1T0L
  .ACCU 8
  sep #$20

  lda #$00
  sta A1B0

  .ACCU 16
  rep #$20
  lda #CHR_BYTES
  sta DAS0L
  .ACCU 8
  sep #$20

  lda #$01
  sta MDMAEN

  ; ----------------------------------------------------------
  ; load tilemap to VRAM with DMA
  ; ----------------------------------------------------------

  lda #$80
  sta VMAIN

  .ACCU 16
  rep #$20
  lda #$0000
  sta VMADDL
  .ACCU 8
  sep #$20

  lda #$01
  sta DMAP0

  lda #$18
  sta BBAD0

  .ACCU 16
  rep #$20
  lda #AssetsTilemap
  sta A1T0L
  .ACCU 8
  sep #$20

  lda #$00
  sta A1B0

  .ACCU 16
  rep #$20
  lda #MAP_BYTES
  sta DAS0L
  .ACCU 8
  sep #$20

  lda #$01
  sta MDMAEN

  ; show BG1
  lda #$01
  sta TM

  lda #$0F
  sta INIDISP

MainLoop:
  jmp MainLoop

NmiHandler:
  rti

IrqHandler:
  rti

; ============================================================
; palette
; 4 colors = 8 bytes
; ============================================================

Palette:
  .db $00,$00    ; black
  .db $FF,$7F    ; white
  .db $00,$00
  .db $00,$00

; ============================================================
; tile graphics
; 8 tiles, 16 bytes each, 2bpp
; tile 0 = blank
; tile 1 = H
; tile 2 = E
; tile 3 = L
; tile 4 = O
; tile 5 = W
; tile 6 = R
; tile 7 = D
; ============================================================

AssetsTiles:
  ; blank
  .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

  ; H
  .db $81,$00,$81,$00,$81,$00,$FF,$00,$81,$00,$81,$00,$81,$00,$81,$00

  ; E
  .db $FF,$00,$80,$00,$80,$00,$FE,$00,$80,$00,$80,$00,$80,$00,$FF,$00

  ; L
  .db $80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$FF,$00

  ; O
  .db $7E,$00,$81,$00,$81,$00,$81,$00,$81,$00,$81,$00,$81,$00,$7E,$00

  ; W
  .db $81,$00,$81,$00,$81,$00,$81,$00,$81,$00,$99,$00,$A5,$00,$42,$00

  ; R
  .db $FE,$00,$81,$00,$81,$00,$FE,$00,$90,$00,$88,$00,$84,$00,$82,$00

  ; D
  .db $FC,$00,$82,$00,$81,$00,$81,$00,$81,$00,$81,$00,$82,$00,$FC,$00

; ============================================================
; tilemap
; 32x32 entries = 2048 bytes
; each entry = tile, attr
; HELLO WORLD starts at row 14 col 10
; offset = (14*32+10)*2 = 916 = $0394 bytes into tilemap
; ============================================================

AssetsTilemap:

  ; 916 bytes of zero before the message
  .dsb $0394, $00

  ; HELLO WORLD
  .db $01,$00   ; H
  .db $02,$00   ; E
  .db $03,$00   ; L
  .db $03,$00   ; L
  .db $04,$00   ; O
  .db $00,$00   ; space
  .db $05,$00   ; W
  .db $04,$00   ; O
  .db $06,$00   ; R
  .db $03,$00   ; L
  .db $07,$00   ; D

  ; fill rest of tilemap with zeros
  .dsb MAP_BYTES - $0394 - $0016, $00

.ORG $7FFC
.dw Reset