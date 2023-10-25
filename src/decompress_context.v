module zstd

[noinit]
pub struct DecompressContext {
	dctx &C.ZSTD_DCtx = unsafe { nil }
}

pub enum DecompressParam {
	window_log_max        = C.ZSTD_d_windowLogMax
	format                = C.ZSTD_d_format
	stable_out_buffer     = C.ZSTD_d_stableOutBuffer
	force_ignore_checksum = C.ZSTD_d_forceIgnoreChecksum
	ref_multiple_d_dicts  = C.ZSTD_d_refMultipleDDicts
}

pub fn new_decompress_context() !&DecompressContext {
	dctx := C.ZSTD_createDCtx()
	if dctx == 0 {
		return error('creating decompression context failed')
	}
	return &DecompressContext{dctx}
}

pub fn (d &DecompressContext) free() {
	C.ZSTD_freeDCtx(d.dctx)
}

pub fn (d &DecompressContext) reset(reset ResetDir) {
	C.ZSTD_DCtx_reset(d.dctx, int(reset))
}

pub fn decompress_param_bounds(param DecompressParam) !(int, int) {
	bounds := C.ZSTD_dParam_getBounds(int(param))
	check_error(bounds.error)!
	return bounds.lowerBound, bounds.upperBound
}

pub fn (d &DecompressContext) set_param(param DecompressParam, value int) ! {
	res := C.ZSTD_DCtx_setParameter(d.dctx, int(param), value)
	check_error(res)!
}

pub fn (d &DecompressContext) get_param(param DecompressParam) !int {
	value := 0
	res := C.ZSTD_DCtx_getParameter(d.dctx, int(param), &value)
	check_error(res)!
	return value
}

pub fn (d &DecompressContext) set_max_window_size(max_window_size int) ! {
	res := C.ZSTD_DCtx_setMaxWindowSize(d.dctx, max_window_size)
	check_error(res)!
}

pub fn (d &DecompressContext) decompress(src []u8) ![]u8 {
	max_len := get_frame_content_size(src)!
	mut dst := []u8{len: max_len}
	len := d.decompress_to(mut dst, src)!
	if len != dst.len {
		dst = unsafe { dst[..len] }
	}
	return dst
}

[inline]
pub fn (d &DecompressContext) decompress_to(mut dst []u8, src []u8) !int {
	return unsafe { d.decompress_at(mut dst.data, dst.len, src.data, src.len)! }
}

[unsafe]
pub fn (d &DecompressContext) decompress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int {
	res := C.ZSTD_decompressDCtx(d.dctx, dst, dst_len, src, src_len)
	check_error(res)!
	return int(res)
}
