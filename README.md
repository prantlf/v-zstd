# Zstd for V

V bindings for [zstd] - a fast lossless compression algorithm, targeting real-time compression scenarios at zlib-level and better compression ratios.

This package uses the version 1.5.5 of [zstd].

## Synopsis

```v
import prantlf.zstd

src := 'A text to compress.'.bytes()
dst := zstd.compress(src)!
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.zstd
v install --git https://github.com/prantlf/v-zstd
```

## Examples

* [cmd/gzstd/gzstd.v]: simple command-line tool for compressing files
* [cmd/gunzstd/gunzstd.v]: simple command-line tool for decompressing files

## API

The API corresponds with the [zstd] C API. See also the [original API documentation].

### Once

If you want to compress or decompress once, use the following convenience functions:

```v
compress(src []u8) ![]u8
compress_with_level(src []u8, compression_level int) ![]u8
decompress(src []u8) ![]u8
```

If you want to reuse the destination buffer for more compressions or decompressions, make sure to check the returned number of bytes written to it:

```v
compress_to(mut dst []u8, src []u8) !int
compress_with_level_to(mut dst []u8, src []u8, compression_level int) !int
decompress_to(mut dst []u8, src []u8) !int
```

Finally, you can have the full controll over the memory pointers by using the unsafe functions:

```v
compress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int
compress_with_level_at(mut dst &u8, dst_len int, src &u8, src_len int, compression_level int) !int
decompress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int
```

### Repeatedly

If you want to compress or decompress multiple times, you can gain better performance by creating a compression or decompression context and reuse it. You will be able to set compression and decompression parameters too:

```v
cctx := zstd.new_compress_context()
defer { cctx.free() }
cctx.set_param(zstd.CompressParam.compression_level, zstd.max_compress_level)!

src := 'A text to compress.'.bytes()
dst := cctx.compress(src)!

cctx.reset(zstd.ResetDir.session_only)

src2 := 'Anoter text to compress.'.bytes()
dst2 := cctx.compress(src2)!
```

#### Compression

```v
enum ResetDir {
  session_only
  parameters
  session_and_parameters
}

new_compress_context() !&CompressContext
(c &CompressContext) free()
(c &CompressContext) reset(reset ResetDir)

const (
  strategy_fast
  strategy_dfast
  strategy_greedy
  strategy_lazy
  strategy_lazy2
  strategy_btlazy2
  strategy_btopt
  strategy_btultra
  strategy_btultra2
)

enum CompressParam {
  compression_level
  window_log
  hash_log
  chain_log
  search_log
  min_match
  target_length
  strategy
  enable_long_distance_matching
  ldm_hash_log
  ldm_min_match
  ldm_bucket_size_log
  ldm_hash_rate_log
  content_size_flag
  checksum_flag
  dict_id_flag
  nb_workers
  job_size
  overlap_log
  rsyncable
  format
  force_max_window
  force_attach_dict
  literal_compression_mode
  target_c_block_size
  src_size_hint
  enable_dedicated_dict_search
  stable_in_buffer
  stable_out_buffer
  block_delimiters
  validate_sequences
  use_block_splitter
  use_row_match_finder
  prefetch_c_dict_tables
  enable_seq_producer_fallback
  max_block_size
}

compress_param_bounds(param CompressParam) !(int, int)
(c &CompressContext) set_param(param CompressParam, value int) !
(c &CompressContext) get_param(param CompressParam) !int
(c &CompressContext) set_pledged_src_size(pledged_src_size int) !

(c &CompressContext) compress(src []u8) ![]u8
(c &CompressContext) compress_to(mut dst []u8, src []u8) !int
(c &CompressContext) compress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int
```

#### Decompression

```v
enum ResetDir {
  session_only
  parameters
  session_and_parameters
}

new_decompress_context() !&DecompressContext
(d &DecompressContext) free()
(d &DecompressContext) reset(reset ResetDir)

enum DecompressParam {
  window_log_max
  format
  stable_out_buffer
  force_ignore_checksum
  ref_multiple_d_dicts
}

decompress_param_bounds(param DecompressParam) !(int, int)
(d &DecompressContext) set_param(param DecompressParam, value int) !
(d &DecompressContext) get_param(param DecompressParam) !int
(d &DecompressContext) set_max_window_size(max_window_size int) !

(d &DecompressContext) decompress(src []u8) ![]u8
(d &DecompressContext) decompress_to(mut dst []u8, src []u8) !int
(d &DecompressContext) decompress_at(mut dst &u8, dst_len int, src &u8, src_len int) !int
```

### Streaming

If you want to compress or decompress large data, or if the data comes chunk after chunk, you can use chunked compression or decompression functions:

```v
cctx := zstd.new_compress_context()!
defer { cctx.free() }
cctx.set_param(zstd.CompressParam.checksum_flag, 1)!
mut sctx := zstd.new_compress_stream_context()

mut dst := []u8{cap: zstd.compress_bound(src.len)}
mut dst_ref := &dst
drain := fn [dst_ref] (buf &u8, len int) ! {
  unsafe { dst_ref.push_many(buf, len) }
}

cctx.compress_chunk(mut sctx, src, false, drain)!
...
unsafe { cctx.compress_chunk(mut sctx, data, len, true, drain)! }
...
cctx.compress_end(mut sctx)!
```

#### Compression

```v
const (
  compress_stream_out_size
  compress_stream_in_size
)

new_compress_stream_context() &StreamContext
(c &CompressContext) compress_chunk(
  mut sctx StreamContext, src []u8, last bool, drain fn (buf &u8, len int) !) !
(c &CompressContext) compress_chunk_at(
  mut sctx StreamContext, src &u8, src_len int, last bool, drain fn (buf &u8, len int) !) !
```

#### Decompression

```v
const (
  decompress_stream_out_size
  decompress_stream_in_size
)

new_decompress_stream_context() &StreamContext
(d &DecompressContext) decompress_chunk(
  mut sctx StreamContext, src []u8, last bool, drain fn (buf &u8, len int) !) !
(d &DecompressContext) decompress_chunk_at(
  mut sctx StreamContext, src &u8, src_len int, last bool, drain fn (buf &u8, len int) !) !
```

### Errors

THe following error codes can be checked by calling the `code` method of `IError`:

```v
const (
  err_no_error
  err_generic
  err_prefix_unknown
  err_version_unsupported
  err_frame_parameter_unsupported
  err_frame_parameter_window_too_large
  err_corruption_detected
  err_checksum_wrong
  err_literals_header_wrong
  err_dictionary_corrupted
  err_dictionary_wrong
  err_dictionary_creation_failed
  err_parameter_unsupported
  err_parameter_combination_unsupported
  err_parameter_out_of_bound
  err_table_log_too_large
  err_max_symbol_value_too_large
  err_max_symbol_value_too_small
  err_stability_condition_not_respected
  err_stage_wrong
  err_init_missing
  err_memory_allocation
  err_work_space_too_small
  err_dst_size_too_small
  err_src_size_wrong
  err_dst_buffer_null
  err_no_forward_progress_dest_full
  err_no_forward_progress_input_empty
  err_frame_index_too_large
  err_seekable_io
  err_dst_buffer_wrong
  err_src_buffer_wrong
  err_sequence_producer_failed
  err_external_sequences_invalid
  err_max_code
)
```

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023-2024 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.zstd
[zstd]: http://www.zstd.net/
[original API documentation]: https://facebook.github.io/zstd/zstd_manual.html
[cmd/gzstd/gzstd.v]: ./cmd/gzstd/gzstd.v
[cmd/gunzstd/gunzstd.v]: ./cmd/gunzstd/gunzstd.v
