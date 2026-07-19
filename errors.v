module zstd

@[noinit]
pub struct ContentSizeUnknown {
	Error
}

pub fn (err &ContentSizeUnknown) msg() string {
	return 'content size unknown'
}

pub const err_no_error = 0
pub const err_generic = 1
pub const err_prefix_unknown = 10
pub const err_version_unsupported = 12
pub const err_frame_parameter_unsupported = 14
pub const err_frame_parameter_window_too_large = 16
pub const err_corruption_detected = 20
pub const err_checksum_wrong = 22
pub const err_literals_header_wrong = 24
pub const err_dictionary_corrupted = 30
pub const err_dictionary_wrong = 32
pub const err_dictionary_creation_failed = 34
pub const err_parameter_unsupported = 40
pub const err_parameter_combination_unsupported = 41
pub const err_parameter_out_of_bound = 42
pub const err_table_log_too_large = 44
pub const err_max_symbol_value_too_large = 46
pub const err_max_symbol_value_too_small = 48
pub const err_stability_condition_not_respected = 50
pub const err_stage_wrong = 60
pub const err_init_missing = 62
pub const err_memory_allocation = 64
pub const err_work_space_too_small = 66
pub const err_dst_size_too_small = 70
pub const err_src_size_wrong = 72
pub const err_dst_buffer_null = 74
pub const err_no_forward_progress_dest_full = 80
pub const err_no_forward_progress_input_empty = 82
pub const err_frame_index_too_large = 100
pub const err_seekable_io = 102
pub const err_dst_buffer_wrong = 104
pub const err_src_buffer_wrong = 105
pub const err_sequence_producer_failed = 106
pub const err_external_sequences_invalid = 107
pub const err_max_code = 120

fn check_error(res usize) ! {
	if C.ZSTD_isError(res) != 0 {
		return error_with_code(unsafe { tos2(C.ZSTD_getErrorName(res)) }, -int(res))
	}
}
