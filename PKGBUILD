# Maintainer: Dirk Ulbricht <ulbdir@gmx.de>
pkgname=msi-claw-a1m-fixes
pkgver=1.0.0
pkgrel=1
pkgdesc="Hardware, Xe GPU driver, and sleep fixes for MSI Claw A1M"
arch=('any')
url="https://github.com/ulbdir/msi-claw-a1m-fixes"
license=('MIT')
depends=('systemd' 'kmod' 'iproute2')
optdepends=(
    'mkinitcpio: to include the xe modprobe configuration into early initramfs'
    'limine-mkinitcpio-hook: for Limine bootloader updates on CachyOS'
)
install=msi-claw-fixes.install
source=(
    'msi-claw-xe.conf'
    'msi-claw-sleep.conf'
    'msi-claw-s2idle.conf'
    'msi-claw-wifi-reload.sh'
    '99-msi-claw-wifi.rules'
    'LICENSE'
)
sha256sums=('3b3e9238d8e64c732c0ff9fce791accf8693d4ed361a777bd514227abb075009'
            'e28f4b554fb04608921fd380f1cc5bebd7c9e302ef515b6a3772f518afac9546'
            '7c95e240faec444d323e10e03df0a42f042d701060ab52079c96bfe9125bb8b4'
            '9fb5f6382dab84064a0db5aa262e2baadc6e1e420a2a53a862d447528db432b8'
            'aafc9d847b2c7363ce600f90fe5e8fdd19f8d11c11d15ac8d80bb2b7f31375cf'
            '1126322e2cc8d165adc4c792eeb195717de2bcc7b39be1ce77959d78e87ef685')

package() {
    # 1. Switch GPU driver to xe
    install -Dm644 "${srcdir}/msi-claw-xe.conf" "${pkgdir}/usr/lib/modprobe.d/msi-claw-xe.conf"

    # 2. Disable S3 sleep (force s2idle)
    install -Dm644 "${srcdir}/msi-claw-sleep.conf" "${pkgdir}/usr/lib/tmpfiles.d/msi-claw-sleep.conf"
    install -Dm644 "${srcdir}/msi-claw-s2idle.conf" "${pkgdir}/usr/lib/systemd/sleep.conf.d/10-msi-claw-s2idle.conf"

    # 3. Reload Wi-Fi module on wakeup from sleep & disable D3cold
    install -Dm755 "${srcdir}/msi-claw-wifi-reload.sh" "${pkgdir}/usr/lib/systemd/system-sleep/msi-claw-wifi-reload.sh"
    install -Dm644 "${srcdir}/99-msi-claw-wifi.rules" "${pkgdir}/usr/lib/udev/rules.d/99-msi-claw-wifi.rules"

    # License
    install -Dm644 "${srcdir}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
