# Premium profile icons

Premium icons live in `assets/icons/premium/`. Each PNG is used in the app as a purchasable profile avatar and needs a separate image for Google Play one-time product setup.

## Quick start

Add or replace a source PNG (any square size), then run:

```bash
./scripts/prepare_premium_icons.sh
```

This will:

1. Export a **store product image** to `play-store/products/{productId}.png` (1024×1024, RGB PNG with no alpha). The `play-store/` directory is gitignored.
2. Normalize the in-app icon to **256×256** with alpha, under **150 KB** (same rules as `octopus.png`).
3. Auto-crop icons that have **black rounded-corner padding** on a white background (e.g. squircle exports), zooming in while keeping the square dimensions.

Validate without changing files:

```bash
./scripts/validate_premium_icons.sh
```

Regenerate Play Console images only (leave in-app PNGs unchanged):

```bash
./scripts/prepare_premium_icons.sh --play-store-only
```

## Specs

| Use | Size | Location |
| --- | --- | --- |
| In-app icon | 256×256 PNG with alpha, ≤ 150 KB | `assets/icons/premium/{id}.png` |
| App Store / Play one-time product | 512–1080 px square, RGB PNG (no alpha), ≤ 8 MB, no text/branding | `play-store/products/{productId}.png` |

## Product ID mapping

Play export filenames come from `store/iap_products.json` when an entry exists with matching `iconId`. Otherwise the script uses `vocab_icon_{iconId}.png`.

Example: `octopus.png` → `play-store/products/blueberini_octopusini_icon.png`

After exporting, upload that PNG in App Store Connect or Play Console under your one-time IAP product image field.

Store exports are flattened onto a white or black background (auto-detected from the icon) so they contain no transparency.

## Env overrides

```bash
TARGET_SIZE=256 PLAY_STORE_SIZE=1024 ./scripts/prepare_premium_icons.sh
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `TARGET_SIZE` | `256` | In-app icon dimensions (`validate_premium_icons.sh`) |
| `PLAY_STORE_SIZE` | `1024` | Play product image side length (512–1080) |
| `PLAY_STORE_DIR` | `play-store/products` | Output directory for Play uploads |
| `MAX_FILE_KB` | `150` | Max in-app icon file size |

## Dependencies

- [ffmpeg](https://ffmpeg.org/) — icon validation probes (`brew install ffmpeg`)
- [ImageMagick](https://imagemagick.org/) — crop/zoom and Play product export (`brew install imagemagick`)
- [jq](https://jqlang.org/) — read `store/iap_products.json` (`brew install jq`)
