
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_nl/gherkin_lexer_nl.c"
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
	91, 93, 95, 100, 107, 112, 115, 116, 
	117, 118, 119, 120, 121, 122, 123, 124, 
	125, 126, 127, 128, 129, 130, 131, 132, 
	133, 148, 150, 152, 154, 156, 158, 160, 
	162, 164, 166, 168, 170, 172, 174, 176, 
	178, 196, 197, 198, 199, 200, 201, 202, 
	203, 204, 205, 206, 207, 208, 209, 210, 
	211, 212, 213, 214, 215, 226, 228, 230, 
	232, 234, 236, 238, 240, 242, 244, 246, 
	248, 250, 252, 254, 257, 259, 261, 263, 
	265, 267, 269, 271, 273, 275, 277, 279, 
	281, 283, 285, 287, 289, 291, 293, 295, 
	297, 299, 301, 303, 305, 307, 309, 311, 
	313, 315, 317, 319, 321, 323, 325, 327, 
	329, 331, 333, 335, 337, 339, 341, 343, 
	345, 347, 349, 351, 353, 355, 356, 357, 
	358, 359, 360, 361, 362, 363, 365, 366, 
	367, 368, 369, 370, 371, 372, 373, 374, 
	389, 391, 393, 395, 397, 399, 401, 403, 
	405, 407, 409, 411, 413, 415, 417, 419, 
	423, 425, 427, 429, 431, 433, 435, 437, 
	439, 441, 443, 445, 447, 449, 451, 453, 
	455, 457, 459, 461, 463, 465, 467, 469, 
	471, 473, 475, 477, 479, 481, 483, 485, 
	487, 489, 491, 493, 495, 497, 499, 501, 
	503, 505, 507, 509, 511, 513, 515, 517, 
	519, 521, 523, 526, 528, 530, 531, 532, 
	533, 534, 535, 536, 537, 538, 539, 540, 
	541, 542, 543, 544, 545, 552, 554, 556, 
	558, 560, 562, 564, 566, 568, 570, 572, 
	574, 576, 578, 580, 582, 586, 592, 595, 
	597, 603, 621, 623, 625, 627, 629, 631, 
	633, 635, 637, 639, 641, 643, 645, 647, 
	649, 651, 653, 655, 657, 659, 661, 663, 
	665, 667, 669, 671, 673, 675, 678, 680, 
	682, 684, 686, 688, 690, 692, 694, 695, 
	696, 697, 698, 699, 700, 701, 702, 703, 
	704, 705, 706, 721, 723, 725, 727, 729, 
	731, 733, 735, 737, 739, 741, 743, 745, 
	747, 749, 751, 754, 756, 758, 760, 762, 
	764, 766, 768, 770, 772, 774, 776, 778, 
	780, 782, 784, 786, 788, 790, 792, 794, 
	796, 798, 800, 802, 804, 806, 808, 810, 
	812, 814, 816, 818, 820, 822, 824, 826, 
	828, 830, 832, 834, 836, 839, 841, 843, 
	844
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 68, 69, 70, 71, 77, 83, 86, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 68, 69, 70, 
	71, 77, 83, 86, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	98, 99, 108, 115, 116, 114, 97, 99, 
	116, 32, 83, 99, 101, 110, 97, 114, 
	105, 111, 58, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 68, 69, 70, 71, 
	77, 83, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 69, 70, 71, 77, 83, 
	86, 124, 9, 13, 97, 110, 117, 110, 
	99, 116, 105, 111, 110, 97, 108, 105, 
	116, 101, 105, 116, 58, 10, 10, 10, 
	32, 35, 37, 64, 65, 70, 83, 86, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 98, 
	99, 10, 115, 10, 116, 10, 114, 10, 
	97, 10, 99, 10, 116, 10, 32, 10, 
	83, 10, 99, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	58, 10, 104, 10, 116, 10, 101, 10, 
	114, 10, 103, 10, 114, 10, 111, 10, 
	110, 10, 100, 10, 117, 10, 110, 10, 
	99, 10, 116, 10, 105, 10, 111, 10, 
	110, 10, 97, 10, 108, 10, 105, 10, 
	116, 10, 101, 10, 105, 10, 116, 10, 
	111, 10, 111, 10, 114, 10, 98, 10, 
	101, 10, 101, 10, 108, 10, 100, 10, 
	101, 10, 110, 101, 103, 101, 118, 101, 
	97, 97, 114, 99, 116, 101, 110, 97, 
	114, 105, 111, 58, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 68, 69, 70, 
	71, 77, 83, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 98, 99, 108, 10, 
	115, 10, 116, 10, 114, 10, 97, 10, 
	99, 10, 116, 10, 32, 10, 83, 10, 
	99, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 111, 10, 58, 10, 
	104, 10, 116, 10, 101, 10, 114, 10, 
	103, 10, 114, 10, 111, 10, 110, 10, 
	100, 10, 115, 10, 97, 10, 110, 10, 
	117, 10, 110, 10, 99, 10, 116, 10, 
	105, 10, 111, 10, 110, 10, 97, 10, 
	108, 10, 105, 10, 116, 10, 101, 10, 
	105, 10, 116, 10, 101, 10, 103, 10, 
	101, 10, 118, 10, 101, 10, 97, 10, 
	97, 10, 114, 10, 99, 116, 10, 101, 
	10, 108, 101, 108, 111, 111, 114, 98, 
	101, 101, 108, 100, 101, 110, 58, 10, 
	10, 10, 32, 35, 70, 124, 9, 13, 
	10, 117, 10, 110, 10, 99, 10, 116, 
	10, 105, 10, 111, 10, 110, 10, 97, 
	10, 108, 10, 105, 10, 116, 10, 101, 
	10, 105, 10, 116, 10, 58, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, 10, 32, 34, 35, 37, 
	42, 64, 65, 68, 69, 70, 71, 77, 
	83, 86, 124, 9, 13, 10, 108, 10, 
	115, 10, 97, 10, 110, 10, 117, 10, 
	110, 10, 99, 10, 116, 10, 105, 10, 
	111, 10, 110, 10, 97, 10, 108, 10, 
	105, 10, 116, 10, 101, 10, 105, 10, 
	116, 10, 58, 10, 101, 10, 103, 10, 
	101, 10, 118, 10, 101, 10, 97, 10, 
	97, 10, 114, 10, 99, 116, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 111, 10, 101, 10, 108, 104, 116, 
	101, 114, 103, 114, 111, 110, 100, 58, 
	10, 10, 10, 32, 35, 37, 42, 64, 
	65, 68, 69, 70, 71, 77, 83, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	98, 108, 10, 115, 10, 116, 10, 114, 
	10, 97, 10, 99, 10, 116, 10, 32, 
	10, 83, 10, 99, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 111, 
	10, 58, 10, 115, 10, 97, 10, 110, 
	10, 117, 10, 110, 10, 99, 10, 116, 
	10, 105, 10, 111, 10, 110, 10, 97, 
	10, 108, 10, 105, 10, 116, 10, 101, 
	10, 105, 10, 116, 10, 101, 10, 103, 
	10, 101, 10, 118, 10, 101, 10, 97, 
	10, 97, 10, 114, 10, 99, 116, 10, 
	101, 10, 108, 115, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 3, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	13, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	16, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 9, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 13, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 4, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 5, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 3, 2, 
	4, 16, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 1, 
	0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 0, 0, 
	1, 1, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 141, 143, 
	145, 147, 149, 151, 153, 155, 157, 159, 
	161, 163, 165, 167, 169, 171, 173, 175, 
	177, 192, 195, 198, 201, 204, 207, 210, 
	213, 216, 219, 222, 225, 228, 231, 234, 
	237, 255, 257, 259, 261, 263, 265, 267, 
	269, 271, 273, 275, 277, 279, 281, 283, 
	285, 287, 289, 291, 293, 304, 307, 310, 
	313, 316, 319, 322, 325, 328, 331, 334, 
	337, 340, 343, 346, 350, 353, 356, 359, 
	362, 365, 368, 371, 374, 377, 380, 383, 
	386, 389, 392, 395, 398, 401, 404, 407, 
	410, 413, 416, 419, 422, 425, 428, 431, 
	434, 437, 440, 443, 446, 449, 452, 455, 
	458, 461, 464, 467, 470, 473, 476, 479, 
	482, 485, 488, 491, 494, 497, 499, 501, 
	503, 505, 507, 509, 511, 513, 516, 518, 
	520, 522, 524, 526, 528, 530, 532, 534, 
	549, 552, 555, 558, 561, 564, 567, 570, 
	573, 576, 579, 582, 585, 588, 591, 594, 
	599, 602, 605, 608, 611, 614, 617, 620, 
	623, 626, 629, 632, 635, 638, 641, 644, 
	647, 650, 653, 656, 659, 662, 665, 668, 
	671, 674, 677, 680, 683, 686, 689, 692, 
	695, 698, 701, 704, 707, 710, 713, 716, 
	719, 722, 725, 728, 731, 734, 737, 740, 
	743, 746, 749, 753, 756, 759, 761, 763, 
	765, 767, 769, 771, 773, 775, 777, 779, 
	781, 783, 785, 787, 789, 796, 799, 802, 
	805, 808, 811, 814, 817, 820, 823, 826, 
	829, 832, 835, 838, 841, 845, 851, 855, 
	858, 864, 882, 885, 888, 891, 894, 897, 
	900, 903, 906, 909, 912, 915, 918, 921, 
	924, 927, 930, 933, 936, 939, 942, 945, 
	948, 951, 954, 957, 960, 963, 967, 970, 
	973, 976, 979, 982, 985, 988, 991, 993, 
	995, 997, 999, 1001, 1003, 1005, 1007, 1009, 
	1011, 1013, 1015, 1030, 1033, 1036, 1039, 1042, 
	1045, 1048, 1051, 1054, 1057, 1060, 1063, 1066, 
	1069, 1072, 1075, 1079, 1082, 1085, 1088, 1091, 
	1094, 1097, 1100, 1103, 1106, 1109, 1112, 1115, 
	1118, 1121, 1124, 1127, 1130, 1133, 1136, 1139, 
	1142, 1145, 1148, 1151, 1154, 1157, 1160, 1163, 
	1166, 1169, 1172, 1175, 1178, 1181, 1184, 1187, 
	1190, 1193, 1196, 1199, 1202, 1206, 1209, 1212, 
	1214
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 73, 74, 75, 157, 162, 165, 247, 
	276, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 73, 
	74, 75, 157, 162, 165, 247, 276, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 392, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 318, 391, 0, 39, 0, 40, 
	0, 41, 0, 42, 0, 43, 0, 44, 
	0, 45, 0, 46, 0, 47, 0, 48, 
	0, 49, 0, 50, 0, 51, 0, 52, 
	0, 53, 0, 54, 0, 56, 55, 56, 
	55, 56, 56, 4, 57, 71, 4, 282, 
	284, 285, 286, 301, 306, 309, 56, 55, 
	56, 58, 55, 56, 59, 55, 56, 60, 
	55, 56, 61, 55, 56, 62, 55, 56, 
	63, 55, 56, 64, 55, 56, 65, 55, 
	56, 66, 55, 56, 67, 55, 56, 68, 
	55, 56, 69, 55, 56, 70, 55, 56, 
	4, 55, 56, 72, 55, 4, 4, 5, 
	15, 17, 31, 34, 37, 73, 74, 75, 
	157, 162, 165, 247, 276, 4, 0, 74, 
	0, 31, 0, 76, 0, 77, 0, 78, 
	0, 79, 0, 80, 0, 81, 0, 82, 
	0, 83, 0, 84, 0, 85, 0, 86, 
	0, 87, 0, 88, 0, 89, 0, 90, 
	0, 92, 91, 92, 91, 92, 92, 4, 
	93, 4, 107, 133, 116, 147, 92, 91, 
	92, 94, 91, 92, 95, 91, 92, 96, 
	91, 92, 97, 91, 92, 98, 91, 92, 
	99, 91, 92, 100, 91, 92, 101, 91, 
	92, 102, 91, 92, 103, 91, 92, 104, 
	91, 92, 105, 91, 92, 106, 91, 92, 
	4, 91, 92, 108, 124, 91, 92, 109, 
	91, 92, 110, 91, 92, 111, 91, 92, 
	112, 91, 92, 113, 91, 92, 114, 91, 
	92, 115, 91, 92, 116, 91, 92, 117, 
	91, 92, 118, 91, 92, 119, 91, 92, 
	120, 91, 92, 121, 91, 92, 122, 91, 
	92, 123, 91, 92, 72, 91, 92, 125, 
	91, 92, 126, 91, 92, 127, 91, 92, 
	128, 91, 92, 129, 91, 92, 130, 91, 
	92, 131, 91, 92, 132, 91, 92, 123, 
	91, 92, 134, 91, 92, 135, 91, 92, 
	136, 91, 92, 137, 91, 92, 138, 91, 
	92, 139, 91, 92, 140, 91, 92, 141, 
	91, 92, 142, 91, 92, 143, 91, 92, 
	144, 91, 92, 145, 91, 92, 146, 91, 
	92, 123, 91, 92, 148, 91, 92, 149, 
	91, 92, 150, 91, 92, 151, 91, 92, 
	152, 91, 92, 153, 91, 92, 154, 91, 
	92, 155, 91, 92, 156, 91, 92, 123, 
	91, 158, 0, 159, 0, 160, 0, 161, 
	0, 74, 0, 163, 0, 164, 0, 31, 
	0, 166, 245, 0, 167, 0, 168, 0, 
	169, 0, 170, 0, 171, 0, 172, 0, 
	173, 0, 175, 174, 175, 174, 175, 175, 
	4, 176, 190, 4, 191, 218, 219, 220, 
	234, 239, 242, 175, 174, 175, 177, 174, 
	175, 178, 174, 175, 179, 174, 175, 180, 
	174, 175, 181, 174, 175, 182, 174, 175, 
	183, 174, 175, 184, 174, 175, 185, 174, 
	175, 186, 174, 175, 187, 174, 175, 188, 
	174, 175, 189, 174, 175, 4, 174, 175, 
	72, 174, 175, 192, 208, 217, 174, 175, 
	193, 174, 175, 194, 174, 175, 195, 174, 
	175, 196, 174, 175, 197, 174, 175, 198, 
	174, 175, 199, 174, 175, 200, 174, 175, 
	201, 174, 175, 202, 174, 175, 203, 174, 
	175, 204, 174, 175, 205, 174, 175, 206, 
	174, 175, 207, 174, 175, 72, 174, 175, 
	209, 174, 175, 210, 174, 175, 211, 174, 
	175, 212, 174, 175, 213, 174, 175, 214, 
	174, 175, 215, 174, 175, 216, 174, 175, 
	207, 174, 175, 190, 174, 175, 219, 174, 
	175, 190, 174, 175, 221, 174, 175, 222, 
	174, 175, 223, 174, 175, 224, 174, 175, 
	225, 174, 175, 226, 174, 175, 227, 174, 
	175, 228, 174, 175, 229, 174, 175, 230, 
	174, 175, 231, 174, 175, 232, 174, 175, 
	233, 174, 175, 207, 174, 175, 235, 174, 
	175, 236, 174, 175, 237, 174, 175, 238, 
	174, 175, 219, 174, 175, 240, 174, 175, 
	241, 174, 175, 190, 174, 175, 201, 243, 
	174, 175, 244, 174, 175, 190, 174, 246, 
	0, 31, 0, 248, 0, 249, 0, 250, 
	0, 251, 0, 252, 0, 253, 0, 254, 
	0, 255, 0, 256, 0, 257, 0, 258, 
	0, 260, 259, 260, 259, 260, 260, 4, 
	261, 4, 260, 259, 260, 262, 259, 260, 
	263, 259, 260, 264, 259, 260, 265, 259, 
	260, 266, 259, 260, 267, 259, 260, 268, 
	259, 260, 269, 259, 260, 270, 259, 260, 
	271, 259, 260, 272, 259, 260, 273, 259, 
	260, 274, 259, 260, 275, 259, 260, 72, 
	259, 276, 277, 276, 0, 281, 280, 279, 
	277, 280, 278, 0, 279, 277, 278, 0, 
	279, 278, 281, 280, 279, 277, 280, 278, 
	281, 281, 5, 15, 17, 31, 34, 37, 
	73, 74, 75, 157, 162, 165, 247, 276, 
	281, 0, 56, 283, 55, 56, 71, 55, 
	56, 285, 55, 56, 71, 55, 56, 287, 
	55, 56, 288, 55, 56, 289, 55, 56, 
	290, 55, 56, 291, 55, 56, 292, 55, 
	56, 293, 55, 56, 294, 55, 56, 295, 
	55, 56, 296, 55, 56, 297, 55, 56, 
	298, 55, 56, 299, 55, 56, 300, 55, 
	56, 72, 55, 56, 302, 55, 56, 303, 
	55, 56, 304, 55, 56, 305, 55, 56, 
	285, 55, 56, 307, 55, 56, 308, 55, 
	56, 71, 55, 56, 310, 316, 55, 56, 
	311, 55, 56, 312, 55, 56, 313, 55, 
	56, 314, 55, 56, 315, 55, 56, 300, 
	55, 56, 317, 55, 56, 71, 55, 319, 
	0, 320, 0, 321, 0, 322, 0, 323, 
	0, 324, 0, 325, 0, 326, 0, 327, 
	0, 328, 0, 330, 329, 330, 329, 330, 
	330, 4, 331, 345, 4, 346, 364, 365, 
	366, 380, 385, 388, 330, 329, 330, 332, 
	329, 330, 333, 329, 330, 334, 329, 330, 
	335, 329, 330, 336, 329, 330, 337, 329, 
	330, 338, 329, 330, 339, 329, 330, 340, 
	329, 330, 341, 329, 330, 342, 329, 330, 
	343, 329, 330, 344, 329, 330, 4, 329, 
	330, 72, 329, 330, 347, 363, 329, 330, 
	348, 329, 330, 349, 329, 330, 350, 329, 
	330, 351, 329, 330, 352, 329, 330, 353, 
	329, 330, 354, 329, 330, 355, 329, 330, 
	356, 329, 330, 357, 329, 330, 358, 329, 
	330, 359, 329, 330, 360, 329, 330, 361, 
	329, 330, 362, 329, 330, 72, 329, 330, 
	345, 329, 330, 365, 329, 330, 345, 329, 
	330, 367, 329, 330, 368, 329, 330, 369, 
	329, 330, 370, 329, 330, 371, 329, 330, 
	372, 329, 330, 373, 329, 330, 374, 329, 
	330, 375, 329, 330, 376, 329, 330, 377, 
	329, 330, 378, 329, 330, 379, 329, 330, 
	362, 329, 330, 381, 329, 330, 382, 329, 
	330, 383, 329, 330, 384, 329, 330, 365, 
	329, 330, 386, 329, 330, 387, 329, 330, 
	345, 329, 330, 356, 389, 329, 330, 390, 
	329, 330, 345, 329, 31, 0, 0, 0
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
	43, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 54, 0, 78, 33, 84, 78, 84, 
	84, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	19, 0, 54, 19, 0, 130, 31, 60, 
	57, 31, 63, 57, 63, 63, 63, 63, 
	63, 63, 63, 63, 66, 31, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 69, 
	33, 69, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	13, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 13, 0, 54, 0, 
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
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	75, 33, 84, 75, 84, 84, 84, 84, 
	84, 84, 84, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 17, 0, 54, 
	17, 0, 54, 0, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 17, 0, 54, 
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
	0, 54, 0, 0, 54, 0, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 81, 
	84, 81, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 21, 
	0, 0, 0, 0, 43, 54, 37, 37, 
	87, 37, 37, 43, 0, 39, 0, 43, 
	0, 0, 54, 0, 0, 39, 0, 0, 
	54, 0, 93, 90, 41, 96, 90, 96, 
	96, 96, 96, 96, 96, 96, 96, 99, 
	0, 43, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 19, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 72, 33, 84, 72, 84, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 15, 0, 
	54, 15, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 15, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 43, 0, 0
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
	43
};

static const int lexer_start = 1;
static const int lexer_first_final = 392;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"

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
    
    
#line 972 "ext/gherkin_lexer_nl/gherkin_lexer_nl.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
    
#line 979 "ext/gherkin_lexer_nl/gherkin_lexer_nl.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
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
#line 1269 "ext/gherkin_lexer_nl/gherkin_lexer_nl.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"
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
#line 1332 "ext/gherkin_lexer_nl/gherkin_lexer_nl.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/nl.c.rl"

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

void Init_gherkin_lexer_nl()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Nl", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

