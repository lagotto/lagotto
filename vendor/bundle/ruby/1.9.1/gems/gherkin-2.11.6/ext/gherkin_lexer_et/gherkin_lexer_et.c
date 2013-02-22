
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_et/gherkin_lexer_et.c"
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
	0, 0, 18, 19, 20, 37, 38, 39, 
	41, 43, 48, 53, 58, 63, 67, 71, 
	73, 74, 75, 76, 77, 78, 79, 80, 
	81, 82, 83, 84, 85, 86, 87, 88, 
	89, 91, 93, 98, 105, 110, 111, 112, 
	113, 114, 115, 116, 117, 119, 120, 121, 
	122, 123, 124, 125, 126, 127, 128, 135, 
	137, 139, 141, 143, 145, 147, 164, 165, 
	166, 168, 169, 170, 171, 172, 173, 174, 
	175, 176, 188, 190, 192, 194, 196, 198, 
	200, 202, 204, 206, 208, 210, 212, 214, 
	216, 218, 220, 222, 224, 226, 228, 230, 
	232, 234, 236, 238, 240, 242, 244, 246, 
	248, 250, 252, 254, 256, 258, 260, 262, 
	264, 266, 268, 270, 272, 274, 276, 278, 
	279, 280, 281, 282, 283, 284, 285, 286, 
	287, 288, 289, 290, 291, 292, 293, 294, 
	295, 308, 310, 312, 314, 316, 318, 320, 
	322, 324, 326, 328, 330, 332, 334, 336, 
	338, 340, 342, 344, 346, 348, 350, 352, 
	354, 356, 358, 361, 363, 365, 367, 369, 
	371, 373, 376, 378, 380, 382, 384, 386, 
	388, 390, 392, 394, 396, 398, 399, 400, 
	401, 402, 403, 404, 405, 406, 407, 408, 
	409, 410, 411, 426, 428, 430, 432, 434, 
	436, 438, 440, 442, 444, 446, 448, 450, 
	452, 454, 456, 458, 460, 462, 464, 466, 
	468, 470, 472, 474, 476, 479, 481, 483, 
	485, 487, 489, 491, 493, 495, 497, 499, 
	501, 503, 505, 507, 509, 511, 513, 515, 
	517, 519, 522, 524, 526, 528, 530, 532, 
	533, 534, 535, 536, 537, 538, 539, 553, 
	555, 557, 559, 561, 563, 565, 567, 569, 
	571, 573, 575, 577, 579, 581, 583, 585, 
	587, 589, 591, 593, 595, 597, 599, 601, 
	603, 606, 608, 610, 612, 614, 616, 618, 
	620, 622, 624, 626, 628, 630, 632, 634, 
	636, 638, 640, 642, 644, 646, 649, 651, 
	655, 661, 664, 666, 672, 689
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	69, 74, 75, 79, 82, 83, 84, 124, 
	9, 13, -69, -65, 10, 32, 34, 35, 
	37, 42, 64, 69, 74, 75, 79, 82, 
	83, 84, 124, 9, 13, 34, 34, 10, 
	13, 10, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 9, 13, 10, 32, 9, 13, 10, 
	13, 10, 95, 70, 69, 65, 84, 85, 
	82, 69, 95, 69, 78, 68, 95, 37, 
	32, 10, 13, 10, 13, 13, 32, 64, 
	9, 10, 9, 10, 13, 32, 64, 11, 
	12, 10, 32, 64, 9, 13, 101, 108, 
	100, 97, 100, 101, 115, 97, 117, 104, 
	116, 117, 109, 105, 100, 58, 10, 10, 
	10, 32, 35, 79, 124, 9, 13, 10, 
	109, 10, 97, 10, 100, 10, 117, 10, 
	115, 10, 58, 10, 32, 34, 35, 37, 
	42, 64, 69, 74, 75, 79, 82, 83, 
	84, 124, 9, 13, 117, 105, 32, 100, 
	109, 97, 100, 117, 115, 58, 10, 10, 
	10, 32, 35, 37, 64, 74, 79, 82, 
	83, 84, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 117, 10, 104, 10, 116, 10, 117, 
	10, 109, 10, 105, 10, 100, 10, 58, 
	10, 109, 10, 97, 10, 100, 10, 117, 
	10, 115, 10, 97, 10, 97, 10, 109, 
	10, 115, 10, 116, 10, 115, 10, 101, 
	10, 110, 10, 97, 10, 97, 10, 114, 
	10, 105, 10, 117, 10, 109, 10, 97, 
	10, 117, 10, 115, 10, 116, 97, 97, 
	109, 115, 116, 115, 101, 110, 97, 97, 
	114, 105, 117, 109, 58, 10, 10, 10, 
	32, 35, 37, 42, 64, 69, 74, 75, 
	79, 83, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 101, 10, 108, 10, 100, 
	10, 97, 10, 100, 10, 101, 10, 115, 
	10, 97, 10, 117, 10, 105, 10, 32, 
	100, 10, 109, 10, 97, 10, 100, 10, 
	117, 10, 115, 10, 58, 10, 105, 116, 
	10, 105, 10, 115, 10, 101, 10, 110, 
	10, 97, 10, 97, 10, 114, 10, 105, 
	10, 117, 10, 109, 105, 116, 105, 115, 
	101, 110, 97, 97, 114, 105, 117, 109, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 69, 74, 75, 79, 82, 83, 84, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 101, 10, 108, 10, 100, 10, 97, 
	10, 100, 10, 101, 10, 115, 10, 97, 
	10, 117, 10, 105, 10, 32, 100, 10, 
	109, 10, 97, 10, 100, 10, 117, 10, 
	115, 10, 58, 10, 97, 10, 97, 10, 
	109, 10, 115, 10, 116, 10, 115, 10, 
	101, 10, 110, 10, 97, 10, 97, 10, 
	114, 10, 105, 10, 117, 10, 109, 10, 
	105, 116, 10, 105, 10, 97, 10, 117, 
	10, 115, 10, 116, 97, 117, 115, 116, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 69, 74, 75, 79, 82, 83, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	101, 10, 108, 10, 100, 10, 97, 10, 
	100, 10, 101, 10, 115, 10, 97, 10, 
	117, 10, 105, 10, 32, 100, 10, 109, 
	10, 97, 10, 100, 10, 117, 10, 115, 
	10, 58, 10, 97, 10, 97, 10, 109, 
	10, 115, 10, 116, 10, 115, 10, 101, 
	10, 110, 10, 97, 10, 97, 10, 114, 
	10, 105, 10, 117, 10, 109, 10, 105, 
	116, 10, 105, 32, 124, 9, 13, 10, 
	32, 92, 124, 9, 13, 10, 92, 124, 
	10, 92, 10, 32, 92, 124, 9, 13, 
	10, 32, 34, 35, 37, 42, 64, 69, 
	74, 75, 79, 82, 83, 84, 124, 9, 
	13, 0
};

static const char _lexer_single_lengths[] = {
	0, 16, 1, 1, 15, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 5, 2, 
	2, 2, 2, 2, 2, 15, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 10, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	11, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 12, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	4, 3, 2, 4, 15, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 0, 0, 1, 1, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 18, 20, 22, 39, 41, 43, 
	46, 49, 54, 59, 64, 69, 73, 77, 
	80, 82, 84, 86, 88, 90, 92, 94, 
	96, 98, 100, 102, 104, 106, 108, 110, 
	112, 115, 118, 123, 130, 135, 137, 139, 
	141, 143, 145, 147, 149, 152, 154, 156, 
	158, 160, 162, 164, 166, 168, 170, 177, 
	180, 183, 186, 189, 192, 195, 212, 214, 
	216, 219, 221, 223, 225, 227, 229, 231, 
	233, 235, 247, 250, 253, 256, 259, 262, 
	265, 268, 271, 274, 277, 280, 283, 286, 
	289, 292, 295, 298, 301, 304, 307, 310, 
	313, 316, 319, 322, 325, 328, 331, 334, 
	337, 340, 343, 346, 349, 352, 355, 358, 
	361, 364, 367, 370, 373, 376, 379, 382, 
	384, 386, 388, 390, 392, 394, 396, 398, 
	400, 402, 404, 406, 408, 410, 412, 414, 
	416, 429, 432, 435, 438, 441, 444, 447, 
	450, 453, 456, 459, 462, 465, 468, 471, 
	474, 477, 480, 483, 486, 489, 492, 495, 
	498, 501, 504, 508, 511, 514, 517, 520, 
	523, 526, 530, 533, 536, 539, 542, 545, 
	548, 551, 554, 557, 560, 563, 565, 567, 
	569, 571, 573, 575, 577, 579, 581, 583, 
	585, 587, 589, 604, 607, 610, 613, 616, 
	619, 622, 625, 628, 631, 634, 637, 640, 
	643, 646, 649, 652, 655, 658, 661, 664, 
	667, 670, 673, 676, 679, 683, 686, 689, 
	692, 695, 698, 701, 704, 707, 710, 713, 
	716, 719, 722, 725, 728, 731, 734, 737, 
	740, 743, 747, 750, 753, 756, 759, 762, 
	764, 766, 768, 770, 772, 774, 776, 790, 
	793, 796, 799, 802, 805, 808, 811, 814, 
	817, 820, 823, 826, 829, 832, 835, 838, 
	841, 844, 847, 850, 853, 856, 859, 862, 
	865, 869, 872, 875, 878, 881, 884, 887, 
	890, 893, 896, 899, 902, 905, 908, 911, 
	914, 917, 920, 923, 926, 929, 933, 936, 
	940, 946, 950, 953, 959, 976
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 44, 62, 65, 119, 180, 247, 303, 
	4, 0, 3, 0, 4, 0, 4, 4, 
	5, 15, 17, 31, 34, 37, 44, 62, 
	65, 119, 180, 247, 303, 4, 0, 6, 
	0, 7, 0, 9, 8, 8, 9, 8, 
	8, 10, 10, 11, 10, 10, 10, 10, 
	11, 10, 10, 10, 10, 12, 10, 10, 
	10, 10, 13, 10, 10, 4, 14, 14, 
	0, 4, 14, 14, 0, 4, 16, 15, 
	4, 0, 18, 0, 19, 0, 20, 0, 
	21, 0, 22, 0, 23, 0, 24, 0, 
	25, 0, 26, 0, 27, 0, 28, 0, 
	29, 0, 30, 0, 309, 0, 32, 0, 
	4, 16, 33, 4, 16, 33, 0, 0, 
	0, 0, 35, 36, 4, 36, 36, 34, 
	35, 35, 4, 36, 34, 36, 0, 38, 
	0, 39, 0, 40, 0, 41, 0, 42, 
	0, 43, 0, 31, 0, 31, 45, 0, 
	46, 0, 47, 0, 48, 0, 49, 0, 
	50, 0, 51, 0, 52, 0, 54, 53, 
	54, 53, 54, 54, 4, 55, 4, 54, 
	53, 54, 56, 53, 54, 57, 53, 54, 
	58, 53, 54, 59, 53, 54, 60, 53, 
	54, 61, 53, 4, 4, 5, 15, 17, 
	31, 34, 37, 44, 62, 65, 119, 180, 
	247, 303, 4, 0, 63, 0, 64, 0, 
	32, 31, 0, 66, 0, 67, 0, 68, 
	0, 69, 0, 70, 0, 71, 0, 73, 
	72, 73, 72, 73, 73, 4, 74, 4, 
	88, 96, 101, 105, 115, 73, 72, 73, 
	75, 72, 73, 76, 72, 73, 77, 72, 
	73, 78, 72, 73, 79, 72, 73, 80, 
	72, 73, 81, 72, 73, 82, 72, 73, 
	83, 72, 73, 84, 72, 73, 85, 72, 
	73, 86, 72, 73, 87, 72, 73, 4, 
	72, 73, 89, 72, 73, 90, 72, 73, 
	91, 72, 73, 92, 72, 73, 93, 72, 
	73, 94, 72, 73, 95, 72, 73, 61, 
	72, 73, 97, 72, 73, 98, 72, 73, 
	99, 72, 73, 100, 72, 73, 95, 72, 
	73, 102, 72, 73, 103, 72, 73, 104, 
	72, 73, 105, 72, 73, 106, 72, 73, 
	107, 72, 73, 108, 72, 73, 109, 72, 
	73, 110, 72, 73, 111, 72, 73, 112, 
	72, 73, 113, 72, 73, 114, 72, 73, 
	95, 72, 73, 116, 72, 73, 117, 72, 
	73, 118, 72, 73, 95, 72, 120, 0, 
	121, 0, 122, 0, 123, 0, 124, 0, 
	125, 0, 126, 0, 127, 0, 128, 0, 
	129, 0, 130, 0, 131, 0, 132, 0, 
	133, 0, 134, 0, 136, 135, 136, 135, 
	136, 136, 4, 137, 151, 4, 152, 159, 
	160, 163, 169, 136, 135, 136, 138, 135, 
	136, 139, 135, 136, 140, 135, 136, 141, 
	135, 136, 142, 135, 136, 143, 135, 136, 
	144, 135, 136, 145, 135, 136, 146, 135, 
	136, 147, 135, 136, 148, 135, 136, 149, 
	135, 136, 150, 135, 136, 4, 135, 136, 
	61, 135, 136, 153, 135, 136, 154, 135, 
	136, 155, 135, 136, 156, 135, 136, 157, 
	135, 136, 158, 135, 136, 151, 135, 136, 
	151, 135, 136, 161, 135, 136, 162, 135, 
	136, 61, 151, 135, 136, 164, 135, 136, 
	165, 135, 136, 166, 135, 136, 167, 135, 
	136, 168, 135, 136, 61, 135, 136, 170, 
	171, 135, 136, 158, 135, 136, 172, 135, 
	136, 173, 135, 136, 174, 135, 136, 175, 
	135, 136, 176, 135, 136, 177, 135, 136, 
	178, 135, 136, 179, 135, 136, 168, 135, 
	181, 182, 0, 43, 0, 183, 0, 184, 
	0, 185, 0, 186, 0, 187, 0, 188, 
	0, 189, 0, 190, 0, 191, 0, 192, 
	0, 194, 193, 194, 193, 194, 194, 4, 
	195, 209, 4, 210, 217, 218, 221, 227, 
	241, 243, 194, 193, 194, 196, 193, 194, 
	197, 193, 194, 198, 193, 194, 199, 193, 
	194, 200, 193, 194, 201, 193, 194, 202, 
	193, 194, 203, 193, 194, 204, 193, 194, 
	205, 193, 194, 206, 193, 194, 207, 193, 
	194, 208, 193, 194, 4, 193, 194, 61, 
	193, 194, 211, 193, 194, 212, 193, 194, 
	213, 193, 194, 214, 193, 194, 215, 193, 
	194, 216, 193, 194, 209, 193, 194, 209, 
	193, 194, 219, 193, 194, 220, 193, 194, 
	61, 209, 193, 194, 222, 193, 194, 223, 
	193, 194, 224, 193, 194, 225, 193, 194, 
	226, 193, 194, 61, 193, 194, 228, 193, 
	194, 229, 193, 194, 230, 193, 194, 231, 
	193, 194, 232, 193, 194, 233, 193, 194, 
	234, 193, 194, 235, 193, 194, 236, 193, 
	194, 237, 193, 194, 238, 193, 194, 239, 
	193, 194, 240, 193, 194, 226, 193, 194, 
	242, 232, 193, 194, 216, 193, 194, 244, 
	193, 194, 245, 193, 194, 246, 193, 194, 
	226, 193, 248, 0, 249, 0, 250, 0, 
	251, 0, 252, 0, 254, 253, 254, 253, 
	254, 254, 4, 255, 269, 4, 270, 277, 
	278, 281, 287, 301, 254, 253, 254, 256, 
	253, 254, 257, 253, 254, 258, 253, 254, 
	259, 253, 254, 260, 253, 254, 261, 253, 
	254, 262, 253, 254, 263, 253, 254, 264, 
	253, 254, 265, 253, 254, 266, 253, 254, 
	267, 253, 254, 268, 253, 254, 4, 253, 
	254, 61, 253, 254, 271, 253, 254, 272, 
	253, 254, 273, 253, 254, 274, 253, 254, 
	275, 253, 254, 276, 253, 254, 269, 253, 
	254, 269, 253, 254, 279, 253, 254, 280, 
	253, 254, 61, 269, 253, 254, 282, 253, 
	254, 283, 253, 254, 284, 253, 254, 285, 
	253, 254, 286, 253, 254, 61, 253, 254, 
	288, 253, 254, 289, 253, 254, 290, 253, 
	254, 291, 253, 254, 292, 253, 254, 293, 
	253, 254, 294, 253, 254, 295, 253, 254, 
	296, 253, 254, 297, 253, 254, 298, 253, 
	254, 299, 253, 254, 300, 253, 254, 286, 
	253, 254, 302, 292, 253, 254, 276, 253, 
	303, 304, 303, 0, 308, 307, 306, 304, 
	307, 305, 0, 306, 304, 305, 0, 306, 
	305, 308, 307, 306, 304, 307, 305, 308, 
	308, 5, 15, 17, 31, 34, 37, 44, 
	62, 65, 119, 180, 247, 303, 308, 0, 
	0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	0, 54, 0, 5, 1, 0, 29, 1, 
	29, 29, 29, 29, 29, 29, 29, 35, 
	0, 43, 0, 43, 0, 43, 54, 0, 
	5, 1, 0, 29, 1, 29, 29, 29, 
	29, 29, 29, 29, 35, 0, 43, 0, 
	43, 0, 43, 139, 48, 9, 106, 11, 
	0, 134, 45, 45, 45, 3, 122, 33, 
	33, 33, 0, 122, 33, 33, 33, 0, 
	122, 33, 0, 33, 0, 102, 7, 7, 
	43, 54, 0, 0, 43, 114, 25, 0, 
	54, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	149, 126, 57, 110, 23, 0, 43, 43, 
	43, 43, 0, 27, 118, 27, 27, 51, 
	27, 0, 54, 0, 1, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 81, 84, 81, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 21, 0, 130, 31, 60, 57, 31, 
	63, 57, 63, 63, 63, 63, 63, 63, 
	63, 66, 31, 43, 0, 43, 0, 43, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 69, 33, 69, 
	84, 84, 84, 84, 84, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 13, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 13, 
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
	0, 43, 0, 43, 144, 57, 54, 0, 
	54, 0, 78, 33, 84, 78, 84, 84, 
	84, 84, 84, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	19, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 19, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 19, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 75, 
	33, 84, 75, 84, 84, 84, 84, 84, 
	84, 84, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 54, 17, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	17, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 17, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 144, 57, 54, 0, 
	54, 0, 72, 33, 84, 72, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 15, 0, 
	54, 15, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 15, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 15, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	0, 0, 0, 43, 54, 37, 37, 87, 
	37, 37, 43, 0, 39, 0, 43, 0, 
	0, 54, 0, 0, 39, 0, 0, 54, 
	0, 93, 90, 41, 96, 90, 96, 96, 
	96, 96, 96, 96, 96, 99, 0, 43, 
	0, 0
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
	43, 43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 309;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"

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
    
    
#line 840 "ext/gherkin_lexer_et/gherkin_lexer_et.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
    
#line 847 "ext/gherkin_lexer_et/gherkin_lexer_et.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
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
#line 1137 "ext/gherkin_lexer_et/gherkin_lexer_et.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"
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
#line 1200 "ext/gherkin_lexer_et/gherkin_lexer_et.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/et.c.rl"

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

void Init_gherkin_lexer_et()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Et", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

