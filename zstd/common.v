module zstd

pub const min_compress_level = C.ZSTD_minCLevel()
pub const max_compress_level = C.ZSTD_maxCLevel()
pub const default_compress_level = C.ZSTD_defaultCLevel()

pub fn get_frame_content_size(frame []u8) !int {
	res := C.ZSTD_getFrameContentSize(frame.data, frame.len)
	match res {
		u64(C.ZSTD_CONTENTSIZE_UNKNOWN) {
			return ContentSizeUnknown{}
		}
		u64(C.ZSTD_CONTENTSIZE_ERROR) {
			return error('invalid content')
		}
		else {
			return int(res)
		}
	}
}

pub fn find_frame_compressed_size(src []u8) !int {
	res := C.ZSTD_findFrameCompressedSize(src.data, src.len)
	check_error(res)!
	return int(res)
}

pub fn compress_bound(srcSize int) int {
	return int(C.ZSTD_compressBound(srcSize))
}
