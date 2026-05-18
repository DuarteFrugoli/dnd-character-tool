# Changelog

All notable changes to this project will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

---

## [0.1.1] - 2026-05-18

### Fixed
- Android: corrected package namespace from `com.example` to `com.duartefrugoli.dnd_character_tool`, fixing crash on launch (ClassNotFoundException)
- Android: configured release signing with upload keystore for Play Store

### Internal
- versionCode 3 (closed testing, first functional build)

---

## [0.1.0] - 2026-05-18

### Internal
- versionCode 1–2: internal and closed testing builds with namespace bug (not distributed to users)

---

## [1.0.0] - 2026-04-30

### Added
- First official release
- 7-step character creation wizard: class, race, background, skills, attributes, name and review
- Attribute methods: Standard Array and Point Buy
- Automatic racial bonuses (PHB) or free distribution (Tasha's)
- Full character sheet with tabs: Stats, Skills, Features, Spells, Inventory, Notes
- HP tracker, spell slot tracker and feature use tracker
- Full SRD spell list with filters
- Support for prepare-all classes, subclasses and innate racial spells
- Export/Import via JSON, compressed token (gzip + base64url) and QR Code
- QR Code scanning via camera
- Pin and drag-to-reorder characters
- 8 color themes with swatch preview
- Android, iOS and Web support
- Character photo: pick from gallery and crop to 1:1
- Bilingual README (EN / PT) and proprietary LICENSE with SRD CC BY 4.0 attribution
