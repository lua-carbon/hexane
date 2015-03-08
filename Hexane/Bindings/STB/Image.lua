--[[
	LuaJIT-STB
	stb_image
]]

local ffi = require("ffi")
local stb_image = ffi.load("stb")

ffi.cdef([==[
/* stb_image v2.02
	For full documentation for this version, see stb/stb_image.c,
	or the original repository at https://github.com/nothings/sb

	QUICK NOTES:
		Primarily of interest to game developers and other people who can
		  avoid problematic images and only need the trivial interface

		JPEG baseline & progressive (12 bpc/arithmetic not supported, same as stock IJG lib)
		PNG 1/2/4/8-bit-per-channel (16 bpc not supported)

		TGA (not sure what subset, if a subset)
		BMP non-1bpp, non-RLE
		PSD (composited view only, no extra channels)

		GIF (*comp always reports as 4-channel)
		HDR (radiance rgbE format)
		PIC (Softimage PIC)
		PNM (PPM and PGM binary only)

		- decode from memory or through FILE (define STBI_NO_STDIO to remove code)
		- decode from arbitrary I/O callbacks
		- SIMD acceleration on x86/x64 (SSE2) and ARM (NEON)
*/

// stdio
typedef struct {} FILE;

enum {
	STBI_default = 0, // only used for req_comp
	STBI_grey       = 1,
	STBI_grey_alpha = 2,
	STBI_rgb        = 3,
	STBI_rgb_alpha  = 4
};

typedef unsigned char stbi_uc;

typedef struct {
	int (*read) (void *user,char *data,int size);   // fill 'data' with 'size' bytes.  return number of bytes actually read
	void (*skip) (void *user,int n);                 // skip the next 'n' bytes, or 'unget' the last -n bytes if negative
	int (*eof) (void *user);                       // returns nonzero if we are at end of file/data
} stbi_io_callbacks;

stbi_uc *stbi_load               (char              const *filename,           int *x, int *y, int *comp, int req_comp);
stbi_uc *stbi_load_from_memory   (stbi_uc           const *buffer, int len   , int *x, int *y, int *comp, int req_comp);
stbi_uc *stbi_load_from_callbacks(stbi_io_callbacks const *clbk  , void *user, int *x, int *y, int *comp, int req_comp);

// #ifndef STBI_NO_STDIO
stbi_uc *stbi_load_from_file  (FILE *f, int *x, int *y, int *comp, int req_comp);
// for stbi_load_from_file, file pointer is left pointing immediately after image

// linear
float *stbi_loadf                 (char const *filename,           int *x, int *y, int *comp, int req_comp);
float *stbi_loadf_from_memory     (stbi_uc const *buffer, int len, int *x, int *y, int *comp, int req_comp);
float *stbi_loadf_from_callbacks  (stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp, int req_comp);
// #ifndef STBI_NO_STDIO
float *stbi_loadf_from_file  (FILE *f,                int *x, int *y, int *comp, int req_comp);

// HDR
void   stbi_hdr_to_ldr_gamma(float gamma);
void   stbi_hdr_to_ldr_scale(float scale);

// linear-HDR
void   stbi_ldr_to_hdr_gamma(float gamma);
void   stbi_ldr_to_hdr_scale(float scale);

int    stbi_is_hdr_from_callbacks(stbi_io_callbacks const *clbk, void *user);
int    stbi_is_hdr_from_memory(stbi_uc const *buffer, int len);

// #ifndef STBI_NO_STDIO
int      stbi_is_hdr          (char const *filename);
int      stbi_is_hdr_from_file(FILE *f);


const char *stbi_failure_reason  (void);
void     stbi_image_free      (void *retval_from_stbi_load);
int      stbi_info_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *comp);
int      stbi_info_from_callbacks(stbi_io_callbacks const *clbk, void *user, int *x, int *y, int *comp);

// #ifndef STBI_NO_STDIO
int      stbi_info            (char const *filename,     int *x, int *y, int *comp);
int      stbi_info_from_file  (FILE *f,                  int *x, int *y, int *comp);

void stbi_set_unpremultiply_on_load(int flag_true_if_should_unpremultiply);
void stbi_convert_iphone_png_to_rgb(int flag_true_if_should_convert);


// ZLIB client - used by PNG, available for other purposes

char *stbi_zlib_decode_malloc_guesssize(const char *buffer, int len, int initial_size, int *outlen);
char *stbi_zlib_decode_malloc_guesssize_headerflag(const char *buffer, int len, int initial_size, int *outlen, int parse_header);
char *stbi_zlib_decode_malloc(const char *buffer, int len, int *outlen);
int   stbi_zlib_decode_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);

char *stbi_zlib_decode_noheader_malloc(const char *buffer, int len, int *outlen);
int   stbi_zlib_decode_noheader_buffer(char *obuffer, int olen, const char *ibuffer, int ilen);
]==])

return stb_image