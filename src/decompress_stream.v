module zstd

const (
	decompress_stream_out_size = int(C.ZSTD_DStreamOutSize())
	decompress_stream_in_size  = int(C.ZSTD_DStreamInSize())
)

pub fn new_decompress_stream_context(drain fn (buf &u8, len int) !) &StreamContext {
	dst := []u8{len: zstd.decompress_stream_out_size}
	output := &C.ZSTD_outBuffer{dst.data, usize(zstd.decompress_stream_out_size), 0}
	src := []u8{len: zstd.decompress_stream_in_size}
	input := &C.ZSTD_inBuffer{src.data, 0, 0}
	return &StreamContext{drain, output, input}
}

[inline]
pub fn (d &DecompressContext) decompress_chunk(mut sctx StreamContext, src []u8, last bool) ! {
	unsafe { d.decompress_chunk_at(mut sctx, src.data, src.len, last)! }
}

[unsafe]
pub fn (d &DecompressContext) decompress_chunk_at(mut sctx StreamContext, src &u8, src_len int, last bool) ! {
	mut res := usize(0)
	mut pos := 0
	mut rest_len := src_len
	for rest_len > 0 {
		max_len := zstd.decompress_stream_in_size - int(sctx.input.size)
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
		drain_buffer(mut sctx)!
		pos += max_len
	}
	if last && (res != 0 || sctx.input.pos != sctx.input.size) {
		return error('unfinished decompression')
	}
}
