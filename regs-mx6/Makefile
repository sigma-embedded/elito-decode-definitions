all:	IPU-CPMEM-I.unit IPU-CPMEM-NI.unit

IPU-CPMEM-I.unit:	IN=IPU-CPMEM/INTERLEAVED.reg
IPU-CPMEM-NI.unit:	IN=IPU-CPMEM/NON-INTERLEAVED.reg

define emit_cpmem_chan
	while read ch desc; do \
		test -n "$$ch" || continue; \
		printf '@unit $1-CPMEM-$*%u\n' "$$ch" && \
		printf '  @reg 0x%08x 0x000028\n' $$[ $2 + ch * 0x28 ] && \
		printf '  @description "%s"\n' "$$desc" && \
		printf '  @use _IPU-CPMEM-$*\n\n'; \
	done
endef

IPU-CPMEM-%.unit:	CPMEM.channel Makefile
	@rm -f $@
	@echo "@unit _IPU-CPMEM-$*" > $@
	@echo "  @disabled" >> $@
	@echo "  @registers IPU-CPMEM/COMMON.reg" >> $@
	@echo "  @registers ${IN}" >> $@
	@echo >> $@

	$(call emit_cpmem_chan,IPU1,0x02700000) < $< >> $@

	@echo >> $@

	$(call emit_cpmem_chan,IPU2,0x02b00000) < $< >> $@

	@chmod a+rX,a-w '$@'

clean:
	rm -f IPU-CPMEM-I.unit IPU-CPMEM-NI.unit
