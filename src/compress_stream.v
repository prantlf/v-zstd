module zstd

const (
	compress_stream_out_size = int(C.ZSTD_CStreamOutSize())
	compress_stream_in_size  = int(C.ZSTD_CStreamInSize())
)

pub fn new_compress_stream_context(drain fn (buf &u8, len int) !) &StreamContext {
	dst := []u8{len: zstd.compress_stream_out_size}
	output := &C.ZSTD_outBuffer{dst.data, usize(zstd.compress_stream_out_size), 0}
	src := []u8{len: zstd.compress_stream_in_size}
	input := &C.ZSTD_inBuffer{src.data, 0, 0}
	return &StreamContext{drain, output, input}
}

[inline]
pub fn (c &CompressContext) compress_chunk(mut sctx StreamContext, src []u8, last bool) ! {
	unsafe { c.compress_chunk_at(mut sctx, src.data, src.len, last)! }
}

[unsafe]
pub fn (c &CompressContext) compress_chunk_at(mut sctx StreamContext, src &u8, src_len int, last bool) ! {
	mut res := usize(0)
	mut pos := 0
	mut rest_len := src_len
	for rest_len > 0 {
		max_len := zstd.compress_stream_in_size - int(sctx.input.size)
		mut len := 0
		len, rest_len = if rest_len <= max_len {
			rest_len, 0
		} else {
			max_len, rest_len - max_len
		}
		unsafe { vmemcpy(&u8(sctx.input.src) + sctx.input.size, src + pos, len) }
		sctx.input.size += usize(len)
		end_op := if last && rest_len == 0 {
			C.ZSTD_e_end
		} else {
			C.ZSTD_e_continue
		}
		res = C.ZSTD_compressStream2(c.cctx, sctx.output, sctx.input, end_op)
		check_error(res)!
		drain_buffer(mut sctx)!
		pos += max_len
	}
	if last && (res != 0 || sctx.input.pos != sctx.input.size) {
		return error('unfinished compression')
	}
}

pub fn (c &CompressContext) compress_end(mut sctx StreamContext) ! {
	mut res := C.ZSTD_compressStream2(c.cctx, sctx.output, sctx.input, C.ZSTD_e_end)
	check_error(res)!
	if sctx.output.pos > 0 {
		sctx.drain(sctx.output.dst, int(sctx.output.pos))!
		sctx.output.pos = 0
	}
}
