srcdir := $(dir ${firstword ${MAKEFILE_LIST}})
abs_srcdir := $(abspath ${srcdir})

VPATH = ${srcdir}

prefix ?= /usr/local
bindir ?= ${prefix}/bin
datadir ?= ${prefix}/data

DECODE_PKGDATA_DIR ?= ${datadir}/decode-registers

bin_PROGRAMS = \
	decode-mx6q \
	decode-mx6dl \
	decode-mx8m \
	decode-ar0144 \
	decode-ar052x \
\
	contrib/set-ar0144 \

REGISTERS_GENDESC_FLAGS_mx6q  = --define imx6qd
REGISTERS_GENDESC_FLAGS_mx6dl = --define imx6sdl
REGISTERS_GENDESC_FLAGS_mx8m  = --define imx8m
REGISTERS_GENDESC_FLAGS_ar0144 = --define ar0144
REGISTERS_GENDESC_FLAGS_ar052x = --define ar052x

REGISTERS_DEFDIR_mx6q = 	${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx6dl =	${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx8m =		${srcdir}/regs-mx8
REGISTERS_DEFDIR_ar0144 =	${srcdir}/regs-ar0144
REGISTERS_DEFDIR_ar052x =	${srcdir}/regs-ar052x

INSTALL = install
INSTALL_BIN = ${INSTALL} -p -m 0755
INSTALL_DATA = ${INSTALL} -p -m 0644
INSTALL_D = ${INSTALL} -d -m 0755

all:

include ${DECODE_PKGDATA_DIR}/mk/build.mk

all:	${bin_PROGRAMS}

install:	.install-bin

$(call set_dev_type,mx6q,devmem)
$(call set_dev_type,mx6dl,devmem)
$(call set_dev_type,mx8m,devmem)

$(call set_dev_type,ar0144,i2c)
$(call set_dev_type,ar052x,i2c)

.install-bin:	${bin_PROGRAMS}
	${INSTALL_D} ${DESTDIR}${bindir}
	${INSTALL} $^ ${DESTDIR}${bindir}/
