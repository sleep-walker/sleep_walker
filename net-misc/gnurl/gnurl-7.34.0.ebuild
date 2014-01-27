# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/curl/curl-7.34.0-r1.ebuild,v 1.12 2014/01/18 05:35:23 vapier Exp $

EAPI="5"

inherit autotools eutils prefix

DESCRIPTION="Minifork of cURL for GNUnet"
HOMEPAGE="https://gnunet.org/gnurl"
SRC_URI="https://gnunet.org/sites/default/files/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs ipv6 threads test"

#lead to lots of false negatives, bug #285669
RESTRICT="test"

RDEPEND="|| (
				( >=net-libs/gnutls-3[static-libs?] dev-libs/nettle )
				( =net-libs/gnutls-2.12*[nettle,static-libs?] dev-libs/nettle )
				( =net-libs/gnutls-2.12*[-nettle,static-libs?] dev-libs/libgcrypt[static-libs?] )
			)
		 app-misc/ca-certificates
		 net-dns/libidn[static-libs?]
		 sys-libs/zlib"

# Do we need to enforce the same ssl backend for curl and rtmpdump? Bug #423303
#	rtmp? (
#		media-video/rtmpdump
#		curl_ssl_gnutls? ( media-video/rtmpdump[gnutls] )
#		curl_ssl_openssl? ( media-video/rtmpdump[-gnutls,ssl] )
#	)

# ssl providers to be added:
# fbopenssl  $(use_with spnego)

# krb4 http://web.mit.edu/kerberos/www/krb4-end-of-life.html

DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? (
		sys-apps/diffutils
		dev-lang/perl
	)"


DOCS=( CHANGES README docs/FEATURES docs/INTERNALS \
	docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE)

src_prepare() {
	sed -i '/LD_LIBRARY_PATH=/d' configure.ac || die #382241

	epatch_user
#	eprefixify gnurl-config.in
	eautoreconf
}

src_configure() {
	einfo "\033[1;32m**************************************************\033[00m"

	# We make use of the fact that later flags override earlier ones
	# So start with all ssl providers off until proven otherwise
	local myconf=()
	myconf+=( --without-axtls --without-cyassl --without-nss --without-polarssl --without-ssl )
	myconf+=( --with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt )
	einfo "SSL provided by gnutls"
	if has_version ">=net-libs/gnutls-3" || has_version "=net-libs/gnutls-2.12*[nettle]"; then
		einfo "gnutls compiled with dev-libs/nettle"
		myconf+=( --with-gnutls --with-nettle )
	else
		einfo "gnutls compiled with dev-libs/libgcrypt"
		myconf+=( --with-gnutls --without-nettle )
	fi
	einfo "\033[1;32m**************************************************\033[00m"

	# These configuration options are organized alphabetically
	# within each category.  This should make it easier if we
	# ever decide to make any of them contingent on USE flags:
	# 1) protocols first.  To see them all do
	# 'grep SUPPORT_PROTOCOLS configure.ac'
	# 2) --enable/disable options second.
	# 'grep -- --enable configure | grep Check | awk '{ print $4 }' | sort
	# 3) --with/without options third.
	# grep -- --with configure | grep Check | awk '{ print $4 }' | sort
	econf \
		--disable-dict \
		--disable-file \
		--disable-ftp \
		--disable-gopher \
		--enable-http \
		--disable-imap \
		--disable-ldap \
		--disable-ldaps \
		--disable-pop3 \
		--disable-rtsp \
		--without-libssh2 \
		--disable-smtp \
		--disable-telnet \
		--disable-tftp \
		--disable-ares \
		--enable-cookies \
		--enable-hidden-symbols \
		$(use_enable ipv6) \
		--enable-largefile \
		--enable-manual \
		--enable-proxy \
		--disable-soname-bump \
		--disable-sspi \
		$(use_enable static-libs static) \
		$(use_enable threads threaded-resolver) \
		--disable-versioned-symbols \
		--without-darwinssl \
		--enable-libidn \
		--disable-gssapi \
		--without-krb4 \
		--without-libmetalink \
		--without-nghttp2 \
		--without-librtmp \
		--without-spnego \
		--without-winidn \
		--without-winssl \
		--with-zlib \
		"${myconf[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete
	rm -rf "${ED}"/usr/share/doc "${ED}"/usr/share/man
	rm "${ED}"/usr/share/aclocal/libcurl.m4
	rm "${ED}"/usr/bin/curl
	rm -rf "${ED}"/usr/include
	rm -rf "${ED}"/etc/

	# https://sourceforge.net/tracker/index.php?func=detail&aid=1705197&group_id=976&atid=350976
	insinto /usr/share/aclocal
#	doins docs/libcurl/libcurl.m4
}
