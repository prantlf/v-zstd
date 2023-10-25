module zstd

[noinit]
pub struct StreamContext {
	drain fn (buf &u8, len int) ! [required]
mut:
	output &C.ZSTD_outBuffer = unsafe { nil }
	input  &C.ZSTD_inBuffer  = unsafe { nil }
}

fn drain_buffer(mut sctx StreamContext) ! {
	if sctx.output.pos > 0 {
		sctx.drain(sctx.output.dst, int(sctx.output.pos))!
		sctx.output.pos = 0
	}
	if sctx.input.size > 0 {
		if sctx.input.pos == sctx.input.size {
			sctx.input.size = 0
			sctx.input.pos = 0
		} else {
			unsafe { vmemmove(sctx.input.src, &u8(sctx.input.src) + sctx.input.pos, sctx.input.pos) }
			sctx.input.size -= sctx.input.pos
			sctx.input.pos = 0
		}
	}
}
