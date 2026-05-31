# Screenshot OCR (Mistral)

Noctalia Shell bar widget plugin. Click the camera icon in your bar, select a screen region, and the text gets OCR'd by Mistral AI and copied to your Wayland clipboard.

## Requirements

| Package | Purpose |
|---------|---------|
| `grim` | Screenshot capture |
| `slurp` | Region selection |
| `wl-clipboard` | `wl-copy` for clipboard |
| `curl` | Mistral API calls |
| `jq` | JSON parsing |
| `imagemagick` | Auto-resize large screenshots (optional) |

```bash
sudo pacman -S grim slurp wl-clipboard curl jq imagemagick
```

## Installation

**1. Clone or copy the plugin into your Noctalia plugins directory:**

```bash
git clone git@github.com:MartianInGreen/noctalia-screenshot-ocr.git \
  ~/.config/noctalia/plugins/screenshot-ocr
```

**2. Register the plugin** — open `~/.config/noctalia/plugins.json` and add this entry:

```json
{
  "screenshot-ocr": {
    "enabled": true
  }
}
```

If `plugins.json` doesn't exist yet, create it with just the entry above wrapped in `{}`.

**3. Restart Noctalia:**

```bash
killall qs && qs -c noctalia-shell
```

## Setup

1. Get a Mistral API key at [console.mistral.ai/api-keys](https://console.mistral.ai/api-keys)
2. Open Noctalia Settings → **Plugins** → **Screenshot OCR (Mistral)**
3. Paste your API key into the settings field
4. Go to **Settings → Bar**, pick a section (Left/Center/Right), and add the **Screenshot OCR (Mistral)** widget

## Usage

Click the camera icon in the bar, select a screen region with slurp, and the OCR'd text lands in your clipboard.
