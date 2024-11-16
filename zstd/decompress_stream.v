module zstd

pub const decompress_stream_out_size = int(C.ZSTD_DStreamOutSize())
pub const decompress_stream_in_size = int(C.ZSTD_DStreamInSize())

pub fn new_decompress_stream_context() &StreamContext {
	return new_stream_context(decompress_stream_out_size, decompress_stream_in_size)
}

@[inline]
pub fn (d &DecompressContext) decompress_chunk(mut sctx StreamContext, src []u8, last bool, drain fn (buf &u8, len int) !) ! {
	unsafe { d.decompress_chunk_at(mut sctx, src.data, src.len, last, drain)! }
}

@[unsafe]
pub fn (d &DecompressContext) decompress_chunk_at(mut sctx StreamContext, src &u8, src_len int, last bool, drain fn (buf &u8, len int) !) ! {
	mut res := usize(0)
	mut pos := 0
	mut rest_len := src_len
	for rest_len > 0 {
		max_len := decompress_stream_in_size - int(sctx.input.size)
		mut len := 0
		len, rest_len = if rest_len <= max_len {
			rest_len, 0
		} else {
			max_len, rest_len - max_len
		}
		unsafe { vmemcpy(&u8(sctx.input.src) + sctx.input.size, src + pos, len) }
		sctx.input.size += usize(len)
		res = C.ZSTD_decompressStream(d.dctx, sctx.output, sctx.input)
		check_error(res)!
		drain_buffer(mut sctx, drain)!
		pos += max_len
	}
	if last && (res != 0 || sctx.input.pos != sctx.input.size) {
		return error('unfinished decompression')
	}
}
