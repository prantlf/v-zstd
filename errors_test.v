module zstd

fn test_check_error_ok_0() {
	check_error(0)!
}

fn test_check_error_ok_1() {
	check_error(1)!
}

fn test_check_error_fail_1() {
	if _ := check_error(usize(-1)) {
		assert false
	} else {
		assert err.msg() == 'Error (generic)'
		assert err.code() == 1
	}
}

fn test_check_error_fail_12() {
	if _ := check_error(usize(-12)) {
		assert false
	} else {
		assert err.msg() == 'Version not supported'
		assert err.code() == 12
	}
}
