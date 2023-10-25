module zstd

[noinit]
pub struct ContentSizeUnknown {
	Error
}

pub fn (err &ContentSizeUnknown) msg() string {
	return 'content size unknown'
}

pub const (
	err_no_error                          = 0
	err_generic                           = 1
	err_prefix_unknown                    = 10
	err_version_unsupported               = 12
	err_frame_parameter_unsupported       = 14
	err_frame_parameter_window_too_large  = 16
	err_corruption_detected               = 20
	err_checksum_wrong                    = 22
	err_literals_header_wrong             = 24
	err_dictionary_corrupted              = 30
	err_dictionary_wrong                  = 32
	err_dictionary_creation_failed        = 34
	err_parameter_unsupported             = 40
	err_parameter_combination_unsupported = 41
	err_parameter_out_of_bound            = 42
	err_table_log_too_large               = 44
	err_max_symbol_value_too_large        = 46
	err_max_symbol_value_too_small        = 48
	err_stability_condition_not_respected = 50
	err_stage_wrong                       = 60
	err_init_missing                      = 62
	err_memory_allocation                 = 64
	err_work_space_too_small              = 66
	err_dst_size_too_small                = 70
	err_src_size_wrong                    = 72
	err_dst_buffer_null                   = 74
	err_no_forward_progress_dest_full     = 80
	err_no_forward_progress_input_empty   = 82
	err_frame_index_too_large             = 100
	err_seekable_io                       = 102
	err_dst_buffer_wrong                  = 104
	err_src_buffer_wrong                  = 105
	err_sequence_producer_failed          = 106
	err_external_sequences_invalid        = 107
	err_max_code                          = 120
)

fn check_error(res usize) ! {
	if C.ZSTD_isError(res) != 0 {
		return error_with_code(unsafe { tos2(C.ZSTD_getErrorName(res)) }, -int(res))
	}
}
