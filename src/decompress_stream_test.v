module zstd

fn compress_stream_test(src []u8) ![]u8 {
	cctx := new_compress_context()!
	defer {
		cctx.free()
	}
	cctx.set_param(CompressParam.checksum_flag, 1)!

	mut dst := []u8{cap: compress_bound(src.len)}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_compress_stream_context()
	cctx.compress_chunk(mut sctx, src, true, drain)!

	return dst
}

fn test_decompress_one() {
	dctx := new_decompress_context()!
	defer {
		dctx.free()
	}
	dctx.set_param(DecompressParam.window_log_max, 27)!
	assert dctx.get_param(DecompressParam.window_log_max)! == 27

	src := [u8(40), u8(181), u8(47), u8(253), u8(36), u8(85), u8(61), u8(2), u8(0), u8(18), u8(133),
		u8(15), u8(20), u8(176), u8(55), u8(7), u8(208), u8(167), u8(37), u8(249), u8(38), u8(165),
		u8(31), u8(217), u8(156), u8(164), u8(6), u8(216), u8(131), u8(51), u8(230), u8(17), u8(1),
		u8(192), u8(97), u8(101), u8(26), u8(13), u8(134), u8(164), u8(194), u8(51), u8(245), u8(233),
		u8(23), u8(95), u8(167), u8(202), u8(30), u8(73), u8(141), u8(176), u8(186), u8(178), u8(142),
		u8(222), u8(48), u8(47), u8(114), u8(57), u8(60), u8(53), u8(47), u8(231), u8(211), u8(81),
		u8(243), u8(42), u8(106), u8(114), u8(254), u8(57), u8(27), u8(4), u8(1), u8(0), u8(1),
		u8(3), u8(5), u8(5), u8(194), u8(123), u8(104), u8(76)]

	mut dst := []u8{cap: compress_bound(src.len)}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_decompress_stream_context()
	dctx.decompress_chunk(mut sctx, src, true, drain)!
	dctx.reset(ResetDir.session_and_parameters)

	assert dst == 'A sentence with a length longer than a minimum content size to test zstd compression.'.bytes()
}

fn test_decompress_two() {
	dctx := new_decompress_context()!
	defer {
		dctx.free()
	}

	src := [u8(40), u8(181), u8(47), u8(253), u8(36), u8(85), u8(61), u8(2), u8(0), u8(18), u8(133),
		u8(15), u8(20), u8(176), u8(55), u8(7), u8(208), u8(167), u8(37), u8(249), u8(38), u8(165),
		u8(31), u8(217), u8(156), u8(164), u8(6), u8(216), u8(131), u8(51), u8(230), u8(17), u8(1),
		u8(192), u8(97), u8(101), u8(26), u8(13), u8(134), u8(164), u8(194), u8(51), u8(245), u8(233),
		u8(23), u8(95), u8(167), u8(202), u8(30), u8(73), u8(141), u8(176), u8(186), u8(178), u8(142),
		u8(222), u8(48), u8(47), u8(114), u8(57), u8(60), u8(53), u8(47), u8(231), u8(211), u8(81),
		u8(243), u8(42), u8(106), u8(114), u8(254), u8(57), u8(27), u8(4), u8(1), u8(0), u8(1),
		u8(3), u8(5), u8(5), u8(194), u8(123), u8(104), u8(76)]
	half := src.len / 2

	mut dst := []u8{cap: compress_bound(src.len)}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_decompress_stream_context()
	unsafe {
		dctx.decompress_chunk_at(mut sctx, src.data, half, false, drain)!
		dctx.decompress_chunk_at(mut sctx, &u8(src.data) + half, src.len - half, true,
			drain)!
	}
	assert dst == 'A sentence with a length longer than a minimum content size to test zstd compression.'.bytes()
	assert src == compress_stream_test(dst)!
}
