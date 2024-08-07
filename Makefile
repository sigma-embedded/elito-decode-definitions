PACKAGE = elito-decode-definitions

srcdir := $(dir ${firstword ${MAKEFILE_LIST}})
abs_srcdir := $(abspath ${srcdir})

VPATH = ${srcdir}

VALGRIND ?=	valgrind --quiet --tool=memcheck --leak-check=full --show-leak-kinds=all --error-exitcode=23
CHECKER ?=	${VALGRIND}

export CHECKER

prefix ?= /usr/local
bindir ?= ${prefix}/bin
datadir ?= ${prefix}/share
pkgdatadir ?= ${datadir}/${PACKAGE}
decoderdir ?= ${pkgdatadir}

DECODE_PKGDATA_DIR ?= ${datadir}/decode-registers

DEVICES = \
	mx6qp mx6q mx6dl mx8mm mx8mq mx8mp mx8qm \
	ar0144 ar052x \
	tw9910 tw9990 \
	alvium \
	tc358867xbg \

bin_DECODERS = \
	$(addprefix decode-,${DEVICES})

decoder_DATA = \
	$(patsubst %,regstream-%.bin,${DEVICES})

pkgdata_DATA = \
	contrib/set-i2c

bin_SCRIPTS = \
	decode-wrapper \
	$(call cond_device,ar0144,set-ar0144) \
	$(call cond_device,ar052x,set-ar052x) \
	$(call cond_device,tw9910,set-tw9910) \
	$(call cond_device,tw9990,set-tw9990) \
	$(call cond_device,tc358867xbg,set-tc358867xbg) \

REGISTERS_GENDESC_FLAGS_mx6q  = --define imx6qd
REGISTERS_GENDESC_FLAGS_mx6qp = --define imx6qd --define imx6qp
REGISTERS_GENDESC_FLAGS_mx6dl = --define imx6sdl
REGISTERS_GENDESC_FLAGS_mx8mm  = --define imx8m --define imx8mm
REGISTERS_GENDESC_FLAGS_mx8mp  = --define imx8m --define imx8mp
REGISTERS_GENDESC_FLAGS_mx8mq  = --define imx8m --define imx8mq
REGISTERS_GENDESC_FLAGS_mx8qm  = --define imx8q --define imx8qm
REGISTERS_GENDESC_FLAGS_ar0144 = --define ar0144
REGISTERS_GENDESC_FLAGS_ar052x = --define ar052x
REGISTERS_GENDESC_FLAGS_tw9910 = --define tw99x0 --define tw9910
REGISTERS_GENDESC_FLAGS_tw9990 = --define tw99x0 --define tw9990
REGISTERS_GENDESC_FLAGS_tc358867xbg = --define tc358867xbg

REGISTERS_DEFDIR_mx6q =		${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx6qp =	${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx6dl =	${srcdir}/regs-mx6
REGISTERS_DEFDIR_mx8mm =	${srcdir}/regs-mx8
REGISTERS_DEFDIR_mx8mq =	${srcdir}/regs-mx8
REGISTERS_DEFDIR_mx8mp =	${srcdir}/regs-mx8mp
REGISTERS_DEFDIR_mx8qm =	${srcdir}/regs-mx8q
REGISTERS_DEFDIR_ar0144 =	${srcdir}/regs-ar0144
REGISTERS_DEFDIR_ar052x =	${srcdir}/regs-ar052x
REGISTERS_DEFDIR_tw9910 =	${srcdir}/regs-tw99x0
REGISTERS_DEFDIR_tw9990 =	${srcdir}/regs-tw99x0
REGISTERS_DEFDIR_alvium =	${srcdir}/regs-alvium
REGISTERS_DEFDIR_tc358867xbg =	${srcdir}/regs-tc358867xbg

REGISTERS_GENDESC :=	$(shell bash -c 'PATH="${bindir}:$$PATH" type -P decode-registers-gendesc' || echo 'decode-registers-gendesc-missing')

INSTALL = install
INSTALL_BIN = ${INSTALL} -p -m 0755
INSTALL_DATA = ${INSTALL} -p -m 0644
INSTALL_D = ${INSTALL} -d -m 0755

SED =	sed
SED_CMD = \
	-e 's!@PKGDATADIR@!${pkgdatadir}!g' \
	-e 's!@BINDIR@!${bindir}!g' \

cond_device = $(if $(filter $1,${DEVICES}),$2)

#####

include ${DECODE_PKGDATA_DIR}/mk/build.mk

all:	${bin_PROGRAMS} ${bin_SCRIPTS} ${decoder_DATA} ${pkgdata_DATA}

install:	.install-bin .install-bin-decoders .install-data-decoders .install-pkgdata

clean:	.subdir-clean
	rm -f ${bin_SCRIPTS} ${decoder_DATA}

run-tests:	${decoder_DATA}
	${srcdir}/contrib/run-test ${bindir}/decode-device $^

$(call set_dev_type,mx6q,devmem)
$(call set_dev_type,mx6qp,devmem)
$(call set_dev_type,mx6dl,devmem)
$(call set_dev_type,mx8mm,devmem)
$(call set_dev_type,mx8mq,devmem)
$(call set_dev_type,mx8mp,devmem)
$(call set_dev_type,mx8qm,devmem)

$(call set_dev_type,ar0144,i2c)
$(call set_dev_type,ar052x,i2c)
$(call set_dev_type,tw9910,i2c)
$(call set_dev_type,tw9990,i2c)
$(call set_dev_type,alvium,i2c)
$(call set_dev_type,tc358867xbg,i2c)

.prepare-mx6qp .prepare-mx6q .prepare-mx6dl:	.prepare-mx6

.prepare-mx6:
	${MAKE} -C ${srcdir}/regs-mx6

.subdir-%:
	${MAKE} -C ${srcdir}/regs-mx6 $*

decode-wrapper:	contrib/decode.sh.in
	@rm -f '$@'
	${SED} ${SED_CMD} < $< > '$@'
	@chmod a+rX,a-w '$@'

set-%:		contrib/set-%.in
	@rm -f '$@'
	${SED} ${SED_CMD} < $< > '$@'
	@chmod a+rx,a-w '$@'

.install-bin:	${bin_PROGRAMS} ${bin_SCRIPTS}
	${INSTALL_D} ${DESTDIR}${bindir}
	${INSTALL_BIN} $^ ${DESTDIR}${bindir}/

.install-bin-decoders: .install-bin
	for l in ${bin_DECODERS}; do \
		rm -f ${DESTDIR}${bindir}/$$l && \
		ln -s decode-wrapper ${DESTDIR}${bindir}/$$l; \
	done

.install-data-decoders:	${decoder_DATA}
	${INSTALL_D} ${DESTDIR}${decoderdir}
	${INSTALL_DATA} $^ ${DESTDIR}${decoderdir}/

.install-pkgdata:	${pkgdata_DATA}
	${INSTALL_D} ${DESTDIR}${pkgdatadir}
	${INSTALL_DATA} $^ ${DESTDIR}${pkgdatadir}/

.PHONY:	run-tests
.DEFAULT_GOAL: all
