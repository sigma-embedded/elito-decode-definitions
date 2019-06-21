PACKAGE = elito-decode-definitions

srcdir := $(dir ${firstword ${MAKEFILE_LIST}})
abs_srcdir := $(abspath ${srcdir})

VPATH = ${srcdir}

prefix ?= /usr/local
bindir ?= ${prefix}/bin
datadir ?= ${prefix}/data
pkgdatadir ?= ${datadir}/${PACKAGE}

PATH := ${bindir}:${PATH}

DECODE_PKGDATA_DIR ?= ${datadir}/decode-registers

bin_PROGRAMS = \
	decode-mx6q \
	decode-mx6dl \
	decode-mx8m \
	decode-ar0144 \
	decode-ar052x \
	decode-tw99x0 \
\
	contrib/set-ar0144 \
	contrib/set-tw99x0 \

REGISTERS_GENDESC_FLAGS_mx6q  = --define imx6qd
REGISTERS_GENDESC_FLAGS_mx6dl = --define imx6sdl
REGISTERS_GENDESC_FLAGS_mx8m  = --define imx8m
REGISTERS_GENDESC_FLAGS_ar0144 = --define ar0144
REGISTERS_GENDESC_FLAGS_ar052x = --define ar052x
REGISTERS_GENDESC_FLAGS_tw99x0 = --define tw99x0

REGISTERS_DEFDIR_mx6q = 	${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx6dl =	${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx8m =		${srcdir}/regs-mx8
REGISTERS_DEFDIR_ar0144 =	${srcdir}/regs-ar0144
REGISTERS_DEFDIR_ar052x =	${srcdir}/regs-ar052x
REGISTERS_DEFDIR_tw99x0 =	${srcdir}/regs-tw99x0

INSTALL = install
INSTALL_BIN = ${INSTALL} -p -m 0755
INSTALL_DATA = ${INSTALL} -p -m 0644
INSTALL_D = ${INSTALL} -d -m 0755

SED =	sed
SED_CMD = \
	-e 's!@PKGDATADIR@!${pkgdatadir}!g'

all:

include ${DECODE_PKGDATA_DIR}/mk/build.mk

all:	${bin_PROGRAMS}

install:	.install-bin

run-tests:	${bin_PROGRAMS}
	${srcdir}/contrib/run-test $^

$(call set_dev_type,mx6q,devmem)
$(call set_dev_type,mx6dl,devmem)
$(call set_dev_type,mx8m,devmem)

$(call set_dev_type,ar0144,i2c)
$(call set_dev_type,ar052x,i2c)
$(call set_dev_type,tw99x0,i2c)

decode-tw99x0:	REGISTERS_ADDR_TYPE=uint8_t

.install-bin:	${bin_PROGRAMS}
	${INSTALL_D} ${DESTDIR}${bindir}
	${INSTALL} $^ ${DESTDIR}${bindir}/


.PHONY:	run-tests
