
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_en/gherkin_lexer_en.c"
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
	91, 93, 95, 100, 107, 112, 114, 115, 
	116, 117, 118, 119, 120, 121, 122, 134, 
	136, 138, 140, 142, 144, 146, 148, 150, 
	152, 154, 156, 158, 160, 162, 164, 166, 
	168, 170, 172, 174, 176, 194, 196, 197, 
	198, 199, 200, 201, 202, 203, 204, 205, 
	206, 207, 222, 224, 226, 228, 230, 232, 
	234, 236, 238, 240, 242, 244, 246, 248, 
	250, 252, 255, 257, 259, 261, 263, 265, 
	267, 269, 271, 274, 276, 278, 280, 282, 
	284, 286, 288, 290, 292, 294, 296, 298, 
	300, 302, 304, 306, 308, 310, 312, 314, 
	316, 318, 320, 322, 324, 326, 328, 331, 
	334, 336, 338, 340, 342, 344, 346, 348, 
	350, 352, 354, 356, 358, 360, 361, 362, 
	363, 364, 365, 366, 367, 368, 369, 370, 
	371, 372, 373, 374, 375, 376, 377, 378, 
	379, 380, 389, 391, 393, 395, 397, 399, 
	401, 403, 405, 407, 409, 411, 413, 415, 
	417, 419, 421, 423, 425, 427, 429, 431, 
	433, 435, 437, 439, 440, 441, 442, 443, 
	444, 445, 446, 447, 448, 449, 450, 451, 
	452, 453, 454, 455, 456, 459, 461, 462, 
	463, 464, 465, 466, 467, 468, 469, 470, 
	485, 487, 489, 491, 493, 495, 497, 499, 
	501, 503, 505, 507, 509, 511, 513, 515, 
	518, 520, 522, 524, 526, 528, 530, 532, 
	534, 537, 539, 541, 543, 545, 547, 549, 
	551, 553, 555, 557, 559, 561, 563, 565, 
	567, 569, 571, 573, 575, 577, 579, 581, 
	583, 585, 587, 589, 591, 593, 594, 595, 
	596, 597, 598, 599, 600, 601, 616, 618, 
	620, 622, 624, 626, 628, 630, 632, 634, 
	636, 638, 640, 642, 644, 646, 649, 651, 
	653, 655, 657, 659, 661, 663, 666, 668, 
	670, 672, 674, 676, 678, 680, 682, 685, 
	687, 689, 691, 693, 695, 697, 699, 701, 
	703, 705, 707, 709, 711, 713, 715, 717, 
	719, 721, 723, 725, 727, 729, 731, 733, 
	735, 737, 740, 743, 745, 747, 749, 751, 
	753, 755, 757, 759, 761, 763, 765, 767, 
	768, 772, 778, 781, 783, 789, 807, 810, 
	812, 814, 816, 818, 820, 822, 824, 826, 
	828, 830, 832, 834, 836, 838, 840, 842, 
	844, 846, 848, 850, 852, 854, 856, 858, 
	860, 862, 864, 866, 868, 870, 872, 874, 
	876, 878, 880, 882, 884, 886, 890, 893, 
	895, 897, 899, 901, 903, 905, 907, 909, 
	911, 913, 915, 916
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 69, 70, 71, 83, 84, 87, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 69, 70, 
	71, 83, 84, 87, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	98, 110, 105, 108, 105, 116, 121, 58, 
	10, 10, 10, 32, 35, 37, 64, 65, 
	66, 69, 70, 83, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 98, 10, 105, 10, 108, 
	10, 105, 10, 116, 10, 121, 10, 58, 
	10, 32, 34, 35, 37, 42, 64, 65, 
	66, 69, 70, 71, 83, 84, 87, 124, 
	9, 13, 97, 117, 99, 107, 103, 114, 
	111, 117, 110, 100, 58, 10, 10, 10, 
	32, 35, 37, 42, 64, 65, 66, 70, 
	71, 83, 84, 87, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, 10, 98, 110, 10, 
	105, 10, 108, 10, 105, 10, 116, 10, 
	121, 10, 58, 10, 100, 10, 117, 10, 
	115, 116, 10, 105, 10, 110, 10, 101, 
	10, 115, 10, 115, 10, 32, 10, 78, 
	10, 101, 10, 101, 10, 100, 10, 101, 
	10, 97, 10, 116, 10, 117, 10, 114, 
	10, 101, 10, 105, 10, 118, 10, 101, 
	10, 110, 10, 99, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 111, 
	10, 32, 58, 10, 79, 84, 10, 117, 
	10, 116, 10, 108, 10, 105, 10, 110, 
	10, 101, 10, 109, 10, 112, 10, 108, 
	10, 97, 10, 116, 10, 104, 115, 116, 
	105, 110, 101, 115, 115, 32, 78, 101, 
	101, 100, 120, 97, 109, 112, 108, 101, 
	115, 58, 10, 10, 10, 32, 35, 65, 
	66, 70, 124, 9, 13, 10, 98, 10, 
	105, 10, 108, 10, 105, 10, 116, 10, 
	121, 10, 58, 10, 117, 10, 115, 10, 
	105, 10, 110, 10, 101, 10, 115, 10, 
	115, 10, 32, 10, 78, 10, 101, 10, 
	101, 10, 100, 10, 101, 10, 97, 10, 
	116, 10, 117, 10, 114, 10, 101, 101, 
	97, 116, 117, 114, 101, 105, 118, 101, 
	110, 99, 101, 110, 97, 114, 105, 111, 
	32, 58, 115, 79, 84, 117, 116, 108, 
	105, 110, 101, 58, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 66, 70, 71, 
	83, 84, 87, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 98, 110, 10, 105, 
	10, 108, 10, 105, 10, 116, 10, 121, 
	10, 58, 10, 100, 10, 117, 10, 115, 
	116, 10, 105, 10, 110, 10, 101, 10, 
	115, 10, 115, 10, 32, 10, 78, 10, 
	101, 10, 101, 10, 100, 10, 101, 10, 
	97, 10, 116, 10, 117, 10, 114, 10, 
	101, 10, 105, 10, 118, 10, 101, 10, 
	110, 10, 99, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	104, 101, 109, 112, 108, 97, 116, 10, 
	10, 10, 32, 35, 37, 42, 64, 65, 
	66, 70, 71, 83, 84, 87, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 98, 
	110, 10, 105, 10, 108, 10, 105, 10, 
	116, 10, 121, 10, 58, 10, 100, 10, 
	97, 117, 10, 99, 10, 107, 10, 103, 
	10, 114, 10, 111, 10, 117, 10, 110, 
	10, 100, 10, 115, 116, 10, 105, 10, 
	110, 10, 101, 10, 115, 10, 115, 10, 
	32, 10, 78, 10, 101, 10, 101, 10, 
	101, 10, 97, 10, 116, 10, 117, 10, 
	114, 10, 101, 10, 105, 10, 118, 10, 
	101, 10, 110, 10, 99, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 32, 58, 10, 79, 84, 10, 
	117, 10, 116, 10, 108, 10, 105, 10, 
	110, 10, 101, 10, 109, 10, 112, 10, 
	108, 10, 97, 10, 116, 10, 104, 104, 
	32, 124, 9, 13, 10, 32, 92, 124, 
	9, 13, 10, 92, 124, 10, 92, 10, 
	32, 92, 124, 9, 13, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 69, 70, 
	71, 83, 84, 87, 124, 9, 13, 10, 
	97, 117, 10, 99, 10, 107, 10, 103, 
	10, 114, 10, 111, 10, 117, 10, 110, 
	10, 100, 10, 115, 10, 105, 10, 110, 
	10, 101, 10, 115, 10, 115, 10, 32, 
	10, 78, 10, 101, 10, 101, 10, 120, 
	10, 97, 10, 109, 10, 112, 10, 108, 
	10, 101, 10, 115, 10, 101, 10, 97, 
	10, 116, 10, 117, 10, 114, 10, 101, 
	10, 99, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 111, 10, 32, 
	58, 115, 10, 79, 84, 10, 117, 10, 
	116, 10, 108, 10, 105, 10, 110, 10, 
	101, 10, 109, 10, 112, 10, 108, 10, 
	97, 10, 116, 100, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 10, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 16, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 13, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 7, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 3, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 13, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 13, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	2, 4, 3, 2, 4, 16, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
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
	1, 1, 0, 0, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	114, 117, 120, 125, 132, 137, 140, 142, 
	144, 146, 148, 150, 152, 154, 156, 168, 
	171, 174, 177, 180, 183, 186, 189, 192, 
	195, 198, 201, 204, 207, 210, 213, 216, 
	219, 222, 225, 228, 231, 249, 252, 254, 
	256, 258, 260, 262, 264, 266, 268, 270, 
	272, 274, 289, 292, 295, 298, 301, 304, 
	307, 310, 313, 316, 319, 322, 325, 328, 
	331, 334, 338, 341, 344, 347, 350, 353, 
	356, 359, 362, 366, 369, 372, 375, 378, 
	381, 384, 387, 390, 393, 396, 399, 402, 
	405, 408, 411, 414, 417, 420, 423, 426, 
	429, 432, 435, 438, 441, 444, 447, 451, 
	455, 458, 461, 464, 467, 470, 473, 476, 
	479, 482, 485, 488, 491, 494, 496, 498, 
	500, 502, 504, 506, 508, 510, 512, 514, 
	516, 518, 520, 522, 524, 526, 528, 530, 
	532, 534, 543, 546, 549, 552, 555, 558, 
	561, 564, 567, 570, 573, 576, 579, 582, 
	585, 588, 591, 594, 597, 600, 603, 606, 
	609, 612, 615, 618, 620, 622, 624, 626, 
	628, 630, 632, 634, 636, 638, 640, 642, 
	644, 646, 648, 650, 652, 656, 659, 661, 
	663, 665, 667, 669, 671, 673, 675, 677, 
	692, 695, 698, 701, 704, 707, 710, 713, 
	716, 719, 722, 725, 728, 731, 734, 737, 
	741, 744, 747, 750, 753, 756, 759, 762, 
	765, 769, 772, 775, 778, 781, 784, 787, 
	790, 793, 796, 799, 802, 805, 808, 811, 
	814, 817, 820, 823, 826, 829, 832, 835, 
	838, 841, 844, 847, 850, 853, 855, 857, 
	859, 861, 863, 865, 867, 869, 884, 887, 
	890, 893, 896, 899, 902, 905, 908, 911, 
	914, 917, 920, 923, 926, 929, 933, 936, 
	939, 942, 945, 948, 951, 954, 958, 961, 
	964, 967, 970, 973, 976, 979, 982, 986, 
	989, 992, 995, 998, 1001, 1004, 1007, 1010, 
	1013, 1016, 1019, 1022, 1025, 1028, 1031, 1034, 
	1037, 1040, 1043, 1046, 1049, 1052, 1055, 1058, 
	1061, 1064, 1068, 1072, 1075, 1078, 1081, 1084, 
	1087, 1090, 1093, 1096, 1099, 1102, 1105, 1108, 
	1110, 1114, 1120, 1124, 1127, 1133, 1151, 1155, 
	1158, 1161, 1164, 1167, 1170, 1173, 1176, 1179, 
	1182, 1185, 1188, 1191, 1194, 1197, 1200, 1203, 
	1206, 1209, 1212, 1215, 1218, 1221, 1224, 1227, 
	1230, 1233, 1236, 1239, 1242, 1245, 1248, 1251, 
	1254, 1257, 1260, 1263, 1266, 1269, 1274, 1278, 
	1281, 1284, 1287, 1290, 1293, 1296, 1299, 1302, 
	1305, 1308, 1311, 1313
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 69, 159, 195, 201, 205, 359, 359, 
	360, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 69, 
	159, 195, 201, 205, 359, 359, 360, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 419, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 418, 0, 39, 0, 40, 0, 
	41, 0, 42, 0, 43, 0, 44, 0, 
	46, 45, 46, 45, 46, 46, 4, 47, 
	4, 61, 366, 385, 392, 398, 46, 45, 
	46, 48, 45, 46, 49, 45, 46, 50, 
	45, 46, 51, 45, 46, 52, 45, 46, 
	53, 45, 46, 54, 45, 46, 55, 45, 
	46, 56, 45, 46, 57, 45, 46, 58, 
	45, 46, 59, 45, 46, 60, 45, 46, 
	4, 45, 46, 62, 45, 46, 63, 45, 
	46, 64, 45, 46, 65, 45, 46, 66, 
	45, 46, 67, 45, 46, 68, 45, 4, 
	4, 5, 15, 17, 31, 34, 37, 69, 
	159, 195, 201, 205, 359, 359, 360, 4, 
	0, 70, 148, 0, 71, 0, 72, 0, 
	73, 0, 74, 0, 75, 0, 76, 0, 
	77, 0, 78, 0, 79, 0, 81, 80, 
	81, 80, 81, 81, 4, 82, 96, 4, 
	97, 105, 117, 123, 127, 147, 147, 81, 
	80, 81, 83, 80, 81, 84, 80, 81, 
	85, 80, 81, 86, 80, 81, 87, 80, 
	81, 88, 80, 81, 89, 80, 81, 90, 
	80, 81, 91, 80, 81, 92, 80, 81, 
	93, 80, 81, 94, 80, 81, 95, 80, 
	81, 4, 80, 81, 68, 80, 81, 98, 
	104, 80, 81, 99, 80, 81, 100, 80, 
	81, 101, 80, 81, 102, 80, 81, 103, 
	80, 81, 68, 80, 81, 96, 80, 81, 
	106, 80, 81, 107, 96, 80, 81, 108, 
	80, 81, 109, 80, 81, 110, 80, 81, 
	111, 80, 81, 112, 80, 81, 113, 80, 
	81, 114, 80, 81, 115, 80, 81, 116, 
	80, 81, 103, 80, 81, 118, 80, 81, 
	119, 80, 81, 120, 80, 81, 121, 80, 
	81, 122, 80, 81, 103, 80, 81, 124, 
	80, 81, 125, 80, 81, 126, 80, 81, 
	96, 80, 81, 128, 80, 81, 129, 80, 
	81, 130, 80, 81, 131, 80, 81, 132, 
	80, 81, 133, 80, 81, 134, 80, 81, 
	135, 68, 80, 81, 136, 141, 80, 81, 
	137, 80, 81, 138, 80, 81, 139, 80, 
	81, 140, 80, 81, 122, 80, 81, 142, 
	80, 81, 143, 80, 81, 144, 80, 81, 
	145, 80, 81, 146, 80, 81, 122, 80, 
	81, 125, 80, 149, 31, 0, 150, 0, 
	151, 0, 152, 0, 153, 0, 154, 0, 
	155, 0, 156, 0, 157, 0, 158, 0, 
	43, 0, 160, 0, 161, 0, 162, 0, 
	163, 0, 164, 0, 165, 0, 166, 0, 
	167, 0, 169, 168, 169, 168, 169, 169, 
	4, 170, 177, 189, 4, 169, 168, 169, 
	171, 168, 169, 172, 168, 169, 173, 168, 
	169, 174, 168, 169, 175, 168, 169, 176, 
	168, 169, 68, 168, 169, 178, 168, 169, 
	179, 168, 169, 180, 168, 169, 181, 168, 
	169, 182, 168, 169, 183, 168, 169, 184, 
	168, 169, 185, 168, 169, 186, 168, 169, 
	187, 168, 169, 188, 168, 169, 176, 168, 
	169, 190, 168, 169, 191, 168, 169, 192, 
	168, 169, 193, 168, 169, 194, 168, 169, 
	176, 168, 196, 0, 197, 0, 198, 0, 
	199, 0, 200, 0, 43, 0, 202, 0, 
	203, 0, 204, 0, 31, 0, 206, 0, 
	207, 0, 208, 0, 209, 0, 210, 0, 
	211, 0, 212, 0, 213, 283, 166, 0, 
	214, 277, 0, 215, 0, 216, 0, 217, 
	0, 218, 0, 219, 0, 220, 0, 221, 
	0, 223, 222, 223, 222, 223, 223, 4, 
	224, 238, 4, 239, 247, 259, 265, 269, 
	276, 276, 223, 222, 223, 225, 222, 223, 
	226, 222, 223, 227, 222, 223, 228, 222, 
	223, 229, 222, 223, 230, 222, 223, 231, 
	222, 223, 232, 222, 223, 233, 222, 223, 
	234, 222, 223, 235, 222, 223, 236, 222, 
	223, 237, 222, 223, 4, 222, 223, 68, 
	222, 223, 240, 246, 222, 223, 241, 222, 
	223, 242, 222, 223, 243, 222, 223, 244, 
	222, 223, 245, 222, 223, 68, 222, 223, 
	238, 222, 223, 248, 222, 223, 249, 238, 
	222, 223, 250, 222, 223, 251, 222, 223, 
	252, 222, 223, 253, 222, 223, 254, 222, 
	223, 255, 222, 223, 256, 222, 223, 257, 
	222, 223, 258, 222, 223, 245, 222, 223, 
	260, 222, 223, 261, 222, 223, 262, 222, 
	223, 263, 222, 223, 264, 222, 223, 245, 
	222, 223, 266, 222, 223, 267, 222, 223, 
	268, 222, 223, 238, 222, 223, 270, 222, 
	223, 271, 222, 223, 272, 222, 223, 273, 
	222, 223, 274, 222, 223, 275, 222, 223, 
	245, 222, 223, 267, 222, 278, 0, 279, 
	0, 280, 0, 281, 0, 282, 0, 219, 
	0, 285, 284, 285, 284, 285, 285, 4, 
	286, 300, 4, 301, 309, 328, 334, 338, 
	358, 358, 285, 284, 285, 287, 284, 285, 
	288, 284, 285, 289, 284, 285, 290, 284, 
	285, 291, 284, 285, 292, 284, 285, 293, 
	284, 285, 294, 284, 285, 295, 284, 285, 
	296, 284, 285, 297, 284, 285, 298, 284, 
	285, 299, 284, 285, 4, 284, 285, 68, 
	284, 285, 302, 308, 284, 285, 303, 284, 
	285, 304, 284, 285, 305, 284, 285, 306, 
	284, 285, 307, 284, 285, 68, 284, 285, 
	300, 284, 285, 310, 318, 284, 285, 311, 
	284, 285, 312, 284, 285, 313, 284, 285, 
	314, 284, 285, 315, 284, 285, 316, 284, 
	285, 317, 284, 285, 307, 284, 285, 319, 
	300, 284, 285, 320, 284, 285, 321, 284, 
	285, 322, 284, 285, 323, 284, 285, 324, 
	284, 285, 325, 284, 285, 326, 284, 285, 
	327, 284, 285, 317, 284, 285, 329, 284, 
	285, 330, 284, 285, 331, 284, 285, 332, 
	284, 285, 333, 284, 285, 307, 284, 285, 
	335, 284, 285, 336, 284, 285, 337, 284, 
	285, 300, 284, 285, 339, 284, 285, 340, 
	284, 285, 341, 284, 285, 342, 284, 285, 
	343, 284, 285, 344, 284, 285, 345, 284, 
	285, 346, 68, 284, 285, 347, 352, 284, 
	285, 348, 284, 285, 349, 284, 285, 350, 
	284, 285, 351, 284, 285, 333, 284, 285, 
	353, 284, 285, 354, 284, 285, 355, 284, 
	285, 356, 284, 285, 357, 284, 285, 333, 
	284, 285, 336, 284, 203, 0, 360, 361, 
	360, 0, 365, 364, 363, 361, 364, 362, 
	0, 363, 361, 362, 0, 363, 362, 365, 
	364, 363, 361, 364, 362, 365, 365, 5, 
	15, 17, 31, 34, 37, 69, 159, 195, 
	201, 205, 359, 359, 360, 365, 0, 46, 
	367, 375, 45, 46, 368, 45, 46, 369, 
	45, 46, 370, 45, 46, 371, 45, 46, 
	372, 45, 46, 373, 45, 46, 374, 45, 
	46, 67, 45, 46, 376, 45, 46, 377, 
	45, 46, 378, 45, 46, 379, 45, 46, 
	380, 45, 46, 381, 45, 46, 382, 45, 
	46, 383, 45, 46, 384, 45, 46, 374, 
	45, 46, 386, 45, 46, 387, 45, 46, 
	388, 45, 46, 389, 45, 46, 390, 45, 
	46, 391, 45, 46, 67, 45, 46, 393, 
	45, 46, 394, 45, 46, 395, 45, 46, 
	396, 45, 46, 397, 45, 46, 67, 45, 
	46, 399, 45, 46, 400, 45, 46, 401, 
	45, 46, 402, 45, 46, 403, 45, 46, 
	404, 45, 46, 405, 45, 46, 406, 68, 
	67, 45, 46, 407, 412, 45, 46, 408, 
	45, 46, 409, 45, 46, 410, 45, 46, 
	411, 45, 46, 397, 45, 46, 413, 45, 
	46, 414, 45, 46, 415, 45, 46, 416, 
	45, 46, 417, 45, 46, 397, 45, 31, 
	0, 0, 0
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
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 69, 33, 
	69, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	13, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 13, 0, 130, 
	31, 60, 57, 31, 63, 57, 63, 63, 
	63, 63, 63, 63, 63, 63, 66, 31, 
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 72, 33, 84, 72, 
	84, 84, 84, 84, 84, 84, 84, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 15, 0, 54, 15, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
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
	0, 15, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	81, 84, 84, 84, 81, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 21, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 0, 0, 43, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 78, 
	33, 84, 78, 84, 84, 84, 84, 84, 
	84, 84, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 19, 0, 54, 19, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
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
	0, 0, 54, 0, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 75, 
	33, 84, 75, 84, 84, 84, 84, 84, 
	84, 84, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 54, 17, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 17, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
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
	54, 0, 17, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 43, 0, 0, 
	0, 43, 54, 37, 37, 87, 37, 37, 
	43, 0, 39, 0, 43, 0, 0, 54, 
	0, 0, 39, 0, 0, 54, 0, 93, 
	90, 41, 96, 90, 96, 96, 96, 96, 
	96, 96, 96, 96, 99, 0, 43, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
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
	0, 0, 54, 0, 0, 54, 0, 13, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
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
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 419;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"

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
    
    
#line 1022 "ext/gherkin_lexer_en/gherkin_lexer_en.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
    
#line 1029 "ext/gherkin_lexer_en/gherkin_lexer_en.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
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
#line 1319 "ext/gherkin_lexer_en/gherkin_lexer_en.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"
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
#line 1382 "ext/gherkin_lexer_en/gherkin_lexer_en.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/en.c.rl"

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

void Init_gherkin_lexer_en()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "En", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

