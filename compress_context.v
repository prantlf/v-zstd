module zstd

@[noinit]
pub struct CompressContext {
	cctx &C.ZSTD_CCtx = unsafe { nil }
}

pub const strategy_fast = C.ZSTD_fast
pub const strategy_dfast = C.ZSTD_dfast
pub const strategy_greedy = C.ZSTD_greedy
pub const strategy_lazy = C.ZSTD_lazy
pub const strategy_lazy2 = C.ZSTD_lazy2
pub const strategy_btlazy2 = C.ZSTD_btlazy2
pub const strategy_btopt = C.ZSTD_btopt
pub const strategy_btultra = C.ZSTD_btultra
pub const strategy_btultra2 = C.ZSTD_btultra2

pub enum CompressParam {
	compression_level             = C.ZSTD_c_compressionLevel
	window_log                    = C.ZSTD_c_windowLog
	hash_log                      = C.ZSTD_c_hashLog
	chain_log                     = C.ZSTD_c_chainLog
	search_log                    = C.ZSTD_c_searchLog
	min_match                     = C.ZSTD_c_minMatch
	target_length                 = C.ZSTD_c_targetLength
	strategy                      = C.ZSTD_c_strategy
	enable_long_distance_matching = C.ZSTD_c_enableLongDistanceMatching
	ldm_hash_log                  = C.ZSTD_c_ldmHashLog
	ldm_min_match                 = C.ZSTD_c_ldmMinMatch
	ldm_bucket_size_log           = C.ZSTD_c_ldmBucketSizeLog
	ldm_hash_rate_log             = C.ZSTD_c_ldmHashRateLog
	content_size_flag             = C.ZSTD_c_contentSizeFlag
	checksum_flag                 = C.ZSTD_c_checksumFlag
	dict_id_flag                  = C.ZSTD_c_dictIDFlag
	nb_workers                    = C.ZSTD_c_nbWorkers
	job_size                      = C.ZSTD_c_jobSize
	overlap_log                   = C.ZSTD_c_overlapLog
	rsyncable                     = C.ZSTD_c_rsyncable
	format                        = C.ZSTD_c_format
	force_max_window              = C.ZSTD_c_forceMaxWindow
	force_attach_dict             = C.ZSTD_c_forceAttachDict
	literal_compression_mode      = C.ZSTD_c_literalCompressionMode
	target_c_block_size           = C.ZSTD_c_targetCBlockSize
	src_size_hint                 = C.ZSTD_c_srcSizeHint
	enable_dedicated_dict_search  = C.ZSTD_c_enableDedicatedDictSearch
	stable_in_buffer              = C.ZSTD_c_stableInBuffer
	stable_out_buffer             = C.ZSTD_c_stableOutBuffer
	block_delimiters              = C.ZSTD_c_blockDelimiters
	validate_sequences            = C.ZSTD_c_validateSequences
	use_row_match_finder          = C.ZSTD_c_useRowMatchFinder
	prefetch_c_dict_tables        = C.ZSTD_c_prefetchCDictTables
	enable_seq_producer_fallback  = C.ZSTD_c_enableSeqProducerFallback
	max_block_size                = C.ZSTD_c_maxBlockSize
}

pub fn new_compress_context() !&CompressContext {
	cctx := C.ZSTD_createCCtx()
	if cctx == 0 {
		return error('creating compression context failed')
	}
	return &CompressContext{cctx}
}

pub fn (c &CompressContext) free() {
	C.ZSTD_freeCCtx(c.cctx)
}

pub fn (c &CompressContext) reset(reset ResetDir) {
	C.ZSTD_CCtx_reset(c.cctx, int(reset))
}

pub fn compress_param_bounds(param CompressParam) !(int, int) {
	bounds := C.ZSTD_cParam_getBounds(int(param))
	check_error(bounds.error)!
	return bounds.lowerBound, bounds.upperBound
}

pub fn (c &CompressContext) set_param(param CompressParam, value int) ! {
	res := C.ZSTD_CCtx_setParameter(c.cctx, int(param), value)
	check_error(res)!
}

pub fn (c &CompressContext) get_param(param CompressParam) !int {
	value := 0
	res := C.ZSTD_CCtx_getParameter(c.cctx, int(param), &value)
	check_error(res)!
	return value
}

pub fn (c &CompressContext) set_pledged_src_size(pledged_src_size int) ! {
	res := C.ZSTD_CCtx_setPledgedSrcSize(c.cctx, pledged_src_size)
	check_error(res)!
}

pub fn (c &CompressContext) compress(src []u8) ![]u8 {
	max_len := int(C.ZSTD_compressBound(src.len))
	mut dst := []u8{len: max_len}
	len := c.compress_to(mut dst, src)!
	if len != dst.len {
		dst = unsafe { dst[..len] }
	}
	return dst
}

@[inline]
pub fn (c &CompressContext) compress_to(mut dst []u8, src []u8) !int {
	return unsafe { c.compress_at(mut dst.data, dst.len, src.data, src.len)! }
}

@[unsafe]
pub fn (c &CompressContext) compress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int {
	res := C.ZSTD_compress2(c.cctx, dst, dst_len, src, src_len)
	check_error(res)!
	return int(res)
}
