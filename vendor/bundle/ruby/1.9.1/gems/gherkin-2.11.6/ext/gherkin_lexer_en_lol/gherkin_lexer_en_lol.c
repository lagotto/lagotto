
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_en_lol/gherkin_lexer_en_lol.c"
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
	0, 0, 19, 20, 21, 39, 40, 41, 
	43, 45, 50, 55, 60, 65, 69, 73, 
	75, 76, 77, 78, 79, 80, 81, 82, 
	83, 84, 85, 86, 87, 88, 89, 90, 
	91, 93, 95, 100, 107, 112, 113, 115, 
	116, 117, 118, 133, 135, 137, 139, 141, 
	143, 145, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 181, 182, 183, 184, 185, 
	186, 187, 188, 189, 190, 191, 198, 200, 
	202, 204, 206, 208, 210, 211, 212, 213, 
	214, 215, 216, 217, 218, 219, 220, 221, 
	222, 223, 225, 226, 227, 228, 229, 230, 
	231, 232, 233, 248, 250, 252, 254, 256, 
	258, 260, 262, 264, 266, 268, 270, 272, 
	274, 276, 278, 280, 282, 284, 286, 288, 
	290, 292, 294, 296, 298, 300, 302, 304, 
	306, 308, 310, 312, 314, 316, 318, 320, 
	322, 324, 325, 326, 341, 343, 345, 347, 
	349, 351, 353, 355, 357, 359, 361, 363, 
	365, 367, 369, 371, 373, 376, 378, 380, 
	382, 384, 386, 388, 390, 392, 394, 396, 
	398, 400, 402, 404, 406, 408, 411, 413, 
	415, 417, 419, 421, 423, 425, 427, 429, 
	431, 432, 433, 434, 435, 436, 437, 438, 
	439, 450, 452, 454, 456, 458, 460, 462, 
	464, 466, 468, 470, 472, 474, 476, 478, 
	480, 482, 484, 486, 488, 490, 492, 494, 
	496, 498, 500, 502, 504, 507, 509, 511, 
	513, 515, 517, 519, 521, 523, 525, 527, 
	531, 537, 540, 542, 548, 566, 568, 570, 
	572, 574, 576, 578, 580, 582, 584, 586, 
	588, 590, 592, 594, 596, 598, 600, 603, 
	605, 607, 609, 611, 613, 615, 617, 619, 
	621, 623, 625, 626
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 68, 69, 73, 77, 79, 87, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 68, 69, 
	73, 77, 79, 87, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	78, 52, 85, 58, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 66, 68, 73, 
	77, 79, 87, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 32, 34, 35, 37, 
	42, 64, 65, 66, 68, 69, 73, 77, 
	79, 87, 124, 9, 13, 69, 88, 65, 
	77, 80, 76, 90, 58, 10, 10, 10, 
	32, 35, 79, 124, 9, 13, 10, 72, 
	10, 32, 10, 72, 10, 65, 10, 73, 
	10, 58, 32, 67, 65, 78, 32, 72, 
	65, 90, 73, 83, 72, 85, 78, 32, 
	58, 83, 82, 83, 76, 89, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 65, 
	66, 68, 73, 77, 79, 87, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 78, 
	10, 85, 10, 84, 10, 69, 10, 32, 
	10, 67, 10, 65, 10, 78, 10, 32, 
	10, 72, 10, 65, 10, 90, 10, 73, 
	10, 83, 10, 72, 10, 85, 10, 78, 
	10, 58, 10, 72, 10, 32, 10, 72, 
	10, 65, 10, 73, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 66, 68, 73, 
	77, 79, 87, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 78, 10, 52, 85, 
	10, 58, 10, 84, 10, 69, 10, 32, 
	10, 67, 10, 65, 10, 78, 10, 32, 
	10, 72, 10, 65, 10, 90, 10, 73, 
	10, 83, 10, 72, 10, 85, 10, 78, 
	10, 32, 58, 10, 83, 10, 82, 10, 
	83, 10, 76, 10, 89, 10, 72, 10, 
	32, 10, 72, 10, 65, 10, 73, 72, 
	32, 72, 65, 73, 58, 10, 10, 10, 
	32, 35, 37, 64, 66, 69, 77, 79, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 52, 
	10, 58, 10, 88, 10, 65, 10, 77, 
	10, 80, 10, 76, 10, 90, 10, 73, 
	10, 83, 10, 72, 10, 85, 10, 78, 
	10, 32, 58, 10, 83, 10, 82, 10, 
	83, 10, 76, 10, 89, 10, 72, 10, 
	32, 10, 72, 10, 65, 10, 73, 32, 
	124, 9, 13, 10, 32, 92, 124, 9, 
	13, 10, 92, 124, 10, 92, 10, 32, 
	92, 124, 9, 13, 10, 32, 34, 35, 
	37, 42, 64, 65, 66, 68, 69, 73, 
	77, 79, 87, 124, 9, 13, 10, 78, 
	10, 85, 10, 84, 10, 69, 10, 32, 
	10, 67, 10, 65, 10, 78, 10, 32, 
	10, 72, 10, 65, 10, 90, 10, 73, 
	10, 83, 10, 72, 10, 85, 10, 78, 
	10, 32, 58, 10, 83, 10, 82, 10, 
	83, 10, 76, 10, 89, 10, 58, 10, 
	72, 10, 32, 10, 72, 10, 65, 10, 
	73, 84, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 2, 1, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 16, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 5, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 13, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	9, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 3, 2, 4, 16, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 0, 0, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 139, 142, 
	144, 146, 148, 163, 166, 169, 172, 175, 
	178, 181, 184, 187, 190, 193, 196, 199, 
	202, 205, 208, 226, 228, 230, 232, 234, 
	236, 238, 240, 242, 244, 246, 253, 256, 
	259, 262, 265, 268, 271, 273, 275, 277, 
	279, 281, 283, 285, 287, 289, 291, 293, 
	295, 297, 300, 302, 304, 306, 308, 310, 
	312, 314, 316, 331, 334, 337, 340, 343, 
	346, 349, 352, 355, 358, 361, 364, 367, 
	370, 373, 376, 379, 382, 385, 388, 391, 
	394, 397, 400, 403, 406, 409, 412, 415, 
	418, 421, 424, 427, 430, 433, 436, 439, 
	442, 445, 447, 449, 464, 467, 470, 473, 
	476, 479, 482, 485, 488, 491, 494, 497, 
	500, 503, 506, 509, 512, 516, 519, 522, 
	525, 528, 531, 534, 537, 540, 543, 546, 
	549, 552, 555, 558, 561, 564, 568, 571, 
	574, 577, 580, 583, 586, 589, 592, 595, 
	598, 600, 602, 604, 606, 608, 610, 612, 
	614, 625, 628, 631, 634, 637, 640, 643, 
	646, 649, 652, 655, 658, 661, 664, 667, 
	670, 673, 676, 679, 682, 685, 688, 691, 
	694, 697, 700, 703, 706, 710, 713, 716, 
	719, 722, 725, 728, 731, 734, 737, 740, 
	744, 750, 754, 757, 763, 781, 784, 787, 
	790, 793, 796, 799, 802, 805, 808, 811, 
	814, 817, 820, 823, 826, 829, 832, 836, 
	839, 842, 845, 848, 851, 854, 857, 860, 
	863, 866, 869, 871
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 38, 59, 60, 76, 84, 184, 59, 
	231, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 38, 
	59, 60, 76, 84, 184, 59, 231, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 267, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 31, 0, 39, 266, 0, 40, 0, 
	42, 41, 42, 41, 42, 42, 4, 43, 
	57, 4, 237, 238, 240, 241, 249, 261, 
	240, 42, 41, 42, 44, 41, 42, 45, 
	41, 42, 46, 41, 42, 47, 41, 42, 
	48, 41, 42, 49, 41, 42, 50, 41, 
	42, 51, 41, 42, 52, 41, 42, 53, 
	41, 42, 54, 41, 42, 55, 41, 42, 
	56, 41, 42, 4, 41, 42, 58, 41, 
	4, 4, 5, 15, 17, 31, 34, 37, 
	38, 59, 60, 76, 84, 184, 59, 231, 
	4, 0, 37, 0, 61, 0, 62, 0, 
	63, 0, 64, 0, 65, 0, 66, 0, 
	67, 0, 69, 68, 69, 68, 69, 69, 
	4, 70, 4, 69, 68, 69, 71, 68, 
	69, 72, 68, 69, 73, 68, 69, 74, 
	68, 69, 75, 68, 69, 58, 68, 77, 
	0, 78, 0, 79, 0, 80, 0, 81, 
	0, 82, 0, 83, 0, 31, 0, 85, 
	0, 86, 0, 87, 0, 88, 0, 89, 
	0, 90, 137, 0, 91, 0, 92, 0, 
	93, 0, 94, 0, 95, 0, 96, 0, 
	98, 97, 98, 97, 98, 98, 4, 99, 
	113, 4, 114, 115, 117, 118, 126, 132, 
	117, 98, 97, 98, 100, 97, 98, 101, 
	97, 98, 102, 97, 98, 103, 97, 98, 
	104, 97, 98, 105, 97, 98, 106, 97, 
	98, 107, 97, 98, 108, 97, 98, 109, 
	97, 98, 110, 97, 98, 111, 97, 98, 
	112, 97, 98, 4, 97, 98, 58, 97, 
	98, 113, 97, 98, 116, 97, 98, 113, 
	97, 98, 114, 97, 98, 119, 97, 98, 
	120, 97, 98, 121, 97, 98, 122, 97, 
	98, 123, 97, 98, 124, 97, 98, 125, 
	97, 98, 113, 97, 98, 127, 97, 98, 
	128, 97, 98, 129, 97, 98, 130, 97, 
	98, 131, 97, 98, 58, 97, 98, 133, 
	97, 98, 134, 97, 98, 135, 97, 98, 
	136, 97, 98, 131, 97, 139, 138, 139, 
	138, 139, 139, 4, 140, 154, 4, 155, 
	156, 159, 160, 168, 179, 159, 139, 138, 
	139, 141, 138, 139, 142, 138, 139, 143, 
	138, 139, 144, 138, 139, 145, 138, 139, 
	146, 138, 139, 147, 138, 139, 148, 138, 
	139, 149, 138, 139, 150, 138, 139, 151, 
	138, 139, 152, 138, 139, 153, 138, 139, 
	4, 138, 139, 58, 138, 139, 154, 138, 
	139, 157, 158, 138, 139, 58, 138, 139, 
	154, 138, 139, 155, 138, 139, 161, 138, 
	139, 162, 138, 139, 163, 138, 139, 164, 
	138, 139, 165, 138, 139, 166, 138, 139, 
	167, 138, 139, 154, 138, 139, 169, 138, 
	139, 170, 138, 139, 171, 138, 139, 172, 
	138, 139, 173, 138, 139, 174, 58, 138, 
	139, 175, 138, 139, 176, 138, 139, 177, 
	138, 139, 178, 138, 139, 157, 138, 139, 
	180, 138, 139, 181, 138, 139, 182, 138, 
	139, 183, 138, 139, 157, 138, 185, 0, 
	186, 0, 187, 0, 188, 0, 189, 0, 
	190, 0, 192, 191, 192, 191, 192, 192, 
	4, 193, 4, 207, 209, 215, 226, 192, 
	191, 192, 194, 191, 192, 195, 191, 192, 
	196, 191, 192, 197, 191, 192, 198, 191, 
	192, 199, 191, 192, 200, 191, 192, 201, 
	191, 192, 202, 191, 192, 203, 191, 192, 
	204, 191, 192, 205, 191, 192, 206, 191, 
	192, 4, 191, 192, 208, 191, 192, 58, 
	191, 192, 210, 191, 192, 211, 191, 192, 
	212, 191, 192, 213, 191, 192, 214, 191, 
	192, 208, 191, 192, 216, 191, 192, 217, 
	191, 192, 218, 191, 192, 219, 191, 192, 
	220, 191, 192, 221, 58, 191, 192, 222, 
	191, 192, 223, 191, 192, 224, 191, 192, 
	225, 191, 192, 208, 191, 192, 227, 191, 
	192, 228, 191, 192, 229, 191, 192, 230, 
	191, 192, 208, 191, 231, 232, 231, 0, 
	236, 235, 234, 232, 235, 233, 0, 234, 
	232, 233, 0, 234, 233, 236, 235, 234, 
	232, 235, 233, 236, 236, 5, 15, 17, 
	31, 34, 37, 38, 59, 60, 76, 84, 
	184, 59, 231, 236, 0, 42, 57, 41, 
	42, 239, 41, 42, 57, 41, 42, 237, 
	41, 42, 242, 41, 42, 243, 41, 42, 
	244, 41, 42, 245, 41, 42, 246, 41, 
	42, 247, 41, 42, 248, 41, 42, 57, 
	41, 42, 250, 41, 42, 251, 41, 42, 
	252, 41, 42, 253, 41, 42, 254, 41, 
	42, 255, 58, 41, 42, 256, 41, 42, 
	257, 41, 42, 258, 41, 42, 259, 41, 
	42, 260, 41, 42, 58, 41, 42, 262, 
	41, 42, 263, 41, 42, 264, 41, 42, 
	265, 41, 42, 260, 41, 31, 0, 0, 
	0
};

static const unsigned char _lexer_trans_actions[] = {
	0, 54, 0, 5, 1, 0, 29, 1, 
	29, 29, 29, 29, 29, 29, 29, 29, 
	35, 0, 43, 0, 43, 0, 43, 54, 
	0, 5, 1, 0, 29, 1, 29, 29, 
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
	0, 43, 149, 126, 57, 110, 23, 0, 
	43, 43, 43, 43, 0, 27, 118, 27, 
	27, 51, 27, 0, 54, 0, 1, 0, 
	43, 0, 43, 0, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 72, 33, 
	84, 72, 84, 84, 84, 84, 84, 84, 
	84, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 15, 0, 54, 15, 0, 
	130, 31, 60, 57, 31, 63, 57, 63, 
	63, 63, 63, 63, 63, 63, 63, 66, 
	31, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	81, 84, 81, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 21, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 78, 33, 
	84, 78, 84, 84, 84, 84, 84, 84, 
	84, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 19, 0, 54, 19, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 19, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 144, 57, 54, 
	0, 54, 0, 75, 33, 84, 75, 84, 
	84, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	17, 0, 54, 17, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 17, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 17, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	69, 33, 69, 84, 84, 84, 84, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 13, 0, 54, 0, 0, 54, 13, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 13, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 0, 0, 43, 
	54, 37, 37, 87, 37, 37, 43, 0, 
	39, 0, 43, 0, 0, 54, 0, 0, 
	39, 0, 0, 54, 0, 93, 90, 41, 
	96, 90, 96, 96, 96, 96, 96, 96, 
	96, 96, 99, 0, 43, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 15, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 43, 0, 
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
	43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 267;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"

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
    
    
#line 781 "ext/gherkin_lexer_en_lol/gherkin_lexer_en_lol.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
    
#line 788 "ext/gherkin_lexer_en_lol/gherkin_lexer_en_lol.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
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
#line 1078 "ext/gherkin_lexer_en_lol/gherkin_lexer_en_lol.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"
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
#line 1141 "ext/gherkin_lexer_en_lol/gherkin_lexer_en_lol.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en_lol.c.rl"

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

void Init_gherkin_lexer_en_lol()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "En_lol", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

