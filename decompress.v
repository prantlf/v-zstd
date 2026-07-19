module zstd

pub fn decompress(src []u8) ![]u8 {
	max_len := get_frame_content_size(src)!
	mut dst := []u8{len: max_len}
	len := decompress_to(mut dst, src)!
	if len != dst.len {
		dst = unsafe { dst[..len] }
	}
	return dst
}

@[inline]
pub fn decompress_to(mut dst []u8, src []u8) !int {
	return unsafe { decompress_at(mut dst.data, dst.len, src.data, src.len)! }
}

@[unsafe]
pub fn decompress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int {
	res := C.ZSTD_decompress(dst, dst_len, src, src_len)
	check_error(res)!
	return int(res)
}
