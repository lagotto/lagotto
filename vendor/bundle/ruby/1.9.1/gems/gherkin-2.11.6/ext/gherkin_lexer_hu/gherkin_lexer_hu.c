
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
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
	0, 0, 19, 20, 21, 22, 24, 26, 
	44, 45, 46, 48, 50, 55, 60, 65, 
	70, 74, 78, 80, 81, 82, 83, 84, 
	85, 86, 87, 88, 89, 90, 91, 92, 
	93, 94, 95, 100, 107, 112, 115, 116, 
	117, 118, 119, 120, 121, 123, 124, 125, 
	126, 127, 128, 129, 130, 131, 132, 133, 
	134, 135, 136, 137, 138, 139, 140, 141, 
	142, 143, 144, 146, 147, 148, 149, 150, 
	151, 152, 153, 154, 155, 156, 171, 173, 
	175, 177, 195, 197, 198, 199, 200, 201, 
	202, 203, 204, 205, 206, 221, 223, 225, 
	227, 229, 231, 233, 235, 237, 239, 241, 
	243, 245, 247, 249, 251, 253, 255, 259, 
	261, 263, 265, 267, 269, 271, 274, 276, 
	278, 280, 282, 284, 286, 288, 290, 292, 
	294, 296, 298, 300, 302, 304, 306, 308, 
	310, 312, 314, 316, 319, 321, 323, 325, 
	327, 329, 331, 333, 335, 337, 339, 341, 
	343, 345, 347, 349, 351, 353, 355, 357, 
	359, 360, 361, 362, 363, 364, 365, 366, 
	367, 368, 369, 370, 381, 383, 385, 387, 
	389, 391, 393, 395, 397, 399, 401, 403, 
	405, 407, 409, 411, 413, 415, 417, 419, 
	421, 423, 425, 427, 429, 431, 433, 435, 
	438, 440, 442, 444, 446, 448, 450, 452, 
	454, 456, 458, 460, 462, 464, 466, 468, 
	470, 472, 474, 476, 478, 480, 482, 484, 
	486, 488, 490, 492, 494, 496, 498, 499, 
	500, 501, 502, 503, 504, 505, 506, 507, 
	508, 509, 510, 511, 518, 520, 522, 524, 
	526, 528, 530, 532, 534, 536, 540, 546, 
	549, 551, 557, 575, 577, 579, 581, 583, 
	585, 587, 589, 591, 593, 595, 597, 599, 
	601, 603, 607, 609, 611, 613, 615, 617, 
	619, 622, 624, 626, 628, 630, 632, 634, 
	636, 638, 640, 642, 644, 646, 648, 650, 
	652, 654, 656, 658, 660, 662, 664, 666, 
	668, 670, 672, 674, 676, 678, 680, 682, 
	684, 686, 688, 690, 691, 692, 707, 709, 
	711, 713, 715, 717, 719, 721, 723, 725, 
	727, 729, 731, 733, 735, 737, 739, 741, 
	745, 747, 749, 751, 753, 755, 757, 760, 
	762, 764, 766, 768, 770, 772, 774, 776, 
	778, 780, 782, 784, 786, 788, 790, 792, 
	794, 796, 798, 800, 802, 805, 807, 809, 
	811, 813, 815, 817, 819, 821, 824, 826, 
	828, 830, 832, 834, 836, 838, 840, 842, 
	844, 846, 848, 850, 852, 854, 856, 858, 
	859, 860
};

static const char _lexer_trans_keys[] = {
	-61, -17, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 70, 72, 74, 77, 80, 
	124, 9, 13, -119, 115, 32, 10, 13, 
	10, 13, -61, 10, 32, 34, 35, 37, 
	42, 64, 65, 68, 70, 72, 74, 77, 
	80, 124, 9, 13, 34, 34, 10, 13, 
	10, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	9, 13, 10, 32, 9, 13, 10, 13, 
	10, 95, 70, 69, 65, 84, 85, 82, 
	69, 95, 69, 78, 68, 95, 37, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	100, 107, 109, 111, 116, 116, 107, 111, 
	114, 101, 105, 110, 110, 121, 105, 98, 
	101, 110, 101, 111, 114, 103, 97, 116, 
	-61, -77, 107, -61, -74, 110, 121, 118, 
	32, 58, 118, -61, -95, 122, 108, 97, 
	116, 58, 10, 10, -61, 10, 32, 35, 
	37, 42, 64, 65, 68, 70, 72, 74, 
	77, 9, 13, -119, 10, 10, 115, 10, 
	32, -61, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 70, 72, 74, 77, 80, 
	124, 9, 13, -61, 97, -95, 116, 116, 
	-61, -87, 114, 58, 10, 10, -61, 10, 
	32, 35, 37, 42, 64, 65, 68, 70, 
	72, 74, 77, 9, 13, -119, 10, 10, 
	115, 10, 32, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	100, 107, 109, 10, 111, 10, 116, 10, 
	116, 10, 107, 10, 111, 10, 114, 10, 
	101, 105, 10, 110, 10, 110, 10, 121, 
	10, 105, 10, 98, 10, 101, 10, 110, 
	10, 101, 10, 111, 10, 114, 10, 103, 
	10, 97, 10, 116, -61, 10, -77, 10, 
	10, 107, -61, 10, -74, 10, 10, 110, 
	10, 121, 10, 118, 10, 32, 58, 10, 
	118, -61, 10, -95, 10, 10, 122, 10, 
	108, 10, 97, 10, 116, 10, 58, 10, 
	97, 10, 101, 10, 108, 10, 108, 10, 
	101, 10, 109, 10, 122, -59, 10, -111, 
	10, 10, 97, 10, 106, 10, 100, 101, 
	108, 108, 101, 109, 122, -59, -111, 58, 
	10, 10, 10, 32, 35, 37, 64, 70, 
	72, 74, 80, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 111, 10, 114, 10, 103, 10, 
	97, 10, 116, -61, 10, -77, 10, 10, 
	107, -61, 10, -74, 10, 10, 110, 10, 
	121, 10, 118, 10, 32, 58, 10, 118, 
	-61, 10, -95, 10, 10, 122, 10, 108, 
	10, 97, 10, 116, 10, 58, -61, 10, 
	-95, 10, 10, 116, 10, 116, -61, 10, 
	-87, 10, 10, 114, 10, 101, 10, 108, 
	10, 108, 10, 101, 10, 109, 10, 122, 
	-59, 10, -111, 10, -61, 10, -87, 10, 
	10, 108, 10, 100, -61, 10, -95, 10, 
	10, 107, 97, 106, 100, -61, -87, 108, 
	100, -61, -95, 107, 58, 10, 10, 10, 
	32, 35, 74, 124, 9, 13, 10, 101, 
	10, 108, 10, 108, 10, 101, 10, 109, 
	10, 122, -59, 10, -111, 10, 10, 58, 
	32, 124, 9, 13, 10, 32, 92, 124, 
	9, 13, 10, 92, 124, 10, 92, 10, 
	32, 92, 124, 9, 13, -61, 10, 32, 
	34, 35, 37, 42, 64, 65, 68, 70, 
	72, 74, 77, 80, 124, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 100, 107, 109, 10, 
	111, 10, 116, 10, 116, 10, 107, 10, 
	111, 10, 114, 10, 101, 105, 10, 110, 
	10, 110, 10, 121, 10, 105, 10, 98, 
	10, 101, 10, 110, 10, 101, 10, 111, 
	10, 114, 10, 103, 10, 97, 10, 116, 
	-61, 10, -77, 10, 10, 107, -61, 10, 
	-74, 10, 10, 110, 10, 121, 10, 118, 
	10, 58, 10, 97, 10, 101, 10, 108, 
	10, 108, 10, 101, 10, 109, 10, 122, 
	-59, 10, -111, 10, 10, 97, 10, 106, 
	10, 100, 10, 10, -61, 10, 32, 35, 
	37, 42, 64, 65, 68, 70, 72, 74, 
	77, 9, 13, -119, 10, 10, 115, 10, 
	32, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 100, 107, 
	109, 10, 111, 10, 116, 10, 116, 10, 
	107, 10, 111, 10, 114, 10, 101, 105, 
	10, 110, 10, 110, 10, 121, 10, 105, 
	10, 98, 10, 101, 10, 110, 10, 101, 
	10, 111, 10, 114, 10, 103, 10, 97, 
	10, 116, -61, 10, -77, 10, 10, 107, 
	-61, 10, -74, 10, 10, 110, 10, 121, 
	10, 118, 10, 32, 58, 10, 118, -61, 
	10, -95, 10, 10, 122, 10, 108, 10, 
	97, 10, 116, 10, 58, -61, 10, 97, 
	-95, 10, 10, 116, 10, 116, -61, 10, 
	-87, 10, 10, 114, 10, 101, 10, 108, 
	10, 108, 10, 101, 10, 109, 10, 122, 
	-59, 10, -111, 10, 10, 97, 10, 106, 
	10, 100, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 1, 2, 2, 16, 
	1, 1, 2, 2, 3, 3, 3, 3, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 3, 5, 3, 3, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 13, 2, 2, 
	2, 16, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 13, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 4, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 9, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 5, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 4, 3, 
	2, 4, 16, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 4, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 13, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 4, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 1, 1, 1, 1, 
	1, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 0, 
	0, 1, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 25, 28, 31, 
	49, 51, 53, 56, 59, 64, 69, 74, 
	79, 83, 87, 90, 92, 94, 96, 98, 
	100, 102, 104, 106, 108, 110, 112, 114, 
	116, 118, 120, 125, 132, 137, 141, 143, 
	145, 147, 149, 151, 153, 156, 158, 160, 
	162, 164, 166, 168, 170, 172, 174, 176, 
	178, 180, 182, 184, 186, 188, 190, 192, 
	194, 196, 198, 201, 203, 205, 207, 209, 
	211, 213, 215, 217, 219, 221, 236, 239, 
	242, 245, 263, 266, 268, 270, 272, 274, 
	276, 278, 280, 282, 284, 299, 302, 305, 
	308, 311, 314, 317, 320, 323, 326, 329, 
	332, 335, 338, 341, 344, 347, 350, 355, 
	358, 361, 364, 367, 370, 373, 377, 380, 
	383, 386, 389, 392, 395, 398, 401, 404, 
	407, 410, 413, 416, 419, 422, 425, 428, 
	431, 434, 437, 440, 444, 447, 450, 453, 
	456, 459, 462, 465, 468, 471, 474, 477, 
	480, 483, 486, 489, 492, 495, 498, 501, 
	504, 506, 508, 510, 512, 514, 516, 518, 
	520, 522, 524, 526, 537, 540, 543, 546, 
	549, 552, 555, 558, 561, 564, 567, 570, 
	573, 576, 579, 582, 585, 588, 591, 594, 
	597, 600, 603, 606, 609, 612, 615, 618, 
	622, 625, 628, 631, 634, 637, 640, 643, 
	646, 649, 652, 655, 658, 661, 664, 667, 
	670, 673, 676, 679, 682, 685, 688, 691, 
	694, 697, 700, 703, 706, 709, 712, 714, 
	716, 718, 720, 722, 724, 726, 728, 730, 
	732, 734, 736, 738, 745, 748, 751, 754, 
	757, 760, 763, 766, 769, 772, 776, 782, 
	786, 789, 795, 813, 816, 819, 822, 825, 
	828, 831, 834, 837, 840, 843, 846, 849, 
	852, 855, 860, 863, 866, 869, 872, 875, 
	878, 882, 885, 888, 891, 894, 897, 900, 
	903, 906, 909, 912, 915, 918, 921, 924, 
	927, 930, 933, 936, 939, 942, 945, 948, 
	951, 954, 957, 960, 963, 966, 969, 972, 
	975, 978, 981, 984, 986, 988, 1003, 1006, 
	1009, 1012, 1015, 1018, 1021, 1024, 1027, 1030, 
	1033, 1036, 1039, 1042, 1045, 1048, 1051, 1054, 
	1059, 1062, 1065, 1068, 1071, 1074, 1077, 1081, 
	1084, 1087, 1090, 1093, 1096, 1099, 1102, 1105, 
	1108, 1111, 1114, 1117, 1120, 1123, 1126, 1129, 
	1132, 1135, 1138, 1141, 1144, 1148, 1151, 1154, 
	1157, 1160, 1163, 1166, 1169, 1172, 1176, 1179, 
	1182, 1185, 1188, 1191, 1194, 1197, 1200, 1203, 
	1206, 1209, 1212, 1215, 1218, 1221, 1224, 1227, 
	1229, 1231
};

static const short _lexer_trans_targs[] = {
	2, 391, 7, 7, 8, 18, 20, 4, 
	34, 37, 52, 53, 82, 160, 230, 233, 
	253, 7, 0, 3, 0, 4, 0, 5, 
	0, 7, 19, 6, 7, 19, 6, 2, 
	7, 7, 8, 18, 20, 4, 34, 37, 
	52, 53, 82, 160, 230, 233, 253, 7, 
	0, 9, 0, 10, 0, 12, 11, 11, 
	12, 11, 11, 13, 13, 14, 13, 13, 
	13, 13, 14, 13, 13, 13, 13, 15, 
	13, 13, 13, 13, 16, 13, 13, 7, 
	17, 17, 0, 7, 17, 17, 0, 7, 
	19, 18, 7, 0, 21, 0, 22, 0, 
	23, 0, 24, 0, 25, 0, 26, 0, 
	27, 0, 28, 0, 29, 0, 30, 0, 
	31, 0, 32, 0, 33, 0, 393, 0, 
	0, 0, 0, 0, 35, 36, 7, 36, 
	36, 34, 35, 35, 7, 36, 34, 36, 
	0, 38, 41, 44, 0, 39, 0, 40, 
	0, 4, 0, 42, 0, 43, 0, 4, 
	0, 45, 41, 0, 46, 0, 47, 0, 
	48, 0, 49, 0, 50, 0, 51, 0, 
	4, 0, 4, 0, 54, 0, 55, 0, 
	56, 0, 57, 0, 58, 0, 59, 0, 
	60, 0, 61, 0, 62, 0, 63, 0, 
	64, 0, 65, 0, 66, 0, 67, 315, 
	0, 68, 0, 69, 0, 70, 0, 71, 
	0, 72, 0, 73, 0, 74, 0, 75, 
	0, 77, 76, 77, 76, 78, 77, 77, 
	7, 259, 80, 7, 273, 288, 289, 303, 
	304, 312, 77, 76, 79, 77, 76, 77, 
	80, 76, 77, 81, 76, 2, 7, 7, 
	8, 18, 20, 4, 34, 37, 52, 53, 
	82, 160, 230, 233, 253, 7, 0, 83, 
	4, 0, 84, 0, 85, 0, 86, 0, 
	87, 0, 88, 0, 89, 0, 90, 0, 
	92, 91, 92, 91, 93, 92, 92, 7, 
	96, 95, 7, 110, 125, 126, 148, 149, 
	157, 92, 91, 94, 92, 91, 92, 95, 
	91, 92, 81, 91, 92, 97, 91, 92, 
	98, 91, 92, 99, 91, 92, 100, 91, 
	92, 101, 91, 92, 102, 91, 92, 103, 
	91, 92, 104, 91, 92, 105, 91, 92, 
	106, 91, 92, 107, 91, 92, 108, 91, 
	92, 109, 91, 92, 7, 91, 92, 111, 
	114, 117, 91, 92, 112, 91, 92, 113, 
	91, 92, 95, 91, 92, 115, 91, 92, 
	116, 91, 92, 95, 91, 92, 118, 114, 
	91, 92, 119, 91, 92, 120, 91, 92, 
	121, 91, 92, 122, 91, 92, 123, 91, 
	92, 124, 91, 92, 95, 91, 92, 95, 
	91, 92, 127, 91, 92, 128, 91, 92, 
	129, 91, 92, 130, 91, 92, 131, 91, 
	132, 92, 91, 133, 92, 91, 92, 134, 
	91, 135, 92, 91, 136, 92, 91, 92, 
	137, 91, 92, 138, 91, 92, 139, 91, 
	92, 140, 81, 91, 92, 141, 91, 142, 
	92, 91, 143, 92, 91, 92, 144, 91, 
	92, 145, 91, 92, 146, 91, 92, 147, 
	91, 92, 81, 91, 92, 95, 91, 92, 
	150, 91, 92, 151, 91, 92, 152, 91, 
	92, 153, 91, 92, 154, 91, 92, 155, 
	91, 156, 92, 91, 147, 92, 91, 92, 
	158, 91, 92, 159, 91, 92, 95, 91, 
	161, 0, 162, 0, 163, 0, 164, 0, 
	165, 0, 166, 0, 167, 0, 168, 0, 
	169, 0, 171, 170, 171, 170, 171, 171, 
	7, 172, 7, 186, 208, 215, 223, 171, 
	170, 171, 173, 170, 171, 174, 170, 171, 
	175, 170, 171, 176, 170, 171, 177, 170, 
	171, 178, 170, 171, 179, 170, 171, 180, 
	170, 171, 181, 170, 171, 182, 170, 171, 
	183, 170, 171, 184, 170, 171, 185, 170, 
	171, 7, 170, 171, 187, 170, 171, 188, 
	170, 171, 189, 170, 171, 190, 170, 171, 
	191, 170, 192, 171, 170, 193, 171, 170, 
	171, 194, 170, 195, 171, 170, 196, 171, 
	170, 171, 197, 170, 171, 198, 170, 171, 
	199, 170, 171, 200, 81, 170, 171, 201, 
	170, 202, 171, 170, 203, 171, 170, 171, 
	204, 170, 171, 205, 170, 171, 206, 170, 
	171, 207, 170, 171, 81, 170, 209, 171, 
	170, 210, 171, 170, 171, 211, 170, 171, 
	212, 170, 213, 171, 170, 214, 171, 170, 
	171, 207, 170, 171, 216, 170, 171, 217, 
	170, 171, 218, 170, 171, 219, 170, 171, 
	220, 170, 171, 221, 170, 222, 171, 170, 
	207, 171, 170, 224, 171, 170, 225, 171, 
	170, 171, 226, 170, 171, 227, 170, 228, 
	171, 170, 229, 171, 170, 171, 207, 170, 
	231, 0, 232, 0, 4, 0, 234, 0, 
	235, 0, 236, 0, 237, 0, 238, 0, 
	239, 0, 240, 0, 241, 0, 243, 242, 
	243, 242, 243, 243, 7, 244, 7, 243, 
	242, 243, 245, 242, 243, 246, 242, 243, 
	247, 242, 243, 248, 242, 243, 249, 242, 
	243, 250, 242, 251, 243, 242, 252, 243, 
	242, 243, 81, 242, 253, 254, 253, 0, 
	258, 257, 256, 254, 257, 255, 0, 256, 
	254, 255, 0, 256, 255, 258, 257, 256, 
	254, 257, 255, 2, 258, 258, 8, 18, 
	20, 4, 34, 37, 52, 53, 82, 160, 
	230, 233, 253, 258, 0, 77, 260, 76, 
	77, 261, 76, 77, 262, 76, 77, 263, 
	76, 77, 264, 76, 77, 265, 76, 77, 
	266, 76, 77, 267, 76, 77, 268, 76, 
	77, 269, 76, 77, 270, 76, 77, 271, 
	76, 77, 272, 76, 77, 7, 76, 77, 
	274, 277, 280, 76, 77, 275, 76, 77, 
	276, 76, 77, 80, 76, 77, 278, 76, 
	77, 279, 76, 77, 80, 76, 77, 281, 
	277, 76, 77, 282, 76, 77, 283, 76, 
	77, 284, 76, 77, 285, 76, 77, 286, 
	76, 77, 287, 76, 77, 80, 76, 77, 
	80, 76, 77, 290, 76, 77, 291, 76, 
	77, 292, 76, 77, 293, 76, 77, 294, 
	76, 295, 77, 76, 296, 77, 76, 77, 
	297, 76, 298, 77, 76, 299, 77, 76, 
	77, 300, 76, 77, 301, 76, 77, 302, 
	76, 77, 81, 76, 77, 80, 76, 77, 
	305, 76, 77, 306, 76, 77, 307, 76, 
	77, 308, 76, 77, 309, 76, 77, 310, 
	76, 311, 77, 76, 302, 77, 76, 77, 
	313, 76, 77, 314, 76, 77, 80, 76, 
	317, 316, 317, 316, 318, 317, 317, 7, 
	321, 320, 7, 335, 350, 351, 373, 380, 
	388, 317, 316, 319, 317, 316, 317, 320, 
	316, 317, 81, 316, 317, 322, 316, 317, 
	323, 316, 317, 324, 316, 317, 325, 316, 
	317, 326, 316, 317, 327, 316, 317, 328, 
	316, 317, 329, 316, 317, 330, 316, 317, 
	331, 316, 317, 332, 316, 317, 333, 316, 
	317, 334, 316, 317, 7, 316, 317, 336, 
	339, 342, 316, 317, 337, 316, 317, 338, 
	316, 317, 320, 316, 317, 340, 316, 317, 
	341, 316, 317, 320, 316, 317, 343, 339, 
	316, 317, 344, 316, 317, 345, 316, 317, 
	346, 316, 317, 347, 316, 317, 348, 316, 
	317, 349, 316, 317, 320, 316, 317, 320, 
	316, 317, 352, 316, 317, 353, 316, 317, 
	354, 316, 317, 355, 316, 317, 356, 316, 
	357, 317, 316, 358, 317, 316, 317, 359, 
	316, 360, 317, 316, 361, 317, 316, 317, 
	362, 316, 317, 363, 316, 317, 364, 316, 
	317, 365, 81, 316, 317, 366, 316, 367, 
	317, 316, 368, 317, 316, 317, 369, 316, 
	317, 370, 316, 317, 371, 316, 317, 372, 
	316, 317, 81, 316, 374, 317, 320, 316, 
	375, 317, 316, 317, 376, 316, 317, 377, 
	316, 378, 317, 316, 379, 317, 316, 317, 
	372, 316, 317, 381, 316, 317, 382, 316, 
	317, 383, 316, 317, 384, 316, 317, 385, 
	316, 317, 386, 316, 387, 317, 316, 372, 
	317, 316, 317, 389, 316, 317, 390, 316, 
	317, 320, 316, 392, 0, 7, 0, 0, 
	0
};

static const unsigned char _lexer_trans_actions[] = {
	29, 0, 54, 0, 5, 1, 0, 29, 
	1, 29, 29, 29, 29, 29, 29, 29, 
	35, 0, 43, 0, 43, 0, 43, 0, 
	43, 149, 126, 57, 110, 23, 0, 29, 
	54, 0, 5, 1, 0, 29, 1, 29, 
	29, 29, 29, 29, 29, 29, 35, 0, 
	43, 0, 43, 0, 43, 139, 48, 9, 
	106, 11, 0, 134, 45, 45, 45, 3, 
	122, 33, 33, 33, 0, 122, 33, 33, 
	33, 0, 122, 33, 0, 33, 0, 102, 
	7, 7, 43, 54, 0, 0, 43, 114, 
	25, 0, 54, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	43, 43, 43, 43, 0, 27, 118, 27, 
	27, 51, 27, 0, 54, 0, 1, 0, 
	43, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 84, 54, 0, 
	78, 33, 84, 78, 84, 84, 84, 84, 
	84, 84, 0, 0, 0, 54, 0, 54, 
	0, 0, 54, 19, 0, 63, 130, 31, 
	60, 57, 31, 63, 57, 63, 63, 63, 
	63, 63, 63, 63, 66, 31, 43, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 84, 54, 0, 72, 
	33, 84, 72, 84, 84, 84, 84, 84, 
	84, 0, 0, 0, 54, 0, 54, 0, 
	0, 54, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 15, 0, 54, 0, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 15, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	69, 33, 69, 84, 84, 84, 84, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 13, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 13, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 13, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 81, 84, 81, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 54, 21, 0, 0, 0, 0, 43, 
	54, 37, 37, 87, 37, 37, 43, 0, 
	39, 0, 43, 0, 0, 54, 0, 0, 
	39, 0, 0, 96, 54, 0, 93, 90, 
	41, 96, 90, 96, 96, 96, 96, 96, 
	96, 96, 99, 0, 43, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	0, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 19, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	144, 57, 54, 0, 84, 54, 0, 75, 
	33, 84, 75, 84, 84, 84, 84, 84, 
	84, 0, 0, 0, 54, 0, 54, 0, 
	0, 54, 17, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 54, 0, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 17, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 17, 0, 0, 54, 0, 0, 
	0, 54, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 43, 0, 43, 0, 
	0
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
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 393;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"

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
    
    
#line 980 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
    
#line 987 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
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
#line 1277 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"
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
#line 1340 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hu.c.rl"

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

void Init_gherkin_lexer_hu()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Hu", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

