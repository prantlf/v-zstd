module zstd

fn decompress_stream_test(src []u8) ![]u8 {
	dctx := new_decompress_context()!
	defer {
		dctx.free()
	}

	mut dst := []u8{cap: compress_bound(src.len)}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_decompress_stream_context(drain)
	dctx.decompress_chunk(mut sctx, src, true)!

	return dst
}

fn test_compress_one() {
	cctx := new_compress_context()!
	defer {
		cctx.free()
	}
	cctx.set_param(CompressParam.compression_level, 5)!
	cctx.set_param(CompressParam.checksum_flag, 1)!

	src := 'A sentence with a length longer than a minimum content size to test zstd compression.'.bytes()
	mut dst := []u8{cap: compress_bound(src.len)}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_compress_stream_context(drain)
	cctx.compress_chunk(mut sctx, src, true)!
	cctx.reset(ResetDir.session_and_parameters)

	assert dst == [u8(40), u8(181), u8(47), u8(253), u8(36), u8(85), u8(61), u8(2), u8(0), u8(18),
		u8(133), u8(15), u8(20), u8(176), u8(55), u8(7), u8(208), u8(167), u8(37), u8(249), u8(38),
		u8(165), u8(31), u8(217), u8(156), u8(164), u8(6), u8(216), u8(131), u8(51), u8(230), u8(17),
		u8(1), u8(192), u8(97), u8(101), u8(26), u8(13), u8(134), u8(164), u8(194), u8(51), u8(245),
		u8(233), u8(23), u8(95), u8(167), u8(202), u8(30), u8(73), u8(141), u8(176), u8(186), u8(178),
		u8(142), u8(222), u8(48), u8(47), u8(114), u8(57), u8(60), u8(53), u8(47), u8(231), u8(211),
		u8(81), u8(243), u8(42), u8(106), u8(114), u8(254), u8(57), u8(27), u8(4), u8(1), u8(0),
		u8(1), u8(3), u8(5), u8(5), u8(194), u8(123), u8(104), u8(76)]
	assert src == decompress_stream_test(dst)!
}

fn test_compress_two() {
	cctx := new_compress_context()!
	defer {
		cctx.free()
	}
	cctx.set_param(CompressParam.compression_level, 5)!
	cctx.set_param(CompressParam.checksum_flag, 1)!

	src := 'A sentence with a length longer than a minimum content size to test zstd compression.'.bytes()
	half := src.len / 2

	max_len := compress_bound(src.len)
	mut dst := []u8{cap: max_len}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_compress_stream_context(drain)
	unsafe {
		cctx.compress_chunk_at(mut sctx, src.data, half, false)!
		cctx.compress_chunk_at(mut sctx, &u8(src.data) + half, src.len - half, true)!
	}
	assert dst == [u8(40), u8(181), u8(47), u8(253), u8(4), u8(88), u8(21), u8(2), u8(0), u8(82),
		u8(133), u8(15), u8(19), u8(176), u8(23), u8(115), u8(208), u8(167), u8(37), u8(249), u8(38),
		u8(211), u8(179), u8(108), u8(78), u8(82), u8(3), u8(236), u8(193), u8(25), u8(243), u8(136),
		u8(0), u8(27), u8(221), u8(245), u8(12), u8(202), u8(6), u8(5), u8(191), u8(129), u8(191),
		u8(158), u8(118), u8(118), u8(160), u8(227), u8(221), u8(219), u8(6), u8(139), u8(80),
		u8(100), u8(42), u8(10), u8(90), u8(148), u8(243), u8(148), u8(216), u8(12), u8(203), u8(137),
		u8(107), u8(40), u8(88), u8(78), u8(5), u8(118), u8(184), u8(119), u8(143), u8(129), u8(0),
		u8(194), u8(123), u8(104), u8(76)]
	assert src == decompress_stream_test(dst)!
}

fn test_compress_with_end() {
	cctx := new_compress_context()!
	defer {
		cctx.free()
	}
	cctx.set_param(CompressParam.compression_level, 5)!
	cctx.set_param(CompressParam.checksum_flag, 1)!

	src := 'A sentence with a length longer than a minimum content size to test zstd compression.'.bytes()
	half := src.len / 2

	max_len := compress_bound(src.len)
	mut dst := []u8{cap: max_len}
	mut dst_ref := &dst

	drain := fn [dst_ref] (buf &u8, len int) ! {
		unsafe { dst_ref.push_many(buf, len) }
	}
	mut sctx := new_compress_stream_context(drain)
	unsafe {
		cctx.compress_chunk_at(mut sctx, src.data, half, false)!
		cctx.compress_chunk_at(mut sctx, &u8(src.data) + half, src.len - half, false)!
	}
	cctx.compress_end(mut sctx)!

	assert dst == [u8(40), u8(181), u8(47), u8(253), u8(4), u8(88), u8(21), u8(2), u8(0), u8(82),
		u8(133), u8(15), u8(19), u8(176), u8(23), u8(115), u8(208), u8(167), u8(37), u8(249), u8(38),
		u8(211), u8(179), u8(108), u8(78), u8(82), u8(3), u8(236), u8(193), u8(25), u8(243), u8(136),
		u8(0), u8(27), u8(221), u8(245), u8(12), u8(202), u8(6), u8(5), u8(191), u8(129), u8(191),
		u8(158), u8(118), u8(118), u8(160), u8(227), u8(221), u8(219), u8(6), u8(139), u8(80),
		u8(100), u8(42), u8(10), u8(90), u8(148), u8(243), u8(148), u8(216), u8(12), u8(203), u8(137),
		u8(107), u8(40), u8(88), u8(78), u8(5), u8(118), u8(184), u8(119), u8(143), u8(129), u8(0),
		u8(194), u8(123), u8(104), u8(76)]
	assert src == decompress_stream_test(dst)!
}
