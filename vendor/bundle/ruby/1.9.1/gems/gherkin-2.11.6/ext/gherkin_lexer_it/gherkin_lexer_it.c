
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_it/gherkin_lexer_it.c"
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
	115, 116, 117, 118, 119, 120, 121, 122, 
	123, 124, 125, 126, 127, 142, 144, 146, 
	148, 150, 152, 154, 156, 158, 160, 162, 
	164, 166, 168, 170, 172, 190, 191, 192, 
	196, 198, 199, 200, 201, 202, 203, 204, 
	205, 212, 214, 216, 218, 220, 222, 224, 
	226, 228, 230, 232, 234, 236, 238, 239, 
	240, 241, 242, 243, 244, 245, 246, 247, 
	248, 249, 250, 251, 252, 253, 264, 266, 
	268, 270, 272, 274, 276, 278, 280, 282, 
	284, 286, 288, 290, 292, 294, 296, 298, 
	300, 302, 304, 306, 308, 310, 312, 314, 
	316, 318, 320, 322, 324, 326, 328, 330, 
	332, 334, 336, 338, 340, 342, 344, 347, 
	349, 351, 353, 355, 357, 359, 361, 363, 
	365, 367, 369, 371, 373, 375, 377, 379, 
	381, 382, 383, 384, 385, 386, 387, 389, 
	390, 391, 392, 393, 394, 395, 396, 397, 
	413, 415, 417, 419, 421, 423, 425, 427, 
	429, 431, 433, 435, 437, 439, 441, 443, 
	445, 447, 449, 451, 453, 455, 457, 459, 
	461, 463, 465, 467, 469, 471, 473, 478, 
	480, 482, 484, 486, 488, 490, 492, 494, 
	496, 498, 500, 502, 504, 506, 508, 510, 
	512, 514, 517, 519, 521, 523, 525, 527, 
	529, 531, 533, 535, 537, 539, 541, 543, 
	545, 547, 549, 551, 552, 553, 554, 555, 
	556, 557, 558, 559, 560, 561, 562, 563, 
	564, 565, 566, 567, 568, 569, 570, 571, 
	572, 587, 589, 591, 593, 595, 597, 599, 
	601, 603, 605, 607, 609, 611, 613, 615, 
	617, 619, 621, 623, 625, 627, 629, 631, 
	636, 638, 640, 642, 644, 646, 648, 650, 
	652, 654, 656, 658, 660, 662, 664, 666, 
	668, 670, 672, 674, 676, 678, 680, 682, 
	684, 686, 690, 696, 699, 701, 707, 725, 
	727, 729, 731, 733, 735, 737, 739, 744, 
	746, 748, 750, 752, 754, 756, 758, 760, 
	762, 764, 766, 768, 770, 772, 774, 776, 
	778, 780, 782, 785, 787, 789, 791, 793, 
	795, 797, 799, 801, 803, 805, 807, 809, 
	811, 813, 815, 817, 819, 821
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 67, 68, 69, 70, 77, 81, 83, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 67, 68, 69, 
	70, 77, 81, 83, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	108, 108, 111, 114, 97, 111, 110, 116, 
	101, 115, 116, 111, 58, 10, 10, 10, 
	32, 35, 37, 42, 64, 65, 68, 69, 
	70, 77, 81, 83, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, 10, 32, 34, 35, 
	37, 42, 64, 65, 67, 68, 69, 70, 
	77, 81, 83, 124, 9, 13, 97, 116, 
	97, 101, 105, 111, 32, 115, 101, 109, 
	112, 105, 58, 10, 10, 10, 32, 35, 
	70, 124, 9, 13, 10, 117, 10, 110, 
	10, 122, 10, 105, 10, 111, 10, 110, 
	10, 97, 10, 108, 10, 105, 10, 116, 
	-61, 10, -96, 10, 10, 58, 117, 110, 
	122, 105, 111, 110, 97, 108, 105, 116, 
	-61, -96, 58, 10, 10, 10, 32, 35, 
	37, 64, 67, 69, 70, 83, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 111, 10, 110, 
	10, 116, 10, 101, 10, 115, 10, 116, 
	10, 111, 10, 58, 10, 115, 10, 101, 
	10, 109, 10, 112, 10, 105, 10, 117, 
	10, 110, 10, 122, 10, 105, 10, 111, 
	10, 110, 10, 97, 10, 108, 10, 105, 
	10, 116, -61, 10, -96, 10, 10, 99, 
	10, 101, 104, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 101, 10, 109, 10, 
	97, 10, 32, 10, 100, 10, 101, 10, 
	108, 10, 108, 10, 111, 10, 32, 10, 
	115, 10, 99, 10, 101, 117, 97, 110, 
	100, 111, 99, 101, 104, 110, 97, 114, 
	105, 111, 58, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 67, 68, 69, 70, 
	77, 81, 83, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 108, 10, 108, 10, 
	111, 10, 114, 10, 97, 10, 111, 10, 
	110, 10, 116, 10, 101, 10, 115, 10, 
	116, 10, 111, 10, 58, 10, 97, 10, 
	116, 10, 97, 101, 105, 111, 10, 117, 
	10, 110, 10, 122, 10, 105, 10, 111, 
	10, 110, 10, 97, 10, 108, 10, 105, 
	10, 116, -61, 10, -96, 10, 10, 117, 
	10, 97, 10, 110, 10, 100, 10, 111, 
	10, 99, 10, 101, 104, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 101, 10, 
	109, 10, 97, 10, 32, 10, 100, 10, 
	101, 10, 108, 10, 108, 10, 111, 10, 
	32, 10, 115, 10, 99, 10, 101, 101, 
	109, 97, 32, 100, 101, 108, 108, 111, 
	32, 115, 99, 101, 110, 97, 114, 105, 
	111, 58, 10, 10, 10, 32, 35, 37, 
	42, 64, 65, 68, 69, 70, 77, 81, 
	83, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 108, 10, 108, 10, 111, 10, 
	114, 10, 97, 10, 97, 10, 116, 10, 
	97, 101, 105, 111, 10, 117, 10, 110, 
	10, 122, 10, 105, 10, 111, 10, 110, 
	10, 97, 10, 108, 10, 105, 10, 116, 
	-61, 10, -96, 10, 10, 58, 10, 117, 
	10, 97, 10, 110, 10, 100, 10, 111, 
	10, 99, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 111, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, 10, 32, 34, 35, 37, 
	42, 64, 65, 67, 68, 69, 70, 77, 
	81, 83, 124, 9, 13, 10, 108, 10, 
	108, 10, 111, 10, 114, 10, 97, 10, 
	97, 10, 116, 10, 97, 101, 105, 111, 
	10, 117, 10, 110, 10, 122, 10, 105, 
	10, 111, 10, 110, 10, 97, 10, 108, 
	10, 105, 10, 116, -61, 10, -96, 10, 
	10, 58, 10, 117, 10, 97, 10, 110, 
	10, 100, 10, 111, 10, 99, 10, 101, 
	104, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 111, 10, 101, 10, 109, 10, 
	97, 10, 32, 10, 100, 10, 101, 10, 
	108, 10, 108, 10, 111, 10, 32, 10, 
	115, 10, 99, 10, 101, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 13, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 16, 1, 1, 4, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	5, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 9, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 14, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 5, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	13, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 5, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 4, 3, 2, 4, 16, 2, 
	2, 2, 2, 2, 2, 2, 5, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 0, 0, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 139, 141, 
	143, 145, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 165, 167, 182, 185, 188, 
	191, 194, 197, 200, 203, 206, 209, 212, 
	215, 218, 221, 224, 227, 245, 247, 249, 
	254, 257, 259, 261, 263, 265, 267, 269, 
	271, 278, 281, 284, 287, 290, 293, 296, 
	299, 302, 305, 308, 311, 314, 317, 319, 
	321, 323, 325, 327, 329, 331, 333, 335, 
	337, 339, 341, 343, 345, 347, 358, 361, 
	364, 367, 370, 373, 376, 379, 382, 385, 
	388, 391, 394, 397, 400, 403, 406, 409, 
	412, 415, 418, 421, 424, 427, 430, 433, 
	436, 439, 442, 445, 448, 451, 454, 457, 
	460, 463, 466, 469, 472, 475, 478, 482, 
	485, 488, 491, 494, 497, 500, 503, 506, 
	509, 512, 515, 518, 521, 524, 527, 530, 
	533, 535, 537, 539, 541, 543, 545, 548, 
	550, 552, 554, 556, 558, 560, 562, 564, 
	580, 583, 586, 589, 592, 595, 598, 601, 
	604, 607, 610, 613, 616, 619, 622, 625, 
	628, 631, 634, 637, 640, 643, 646, 649, 
	652, 655, 658, 661, 664, 667, 670, 676, 
	679, 682, 685, 688, 691, 694, 697, 700, 
	703, 706, 709, 712, 715, 718, 721, 724, 
	727, 730, 734, 737, 740, 743, 746, 749, 
	752, 755, 758, 761, 764, 767, 770, 773, 
	776, 779, 782, 785, 787, 789, 791, 793, 
	795, 797, 799, 801, 803, 805, 807, 809, 
	811, 813, 815, 817, 819, 821, 823, 825, 
	827, 842, 845, 848, 851, 854, 857, 860, 
	863, 866, 869, 872, 875, 878, 881, 884, 
	887, 890, 893, 896, 899, 902, 905, 908, 
	914, 917, 920, 923, 926, 929, 932, 935, 
	938, 941, 944, 947, 950, 953, 956, 959, 
	962, 965, 968, 971, 974, 977, 980, 983, 
	986, 989, 993, 999, 1003, 1006, 1012, 1030, 
	1033, 1036, 1039, 1042, 1045, 1048, 1051, 1057, 
	1060, 1063, 1066, 1069, 1072, 1075, 1078, 1081, 
	1084, 1087, 1090, 1093, 1096, 1099, 1102, 1105, 
	1108, 1111, 1114, 1118, 1121, 1124, 1127, 1130, 
	1133, 1136, 1139, 1142, 1145, 1148, 1151, 1154, 
	1157, 1160, 1163, 1166, 1169, 1172
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 42, 69, 72, 94, 41, 168, 173, 
	321, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 42, 
	69, 72, 94, 41, 168, 173, 321, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 373, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 0, 39, 0, 40, 0, 41, 
	0, 31, 0, 43, 0, 44, 0, 45, 
	0, 46, 0, 47, 0, 48, 0, 49, 
	0, 50, 0, 52, 51, 52, 51, 52, 
	52, 4, 53, 67, 4, 327, 332, 67, 
	335, 331, 348, 353, 52, 51, 52, 54, 
	51, 52, 55, 51, 52, 56, 51, 52, 
	57, 51, 52, 58, 51, 52, 59, 51, 
	52, 60, 51, 52, 61, 51, 52, 62, 
	51, 52, 63, 51, 52, 64, 51, 52, 
	65, 51, 52, 66, 51, 52, 4, 51, 
	52, 68, 51, 4, 4, 5, 15, 17, 
	31, 34, 37, 42, 69, 72, 94, 41, 
	168, 173, 321, 4, 0, 70, 0, 71, 
	0, 31, 31, 31, 31, 0, 32, 73, 
	0, 74, 0, 75, 0, 76, 0, 77, 
	0, 78, 0, 80, 79, 80, 79, 80, 
	80, 4, 81, 4, 80, 79, 80, 82, 
	79, 80, 83, 79, 80, 84, 79, 80, 
	85, 79, 80, 86, 79, 80, 87, 79, 
	80, 88, 79, 80, 89, 79, 80, 90, 
	79, 80, 91, 79, 92, 80, 79, 93, 
	80, 79, 80, 68, 79, 95, 0, 96, 
	0, 97, 0, 98, 0, 99, 0, 100, 
	0, 101, 0, 102, 0, 103, 0, 104, 
	0, 105, 0, 106, 0, 107, 0, 109, 
	108, 109, 108, 109, 109, 4, 110, 4, 
	124, 132, 137, 149, 109, 108, 109, 111, 
	108, 109, 112, 108, 109, 113, 108, 109, 
	114, 108, 109, 115, 108, 109, 116, 108, 
	109, 117, 108, 109, 118, 108, 109, 119, 
	108, 109, 120, 108, 109, 121, 108, 109, 
	122, 108, 109, 123, 108, 109, 4, 108, 
	109, 125, 108, 109, 126, 108, 109, 127, 
	108, 109, 128, 108, 109, 129, 108, 109, 
	130, 108, 109, 131, 108, 109, 68, 108, 
	109, 133, 108, 109, 134, 108, 109, 135, 
	108, 109, 136, 108, 109, 131, 108, 109, 
	138, 108, 109, 139, 108, 109, 140, 108, 
	109, 141, 108, 109, 142, 108, 109, 143, 
	108, 109, 144, 108, 109, 145, 108, 109, 
	146, 108, 109, 147, 108, 148, 109, 108, 
	131, 109, 108, 109, 150, 108, 109, 151, 
	155, 108, 109, 152, 108, 109, 153, 108, 
	109, 154, 108, 109, 130, 108, 109, 156, 
	108, 109, 157, 108, 109, 158, 108, 109, 
	159, 108, 109, 160, 108, 109, 161, 108, 
	109, 162, 108, 109, 163, 108, 109, 164, 
	108, 109, 165, 108, 109, 166, 108, 109, 
	167, 108, 109, 151, 108, 169, 0, 170, 
	0, 171, 0, 172, 0, 31, 0, 174, 
	0, 175, 251, 0, 176, 0, 177, 0, 
	178, 0, 179, 0, 180, 0, 181, 0, 
	183, 182, 183, 182, 183, 183, 4, 184, 
	198, 4, 199, 204, 212, 198, 215, 203, 
	227, 232, 183, 182, 183, 185, 182, 183, 
	186, 182, 183, 187, 182, 183, 188, 182, 
	183, 189, 182, 183, 190, 182, 183, 191, 
	182, 183, 192, 182, 183, 193, 182, 183, 
	194, 182, 183, 195, 182, 183, 196, 182, 
	183, 197, 182, 183, 4, 182, 183, 68, 
	182, 183, 200, 182, 183, 201, 182, 183, 
	202, 182, 183, 203, 182, 183, 198, 182, 
	183, 205, 182, 183, 206, 182, 183, 207, 
	182, 183, 208, 182, 183, 209, 182, 183, 
	210, 182, 183, 211, 182, 183, 68, 182, 
	183, 213, 182, 183, 214, 182, 183, 198, 
	198, 198, 198, 182, 183, 216, 182, 183, 
	217, 182, 183, 218, 182, 183, 219, 182, 
	183, 220, 182, 183, 221, 182, 183, 222, 
	182, 183, 223, 182, 183, 224, 182, 183, 
	225, 182, 226, 183, 182, 211, 183, 182, 
	183, 228, 182, 183, 229, 182, 183, 230, 
	182, 183, 231, 182, 183, 198, 182, 183, 
	233, 182, 183, 234, 238, 182, 183, 235, 
	182, 183, 236, 182, 183, 237, 182, 183, 
	210, 182, 183, 239, 182, 183, 240, 182, 
	183, 241, 182, 183, 242, 182, 183, 243, 
	182, 183, 244, 182, 183, 245, 182, 183, 
	246, 182, 183, 247, 182, 183, 248, 182, 
	183, 249, 182, 183, 250, 182, 183, 234, 
	182, 252, 0, 253, 0, 254, 0, 255, 
	0, 256, 0, 257, 0, 258, 0, 259, 
	0, 260, 0, 261, 0, 262, 0, 263, 
	0, 264, 0, 265, 0, 266, 0, 267, 
	0, 268, 0, 269, 0, 270, 0, 272, 
	271, 272, 271, 272, 272, 4, 273, 287, 
	4, 288, 293, 287, 296, 292, 309, 314, 
	272, 271, 272, 274, 271, 272, 275, 271, 
	272, 276, 271, 272, 277, 271, 272, 278, 
	271, 272, 279, 271, 272, 280, 271, 272, 
	281, 271, 272, 282, 271, 272, 283, 271, 
	272, 284, 271, 272, 285, 271, 272, 286, 
	271, 272, 4, 271, 272, 68, 271, 272, 
	289, 271, 272, 290, 271, 272, 291, 271, 
	272, 292, 271, 272, 287, 271, 272, 294, 
	271, 272, 295, 271, 272, 287, 287, 287, 
	287, 271, 272, 297, 271, 272, 298, 271, 
	272, 299, 271, 272, 300, 271, 272, 301, 
	271, 272, 302, 271, 272, 303, 271, 272, 
	304, 271, 272, 305, 271, 272, 306, 271, 
	307, 272, 271, 308, 272, 271, 272, 68, 
	271, 272, 310, 271, 272, 311, 271, 272, 
	312, 271, 272, 313, 271, 272, 287, 271, 
	272, 315, 271, 272, 316, 271, 272, 317, 
	271, 272, 318, 271, 272, 319, 271, 272, 
	320, 271, 272, 308, 271, 321, 322, 321, 
	0, 326, 325, 324, 322, 325, 323, 0, 
	324, 322, 323, 0, 324, 323, 326, 325, 
	324, 322, 325, 323, 326, 326, 5, 15, 
	17, 31, 34, 37, 42, 69, 72, 94, 
	41, 168, 173, 321, 326, 0, 52, 328, 
	51, 52, 329, 51, 52, 330, 51, 52, 
	331, 51, 52, 67, 51, 52, 333, 51, 
	52, 334, 51, 52, 67, 67, 67, 67, 
	51, 52, 336, 51, 52, 337, 51, 52, 
	338, 51, 52, 339, 51, 52, 340, 51, 
	52, 341, 51, 52, 342, 51, 52, 343, 
	51, 52, 344, 51, 52, 345, 51, 346, 
	52, 51, 347, 52, 51, 52, 68, 51, 
	52, 349, 51, 52, 350, 51, 52, 351, 
	51, 52, 352, 51, 52, 67, 51, 52, 
	354, 51, 52, 355, 360, 51, 52, 356, 
	51, 52, 357, 51, 52, 358, 51, 52, 
	359, 51, 52, 347, 51, 52, 361, 51, 
	52, 362, 51, 52, 363, 51, 52, 364, 
	51, 52, 365, 51, 52, 366, 51, 52, 
	367, 51, 52, 368, 51, 52, 369, 51, 
	52, 370, 51, 52, 371, 51, 52, 372, 
	51, 52, 355, 51, 0, 0
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
	43, 0, 43, 0, 43, 0, 43, 0, 
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
	54, 15, 0, 130, 31, 60, 57, 31, 
	63, 57, 63, 63, 63, 63, 63, 63, 
	63, 63, 66, 31, 43, 0, 43, 0, 
	43, 0, 0, 0, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 81, 84, 81, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 21, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 69, 33, 69, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 75, 33, 
	84, 75, 84, 84, 84, 84, 84, 84, 
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
	0, 0, 54, 0, 0, 54, 17, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
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
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 78, 33, 84, 
	78, 84, 84, 84, 84, 84, 84, 84, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 19, 0, 54, 19, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 19, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 0, 0, 
	43, 54, 37, 37, 87, 37, 37, 43, 
	0, 39, 0, 43, 0, 0, 54, 0, 
	0, 39, 0, 0, 54, 0, 93, 90, 
	41, 96, 90, 96, 96, 96, 96, 96, 
	96, 96, 96, 99, 0, 43, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 15, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 0
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
	43, 43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 373;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"

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
    
    
#line 944 "ext/gherkin_lexer_it/gherkin_lexer_it.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
    
#line 951 "ext/gherkin_lexer_it/gherkin_lexer_it.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
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
#line 1241 "ext/gherkin_lexer_it/gherkin_lexer_it.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"
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
#line 1304 "ext/gherkin_lexer_it/gherkin_lexer_it.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/it.c.rl"

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

void Init_gherkin_lexer_it()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "It", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

