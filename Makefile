PACKAGE = elito-decode-definitions

srcdir := $(dir ${firstword ${MAKEFILE_LIST}})
abs_srcdir := $(abspath ${srcdir})

VPATH = ${srcdir}

VALGRIND ?=	valgrind --quiet --tool=memcheck --leak-check=full --show-leak-kinds=all --error-exitcode=23
CHECKER ?=	${VALGRIND}

export CHECKER

prefix ?= /usr/local
bindir ?= ${prefix}/bin
datadir ?= ${prefix}/data
pkgdatadir ?= ${datadir}/${PACKAGE}
decoderdir ?= ${pkgdatadir}

PATH := ${bindir}:${PATH}

DECODE_PKGDATA_DIR ?= ${datadir}/decode-registers

bin_PROGRAMS = \
	contrib/set-ar0144 \
	contrib/set-tw99x0 \

bin_DECODERS = \
	decode-mx6q \
	decode-mx6dl \
	decode-mx8m \
	decode-ar0144 \
	decode-ar052x \
	decode-tw99x0 \

decoder_DATA = \
	$(patsubst decode-%,regstream-%.bin,${bin_DECODERS})

bin_SCRIPTS = \
	decode-wrapper

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

all:	${bin_PROGRAMS} ${bin_SCRIPTS} ${decoder_DATA}

install:	.install-bin .install-bin-decoders .install-data-decoders

clean:
	rm -f ${bin_SCRIPTS} ${decoder_DATA}

run-tests:	${decoder_DATA}
	${srcdir}/contrib/run-test ${bindir}/decode-device $^

$(call set_dev_type,mx6q,devmem)
$(call set_dev_type,mx6dl,devmem)
$(call set_dev_type,mx8m,devmem)

$(call set_dev_type,ar0144,i2c)
$(call set_dev_type,ar052x,i2c)
$(call set_dev_type,tw99x0,i2c)

.prepare-mx6q .prepare-mx6dl:	.prepare-mx6

.prepare-mx6:
	${MAKE} -C ${srcdir}/regs-mx6

.subdir-%:
	${MAKE} -C ${srcdir}/regs-mx6 $*

decode-wrapper:	contrib/decode.sh.in
	@rm -f '$@'
	${SED} ${SED_CMD} < $< > '$@'
	@chmod a+rX,a-w '$@'

.install-bin:	${bin_PROGRAMS} ${bin_SCRIPTS}
	${INSTALL_D} ${DESTDIR}${bindir}
	${INSTALL_BIN} $^ ${DESTDIR}${bindir}/

.install-bin-decoders:
	for l in ${bin_DECODERS}; do \
		rm -f ${DESTDIR}${bindir}/$$l && \
		ln -s decode-wrapper ${DESTDIR}${bindir}/$$l; \
	done

.install-data-decoders:	${decoder_DATA}
	${INSTALL_D} ${DESTDIR}${decoderdir}
	${INSTALL_DATA} $^ ${DESTDIR}${decoderdir}/


.PHONY:	run-tests
