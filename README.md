# Screenshot OCR (Mistral)

Noctalia Shell bar widget plugin. Click the camera icon in your bar, select a screen region, and the text gets OCR'd by Mistral AI and copied to your clipboard.

## Requirements

Install these packages (Arch):

```bash
sudo pacman -S grim slurp wl-clipboard curl jq imagemagick
```

- `grim` + `slurp` — screenshot + region selection
- `wl-clipboard` — `wl-copy` for clipboard
- `curl` — API calls
- `jq` — JSON parsing
- `imagemagick` — optional, for auto-resizing large screenshots

## Installation

```bash
# Copy the plugin
cp -r screenshot-ocr ~/.config/noctalia/plugins/

# Register it in plugins.json (add this entry if not present):
# "screenshot-ocr": { "enabled": true }

# Restart Noctalia
killall qs && qs -c noctalia-shell
```

## Setup

1. Get a Mistral API key from https://console.mistral.ai/api-keys
2. Open Noctalia Settings → Plugins → Screenshot OCR (Mistral)
3. Paste your API key
4. Go to Bar settings → add the "Screenshot OCR (Mistral)" widget to your bar

## Usage

Click the camera icon in your bar → select a region → text appears in your clipboard.

On Arch, install deps with: `sudo pacman -S grim slurp wl-clipboard curl jq imagemagick`
