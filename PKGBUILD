# Maintainer: Hannah R. <git@rennersh.de>

pkgname=noctalia-plugin-screenshot-ocr
pkgver=1.0.0
pkgrel=1
pkgdesc="Noctalia Shell screenshot OCR plugin powered by Mistral OCR"
arch=('any')
url="https://github.com/MartianInGreen/noctalia-screenshot-ocr"
license=('MIT')
depends=('bash' 'curl' 'grim' 'jq' 'noctalia-shell>=4.0.0' 'slurp' 'wl-clipboard')
optdepends=('imagemagick: resize large screenshots before OCR')
_source_url="https://raw.githubusercontent.com/MartianInGreen/noctalia-screenshot-ocr/v${pkgver}"
source=("BarWidget.qml::$_source_url/BarWidget.qml"
        "PluginSettings.qml::$_source_url/PluginSettings.qml"
        "manifest.json::$_source_url/manifest.json"
        "README.md::$_source_url/README.md"
        "screenshot-ocr.sh::$_source_url/scripts/screenshot-ocr.sh"
        "LICENSE::$_source_url/LICENSE")
sha256sums=('51909327fa195142349b22b3babafbfa7dedb4ea135096c26b843cd212cf302d'
            '54f538bb1b98523645932a9dbf5e16f6f6a669f764500982086af7b790eb564c'
            '9fd53edb856019c90963cd35b1c9e13123045a3367bba4d12dfeffae053ee5d6'
            'eefcc38f58e8259ee79af2f49093a751b2d36cb1f670a409c6c630a168a0bf1f'
            'bd9f4cf5b88f218bac5025a01028307ed92ea15a8b9cc0e0f3e22dff11d899be'
            '3afa37d3b9e20561118f1bccc10ed6e17ec9b76270a228d7f8794e4a5e132eab')

package() {
  local plugin_dir="$pkgdir/usr/share/noctalia/plugins/screenshot-ocr"

  install -Dm644 BarWidget.qml "$plugin_dir/BarWidget.qml"
  install -Dm644 PluginSettings.qml "$plugin_dir/PluginSettings.qml"
  install -Dm644 manifest.json "$plugin_dir/manifest.json"
  install -Dm644 README.md "$plugin_dir/README.md"
  install -Dm755 screenshot-ocr.sh "$plugin_dir/scripts/screenshot-ocr.sh"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
