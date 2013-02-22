
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_bm/gherkin_lexer_bm.c"
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
	0, 0, 21, 22, 23, 43, 44, 45, 
	47, 49, 54, 59, 64, 69, 73, 77, 
	79, 80, 81, 82, 83, 84, 85, 86, 
	87, 88, 89, 90, 91, 92, 93, 94, 
	95, 97, 99, 104, 111, 116, 117, 118, 
	119, 120, 121, 122, 123, 124, 125, 126, 
	127, 128, 129, 130, 131, 132, 133, 134, 
	141, 143, 145, 147, 149, 151, 153, 173, 
	174, 175, 176, 177, 178, 179, 180, 181, 
	182, 183, 195, 197, 199, 201, 203, 205, 
	207, 209, 211, 213, 215, 217, 219, 221, 
	223, 225, 227, 229, 231, 233, 235, 237, 
	239, 241, 243, 245, 247, 249, 251, 253, 
	255, 257, 259, 261, 263, 265, 267, 269, 
	271, 273, 275, 277, 279, 281, 283, 285, 
	287, 289, 291, 293, 295, 297, 299, 301, 
	303, 305, 307, 309, 311, 313, 315, 317, 
	319, 321, 323, 324, 325, 326, 327, 328, 
	329, 330, 331, 332, 333, 334, 335, 336, 
	337, 338, 339, 340, 341, 342, 343, 344, 
	360, 362, 364, 366, 368, 370, 372, 374, 
	376, 378, 380, 382, 384, 386, 388, 390, 
	392, 394, 396, 398, 400, 402, 404, 406, 
	408, 410, 412, 414, 416, 418, 420, 422, 
	424, 426, 428, 430, 432, 434, 436, 438, 
	440, 442, 444, 446, 448, 450, 452, 454, 
	456, 458, 460, 462, 464, 466, 468, 470, 
	472, 474, 476, 478, 480, 482, 484, 486, 
	488, 490, 492, 494, 495, 496, 497, 498, 
	499, 500, 501, 502, 503, 504, 505, 506, 
	507, 508, 509, 510, 511, 512, 513, 514, 
	515, 516, 517, 532, 534, 536, 538, 540, 
	542, 544, 546, 548, 550, 552, 554, 556, 
	558, 560, 562, 564, 566, 568, 570, 572, 
	574, 576, 578, 580, 582, 584, 586, 588, 
	590, 592, 594, 596, 598, 600, 602, 604, 
	606, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 626, 627, 628, 629, 630, 631, 
	632, 633, 634, 635, 652, 654, 656, 658, 
	660, 662, 664, 666, 668, 670, 672, 674, 
	676, 678, 680, 682, 684, 686, 688, 690, 
	692, 694, 696, 698, 700, 702, 704, 706, 
	708, 710, 712, 714, 716, 718, 720, 722, 
	724, 726, 728, 730, 732, 734, 736, 738, 
	740, 742, 744, 746, 748, 750, 752, 754, 
	756, 758, 760, 762, 764, 766, 768, 770, 
	772, 774, 776, 778, 780, 782, 784, 786, 
	788, 790, 792, 794, 796, 798, 800, 802, 
	804, 806, 808, 810, 812, 813, 814, 815, 
	816, 820, 826, 829, 831, 837, 857
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 67, 68, 70, 75, 76, 77, 
	83, 84, 124, 9, 13, -69, -65, 10, 
	32, 34, 35, 37, 42, 64, 65, 66, 
	67, 68, 70, 75, 76, 77, 83, 84, 
	124, 9, 13, 34, 34, 10, 13, 10, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 9, 
	13, 10, 32, 9, 13, 10, 13, 10, 
	95, 70, 69, 65, 84, 85, 82, 69, 
	95, 69, 78, 68, 95, 37, 32, 10, 
	13, 10, 13, 13, 32, 64, 9, 10, 
	9, 10, 13, 32, 64, 11, 12, 10, 
	32, 64, 9, 13, 112, 97, 98, 105, 
	108, 97, 97, 103, 105, 111, 110, 116, 
	111, 104, 32, 58, 10, 10, 10, 32, 
	35, 70, 124, 9, 13, 10, 117, 10, 
	110, 10, 103, 10, 115, 10, 105, 10, 
	58, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 67, 68, 70, 75, 76, 77, 
	83, 84, 124, 9, 13, 97, 110, 117, 
	110, 103, 115, 105, 58, 10, 10, 10, 
	32, 35, 37, 64, 67, 70, 76, 77, 
	83, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	111, 10, 110, 10, 116, 10, 111, 10, 
	104, 10, 32, 10, 58, 10, 117, 10, 
	110, 10, 103, 10, 115, 10, 105, 10, 
	97, 10, 116, 10, 97, 10, 114, 10, 
	32, 10, 66, 10, 101, 10, 108, 10, 
	97, 10, 107, 10, 97, 10, 110, 10, 
	103, 10, 101, 10, 110, 10, 103, 10, 
	103, 10, 97, 10, 114, 10, 105, 10, 
	115, 10, 107, 10, 97, 10, 110, 10, 
	32, 10, 83, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 111, 101, 109, 117, 100, 105, 
	97, 116, 97, 114, 32, 66, 101, 108, 
	97, 107, 97, 110, 103, 58, 10, 10, 
	10, 32, 35, 37, 42, 64, 65, 66, 
	68, 70, 75, 77, 83, 84, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 112, 
	10, 97, 10, 98, 10, 105, 10, 108, 
	10, 97, 10, 97, 10, 103, 10, 105, 
	10, 97, 10, 110, 10, 117, 10, 110, 
	10, 103, 10, 115, 10, 105, 10, 58, 
	10, 101, 10, 109, 10, 117, 10, 100, 
	10, 105, 10, 101, 10, 110, 10, 103, 
	10, 103, 10, 97, 10, 114, 10, 105, 
	10, 115, 10, 107, 10, 97, 10, 110, 
	10, 32, 10, 83, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 111, 
	10, 32, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 111, 10, 101, 
	10, 116, 10, 97, 10, 112, 101, 110, 
	103, 103, 97, 114, 105, 115, 107, 97, 
	110, 32, 83, 101, 110, 97, 114, 105, 
	111, 32, 58, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 66, 68, 70, 75, 
	83, 84, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 112, 10, 97, 10, 98, 
	10, 105, 10, 108, 10, 97, 10, 97, 
	10, 103, 10, 105, 10, 97, 10, 110, 
	10, 117, 10, 110, 10, 103, 10, 115, 
	10, 105, 10, 58, 10, 101, 10, 109, 
	10, 117, 10, 100, 10, 105, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 111, 10, 101, 10, 116, 10, 97, 
	10, 112, 101, 110, 97, 114, 105, 111, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 65, 66, 68, 70, 75, 76, 77, 
	83, 84, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 112, 10, 97, 10, 98, 
	10, 105, 10, 108, 10, 97, 10, 97, 
	10, 103, 10, 105, 10, 97, 10, 110, 
	10, 117, 10, 110, 10, 103, 10, 115, 
	10, 105, 10, 58, 10, 101, 10, 109, 
	10, 117, 10, 100, 10, 105, 10, 97, 
	10, 116, 10, 97, 10, 114, 10, 32, 
	10, 66, 10, 101, 10, 108, 10, 97, 
	10, 107, 10, 97, 10, 110, 10, 103, 
	10, 101, 10, 110, 10, 103, 10, 103, 
	10, 97, 10, 114, 10, 105, 10, 115, 
	10, 107, 10, 97, 10, 110, 10, 32, 
	10, 83, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 111, 10, 32, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 10, 101, 10, 116, 
	10, 97, 10, 112, 101, 116, 97, 112, 
	32, 124, 9, 13, 10, 32, 92, 124, 
	9, 13, 10, 92, 124, 10, 92, 10, 
	32, 92, 124, 9, 13, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 67, 68, 
	70, 75, 76, 77, 83, 84, 124, 9, 
	13, 0
};

static const char _lexer_single_lengths[] = {
	0, 19, 1, 1, 18, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 5, 
	2, 2, 2, 2, 2, 2, 18, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 10, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 14, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 15, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	2, 4, 3, 2, 4, 18, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 1, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 0, 0, 1, 1, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 21, 23, 25, 45, 47, 49, 
	52, 55, 60, 65, 70, 75, 79, 83, 
	86, 88, 90, 92, 94, 96, 98, 100, 
	102, 104, 106, 108, 110, 112, 114, 116, 
	118, 121, 124, 129, 136, 141, 143, 145, 
	147, 149, 151, 153, 155, 157, 159, 161, 
	163, 165, 167, 169, 171, 173, 175, 177, 
	184, 187, 190, 193, 196, 199, 202, 222, 
	224, 226, 228, 230, 232, 234, 236, 238, 
	240, 242, 254, 257, 260, 263, 266, 269, 
	272, 275, 278, 281, 284, 287, 290, 293, 
	296, 299, 302, 305, 308, 311, 314, 317, 
	320, 323, 326, 329, 332, 335, 338, 341, 
	344, 347, 350, 353, 356, 359, 362, 365, 
	368, 371, 374, 377, 380, 383, 386, 389, 
	392, 395, 398, 401, 404, 407, 410, 413, 
	416, 419, 422, 425, 428, 431, 434, 437, 
	440, 443, 446, 448, 450, 452, 454, 456, 
	458, 460, 462, 464, 466, 468, 470, 472, 
	474, 476, 478, 480, 482, 484, 486, 488, 
	504, 507, 510, 513, 516, 519, 522, 525, 
	528, 531, 534, 537, 540, 543, 546, 549, 
	552, 555, 558, 561, 564, 567, 570, 573, 
	576, 579, 582, 585, 588, 591, 594, 597, 
	600, 603, 606, 609, 612, 615, 618, 621, 
	624, 627, 630, 633, 636, 639, 642, 645, 
	648, 651, 654, 657, 660, 663, 666, 669, 
	672, 675, 678, 681, 684, 687, 690, 693, 
	696, 699, 702, 705, 707, 709, 711, 713, 
	715, 717, 719, 721, 723, 725, 727, 729, 
	731, 733, 735, 737, 739, 741, 743, 745, 
	747, 749, 751, 766, 769, 772, 775, 778, 
	781, 784, 787, 790, 793, 796, 799, 802, 
	805, 808, 811, 814, 817, 820, 823, 826, 
	829, 832, 835, 838, 841, 844, 847, 850, 
	853, 856, 859, 862, 865, 868, 871, 874, 
	877, 880, 883, 886, 889, 892, 895, 898, 
	901, 904, 907, 909, 911, 913, 915, 917, 
	919, 921, 923, 925, 942, 945, 948, 951, 
	954, 957, 960, 963, 966, 969, 972, 975, 
	978, 981, 984, 987, 990, 993, 996, 999, 
	1002, 1005, 1008, 1011, 1014, 1017, 1020, 1023, 
	1026, 1029, 1032, 1035, 1038, 1041, 1044, 1047, 
	1050, 1053, 1056, 1059, 1062, 1065, 1068, 1071, 
	1074, 1077, 1080, 1083, 1086, 1089, 1092, 1095, 
	1098, 1101, 1104, 1107, 1110, 1113, 1116, 1119, 
	1122, 1125, 1128, 1131, 1134, 1137, 1140, 1143, 
	1146, 1149, 1152, 1155, 1158, 1161, 1164, 1167, 
	1170, 1173, 1176, 1179, 1182, 1184, 1186, 1188, 
	1190, 1194, 1200, 1204, 1207, 1213, 1233
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 43, 46, 63, 65, 138, 143, 227, 
	298, 388, 392, 4, 0, 3, 0, 4, 
	0, 4, 4, 5, 15, 17, 31, 34, 
	37, 43, 46, 63, 65, 138, 143, 227, 
	298, 388, 392, 4, 0, 6, 0, 7, 
	0, 9, 8, 8, 9, 8, 8, 10, 
	10, 11, 10, 10, 10, 10, 11, 10, 
	10, 10, 10, 12, 10, 10, 10, 10, 
	13, 10, 10, 4, 14, 14, 0, 4, 
	14, 14, 0, 4, 16, 15, 4, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 23, 0, 24, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	30, 0, 398, 0, 32, 0, 4, 16, 
	33, 4, 16, 33, 0, 0, 0, 0, 
	35, 36, 4, 36, 36, 34, 35, 35, 
	4, 36, 34, 36, 0, 38, 0, 39, 
	0, 40, 0, 41, 0, 42, 0, 31, 
	0, 44, 0, 45, 0, 31, 0, 47, 
	0, 48, 0, 49, 0, 50, 0, 51, 
	0, 52, 0, 53, 0, 55, 54, 55, 
	54, 55, 55, 4, 56, 4, 55, 54, 
	55, 57, 54, 55, 58, 54, 55, 59, 
	54, 55, 60, 54, 55, 61, 54, 55, 
	62, 54, 4, 4, 5, 15, 17, 31, 
	34, 37, 43, 46, 63, 65, 138, 143, 
	227, 298, 388, 392, 4, 0, 64, 0, 
	31, 0, 66, 0, 67, 0, 68, 0, 
	69, 0, 70, 0, 71, 0, 73, 72, 
	73, 72, 73, 73, 4, 74, 4, 88, 
	95, 100, 113, 132, 73, 72, 73, 75, 
	72, 73, 76, 72, 73, 77, 72, 73, 
	78, 72, 73, 79, 72, 73, 80, 72, 
	73, 81, 72, 73, 82, 72, 73, 83, 
	72, 73, 84, 72, 73, 85, 72, 73, 
	86, 72, 73, 87, 72, 73, 4, 72, 
	73, 89, 72, 73, 90, 72, 73, 91, 
	72, 73, 92, 72, 73, 93, 72, 73, 
	94, 72, 73, 62, 72, 73, 96, 72, 
	73, 97, 72, 73, 98, 72, 73, 99, 
	72, 73, 94, 72, 73, 101, 72, 73, 
	102, 72, 73, 103, 72, 73, 104, 72, 
	73, 105, 72, 73, 106, 72, 73, 107, 
	72, 73, 108, 72, 73, 109, 72, 73, 
	110, 72, 73, 111, 72, 73, 112, 72, 
	73, 94, 72, 73, 114, 72, 73, 115, 
	72, 73, 116, 72, 73, 117, 72, 73, 
	118, 72, 73, 119, 72, 73, 120, 72, 
	73, 121, 72, 73, 122, 72, 73, 123, 
	72, 73, 124, 72, 73, 125, 72, 73, 
	126, 72, 73, 127, 72, 73, 128, 72, 
	73, 129, 72, 73, 130, 72, 73, 131, 
	72, 73, 93, 72, 73, 133, 72, 73, 
	134, 72, 73, 135, 72, 73, 136, 72, 
	73, 137, 72, 73, 94, 72, 139, 0, 
	140, 0, 141, 0, 142, 0, 63, 0, 
	144, 0, 145, 0, 146, 0, 147, 0, 
	148, 0, 149, 0, 150, 0, 151, 0, 
	152, 0, 153, 0, 154, 0, 155, 0, 
	156, 0, 157, 0, 159, 158, 159, 158, 
	159, 159, 4, 160, 174, 4, 175, 181, 
	184, 186, 192, 197, 217, 223, 159, 158, 
	159, 161, 158, 159, 162, 158, 159, 163, 
	158, 159, 164, 158, 159, 165, 158, 159, 
	166, 158, 159, 167, 158, 159, 168, 158, 
	159, 169, 158, 159, 170, 158, 159, 171, 
	158, 159, 172, 158, 159, 173, 158, 159, 
	4, 158, 159, 62, 158, 159, 176, 158, 
	159, 177, 158, 159, 178, 158, 159, 179, 
	158, 159, 180, 158, 159, 174, 158, 159, 
	182, 158, 159, 183, 158, 159, 174, 158, 
	159, 185, 158, 159, 174, 158, 159, 187, 
	158, 159, 188, 158, 159, 189, 158, 159, 
	190, 158, 159, 191, 158, 159, 62, 158, 
	159, 193, 158, 159, 194, 158, 159, 195, 
	158, 159, 196, 158, 159, 184, 158, 159, 
	198, 158, 159, 199, 158, 159, 200, 158, 
	159, 201, 158, 159, 202, 158, 159, 203, 
	158, 159, 204, 158, 159, 205, 158, 159, 
	206, 158, 159, 207, 158, 159, 208, 158, 
	159, 209, 158, 159, 210, 158, 159, 211, 
	158, 159, 212, 158, 159, 213, 158, 159, 
	214, 158, 159, 215, 158, 159, 216, 158, 
	159, 191, 158, 159, 218, 158, 159, 219, 
	158, 159, 220, 158, 159, 221, 158, 159, 
	222, 158, 159, 191, 158, 159, 224, 158, 
	159, 225, 158, 159, 226, 158, 159, 183, 
	158, 228, 0, 229, 0, 230, 0, 231, 
	0, 232, 0, 233, 0, 234, 0, 235, 
	0, 236, 0, 237, 0, 238, 0, 239, 
	0, 240, 0, 241, 0, 242, 0, 243, 
	0, 244, 0, 245, 0, 246, 0, 247, 
	0, 248, 0, 250, 249, 250, 249, 250, 
	250, 4, 251, 265, 4, 266, 272, 275, 
	277, 283, 288, 294, 250, 249, 250, 252, 
	249, 250, 253, 249, 250, 254, 249, 250, 
	255, 249, 250, 256, 249, 250, 257, 249, 
	250, 258, 249, 250, 259, 249, 250, 260, 
	249, 250, 261, 249, 250, 262, 249, 250, 
	263, 249, 250, 264, 249, 250, 4, 249, 
	250, 62, 249, 250, 267, 249, 250, 268, 
	249, 250, 269, 249, 250, 270, 249, 250, 
	271, 249, 250, 265, 249, 250, 273, 249, 
	250, 274, 249, 250, 265, 249, 250, 276, 
	249, 250, 265, 249, 250, 278, 249, 250, 
	279, 249, 250, 280, 249, 250, 281, 249, 
	250, 282, 249, 250, 62, 249, 250, 284, 
	249, 250, 285, 249, 250, 286, 249, 250, 
	287, 249, 250, 275, 249, 250, 289, 249, 
	250, 290, 249, 250, 291, 249, 250, 292, 
	249, 250, 293, 249, 250, 282, 249, 250, 
	295, 249, 250, 296, 249, 250, 297, 249, 
	250, 274, 249, 299, 0, 300, 0, 301, 
	0, 302, 0, 303, 0, 304, 0, 305, 
	0, 307, 306, 307, 306, 307, 307, 4, 
	308, 322, 4, 323, 329, 332, 334, 340, 
	345, 358, 378, 384, 307, 306, 307, 309, 
	306, 307, 310, 306, 307, 311, 306, 307, 
	312, 306, 307, 313, 306, 307, 314, 306, 
	307, 315, 306, 307, 316, 306, 307, 317, 
	306, 307, 318, 306, 307, 319, 306, 307, 
	320, 306, 307, 321, 306, 307, 4, 306, 
	307, 62, 306, 307, 324, 306, 307, 325, 
	306, 307, 326, 306, 307, 327, 306, 307, 
	328, 306, 307, 322, 306, 307, 330, 306, 
	307, 331, 306, 307, 322, 306, 307, 333, 
	306, 307, 322, 306, 307, 335, 306, 307, 
	336, 306, 307, 337, 306, 307, 338, 306, 
	307, 339, 306, 307, 62, 306, 307, 341, 
	306, 307, 342, 306, 307, 343, 306, 307, 
	344, 306, 307, 332, 306, 307, 346, 306, 
	307, 347, 306, 307, 348, 306, 307, 349, 
	306, 307, 350, 306, 307, 351, 306, 307, 
	352, 306, 307, 353, 306, 307, 354, 306, 
	307, 355, 306, 307, 356, 306, 307, 357, 
	306, 307, 339, 306, 307, 359, 306, 307, 
	360, 306, 307, 361, 306, 307, 362, 306, 
	307, 363, 306, 307, 364, 306, 307, 365, 
	306, 307, 366, 306, 307, 367, 306, 307, 
	368, 306, 307, 369, 306, 307, 370, 306, 
	307, 371, 306, 307, 372, 306, 307, 373, 
	306, 307, 374, 306, 307, 375, 306, 307, 
	376, 306, 307, 377, 306, 307, 339, 306, 
	307, 379, 306, 307, 380, 306, 307, 381, 
	306, 307, 382, 306, 307, 383, 306, 307, 
	339, 306, 307, 385, 306, 307, 386, 306, 
	307, 387, 306, 307, 331, 306, 389, 0, 
	390, 0, 391, 0, 45, 0, 392, 393, 
	392, 0, 397, 396, 395, 393, 396, 394, 
	0, 395, 393, 394, 0, 395, 394, 397, 
	396, 395, 393, 396, 394, 397, 397, 5, 
	15, 17, 31, 34, 37, 43, 46, 63, 
	65, 138, 143, 227, 298, 388, 392, 397, 
	0, 0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	0, 54, 0, 5, 1, 0, 29, 1, 
	29, 29, 29, 29, 29, 29, 29, 29, 
	29, 29, 35, 0, 43, 0, 43, 0, 
	43, 54, 0, 5, 1, 0, 29, 1, 
	29, 29, 29, 29, 29, 29, 29, 29, 
	29, 29, 35, 0, 43, 0, 43, 0, 
	43, 139, 48, 9, 106, 11, 0, 134, 
	45, 45, 45, 3, 122, 33, 33, 33, 
	0, 122, 33, 33, 33, 0, 122, 33, 
	0, 33, 0, 102, 7, 7, 43, 54, 
	0, 0, 43, 114, 25, 0, 54, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 149, 126, 
	57, 110, 23, 0, 43, 43, 43, 43, 
	0, 27, 118, 27, 27, 51, 27, 0, 
	54, 0, 1, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 54, 0, 81, 84, 81, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	21, 0, 130, 31, 60, 57, 31, 63, 
	57, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 63, 66, 31, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 69, 33, 69, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 13, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 144, 57, 54, 0, 
	54, 0, 72, 33, 84, 72, 84, 84, 
	84, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	15, 0, 54, 15, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 15, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 78, 33, 84, 78, 84, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 19, 0, 
	54, 19, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 19, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 75, 
	33, 84, 75, 84, 84, 84, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 17, 0, 
	54, 17, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 0, 
	0, 43, 54, 37, 37, 87, 37, 37, 
	43, 0, 39, 0, 43, 0, 0, 54, 
	0, 0, 39, 0, 0, 54, 0, 93, 
	90, 41, 96, 90, 96, 96, 96, 96, 
	96, 96, 96, 96, 96, 96, 99, 0, 
	43, 0, 0
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
	43, 43, 43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 398;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"

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
    
    
#line 980 "ext/gherkin_lexer_bm/gherkin_lexer_bm.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
    
#line 987 "ext/gherkin_lexer_bm/gherkin_lexer_bm.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
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
#line 1277 "ext/gherkin_lexer_bm/gherkin_lexer_bm.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"
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
#line 1340 "ext/gherkin_lexer_bm/gherkin_lexer_bm.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/bm.c.rl"

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

void Init_gherkin_lexer_bm()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Bm", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

