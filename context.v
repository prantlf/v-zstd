module zstd

pub enum ResetDir {
	session_only           = C.ZSTD_reset_session_only
	parameters             = C.ZSTD_reset_parameters
	session_and_parameters = C.ZSTD_reset_session_and_parameters
}
