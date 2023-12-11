module zstd

#flag -D ZSTD_STATIC_LINKING_ONLY
#flag -D ZSTD_DISABLE_ASM
$if windows {
	#flag -D ZSTD_NO_INTRINSICS
}
#flag -I @VROOT/libzstd
#flag @VROOT/libzstd/common/debug.o
#flag @VROOT/libzstd/common/entropy_common.o
#flag @VROOT/libzstd/common/error_private.o
#flag @VROOT/libzstd/common/fse_decompress.o
#flag @VROOT/libzstd/common/pool.o
#flag @VROOT/libzstd/common/threading.o
#flag @VROOT/libzstd/common/xxhash.o
#flag @VROOT/libzstd/common/zstd_common.o
#flag @VROOT/libzstd/compress/fse_compress.o
#flag @VROOT/libzstd/compress/hist.o
#flag @VROOT/libzstd/compress/huf_compress.o
#flag @VROOT/libzstd/compress/zstd_compress.o
#flag @VROOT/libzstd/compress/zstd_compress_literals.o
#flag @VROOT/libzstd/compress/zstd_compress_sequences.o
#flag @VROOT/libzstd/compress/zstd_compress_superblock.o
#flag @VROOT/libzstd/compress/zstd_double_fast.o
#flag @VROOT/libzstd/compress/zstd_fast.o
#flag @VROOT/libzstd/compress/zstd_lazy.o
#flag @VROOT/libzstd/compress/zstd_ldm.o
#flag @VROOT/libzstd/compress/zstd_opt.o
#flag @VROOT/libzstd/compress/zstdmt_compress.o
#flag @VROOT/libzstd/decompress/huf_decompress.o
#flag @VROOT/libzstd/decompress/zstd_ddict.o
#flag @VROOT/libzstd/decompress/zstd_decompress.o
#flag @VROOT/libzstd/decompress/zstd_decompress_block.o
#include "zstd.h"

@[typedef]
struct C.ZSTD_CCtx {}

@[typedef]
struct C.ZSTD_DCtx {}

// [typedef]
// struct C.ZSTD_CStream {}

// [typedef]
// struct C.ZSTD_DStream {}

@[typedef]
struct C.ZSTD_bounds {
	error      usize
	lowerBound int
	upperBound int
}

@[typedef]
struct C.ZSTD_inBuffer {
mut:
	src  voidptr
	size usize
	pos  usize
}

@[typedef]
struct C.ZSTD_outBuffer {
mut:
	dst  voidptr
	size usize
	pos  usize
}

fn C.ZSTD_isError(err usize) u32
fn C.ZSTD_getErrorName(err usize) charptr

fn C.ZSTD_compress(dst voidptr, dstCapacity usize, src voidptr, srcSize usize, compressionLevel int) usize
fn C.ZSTD_decompress(dst voidptr, dstCapacity usize, src voidptr, compressedSize usize) usize

fn C.ZSTD_getFrameContentSize(src voidptr, srcSize usize) u64
fn C.ZSTD_findFrameCompressedSize(src voidptr, srcSize usize) usize

fn C.ZSTD_compressBound(srcSize usize) usize
fn C.ZSTD_minCLevel() int
fn C.ZSTD_maxCLevel() int
fn C.ZSTD_defaultCLevel() int

fn C.ZSTD_createCCtx() &C.ZSTD_CCtx
fn C.ZSTD_freeCCtx(cctx &C.ZSTD_CCtx) usize
fn C.ZSTD_CCtx_reset(cctx &C.ZSTD_CCtx, reset int) usize
fn C.ZSTD_cParam_getBounds(cParam int) C.ZSTD_bounds
fn C.ZSTD_CCtx_setParameter(cctx &C.ZSTD_CCtx, param int, value int) usize
fn C.ZSTD_CCtx_getParameter(cctx &C.ZSTD_CCtx, param int, value &int) usize
fn C.ZSTD_CCtx_setPledgedSrcSize(cctx &C.ZSTD_CCtx, pledgedSrcSize int) usize
fn C.ZSTD_compress2(cctx &C.ZSTD_CCtx, dst voidptr, dstCapacity usize, src voidptr, srcSize usize) usize

fn C.ZSTD_createDCtx() &C.ZSTD_DCtx
fn C.ZSTD_freeDCtx(dctx &C.ZSTD_DCtx) usize
fn C.ZSTD_DCtx_reset(dctx &C.ZSTD_DCtx, reset int) usize
fn C.ZSTD_dParam_getBounds(dParam int) C.ZSTD_bounds
fn C.ZSTD_DCtx_setParameter(dctx &C.ZSTD_DCtx, param int, value int) usize
fn C.ZSTD_DCtx_getParameter(dctx &C.ZSTD_DCtx, param int, value &int) usize
fn C.ZSTD_DCtx_setMaxWindowSize(dctx &C.ZSTD_DCtx, maxWindowSize usize) usize
fn C.ZSTD_decompressDCtx(dctx &C.ZSTD_DCtx, dst voidptr, dstCapacity usize, src voidptr, srcSize usize) usize

// fn C.ZSTD_createCStream() &C.ZSTD_CStream
// fn C.ZSTD_freeCStream(zcs &C.ZSTD_CStream) usize
fn C.ZSTD_CStreamInSize() usize
fn C.ZSTD_CStreamOutSize() usize
fn C.ZSTD_compressStream2(cctx &C.ZSTD_CCtx, output &C.ZSTD_outBuffer, input &C.ZSTD_inBuffer, endOp int) usize

// fn C.ZSTD_createDStream() &C.ZSTD_DStream
// fn C.ZSTD_freeDStream(zds &C.ZSTD_DStream) usize
// fn C.ZSTD_initDStream(zds &C.ZSTD_DStream) usize
fn C.ZSTD_DStreamInSize() usize
fn C.ZSTD_DStreamOutSize() usize
fn C.ZSTD_decompressStream(zds &C.ZSTD_DCtx, output &C.ZSTD_outBuffer, input &C.ZSTD_inBuffer) usize
