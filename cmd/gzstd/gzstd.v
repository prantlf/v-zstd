module main

import os { create, open, rm }
import zstd { CompressContext, CompressParam, StreamContext, new_compress_context, new_compress_stream_context }

fn compress(in_name string, cctx &CompressContext, mut sctx StreamContext, mut buf []u8) ! {
	cctx.reset(zstd.ResetDir.session_only)

	mut in_file := open(in_name)!
	defer {
		in_file.close()
	}

	out_name := '${in_name}.z'
	mut out_file := create(out_name)!
	defer {
		out_file.close()
	}
	mut out_file_ref := &out_file

	drain := fn [mut out_file_ref] (buf &u8, len int) ! {
		unsafe { out_file_ref.write_full_buffer(buf, usize(len))! }
	}
	abort := fn [out_name, mut out_file_ref] () {
		out_file_ref.close()
		rm(out_name) or { eprintln('cleanup failed: ${err.msg()}') }
	}

	for {
		len := in_file.read_into_ptr(buf.data, buf.len) or {
			abort()
			return err
		}
		last := len < buf.len
		unsafe {
			cctx.compress_chunk_at(mut sctx, buf.data, len, last, drain) or {
				abort()
				return err
			}
		}
		if last {
			break
		}
	}
}

fn main() {
	if os.args.len < 2 {
		eprintln('name of file to compress missing')
		exit(1)
	}

	cctx := new_compress_context()!
	defer {
		cctx.free()
	}
	cctx.set_param(CompressParam.checksum_flag, 1)!
	mut sctx := new_compress_stream_context()
	mut buf := []u8{len: zstd.compress_stream_in_size}

	for i in 1 .. os.args.len {
		name := os.args[i]
		if _ := compress(name, cctx, mut sctx, mut buf) {
			println('${name} compressed')
		} else {
			println('${name} failed: ${err.msg()}')
		}
	}
}
