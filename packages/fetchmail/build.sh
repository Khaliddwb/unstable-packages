##
## NOTE: script 'fetchmailconf' uses TkInter which is not available
##       in Termux variant of python2.
##
TERMUX_PKG_HOMEPAGE=http://www.fetchmail.info/
TERMUX_PKG_DESCRIPTION="A remote-mail retrieval utility"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="Leonid Plyushch <leonid.plyushch@gmail.com>"
TERMUX_PKG_VERSION=6.3.26
TERMUX_PKG_REVISION=4
TERMUX_PKG_SRCURL=https://sourceforge.net/projects/fetchmail/files/branch_6.3/fetchmail-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=79b4c54cdbaf02c1a9a691d9948fcb1a77a1591a813e904283a8b614b757e850
TERMUX_PKG_DEPENDS="libcrypt, openssl"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-ssl=$TERMUX_PREFIX"

termux_step_pre_configure() {
	export LIBS="-llog"
}
