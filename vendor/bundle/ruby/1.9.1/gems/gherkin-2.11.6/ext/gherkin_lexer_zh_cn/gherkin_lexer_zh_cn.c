
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
#include <assert.h>
#include <ruby.h>

#if defined(_WIN32)
#include <stddef.h>
#endif

#ifdef HAVE_RUBY_RE_H
#include <ruby/re.h>
#else
#include <re.h>
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
#define ENCODED_STR_NEW(ptr, len) \
    rb_enc_str_new(ptr, len, rb_utf8_encoding())
#else
#define ENCODED_STR_NEW(ptr, len) \
    rb_str_new(ptr, len)
#endif

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif

#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#define DATA_GET(FROM, TYPE, NAME) \
  Data_Get_Struct(FROM, TYPE, NAME); \
  if (NAME == NULL) { \
    rb_raise(rb_eArgError, "NULL found for " # NAME " when it shouldn't be."); \
  }
 
typedef struct lexer_state {
  int content_len;
  int line_number;
  int current_line;
  int start_col;
  size_t mark;
  size_t keyword_start;
  size_t keyword_end;
  size_t next_keyword_start;
  size_t content_start;
  size_t content_end;
  size_t docstring_content_type_start;
  size_t docstring_content_type_end;
  size_t query_start;
  size_t last_newline;
  size_t final_newline;
} lexer_state;

static VALUE mGherkin;
static VALUE mGherkinLexer;
static VALUE mCLexer;
static VALUE cI18nLexer;
static VALUE rb_eGherkinLexingError;

#define LEN(AT, P) (P - data - lexer->AT)
#define MARK(M, P) (lexer->M = (P) - data)
#define PTR_TO(P) (data + lexer->P)

#define STORE_KW_END_CON(EVENT) \
  store_multiline_kw_con(listener, # EVENT, \
    PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end - 1)), \
    PTR_TO(content_start), LEN(content_start, PTR_TO(content_end)), \
    lexer->current_line, lexer->start_col); \
    if (lexer->content_end != 0) { \
      p = PTR_TO(content_end - 1); \
    } \
    lexer->content_end = 0

#define STORE_ATTR(ATTR) \
    store_attr(listener, # ATTR, \
      PTR_TO(content_start), LEN(content_start, p), \
      lexer->line_number)


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_zh_cn/gherkin_lexer_zh_cn.c"
static const char _lexer_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 12, 1, 13, 1, 16, 1, 
	17, 1, 18, 1, 19, 1, 20, 1, 
	21, 1, 22, 1, 23, 2, 1, 18, 
	2, 4, 5, 2, 13, 0, 2, 14, 
	15, 2, 17, 0, 2, 17, 2, 2, 
	17, 16, 2, 17, 19, 2, 18, 6, 
	2, 18, 7, 2, 18, 8, 2, 18, 
	9, 2, 18, 10, 2, 18, 16, 2, 
	20, 21, 2, 22, 0, 2, 22, 2, 
	2, 22, 16, 2, 22, 19, 3, 3, 
	14, 15, 3, 5, 14, 15, 3, 11, 
	14, 15, 3, 12, 14, 15, 3, 13, 
	14, 15, 3, 14, 15, 18, 3, 17, 
	0, 11, 3, 17, 14, 15, 4, 1, 
	14, 15, 18, 4, 4, 5, 14, 15, 
	4, 17, 0, 14, 15, 5, 17, 0, 
	11, 14, 15
};

static const short _lexer_key_offsets[] = {
	0, 0, 15, 17, 18, 19, 20, 21, 
	23, 25, 39, 46, 47, 49, 51, 52, 
	53, 54, 55, 56, 57, 58, 59, 61, 
	62, 63, 64, 65, 66, 67, 68, 69, 
	81, 83, 85, 87, 89, 91, 105, 107, 
	108, 109, 110, 111, 112, 113, 114, 115, 
	116, 117, 118, 130, 132, 134, 136, 138, 
	140, 148, 150, 153, 156, 158, 160, 162, 
	164, 166, 168, 170, 172, 175, 177, 179, 
	181, 183, 185, 187, 189, 191, 193, 195, 
	197, 199, 201, 203, 205, 207, 209, 211, 
	213, 215, 217, 219, 221, 223, 225, 227, 
	229, 231, 233, 235, 237, 239, 241, 243, 
	245, 247, 249, 251, 253, 255, 257, 259, 
	261, 263, 265, 266, 267, 268, 269, 270, 
	271, 272, 274, 276, 281, 286, 291, 296, 
	300, 304, 306, 307, 308, 309, 310, 311, 
	312, 313, 314, 315, 316, 317, 318, 319, 
	320, 321, 322, 327, 334, 339, 343, 349, 
	352, 354, 360, 374, 382, 384, 387, 390, 
	392, 394, 396, 398, 400, 402, 404, 406, 
	408, 410, 412, 414, 416, 418, 420, 422, 
	424, 426, 428, 430, 432, 434, 436, 438, 
	440, 442, 444, 446, 448, 450, 452, 454, 
	456, 458, 460, 462, 464, 466, 468, 470, 
	472, 474, 476, 478, 480, 482, 484, 486, 
	487, 488, 500, 502, 504, 506, 508, 510, 
	518, 520, 523, 526, 528, 530, 532, 534, 
	536, 538, 540, 542, 545, 547, 549, 551, 
	553, 555, 557, 559, 561, 563, 565, 567, 
	569, 571, 573, 575, 577, 579, 581, 583, 
	585, 587, 589, 591, 594, 596, 598, 600, 
	602, 604, 606, 608, 610, 612, 614, 616, 
	618, 620, 622, 624, 626, 628, 630, 632, 
	634, 636, 638, 640, 642, 644, 645, 646, 
	647, 648, 649, 650, 651, 661, 663, 665, 
	667, 669, 671, 673, 677, 679, 681, 683, 
	685, 688, 690, 692, 694, 696, 698, 700, 
	702, 704, 706, 708, 710, 712, 714, 716, 
	718, 720, 722, 724, 726, 728, 730, 732, 
	734, 736, 738, 740, 742, 744, 746, 748, 
	750, 752, 753, 754, 755, 756, 757, 758, 
	759, 760, 761, 762, 763, 764, 765, 766, 
	767, 768, 769, 776, 778, 780, 782, 784, 
	786, 788, 789, 790
};

static const char _lexer_trans_keys[] = {
	-28, -27, -24, -23, -17, 10, 32, 34, 
	35, 37, 42, 64, 124, 9, 13, -67, 
	-66, -122, -26, -104, -81, 10, 13, 10, 
	13, -28, -27, -24, -23, 10, 32, 34, 
	35, 37, 42, 64, 124, 9, 13, -127, 
	-119, -118, -112, -100, -71, -67, -121, -27, 
	-24, -90, -82, -126, -102, -82, -66, -89, 
	-26, -100, -84, -27, 58, -92, -89, -25, 
	-70, -78, 58, 10, 10, -28, -27, -24, 
	-23, 10, 32, 35, 37, 42, 64, 9, 
	13, -67, 10, -122, 10, -26, 10, -104, 
	10, -81, 10, -28, -27, -24, -23, 10, 
	32, 34, 35, 37, 42, 64, 124, 9, 
	13, -128, -125, -116, -28, -72, -108, -116, 
	-26, -103, -81, 58, 10, 10, -28, -27, 
	-24, -23, 10, 32, 35, 37, 42, 64, 
	9, 13, -67, 10, -122, 10, -26, 10, 
	-104, 10, -81, 10, -127, -119, -118, -112, 
	-100, -71, -67, 10, -121, 10, -27, -24, 
	10, -90, -82, 10, -126, 10, -102, 10, 
	-82, 10, -66, 10, -89, 10, -26, 10, 
	-100, 10, -84, 10, -27, 10, 58, -92, 
	10, -89, 10, -25, 10, -70, 10, -78, 
	10, 10, 58, -97, 10, -24, 10, -125, 
	10, -67, 10, -116, 10, -26, 10, -105, 
	10, -74, 10, -70, 10, -26, 10, -103, 
	10, -81, 10, -74, 10, -28, 10, -72, 
	10, -108, 10, -109, 10, -128, 10, -116, 
	10, -126, 10, -93, 10, -28, 10, -71, 
	10, -120, 10, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, -126, -93, -28, -71, -120, 34, 34, 
	10, 13, 10, 13, 10, 32, 34, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 9, 13, 10, 32, 9, 13, 
	10, 13, 10, 95, 70, 69, 65, 84, 
	85, 82, 69, 95, 69, 78, 68, 95, 
	37, 32, 13, 32, 64, 9, 10, 9, 
	10, 13, 32, 64, 11, 12, 10, 32, 
	64, 9, 13, 32, 124, 9, 13, 10, 
	32, 92, 124, 9, 13, 10, 92, 124, 
	10, 92, 10, 32, 92, 124, 9, 13, 
	-28, -27, -24, -23, 10, 32, 34, 35, 
	37, 42, 64, 124, 9, 13, -127, -119, 
	-118, -112, -100, -71, -67, 10, -121, 10, 
	-27, -24, 10, -90, -82, 10, -126, 10, 
	-102, 10, -82, 10, -66, 10, -89, 10, 
	-26, 10, -100, 10, -84, 10, 10, 58, 
	-97, 10, -24, 10, -125, 10, -67, 10, 
	-116, 10, -26, 10, -105, 10, -74, 10, 
	-70, 10, -26, 10, -103, 10, -81, 10, 
	-74, 10, -28, 10, -72, 10, -108, 10, 
	-109, 10, -128, 10, -116, 10, -126, 10, 
	-93, 10, -28, 10, -71, 10, -120, 10, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 10, 
	-28, -27, -24, -23, 10, 32, 35, 37, 
	42, 64, 9, 13, -67, 10, -122, 10, 
	-26, 10, -104, 10, -81, 10, -127, -119, 
	-118, -112, -100, -71, -67, 10, -121, 10, 
	-27, -24, 10, -90, -82, 10, -126, 10, 
	-102, 10, -82, 10, -66, 10, -89, 10, 
	-26, 10, -100, 10, -84, 10, -27, 10, 
	58, -92, 10, -89, 10, -25, 10, -70, 
	10, -78, 10, 10, 58, -97, 10, -24, 
	10, -125, 10, -67, 10, -116, 10, -26, 
	10, -105, 10, -74, 10, -70, 10, -26, 
	10, -103, 10, -81, 10, -74, 10, -28, 
	10, -72, 10, -108, 10, -109, 10, -128, 
	-125, 10, -116, 10, -116, 10, -26, 10, 
	-103, 10, -81, 10, -126, 10, -93, 10, 
	-28, 10, -71, 10, -120, 10, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, -97, -24, -125, -67, 
	58, 10, 10, -28, -27, -24, 10, 32, 
	35, 37, 64, 9, 13, -66, 10, -117, 
	10, -27, 10, -83, 10, -112, 10, 10, 
	58, -119, -118, -100, 10, -89, 10, -26, 
	10, -100, 10, -84, 10, -27, 10, 58, 
	-92, 10, -89, 10, -25, 10, -70, 10, 
	-78, 10, -97, 10, -24, 10, -125, 10, 
	-67, 10, -70, 10, -26, 10, -103, 10, 
	-81, 10, -125, 10, -116, 10, -26, 10, 
	-103, 10, -81, 10, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	-116, -26, -105, -74, -70, -26, -103, -81, 
	-74, -109, -117, -27, -83, -112, 58, 10, 
	10, -27, 10, 32, 35, 124, 9, 13, 
	-118, 10, -97, 10, -24, 10, -125, 10, 
	-67, 10, 10, 58, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 13, 2, 1, 1, 1, 1, 2, 
	2, 12, 7, 1, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 10, 
	2, 2, 2, 2, 2, 12, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 10, 2, 2, 2, 2, 2, 
	8, 2, 3, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 2, 2, 3, 3, 3, 3, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 3, 5, 3, 2, 4, 3, 
	2, 4, 12, 8, 2, 3, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 10, 2, 2, 2, 2, 2, 8, 
	2, 3, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 8, 2, 2, 2, 
	2, 2, 2, 4, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 5, 2, 2, 2, 2, 2, 
	2, 1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 1, 1, 1, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 1, 1, 0, 
	0, 1, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 15, 18, 20, 22, 24, 26, 
	29, 32, 46, 54, 56, 59, 62, 64, 
	66, 68, 70, 72, 74, 76, 78, 81, 
	83, 85, 87, 89, 91, 93, 95, 97, 
	109, 112, 115, 118, 121, 124, 138, 141, 
	143, 145, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 175, 178, 181, 184, 187, 
	190, 199, 202, 206, 210, 213, 216, 219, 
	222, 225, 228, 231, 234, 238, 241, 244, 
	247, 250, 253, 256, 259, 262, 265, 268, 
	271, 274, 277, 280, 283, 286, 289, 292, 
	295, 298, 301, 304, 307, 310, 313, 316, 
	319, 322, 325, 328, 331, 334, 337, 340, 
	343, 346, 349, 352, 355, 358, 361, 364, 
	367, 370, 373, 375, 377, 379, 381, 383, 
	385, 387, 390, 393, 398, 403, 408, 413, 
	417, 421, 424, 426, 428, 430, 432, 434, 
	436, 438, 440, 442, 444, 446, 448, 450, 
	452, 454, 456, 461, 468, 473, 477, 483, 
	487, 490, 496, 510, 519, 522, 526, 530, 
	533, 536, 539, 542, 545, 548, 551, 554, 
	557, 560, 563, 566, 569, 572, 575, 578, 
	581, 584, 587, 590, 593, 596, 599, 602, 
	605, 608, 611, 614, 617, 620, 623, 626, 
	629, 632, 635, 638, 641, 644, 647, 650, 
	653, 656, 659, 662, 665, 668, 671, 674, 
	676, 678, 690, 693, 696, 699, 702, 705, 
	714, 717, 721, 725, 728, 731, 734, 737, 
	740, 743, 746, 749, 753, 756, 759, 762, 
	765, 768, 771, 774, 777, 780, 783, 786, 
	789, 792, 795, 798, 801, 804, 807, 810, 
	813, 816, 819, 822, 826, 829, 832, 835, 
	838, 841, 844, 847, 850, 853, 856, 859, 
	862, 865, 868, 871, 874, 877, 880, 883, 
	886, 889, 892, 895, 898, 901, 903, 905, 
	907, 909, 911, 913, 915, 925, 928, 931, 
	934, 937, 940, 943, 948, 951, 954, 957, 
	960, 964, 967, 970, 973, 976, 979, 982, 
	985, 988, 991, 994, 997, 1000, 1003, 1006, 
	1009, 1012, 1015, 1018, 1021, 1024, 1027, 1030, 
	1033, 1036, 1039, 1042, 1045, 1048, 1051, 1054, 
	1057, 1060, 1062, 1064, 1066, 1068, 1070, 1072, 
	1074, 1076, 1078, 1080, 1082, 1084, 1086, 1088, 
	1090, 1092, 1094, 1101, 1104, 1107, 1110, 1113, 
	1116, 1119, 1121, 1123
};

static const short _lexer_trans_targs[] = {
	2, 10, 38, 114, 353, 9, 9, 119, 
	129, 131, 145, 146, 149, 9, 0, 3, 
	339, 0, 4, 0, 5, 0, 6, 0, 
	7, 0, 9, 130, 8, 9, 130, 8, 
	2, 10, 38, 114, 9, 9, 119, 129, 
	131, 145, 146, 149, 9, 0, 11, 18, 
	277, 329, 333, 337, 338, 0, 12, 0, 
	13, 16, 0, 14, 15, 0, 7, 0, 
	7, 0, 17, 0, 7, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 207, 
	0, 24, 0, 25, 0, 26, 0, 27, 
	0, 28, 0, 29, 0, 31, 30, 31, 
	30, 32, 155, 185, 187, 31, 31, 9, 
	192, 206, 9, 31, 30, 33, 31, 30, 
	34, 31, 30, 35, 31, 30, 36, 31, 
	30, 37, 31, 30, 2, 10, 38, 114, 
	9, 9, 119, 129, 131, 145, 146, 149, 
	9, 0, 39, 43, 0, 40, 0, 41, 
	0, 42, 0, 7, 0, 44, 0, 45, 
	0, 46, 0, 47, 0, 48, 0, 50, 
	49, 50, 49, 51, 56, 92, 94, 50, 
	50, 9, 99, 113, 9, 50, 49, 52, 
	50, 49, 53, 50, 49, 54, 50, 49, 
	55, 50, 49, 37, 50, 49, 57, 64, 
	75, 79, 83, 87, 91, 50, 49, 58, 
	50, 49, 59, 62, 50, 49, 60, 61, 
	50, 49, 37, 50, 49, 37, 50, 49, 
	63, 50, 49, 37, 50, 49, 65, 50, 
	49, 66, 50, 49, 67, 50, 49, 68, 
	50, 49, 69, 50, 37, 49, 70, 50, 
	49, 71, 50, 49, 72, 50, 49, 73, 
	50, 49, 74, 50, 49, 50, 37, 49, 
	76, 50, 49, 77, 50, 49, 78, 50, 
	49, 74, 50, 49, 80, 50, 49, 81, 
	50, 49, 82, 50, 49, 37, 50, 49, 
	84, 50, 49, 85, 50, 49, 86, 50, 
	49, 68, 50, 49, 88, 50, 49, 89, 
	50, 49, 90, 50, 49, 37, 50, 49, 
	37, 50, 49, 93, 50, 49, 88, 50, 
	49, 95, 50, 49, 96, 50, 49, 97, 
	50, 49, 98, 50, 49, 37, 50, 49, 
	50, 100, 49, 50, 101, 49, 50, 102, 
	49, 50, 103, 49, 50, 104, 49, 50, 
	105, 49, 50, 106, 49, 50, 107, 49, 
	50, 108, 49, 50, 109, 49, 50, 110, 
	49, 50, 111, 49, 50, 112, 49, 50, 
	9, 49, 50, 37, 49, 115, 0, 116, 
	0, 117, 0, 118, 0, 7, 0, 120, 
	0, 121, 0, 123, 122, 122, 123, 122, 
	122, 124, 124, 125, 124, 124, 124, 124, 
	125, 124, 124, 124, 124, 126, 124, 124, 
	124, 124, 127, 124, 124, 9, 128, 128, 
	0, 9, 128, 128, 0, 9, 130, 129, 
	9, 0, 132, 0, 133, 0, 134, 0, 
	135, 0, 136, 0, 137, 0, 138, 0, 
	139, 0, 140, 0, 141, 0, 142, 0, 
	143, 0, 144, 0, 355, 0, 7, 0, 
	0, 0, 0, 0, 147, 148, 9, 148, 
	148, 146, 147, 147, 9, 148, 146, 148, 
	0, 149, 150, 149, 0, 154, 153, 152, 
	150, 153, 151, 0, 152, 150, 151, 0, 
	152, 151, 154, 153, 152, 150, 153, 151, 
	2, 10, 38, 114, 154, 154, 119, 129, 
	131, 145, 146, 149, 154, 0, 156, 163, 
	168, 172, 176, 180, 184, 31, 30, 157, 
	31, 30, 158, 161, 31, 30, 159, 160, 
	31, 30, 37, 31, 30, 37, 31, 30, 
	162, 31, 30, 37, 31, 30, 164, 31, 
	30, 165, 31, 30, 166, 31, 30, 167, 
	31, 30, 31, 37, 30, 169, 31, 30, 
	170, 31, 30, 171, 31, 30, 167, 31, 
	30, 173, 31, 30, 174, 31, 30, 175, 
	31, 30, 37, 31, 30, 177, 31, 30, 
	178, 31, 30, 179, 31, 30, 167, 31, 
	30, 181, 31, 30, 182, 31, 30, 183, 
	31, 30, 37, 31, 30, 37, 31, 30, 
	186, 31, 30, 181, 31, 30, 188, 31, 
	30, 189, 31, 30, 190, 31, 30, 191, 
	31, 30, 37, 31, 30, 31, 193, 30, 
	31, 194, 30, 31, 195, 30, 31, 196, 
	30, 31, 197, 30, 31, 198, 30, 31, 
	199, 30, 31, 200, 30, 31, 201, 30, 
	31, 202, 30, 31, 203, 30, 31, 204, 
	30, 31, 205, 30, 31, 9, 30, 31, 
	37, 30, 209, 208, 209, 208, 210, 215, 
	251, 257, 209, 209, 9, 262, 276, 9, 
	209, 208, 211, 209, 208, 212, 209, 208, 
	213, 209, 208, 214, 209, 208, 37, 209, 
	208, 216, 223, 234, 238, 242, 246, 250, 
	209, 208, 217, 209, 208, 218, 221, 209, 
	208, 219, 220, 209, 208, 37, 209, 208, 
	37, 209, 208, 222, 209, 208, 37, 209, 
	208, 224, 209, 208, 225, 209, 208, 226, 
	209, 208, 227, 209, 208, 228, 209, 37, 
	208, 229, 209, 208, 230, 209, 208, 231, 
	209, 208, 232, 209, 208, 233, 209, 208, 
	209, 37, 208, 235, 209, 208, 236, 209, 
	208, 237, 209, 208, 233, 209, 208, 239, 
	209, 208, 240, 209, 208, 241, 209, 208, 
	37, 209, 208, 243, 209, 208, 244, 209, 
	208, 245, 209, 208, 227, 209, 208, 247, 
	209, 208, 248, 209, 208, 249, 209, 208, 
	37, 209, 208, 37, 209, 208, 252, 253, 
	209, 208, 247, 209, 208, 254, 209, 208, 
	255, 209, 208, 256, 209, 208, 233, 209, 
	208, 258, 209, 208, 259, 209, 208, 260, 
	209, 208, 261, 209, 208, 37, 209, 208, 
	209, 263, 208, 209, 264, 208, 209, 265, 
	208, 209, 266, 208, 209, 267, 208, 209, 
	268, 208, 209, 269, 208, 209, 270, 208, 
	209, 271, 208, 209, 272, 208, 209, 273, 
	208, 209, 274, 208, 209, 275, 208, 209, 
	9, 208, 209, 37, 208, 278, 0, 279, 
	0, 280, 0, 281, 0, 282, 0, 284, 
	283, 284, 283, 285, 291, 310, 284, 284, 
	9, 315, 9, 284, 283, 286, 284, 283, 
	287, 284, 283, 288, 284, 283, 289, 284, 
	283, 290, 284, 283, 284, 37, 283, 292, 
	302, 306, 284, 283, 293, 284, 283, 294, 
	284, 283, 295, 284, 283, 296, 284, 283, 
	297, 284, 37, 283, 298, 284, 283, 299, 
	284, 283, 300, 284, 283, 301, 284, 283, 
	290, 284, 283, 303, 284, 283, 304, 284, 
	283, 305, 284, 283, 290, 284, 283, 307, 
	284, 283, 308, 284, 283, 309, 284, 283, 
	296, 284, 283, 311, 284, 283, 312, 284, 
	283, 313, 284, 283, 314, 284, 283, 290, 
	284, 283, 284, 316, 283, 284, 317, 283, 
	284, 318, 283, 284, 319, 283, 284, 320, 
	283, 284, 321, 283, 284, 322, 283, 284, 
	323, 283, 284, 324, 283, 284, 325, 283, 
	284, 326, 283, 284, 327, 283, 284, 328, 
	283, 284, 9, 283, 330, 0, 331, 0, 
	332, 0, 7, 0, 334, 0, 335, 0, 
	336, 0, 22, 0, 40, 0, 7, 0, 
	340, 0, 341, 0, 342, 0, 343, 0, 
	344, 0, 346, 345, 346, 345, 347, 346, 
	346, 9, 9, 346, 345, 348, 346, 345, 
	349, 346, 345, 350, 346, 345, 351, 346, 
	345, 352, 346, 345, 346, 37, 345, 354, 
	0, 9, 0, 0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	29, 29, 29, 29, 0, 54, 0, 5, 
	1, 0, 29, 1, 35, 0, 43, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 149, 126, 57, 110, 23, 0, 
	29, 29, 29, 29, 54, 0, 5, 1, 
	0, 29, 1, 35, 0, 43, 0, 0, 
	0, 0, 0, 0, 0, 43, 0, 43, 
	0, 0, 43, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 84, 84, 84, 84, 54, 0, 78, 
	33, 84, 78, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 19, 54, 0, 63, 63, 63, 63, 
	130, 31, 60, 57, 31, 63, 57, 66, 
	31, 43, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 84, 84, 84, 84, 54, 
	0, 72, 33, 84, 72, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 15, 54, 0, 0, 0, 
	0, 0, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 0, 
	54, 0, 15, 54, 0, 15, 54, 0, 
	0, 54, 0, 15, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 15, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 15, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 15, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 15, 54, 0, 
	15, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 15, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	15, 0, 54, 15, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 139, 48, 9, 106, 11, 
	0, 134, 45, 45, 45, 3, 122, 33, 
	33, 33, 0, 122, 33, 33, 33, 0, 
	122, 33, 0, 33, 0, 102, 7, 7, 
	43, 54, 0, 0, 43, 114, 25, 0, 
	54, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	43, 43, 43, 43, 0, 27, 118, 27, 
	27, 51, 27, 0, 54, 0, 1, 0, 
	43, 0, 0, 0, 43, 54, 37, 37, 
	87, 37, 37, 43, 0, 39, 0, 43, 
	0, 0, 54, 0, 0, 39, 0, 0, 
	96, 96, 96, 96, 54, 0, 93, 90, 
	41, 96, 90, 99, 0, 43, 0, 0, 
	0, 0, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 0, 
	54, 0, 19, 54, 0, 19, 54, 0, 
	0, 54, 0, 19, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 54, 19, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 19, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 19, 54, 0, 19, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 19, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	19, 0, 144, 57, 54, 0, 84, 84, 
	84, 84, 54, 0, 75, 33, 84, 75, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 17, 54, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 0, 54, 0, 17, 54, 0, 
	17, 54, 0, 0, 54, 0, 17, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 17, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	54, 17, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	17, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	17, 54, 0, 17, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 17, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	17, 0, 54, 17, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 84, 84, 84, 54, 0, 
	69, 33, 69, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 13, 0, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 13, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 13, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 84, 54, 
	0, 81, 81, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 21, 0, 0, 
	43, 0, 43, 0, 0
};

static const unsigned char _lexer_eof_actions[] = {
	0, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 355;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"

static VALUE 
unindent(VALUE con, int start_col)
{
  VALUE re;
  /* Gherkin will crash gracefully if the string representation of start_col pushes the pattern past 32 characters */
  char pat[32]; 
  snprintf(pat, 32, "^[\t ]{0,%d}", start_col); 
  re = rb_reg_regcomp(rb_str_new2(pat));
  rb_funcall(con, rb_intern("gsub!"), 2, re, rb_str_new2(""));

  return Qnil;

}

static void 
store_kw_con(VALUE listener, const char * event_name, 
             const char * keyword_at, size_t keyword_length, 
             const char * at,         size_t length, 
             int current_line)
{
  VALUE con = Qnil, kw = Qnil;
  kw = ENCODED_STR_NEW(keyword_at, keyword_length);
  con = ENCODED_STR_NEW(at, length);
  rb_funcall(con, rb_intern("strip!"), 0);
  rb_funcall(listener, rb_intern(event_name), 3, kw, con, INT2FIX(current_line)); 
}

static void
store_multiline_kw_con(VALUE listener, const char * event_name,
                      const char * keyword_at, size_t keyword_length,
                      const char * at,         size_t length,
                      int current_line, int start_col)
{
  VALUE split;
  VALUE con = Qnil, kw = Qnil, name = Qnil, desc = Qnil;

  kw = ENCODED_STR_NEW(keyword_at, keyword_length);
  con = ENCODED_STR_NEW(at, length);

  unindent(con, start_col);
  
  split = rb_str_split(con, "\n");

  name = rb_funcall(split, rb_intern("shift"), 0);
  desc = rb_ary_join(split, rb_str_new2( "\n" ));

  if( name == Qnil ) 
  {
    name = rb_str_new2("");
  }
  if( rb_funcall(desc, rb_intern("size"), 0) == 0) 
  {
    desc = rb_str_new2("");
  }
  rb_funcall(name, rb_intern("strip!"), 0);
  rb_funcall(desc, rb_intern("rstrip!"), 0);
  rb_funcall(listener, rb_intern(event_name), 4, kw, name, desc, INT2FIX(current_line)); 
}

static void 
store_attr(VALUE listener, const char * attr_type,
           const char * at, size_t length, 
           int line)
{
  VALUE val = ENCODED_STR_NEW(at, length);
  rb_funcall(listener, rb_intern(attr_type), 2, val, INT2FIX(line));
}
static void 
store_docstring_content(VALUE listener, 
          int start_col, 
          const char *type_at, size_t type_length,
          const char *at, size_t length, 
          int current_line)
{
  VALUE re2;
  VALUE unescape_escaped_quotes;
  VALUE con = ENCODED_STR_NEW(at, length);
  VALUE con_type = ENCODED_STR_NEW(type_at, type_length);

  unindent(con, start_col);

  re2 = rb_reg_regcomp(rb_str_new2("\r\\Z"));
  unescape_escaped_quotes = rb_reg_regcomp(rb_str_new2("\\\\\"\\\\\"\\\\\""));
  rb_funcall(con, rb_intern("sub!"), 2, re2, rb_str_new2(""));
  rb_funcall(con_type, rb_intern("strip!"), 0);
  rb_funcall(con, rb_intern("gsub!"), 2, unescape_escaped_quotes, rb_str_new2("\"\"\""));
  rb_funcall(listener, rb_intern("doc_string"), 3, con_type, con, INT2FIX(current_line));
}
static void 
raise_lexer_error(const char * at, int line)
{ 
  rb_raise(rb_eGherkinLexingError, "Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information.", line, at);
}

static void lexer_init(lexer_state *lexer) {
  lexer->content_start = 0;
  lexer->content_end = 0;
  lexer->content_len = 0;
  lexer->docstring_content_type_start = 0;
  lexer->docstring_content_type_end = 0;
  lexer->mark = 0;
  lexer->keyword_start = 0;
  lexer->keyword_end = 0;
  lexer->next_keyword_start = 0;
  lexer->line_number = 1;
  lexer->last_newline = 0;
  lexer->final_newline = 0;
  lexer->start_col = 0;
}

static VALUE CLexer_alloc(VALUE klass)
{
  VALUE obj;
  lexer_state *lxr = ALLOC(lexer_state);
  lexer_init(lxr);

  obj = Data_Wrap_Struct(klass, NULL, -1, lxr);

  return obj;
}

static VALUE CLexer_init(VALUE self, VALUE listener)
{
  lexer_state *lxr; 
  rb_iv_set(self, "@listener", listener);
  
  lxr = NULL;
  DATA_GET(self, lexer_state, lxr);
  lexer_init(lxr);
  
  return self;
}

static VALUE CLexer_scan(VALUE self, VALUE input)
{
  VALUE input_copy;
  char *data;
  size_t len;
  VALUE listener = rb_iv_get(self, "@listener");

  lexer_state *lexer;
  lexer = NULL;
  DATA_GET(self, lexer_state, lexer);

  input_copy = rb_str_dup(input);

  rb_str_append(input_copy, rb_str_new2("\n%_FEATURE_END_%"));
  data = RSTRING_PTR(input_copy);
  len = RSTRING_LEN(input_copy);
  
  if (len == 0) { 
    rb_raise(rb_eGherkinLexingError, "No content to lex.");
  } else {

    const char *p, *pe, *eof;
    int cs = 0;
    
    VALUE current_row = Qnil;

    p = data;
    pe = data + len;
    eof = pe;
    
    assert(*pe == '\0' && "pointer does not end on NULL");
    
    
#line 918 "ext/gherkin_lexer_zh_cn/gherkin_lexer_zh_cn.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
    
#line 925 "ext/gherkin_lexer_zh_cn/gherkin_lexer_zh_cn.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _lexer_trans_keys + _lexer_key_offsets[cs];
	_trans = _lexer_index_offsets[cs];

	_klen = _lexer_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _lexer_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	cs = _lexer_trans_targs[_trans];

	if ( _lexer_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _lexer_actions + _lexer_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    VALUE re_pipe, re_newline, re_backslash;
    VALUE con = ENCODED_STR_NEW(PTR_TO(content_start), LEN(content_start, p));
    rb_funcall(con, rb_intern("strip!"), 0);
    re_pipe      = rb_reg_regcomp(rb_str_new2("\\\\\\|"));
    re_newline   = rb_reg_regcomp(rb_str_new2("\\\\n"));
    re_backslash = rb_reg_regcomp(rb_str_new2("\\\\\\\\"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_pipe,      rb_str_new2("|"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_newline,   rb_str_new2("\n"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_backslash, rb_str_new2("\\"));

    rb_ary_push(current_row, con);
  }
	break;
	case 22:
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    int line;
    if (cs < lexer_first_final) {
      size_t count = 0;
      VALUE newstr_val;
      char *newstr;
      int newstr_count = 0;        
      size_t len;
      const char *buff;
      if (lexer->last_newline != 0) {
        len = LEN(last_newline, eof);
        buff = PTR_TO(last_newline);
      } else {
        len = strlen(data);
        buff = data;
      }

      /* Allocate as a ruby string so that it gets cleaned up by GC */
      newstr_val = rb_str_new(buff, len);
      newstr = RSTRING_PTR(newstr_val);


      for (count = 0; count < len; count++) {
        if(buff[count] == 10) {
          newstr[newstr_count] = '\0'; /* terminate new string at first newline found */
          break;
        } else {
          if (buff[count] == '%') {
            newstr[newstr_count++] = buff[count];
            newstr[newstr_count] = buff[count];
          } else {
            newstr[newstr_count] = buff[count];
          }
        }
        newstr_count++;
      }

      line = lexer->line_number;
      lexer_init(lexer); /* Re-initialize so we can scan again with the same lexer */
      raise_lexer_error(newstr, line);
    } else {
      rb_funcall(listener, rb_intern("eof"), 0);
    }
  }
	break;
#line 1215 "ext/gherkin_lexer_zh_cn/gherkin_lexer_zh_cn.c"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	const char *__acts = _lexer_actions + _lexer_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"
	{
    int line;
    if (cs < lexer_first_final) {
      size_t count = 0;
      VALUE newstr_val;
      char *newstr;
      int newstr_count = 0;        
      size_t len;
      const char *buff;
      if (lexer->last_newline != 0) {
        len = LEN(last_newline, eof);
        buff = PTR_TO(last_newline);
      } else {
        len = strlen(data);
        buff = data;
      }

      /* Allocate as a ruby string so that it gets cleaned up by GC */
      newstr_val = rb_str_new(buff, len);
      newstr = RSTRING_PTR(newstr_val);


      for (count = 0; count < len; count++) {
        if(buff[count] == 10) {
          newstr[newstr_count] = '\0'; /* terminate new string at first newline found */
          break;
        } else {
          if (buff[count] == '%') {
            newstr[newstr_count++] = buff[count];
            newstr[newstr_count] = buff[count];
          } else {
            newstr[newstr_count] = buff[count];
          }
        }
        newstr_count++;
      }

      line = lexer->line_number;
      lexer_init(lexer); /* Re-initialize so we can scan again with the same lexer */
      raise_lexer_error(newstr, line);
    } else {
      rb_funcall(listener, rb_intern("eof"), 0);
    }
  }
	break;
#line 1278 "ext/gherkin_lexer_zh_cn/gherkin_lexer_zh_cn.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_cn.c.rl"

    assert(p <= pe && "data overflow after parsing execute");
    assert(lexer->content_start <= len && "content starts after data end");
    assert(lexer->mark < len && "mark is after data end");
    
    /* Reset lexer by re-initializing the whole thing */
    lexer_init(lexer);

    if (cs == lexer_error) {
      rb_raise(rb_eGherkinLexingError, "Invalid format, lexing fails.");
    } else {
      return Qtrue;
    }
  }
}

void Init_gherkin_lexer_zh_cn()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Zh_cn", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

