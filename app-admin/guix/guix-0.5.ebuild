# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils autotools user

GUILE_VERSION="2.0.9"
DESCRIPTION="GNUnet is an anonymous, distributed, reputation based network."
HOMEPAGE="http://www.gnu.org/software/guix/"
SRC_URI="
	http://alpha.gnu.org/gnu/guix/${P}.tar.gz
	http://alpha.gnu.org/gnu/guix/bootstrap/x86_64-linux/20131110/guile-${GUILE_VERSION}.tar.xz -> guile-${GUILE_VERSION}-x86_64.tar.xz
	http://alpha.gnu.org/gnu/guix/bootstrap/mips64el-linux/20131110/guile-${GUILE_VERSION}.tar.xz -> guile-${GUILE_VERSION}-mips64el.tar.xz
	http://alpha.gnu.org/gnu/guix/bootstrap/i686-linux/20131110/guile-${GUILE_VERSION}.tar.xz -> guile-${GUILE_VERSION}-i686.tar.xz
"

IUSE="+build-daemon"
KEYWORDS="~amd64 ~mips64el ~x86"

# some tests fails due to too long path - tests/builders.scm, tests/packages.scm, tests/guix-package.sh
# some fails due to sandbox - tests/builders.scm
# local test works
RESTRICT="test"

LICENSE="GPL-2"
SLOT="0"

DEPEND="build-daemon? (
			dev-db/sqlite:3
			app-arch/bzip2
			sys-devel/gcc
		)
		app-arch/xz-utils
		dev-libs/libgcrypt
		>=dev-scheme/guile-2.0.5"

pkg_preinst() {
	local i
	enewgroup guix-builders
	for i in {1..5}; do
		enewuser "guix-builder$i" -1 -1 /dev/null guix-builders
	done
}

src_prepare() {
	for arch in i686 x86_64 mips64el; do
		mkdir -p "gnu/packages/bootstrap/${arch}-linux"
		cp "${DISTDIR}/guile-${GUILE_VERSION}-${arch}.tar.xz" "gnu/packages/bootstrap/${arch}-linux/guile-${GUILE_VERSION}.tar.xz"
	done
}

src_compile() {
	econf \
		$(use_enable build-daemon daemon) || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	newinitd "${FILESDIR}/guixd-${PV}" guixd
}

pkg_postinst() {
	# make sure permissions are ok
#	chown -R gnunetd:gnunetd "${ROOT}"/var/lib/gnunet

	ewarn "This ebuild is HIGLY experimental"
}
