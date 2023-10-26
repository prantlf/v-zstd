module zstd

fn test_get_frame_content_size_empty() {
	if _ := get_frame_content_size([]u8{}) {
		assert false
	} else {
		assert err.msg() == 'invalid content'
	}
}

fn test_get_frame_content_size_real() {
	src := 'A sentence with a length longer than a minimum content size to test zstd compression.'.bytes()
	dst := compress(src)!
	len := get_frame_content_size(dst)!
	assert len == src.len
}

fn test_compress_bound_zero() {
	len := compress_bound(0)
	assert len == 64
}

fn test_compress_bound() {
	len := compress_bound(64)
	assert len == 127
}

fn test_compress_level() {
	assert min_compress_level < max_compress_level
	assert min_compress_level <= default_compress_level
	assert default_compress_level <= max_compress_level
}
