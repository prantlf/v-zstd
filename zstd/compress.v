module zstd

@[inline]
pub fn compress(src []u8) ![]u8 {
	return compress_with_level(src, default_compress_level)!
}

pub fn compress_with_level(src []u8, compression_level int) ![]u8 {
	max_len := int(C.ZSTD_compressBound(src.len))
	mut dst := []u8{len: max_len}
	len := compress_with_level_to(mut dst, src, compression_level)!
	if len != dst.len {
		dst = unsafe { dst[..len] }
	}
	return dst
}

@[inline]
pub fn compress_to(mut dst []u8, src []u8) !int {
	return compress_with_level_to(mut dst, src, default_compress_level)!
}

@[inline]
pub fn compress_with_level_to(mut dst []u8, src []u8, compression_level int) !int {
	return unsafe { compress_with_level_at(mut dst.data, dst.len, src.data, src.len, compression_level)! }
}

@[inline; unsafe]
pub fn compress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int {
	return unsafe { compress_with_level_at(mut dst, dst_len, src, src_len, default_compress_level)! }
}

@[unsafe]
pub fn compress_with_level_at(mut dst &u8, dst_len int, src &u8, src_len int, compression_level int) !int {
	res := C.ZSTD_compress(dst, dst_len, src, src_len, compression_level)
	check_error(res)!
	return int(res)
}
