TERMUX_PKG_HOMEPAGE=http://www.catb.org/~esr/open-adventure/
TERMUX_PKG_DESCRIPTION="Port of the 'Colossal Cave Adventure' text-based adventure game"
TERMUX_PKG_LICENSE="BSD"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=1.4
TERMUX_PKG_SRCURL=https://gitlab.com/esr/open-adventure/-/archive/$TERMUX_PKG_VERSION/open-adventure-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=7bb027a1f8076cf4d4803e8b2d9fda1934e95ea4385c3ace9ed2e571dc4e0f02
TERMUX_PKG_DEPENDS="libedit"
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_make_install() {
	install -Dm700 advent "$TERMUX_PREFIX"/bin/advent
}
