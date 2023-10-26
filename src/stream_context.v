module zstd

[noinit]
pub struct StreamContext {
mut:
	output &C.ZSTD_outBuffer = unsafe { nil }
	input  &C.ZSTD_inBuffer  = unsafe { nil }
}

pub fn (mut s StreamContext) reset() {
	s.output.pos = 0
	s.input.size = 0
	s.input.pos = 0
}

fn new_stream_context(out_len int, in_len int) &StreamContext {
	dst := []u8{len: out_len}
	output := &C.ZSTD_outBuffer{dst.data, usize(out_len), 0}
	src := []u8{len: in_len}
	input := &C.ZSTD_inBuffer{src.data, 0, 0}
	return &StreamContext{output, input}
}

fn drain_buffer(mut sctx StreamContext, drain fn (buf &u8, len int) !) ! {
	if sctx.output.pos > 0 {
		drain(sctx.output.dst, int(sctx.output.pos))!
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
