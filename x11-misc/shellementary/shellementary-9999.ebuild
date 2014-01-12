# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

E_PYTHON=1
SUPPORT_PYTHON_ABIS=1
RESTRICT_PYTHON_ABIS="3.*"

ESVN_SUB_PROJECT="PROTO"

inherit enlightenment

DESCRIPTION="Tool to display Elementary dialogs from the command line and shell scripts"

IUSE="static-libs"

RDEPEND=">=media-libs/elementary-1.7.0"
DEPEND=${RDEPEND}

src_prepare() {
	enlightenment_src_prepare
	python_copy_sources
}

src_configure() {
	python_execute_function -s enlightenment_src_configure
}

src_compile() {
	python_execute_function -s enlightenment_src_compile
}

src_install() {
	python_execute_function -s enlightenment_src_install
}
