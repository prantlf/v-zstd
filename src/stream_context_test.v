module zstd

fn test_drain_empty_buffer() {
	drain := fn (buf &u8, len int) ! {}
	output := &C.ZSTD_outBuffer{unsafe { nil }, 0, 0}
	input := &C.ZSTD_inBuffer{unsafe { nil }, 0, 0}
	mut sctx := &StreamContext{drain, output, input}
	drain_buffer(mut sctx)!
}

fn test_drain_output() {
	drain := fn (buf &u8, len int) ! {}
	output := &C.ZSTD_outBuffer{unsafe { nil }, 0, 1}
	input := &C.ZSTD_inBuffer{unsafe { nil }, 0, 0}
	mut sctx := &StreamContext{drain, output, input}
	drain_buffer(mut sctx)!
	assert output.pos == 0
}

fn test_drain_partially_consumed_input() {
	drain := fn (buf &u8, len int) ! {}
	output := &C.ZSTD_outBuffer{unsafe { nil }, 0, 0}
	input := &C.ZSTD_inBuffer{unsafe { nil }, 1, 1}
	mut sctx := &StreamContext{drain, output, input}
	drain_buffer(mut sctx)!
	assert input.size == 0
	assert input.pos == 0
}

fn test_drain_fully_consumed_input() {
	drain := fn (buf &u8, len int) ! {}
	output := &C.ZSTD_outBuffer{unsafe { nil }, 0, 0}
	mut src := [u8(1), u8(2)]
	input := &C.ZSTD_inBuffer{unsafe { src.data }, 2, 1}
	mut sctx := &StreamContext{drain, output, input}
	drain_buffer(mut sctx)!
	assert input.size == 1
	assert input.pos == 0
	assert src[0] == u8(2)
}
