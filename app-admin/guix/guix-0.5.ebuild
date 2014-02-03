# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils autotools user

MY_PV="${PV/_/}"

GUILE_VERSION="2.0.9"
DESCRIPTION="GNUnet is an anonymous, distributed, reputation based network."
HOMEPAGE="http://www.gnu.org/software/guix/"
SRC_URI="
	http://alpha.gnu.org/gnu/guix/${P}.tar.gz
	http://alpha.gnu.org/gnu/guix/bootstrap/x86_64-linux/20131110/guile-${GUILE_VERSION}.tar.xz -> guile-${GUILE_VERSION}-x86_64.tar.xz
	http://alpha.gnu.org/gnu/guix/bootstrap/mips64el-linux/20131110/guile-${GUILE_VERSION}.tar.xz -> guile-${GUILE_VERSION}-mips64el.tar.xz
	http://alpha.gnu.org/gnu/guix/bootstrap/i686-linux/20131110/guile-${GUILE_VERSION}.tar.xz -> guile-${GUILE_VERSION}-i686.tar.xz
"
#tests don't work
RESTRICT="test"

#IUSE="mysql nls sqlite postgres +opus dane"
IUSE="+build-daemon"
KEYWORDS="~amd64 ~mips64el ~x86"



LICENSE="GPL-2"
SLOT="0"
S="${WORKDIR}/${PN}-${MY_PV}"

DEPEND="build-daemon? (
			dev-db/sqlite:3
			app-arch/bzip2
			sys-devel/gcc
		)
		app-arch/xz-utils
		dev-libs/libgcrypt
		>=dev-scheme/guile-2.0.5"

#pkg_setup() {
#
#}

#pkg_preinst() {
#	enewgroup gnunetd
#	enewuser gnunetd -1 -1 /dev/null gnunetd
#}

src_prepare() {
#	sed -i 's:@GN_USER_HOME_DIR@:/etc:g' src/include/gnunet_directories.h.in
#	AT_M4DIR="${S}/m4" eautoreconf
#	epatch "${FILESDIR}"/${P}-remove_sudo_from_libtool.patch
	for arch in i686 x86_64 mips64el; do
		mkdir -p "gnu/packages/bootstrap/${arch}-linux"
		cp "${DISTDIR}/guile-${GUILE_VERSION}-${arch}.tar.xz" "gnu/packages/bootstrap/${arch}-linux/guile-${GUILE_VERSION}tar.xz"
	done
}

src_compile() {
	econf \
		$(use_enable build-daemon daemon) || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
#	dodoc AUTHORS ChangeLog INSTALL NEWS README
#	docinto contrib
#	dodoc contrib/*
#	newinitd "${FILESDIR}"/${PN}.initd-0.9.0v2 gnunet
#	dodir /var/lib/gnunet
#	chown gnunetd:gnunetd "${D}"/var/lib/gnunet
}

pkg_postinst() {
	# make sure permissions are ok
#	chown -R gnunetd:gnunetd "${ROOT}"/var/lib/gnunet

	ewarn "This ebuild is HIGLY experimental"
}
