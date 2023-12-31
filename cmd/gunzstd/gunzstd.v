// Decompresses files supplied on the command line. Creates new files cutting
// the extension ".z" from the original name away, or appending the extension
// ".uz", if the file without the extension ".z" already exists. The target
// file will be overwritten if it exists.

module main

import os { create, exists, open, rm }
import zstd { DecompressContext, StreamContext, new_decompress_context, new_decompress_stream_context }

fn decompress(in_name string, dctx &DecompressContext, mut sctx StreamContext, mut buf []u8) ! {
	// make sure that a failed previous decompression won't affect the new one
	dctx.reset(zstd.ResetDir.session_only)

	mut in_file := open(in_name)!
	defer {
		in_file.close()
	}

	out_name := if in_name.ends_with('.z') {
		name := in_name[..in_name.len - 2]
		// don't overwrite the original decompressed file - this is an example
		if exists(name) {
			'${name}.uz'
		} else {
			name
		}
	} else {
		'${in_name}.uz'
	}
	mut out_file := create(out_name)!
	defer {
		out_file.close()
	}
	mut out_file_ref := &out_file

	drain := fn [mut out_file_ref] (buf &u8, len int) ! {
		unsafe { out_file_ref.write_full_buffer(buf, usize(len))! }
	}

	// don't leave incomplete output files if something fails
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
			dctx.decompress_chunk_at(mut sctx, buf.data, len, last, drain) or {
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
		eprintln('name of file to decompress missing')
		exit(1)
	}

	dctx := new_decompress_context()!
	defer {
		dctx.free()
	}

	mut sctx := new_decompress_stream_context()

	// use the optimal input buffer size to prevent buffering or extra draining
	mut buf := []u8{len: zstd.decompress_stream_in_size}

	for i in 1 .. os.args.len {
		name := os.args[i]
		if _ := decompress(name, dctx, mut sctx, mut buf) {
			println('${name} decompressed')
		} else {
			println('${name} failed: ${err.msg()}')
		}
	}
}
