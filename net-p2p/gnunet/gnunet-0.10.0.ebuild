# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils autotools user

MY_PV="${PV/_/}"

DESCRIPTION="GNUnet is an anonymous, distributed, reputation based network."
HOMEPAGE="http://gnunet.org/"
SRC_URI="http://ftp.gnu.org/gnu/gnunet/${PN}-${MY_PV}.tar.gz"
#tests don't work
RESTRICT="test"

IUSE="mysql nls sqlite postgres +opus dane"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
LICENSE="GPL-2"
SLOT="0"
S="${WORKDIR}/${PN}-${MY_PV}"

DEPEND=">=dev-libs/libgcrypt-1.6.0
	>=media-libs/libextractor-0.6.1
	>=dev-libs/gmp-4.0.0
	sys-libs/zlib
	net-misc/gnurl
	sys-apps/sed
	mysql? ( >=virtual/mysql-5.1 )
		sqlite? ( >=dev-db/sqlite-3.0.8 )
	nls? ( sys-devel/gettext )
	>=net-libs/libmicrohttpd-0.9.31[messages]
	dev-libs/libunistring
	dane? ( net-libs/gnutls[dane] )
	net-libs/gnutls
	opus? ( media-libs/opus )
	>=sci-mathematics/glpk-4.45"

pkg_setup() {
	if ! use mysql && ! use sqlite; then
		einfo
		einfo "You need to specify at least one of 'mysql' or 'sqlite'"
		einfo "USE flag in order to have properly installed gnunet"
		einfo
		die "Invalid USE flag set"
	fi
}

pkg_preinst() {
	enewgroup gnunetd
	enewuser gnunetd -1 -1 /dev/null gnunetd
}

src_prepare() {
	sed -i 's:@GN_USER_HOME_DIR@:/etc:g' src/include/gnunet_directories.h.in
	AT_M4DIR="${S}/m4" eautoreconf
	epatch "${FILESDIR}"/${P}-remove_sudo_from_libtool.patch
}

src_compile() {
	local myconf
	myconf=" --with-sudo=yes --with-nssdir=/usr/lib"
	use mysql || myconf="${myconf} --without-mysql"
	use postgres || myconf="${myconf} --without-postgres"
	econf \
		$(use_enable nls) \
		${myconf} || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" -j1 install || die "make install failed"
	dodoc AUTHORS ChangeLog INSTALL NEWS README
	docinto contrib
	dodoc contrib/*
	newinitd "${FILESDIR}"/${PN}.initd-0.9.0v2 gnunet
	dodir /var/lib/gnunet
	chown gnunetd:gnunetd "${D}"/var/lib/gnunet
}

pkg_postinst() {
	# make sure permissions are ok
	chown -R gnunetd:gnunetd "${ROOT}"/var/lib/gnunet

	ewarn "This ebuild is HIGLY experimental"
}
