
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_hr/gherkin_lexer_hr.c"
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
	91, 93, 95, 100, 107, 112, 113, 114, 
	116, 117, 119, 120, 121, 122, 123, 124, 
	125, 126, 127, 142, 144, 146, 148, 150, 
	152, 154, 156, 158, 160, 162, 164, 166, 
	168, 170, 172, 190, 191, 192, 193, 195, 
	196, 197, 198, 199, 200, 201, 202, 203, 
	215, 217, 219, 221, 223, 225, 227, 229, 
	231, 233, 235, 237, 239, 241, 243, 245, 
	247, 249, 251, 253, 255, 257, 259, 261, 
	263, 266, 268, 270, 272, 274, 276, 278, 
	280, 282, 284, 286, 289, 291, 293, 295, 
	297, 299, 301, 303, 305, 307, 310, 312, 
	314, 316, 318, 320, 322, 325, 327, 329, 
	331, 332, 333, 334, 335, 336, 337, 338, 
	340, 341, 342, 343, 344, 345, 346, 347, 
	348, 349, 364, 366, 368, 370, 372, 374, 
	376, 378, 380, 382, 384, 386, 388, 390, 
	392, 394, 396, 398, 401, 403, 406, 408, 
	410, 412, 414, 416, 418, 420, 422, 424, 
	427, 429, 431, 433, 435, 438, 440, 442, 
	444, 446, 448, 450, 452, 455, 457, 459, 
	461, 463, 465, 467, 469, 471, 473, 475, 
	477, 479, 483, 484, 485, 486, 487, 488, 
	489, 490, 491, 492, 500, 502, 504, 506, 
	509, 511, 513, 515, 517, 519, 521, 523, 
	525, 527, 529, 531, 533, 535, 536, 537, 
	538, 539, 540, 541, 543, 544, 545, 561, 
	563, 565, 567, 569, 571, 573, 575, 577, 
	579, 581, 583, 585, 587, 589, 591, 593, 
	595, 598, 600, 603, 605, 607, 609, 611, 
	613, 615, 617, 619, 621, 624, 626, 628, 
	630, 632, 635, 637, 639, 641, 643, 645, 
	647, 649, 651, 653, 655, 657, 660, 662, 
	664, 666, 668, 670, 672, 674, 676, 678, 
	680, 682, 684, 688, 689, 690, 691, 692, 
	693, 694, 695, 698, 702, 708, 711, 713, 
	719, 737, 739, 741, 743, 745, 748, 750, 
	752, 754, 757, 759, 761, 763, 765, 767, 
	769, 772, 774, 776, 778, 780, 782, 784, 
	786, 788, 790, 792, 794, 796, 798, 800, 
	802, 804, 806, 808, 812
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 73, 75, 77, 79, 80, 83, 90, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 73, 75, 77, 
	79, 80, 83, 90, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	108, 105, 97, 111, 100, 32, 97, 110, 
	99, 101, 112, 116, 58, 10, 10, 10, 
	32, 35, 37, 42, 64, 65, 73, 75, 
	77, 79, 83, 90, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, 10, 32, 34, 35, 
	37, 42, 64, 65, 73, 75, 77, 79, 
	80, 83, 90, 124, 9, 13, 111, 103, 
	117, -60, 99, -121, 110, 111, 115, 116, 
	58, 10, 10, 10, 32, 35, 37, 64, 
	75, 77, 79, 80, 83, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 111, 10, 110, 10, 
	99, 10, 101, 10, 112, 10, 116, 10, 
	58, 10, 111, 10, 103, 10, 117, -60, 
	10, 99, -121, 10, 10, 110, 10, 111, 
	10, 115, 10, 115, 10, 111, 10, 98, 
	10, 105, 10, 110, 10, 97, 10, 111, 
	114, 10, 122, 10, 97, 10, 100, 10, 
	105, 10, 109, 10, 106, 10, 101, 10, 
	114, 10, 105, 10, 99, 107, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 106, 10, 58, 105, 10, 105, 10, 
	99, 110, 115, 100, 97, 111, 98, 105, 
	110, 97, 111, 114, 122, 97, 100, 105, 
	110, 97, 58, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 73, 75, 77, 79, 
	83, 90, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 108, 10, 105, 10, 97, 
	111, 10, 100, 10, 32, 97, 10, 110, 
	10, 99, 10, 101, 10, 112, 10, 116, 
	10, 58, 10, 111, 10, 103, 10, 117, 
	-60, 10, 99, -121, 10, 10, 110, 10, 
	111, 10, 115, 10, 110, 115, 10, 100, 
	10, 97, 10, 111, 10, 98, 10, 105, 
	10, 110, 10, 97, 10, 99, 107, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 106, 10, 105, 10, 99, 10, 
	97, 10, 100, 10, 97, 10, 110, 10, 
	32, 105, 111, 105, 109, 106, 101, 114, 
	105, 58, 10, 10, 10, 32, 35, 77, 
	79, 124, 9, 13, 10, 111, 10, 103, 
	10, 117, -60, 10, 99, -121, 10, 10, 
	110, 10, 111, 10, 115, 10, 116, 10, 
	58, 10, 115, 10, 111, 10, 98, 10, 
	105, 10, 110, 10, 97, 99, 107, 101, 
	110, 97, 114, 105, 106, 58, 105, 10, 
	10, 10, 32, 35, 37, 42, 64, 65, 
	73, 75, 77, 79, 80, 83, 90, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	108, 10, 105, 10, 97, 111, 10, 100, 
	10, 32, 97, 10, 110, 10, 99, 10, 
	101, 10, 112, 10, 116, 10, 58, 10, 
	111, 10, 103, 10, 117, -60, 10, 99, 
	-121, 10, 10, 110, 10, 111, 10, 115, 
	10, 110, 115, 10, 100, 10, 97, 10, 
	111, 10, 98, 10, 105, 10, 110, 10, 
	97, 10, 111, 10, 122, 10, 97, 10, 
	100, 10, 99, 107, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 106, 
	10, 105, 10, 99, 10, 97, 10, 100, 
	10, 97, 10, 110, 10, 32, 105, 111, 
	105, 99, 97, 97, 100, 97, 110, 32, 
	105, 111, 32, 124, 9, 13, 10, 32, 
	92, 124, 9, 13, 10, 92, 124, 10, 
	92, 10, 32, 92, 124, 9, 13, 10, 
	32, 34, 35, 37, 42, 64, 65, 73, 
	75, 77, 79, 80, 83, 90, 124, 9, 
	13, 10, 108, 10, 105, 10, 97, 10, 
	100, 10, 32, 97, 10, 111, 10, 103, 
	10, 117, -60, 10, 99, -121, 10, 10, 
	110, 10, 111, 10, 115, 10, 116, 10, 
	58, 10, 110, 115, 10, 100, 10, 97, 
	10, 111, 10, 98, 10, 105, 10, 110, 
	10, 97, 10, 99, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 106, 
	10, 97, 10, 100, 10, 97, 10, 110, 
	10, 32, 105, 111, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 2, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 16, 1, 1, 1, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 10, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 13, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 4, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 6, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 14, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 4, 1, 1, 1, 1, 1, 
	1, 1, 3, 2, 4, 3, 2, 4, 
	16, 2, 2, 2, 2, 3, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 4, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 1, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 1, 0, 0, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 139, 141, 
	144, 146, 149, 151, 153, 155, 157, 159, 
	161, 163, 165, 180, 183, 186, 189, 192, 
	195, 198, 201, 204, 207, 210, 213, 216, 
	219, 222, 225, 243, 245, 247, 249, 252, 
	254, 256, 258, 260, 262, 264, 266, 268, 
	280, 283, 286, 289, 292, 295, 298, 301, 
	304, 307, 310, 313, 316, 319, 322, 325, 
	328, 331, 334, 337, 340, 343, 346, 349, 
	352, 356, 359, 362, 365, 368, 371, 374, 
	377, 380, 383, 386, 390, 393, 396, 399, 
	402, 405, 408, 411, 414, 417, 421, 424, 
	427, 430, 433, 436, 439, 443, 446, 449, 
	452, 454, 456, 458, 460, 462, 464, 466, 
	469, 471, 473, 475, 477, 479, 481, 483, 
	485, 487, 502, 505, 508, 511, 514, 517, 
	520, 523, 526, 529, 532, 535, 538, 541, 
	544, 547, 550, 553, 557, 560, 564, 567, 
	570, 573, 576, 579, 582, 585, 588, 591, 
	595, 598, 601, 604, 607, 611, 614, 617, 
	620, 623, 626, 629, 632, 636, 639, 642, 
	645, 648, 651, 654, 657, 660, 663, 666, 
	669, 672, 677, 679, 681, 683, 685, 687, 
	689, 691, 693, 695, 703, 706, 709, 712, 
	716, 719, 722, 725, 728, 731, 734, 737, 
	740, 743, 746, 749, 752, 755, 757, 759, 
	761, 763, 765, 767, 770, 772, 774, 790, 
	793, 796, 799, 802, 805, 808, 811, 814, 
	817, 820, 823, 826, 829, 832, 835, 838, 
	841, 845, 848, 852, 855, 858, 861, 864, 
	867, 870, 873, 876, 879, 883, 886, 889, 
	892, 895, 899, 902, 905, 908, 911, 914, 
	917, 920, 923, 926, 929, 932, 936, 939, 
	942, 945, 948, 951, 954, 957, 960, 963, 
	966, 969, 972, 977, 979, 981, 983, 985, 
	987, 989, 991, 995, 999, 1005, 1009, 1012, 
	1018, 1036, 1039, 1042, 1045, 1048, 1052, 1055, 
	1058, 1061, 1065, 1068, 1071, 1074, 1077, 1080, 
	1083, 1087, 1090, 1093, 1096, 1099, 1102, 1105, 
	1108, 1111, 1114, 1117, 1120, 1123, 1126, 1129, 
	1132, 1135, 1138, 1141, 1146
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 31, 39, 67, 135, 143, 236, 310, 
	315, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 31, 
	39, 67, 135, 143, 236, 310, 315, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 356, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 0, 31, 0, 40, 42, 0, 
	41, 0, 32, 31, 0, 43, 0, 44, 
	0, 45, 0, 46, 0, 47, 0, 48, 
	0, 50, 49, 50, 49, 50, 50, 4, 
	51, 65, 4, 321, 65, 323, 326, 336, 
	344, 351, 50, 49, 50, 52, 49, 50, 
	53, 49, 50, 54, 49, 50, 55, 49, 
	50, 56, 49, 50, 57, 49, 50, 58, 
	49, 50, 59, 49, 50, 60, 49, 50, 
	61, 49, 50, 62, 49, 50, 63, 49, 
	50, 64, 49, 50, 4, 49, 50, 66, 
	49, 4, 4, 5, 15, 17, 31, 34, 
	37, 31, 39, 67, 135, 143, 236, 310, 
	315, 4, 0, 68, 0, 69, 0, 70, 
	0, 71, 72, 0, 72, 0, 73, 0, 
	74, 0, 75, 0, 76, 0, 77, 0, 
	79, 78, 79, 78, 79, 79, 4, 80, 
	4, 94, 101, 109, 115, 125, 79, 78, 
	79, 81, 78, 79, 82, 78, 79, 83, 
	78, 79, 84, 78, 79, 85, 78, 79, 
	86, 78, 79, 87, 78, 79, 88, 78, 
	79, 89, 78, 79, 90, 78, 79, 91, 
	78, 79, 92, 78, 79, 93, 78, 79, 
	4, 78, 79, 95, 78, 79, 96, 78, 
	79, 97, 78, 79, 98, 78, 79, 99, 
	78, 79, 100, 78, 79, 66, 78, 79, 
	102, 78, 79, 103, 78, 79, 104, 78, 
	105, 79, 106, 78, 106, 79, 78, 79, 
	107, 78, 79, 108, 78, 79, 99, 78, 
	79, 110, 78, 79, 111, 78, 79, 112, 
	78, 79, 113, 78, 79, 114, 78, 79, 
	100, 78, 79, 116, 119, 78, 79, 117, 
	78, 79, 118, 78, 79, 112, 78, 79, 
	120, 78, 79, 121, 78, 79, 122, 78, 
	79, 123, 78, 79, 124, 78, 79, 100, 
	78, 79, 126, 133, 78, 79, 127, 78, 
	79, 128, 78, 79, 129, 78, 79, 130, 
	78, 79, 131, 78, 79, 132, 78, 79, 
	66, 100, 78, 79, 134, 78, 79, 114, 
	78, 136, 138, 0, 137, 0, 31, 0, 
	139, 0, 140, 0, 141, 0, 142, 0, 
	76, 0, 144, 210, 0, 145, 0, 146, 
	0, 147, 0, 148, 0, 149, 0, 150, 
	0, 151, 0, 153, 152, 153, 152, 153, 
	153, 4, 154, 168, 4, 169, 168, 171, 
	180, 188, 196, 205, 153, 152, 153, 155, 
	152, 153, 156, 152, 153, 157, 152, 153, 
	158, 152, 153, 159, 152, 153, 160, 152, 
	153, 161, 152, 153, 162, 152, 153, 163, 
	152, 153, 164, 152, 153, 165, 152, 153, 
	166, 152, 153, 167, 152, 153, 4, 152, 
	153, 66, 152, 153, 170, 152, 153, 168, 
	152, 153, 172, 174, 152, 153, 173, 152, 
	153, 66, 168, 152, 153, 175, 152, 153, 
	176, 152, 153, 177, 152, 153, 178, 152, 
	153, 179, 152, 153, 66, 152, 153, 181, 
	152, 153, 182, 152, 153, 183, 152, 184, 
	153, 185, 152, 185, 153, 152, 153, 186, 
	152, 153, 187, 152, 153, 178, 152, 153, 
	189, 191, 152, 153, 190, 152, 153, 168, 
	152, 153, 192, 152, 153, 193, 152, 153, 
	194, 152, 153, 195, 152, 153, 179, 152, 
	153, 197, 203, 152, 153, 198, 152, 153, 
	199, 152, 153, 200, 152, 153, 201, 152, 
	153, 202, 152, 153, 179, 152, 153, 204, 
	152, 153, 195, 152, 153, 206, 152, 153, 
	207, 152, 153, 208, 152, 153, 209, 152, 
	153, 66, 168, 168, 152, 211, 0, 212, 
	0, 213, 0, 214, 0, 215, 0, 216, 
	0, 217, 0, 219, 218, 219, 218, 219, 
	219, 4, 220, 230, 4, 219, 218, 219, 
	221, 218, 219, 222, 218, 219, 223, 218, 
	224, 219, 225, 218, 225, 219, 218, 219, 
	226, 218, 219, 227, 218, 219, 228, 218, 
	219, 229, 218, 219, 66, 218, 219, 231, 
	218, 219, 232, 218, 219, 233, 218, 219, 
	234, 218, 219, 235, 218, 219, 229, 218, 
	237, 307, 0, 238, 0, 239, 0, 240, 
	0, 241, 0, 242, 0, 243, 0, 244, 
	216, 0, 246, 245, 246, 245, 246, 246, 
	4, 247, 261, 4, 262, 261, 264, 273, 
	281, 289, 293, 302, 246, 245, 246, 248, 
	245, 246, 249, 245, 246, 250, 245, 246, 
	251, 245, 246, 252, 245, 246, 253, 245, 
	246, 254, 245, 246, 255, 245, 246, 256, 
	245, 246, 257, 245, 246, 258, 245, 246, 
	259, 245, 246, 260, 245, 246, 4, 245, 
	246, 66, 245, 246, 263, 245, 246, 261, 
	245, 246, 265, 267, 245, 246, 266, 245, 
	246, 66, 261, 245, 246, 268, 245, 246, 
	269, 245, 246, 270, 245, 246, 271, 245, 
	246, 272, 245, 246, 66, 245, 246, 274, 
	245, 246, 275, 245, 246, 276, 245, 277, 
	246, 278, 245, 278, 246, 245, 246, 279, 
	245, 246, 280, 245, 246, 271, 245, 246, 
	282, 284, 245, 246, 283, 245, 246, 261, 
	245, 246, 285, 245, 246, 286, 245, 246, 
	287, 245, 246, 288, 245, 246, 272, 245, 
	246, 290, 245, 246, 291, 245, 246, 292, 
	245, 246, 286, 245, 246, 294, 300, 245, 
	246, 295, 245, 246, 296, 245, 246, 297, 
	245, 246, 298, 245, 246, 299, 245, 246, 
	272, 245, 246, 301, 245, 246, 288, 245, 
	246, 303, 245, 246, 304, 245, 246, 305, 
	245, 246, 306, 245, 246, 66, 261, 261, 
	245, 308, 0, 309, 0, 47, 0, 311, 
	0, 312, 0, 313, 0, 314, 0, 32, 
	31, 31, 0, 315, 316, 315, 0, 320, 
	319, 318, 316, 319, 317, 0, 318, 316, 
	317, 0, 318, 317, 320, 319, 318, 316, 
	319, 317, 320, 320, 5, 15, 17, 31, 
	34, 37, 31, 39, 67, 135, 143, 236, 
	310, 315, 320, 0, 50, 322, 49, 50, 
	65, 49, 50, 324, 49, 50, 325, 49, 
	50, 66, 65, 49, 50, 327, 49, 50, 
	328, 49, 50, 329, 49, 330, 50, 331, 
	49, 331, 50, 49, 50, 332, 49, 50, 
	333, 49, 50, 334, 49, 50, 335, 49, 
	50, 66, 49, 50, 337, 339, 49, 50, 
	338, 49, 50, 65, 49, 50, 340, 49, 
	50, 341, 49, 50, 342, 49, 50, 343, 
	49, 50, 335, 49, 50, 345, 49, 50, 
	346, 49, 50, 347, 49, 50, 348, 49, 
	50, 349, 49, 50, 350, 49, 50, 335, 
	49, 50, 352, 49, 50, 353, 49, 50, 
	354, 49, 50, 355, 49, 50, 66, 65, 
	65, 49, 0, 0
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
	43, 0, 43, 0, 43, 0, 0, 43, 
	0, 43, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 54, 0, 78, 
	33, 84, 78, 84, 84, 84, 84, 84, 
	84, 84, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 19, 0, 54, 19, 
	0, 130, 31, 60, 57, 31, 63, 57, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	66, 31, 43, 0, 43, 0, 43, 0, 
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
	0, 54, 0, 0, 54, 13, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	13, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 72, 33, 84, 72, 84, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 15, 0, 
	54, 15, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 15, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 15, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 15, 0, 0, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 81, 84, 84, 81, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 21, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	75, 33, 84, 75, 84, 84, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 17, 0, 
	54, 17, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 17, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 17, 0, 0, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	0, 0, 43, 0, 0, 0, 43, 54, 
	37, 37, 87, 37, 37, 43, 0, 39, 
	0, 43, 0, 0, 54, 0, 0, 39, 
	0, 0, 54, 0, 93, 90, 41, 96, 
	90, 96, 96, 96, 96, 96, 96, 96, 
	96, 99, 0, 43, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 19, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 19, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 19, 0, 
	0, 0, 0, 0
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
	43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 356;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"

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
    
    
#line 927 "ext/gherkin_lexer_hr/gherkin_lexer_hr.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
    
#line 934 "ext/gherkin_lexer_hr/gherkin_lexer_hr.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
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
#line 1224 "ext/gherkin_lexer_hr/gherkin_lexer_hr.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"
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
#line 1287 "ext/gherkin_lexer_hr/gherkin_lexer_hr.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/hr.c.rl"

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

void Init_gherkin_lexer_hr()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Hr", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

