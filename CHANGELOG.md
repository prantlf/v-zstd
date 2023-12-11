# Changes

## [0.1.1](https://github.com/prantlf/v-zstd/compare/v0.1.0...v0.1.1) (2023-12-11)

### Bug Fixes

* Adapt for V langage changes ([27462ee](https://github.com/prantlf/v-zstd/commit/27462ee8d0f10c1274e6965697405408c54cd4c0))

## [0.1.0](https://github.com/prantlf/v-zstd/compare/v0.0.1...v0.1.0) (2023-10-26)

### Features

* Remove the drain function from stream context ([f9e5872](https://github.com/prantlf/v-zstd/commit/f9e58728ad28bcc08ed2dbd2358e1d993bedf8a8))
* Make input and ooutput sizes of the stream buffers public ([b34cd33](https://github.com/prantlf/v-zstd/commit/b34cd3357ce89b81104ee9ecd6092c7b61177b1f))
* Add gzstd anz gunzstd executables as examples ([d4b7fb3](https://github.com/prantlf/v-zstd/commit/d4b7fb3d02319e8abbbe38379880f36238b01487))

### BREAKING CHANGES

Do not pass the drain function to new_compress_stream_context and new_decompress_stream_context. Pass it to each call of compress_chunk, compress_chunk_at, compress_end, decompress_chunk and decompress_chunk_at.

## 0.0.1 (2023-10-25)

Initial release.
