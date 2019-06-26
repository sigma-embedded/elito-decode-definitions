all:	IPU-CPMEM/interleaved.reg
all:	IPU-CPMEM/non-interleaved.reg

define emit_cpmem_chan
	while read ch desc; do \
		test -n "$$ch" || continue; \
		printf '@register "CH-$1#%u_0"\n' "$$ch" && \
		printf '  @addr 0x%08x\n' $$[ ch * 64 ] && \
		printf '  @use _IPU_CPMEM-W0-$1\n'; \
		printf '\n' && \
		printf '@register "CH-$1#%u_1"\n' "$$ch" && \
		printf '  @addr 0x%08x\n' $$[ ch * 64 + 0x20 ] && \
		printf '  @use _IPU_CPMEM-W1-$1\n\n'; \
	done
endef

IPU-CPMEM/interleaved.reg:	T=I
IPU-CPMEM/non-interleaved.reg:	T=NI

IPU-CPMEM/%.reg:	CPMEM.channel Makefile
	@rm -f $@
	$(call emit_cpmem_chan,$T) < $< > $@
	@chmod a+rX,a-w '$@'

clean:
	rm -f IPU-CPMEM/interleaved.reg
	rm -f IPU-CPMEM/non-interleaved.reg
