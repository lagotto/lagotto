
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
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
	127, 128, 135, 137, 139, 141, 143, 145, 
	147, 149, 151, 153, 155, 157, 159, 161, 
	163, 165, 167, 187, 188, 189, 190, 191, 
	192, 193, 194, 195, 196, 197, 198, 199, 
	200, 201, 202, 203, 204, 205, 217, 219, 
	221, 223, 225, 227, 229, 231, 233, 235, 
	237, 239, 241, 243, 245, 247, 249, 251, 
	253, 255, 257, 259, 261, 263, 265, 267, 
	269, 271, 273, 275, 277, 279, 281, 283, 
	285, 287, 289, 291, 293, 295, 297, 299, 
	301, 303, 305, 307, 309, 311, 313, 315, 
	317, 319, 321, 323, 325, 327, 329, 331, 
	333, 335, 337, 339, 341, 343, 345, 347, 
	349, 350, 351, 352, 353, 354, 355, 356, 
	357, 358, 359, 360, 361, 362, 378, 380, 
	382, 384, 386, 388, 390, 392, 394, 396, 
	398, 400, 402, 404, 406, 408, 410, 412, 
	414, 416, 418, 420, 422, 424, 426, 428, 
	430, 432, 434, 436, 438, 440, 442, 444, 
	446, 448, 450, 452, 454, 456, 458, 460, 
	462, 464, 466, 468, 470, 472, 474, 478, 
	480, 482, 484, 486, 488, 490, 492, 494, 
	496, 498, 500, 502, 504, 505, 506, 507, 
	508, 509, 510, 511, 512, 513, 514, 515, 
	516, 517, 518, 519, 520, 521, 522, 523, 
	524, 539, 541, 543, 545, 547, 549, 551, 
	553, 555, 557, 559, 561, 563, 565, 567, 
	569, 571, 573, 575, 577, 579, 581, 583, 
	585, 587, 589, 591, 593, 595, 597, 599, 
	601, 603, 605, 607, 609, 611, 613, 615, 
	619, 621, 623, 625, 627, 629, 631, 633, 
	635, 637, 639, 641, 643, 645, 646, 647, 
	648, 649, 650, 651, 652, 653, 654, 655, 
	672, 674, 676, 678, 680, 682, 684, 686, 
	688, 690, 692, 694, 696, 698, 700, 702, 
	704, 706, 708, 710, 712, 714, 716, 718, 
	720, 722, 724, 726, 728, 730, 732, 734, 
	736, 738, 740, 742, 744, 746, 748, 750, 
	752, 754, 756, 758, 760, 762, 764, 766, 
	768, 770, 772, 774, 776, 778, 780, 782, 
	784, 786, 788, 792, 794, 796, 798, 800, 
	802, 804, 806, 808, 810, 812, 814, 816, 
	818, 821, 822, 823, 824, 825, 826, 827, 
	828, 829, 830, 831, 832, 833, 834, 838, 
	844, 847, 849, 855, 875
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	66, 70, 72, 80, 83, 97, 100, 109, 
	117, 119, 124, 9, 13, -69, -65, 10, 
	32, 34, 35, 37, 42, 64, 66, 70, 
	72, 80, 83, 97, 100, 109, 117, 119, 
	124, 9, 13, 34, 34, 10, 13, 10, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 9, 
	13, 10, 32, 9, 13, 10, 13, 10, 
	95, 70, 69, 65, 84, 85, 82, 69, 
	95, 69, 78, 68, 95, 37, 32, 10, 
	13, 10, 13, 13, 32, 64, 9, 10, 
	9, 10, 13, 32, 64, 11, 12, 10, 
	32, 64, 9, 13, 101, 105, 115, 112, 
	105, 108, 108, 101, 114, 58, 10, 10, 
	10, 32, 35, 70, 124, 9, 13, 10, 
	117, 10, 110, 10, 107, 10, 116, 10, 
	105, 10, 111, 10, 110, 10, 97, 10, 
	108, 10, 105, 10, 116, -61, 10, -87, 
	10, 10, 105, 10, 116, 10, 58, 10, 
	32, 34, 35, 37, 42, 64, 66, 70, 
	72, 80, 83, 97, 100, 109, 117, 119, 
	124, 9, 13, 117, 110, 107, 116, 105, 
	111, 110, 97, 108, 105, 116, -61, -87, 
	105, 116, 58, 10, 10, 10, 32, 35, 
	37, 64, 66, 70, 72, 80, 83, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 101, 10, 
	105, 10, 115, 10, 112, 10, 105, 10, 
	108, 10, 108, 10, 101, 10, 114, 10, 
	58, 10, 117, 10, 110, 10, 107, 10, 
	116, 10, 105, 10, 111, 10, 110, 10, 
	97, 10, 108, 10, 105, 10, 116, -61, 
	10, -87, 10, 10, 105, 10, 116, 10, 
	97, 10, 110, 10, 110, 10, 101, 10, 
	114, 10, 103, 10, 114, 10, 111, 10, 
	110, 10, 100, 10, 108, 10, 97, 10, 
	110, 10, 103, 10, 32, 10, 118, 10, 
	117, 10, 109, 10, 32, 10, 83, 10, 
	122, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 111, 97, 110, 110, 
	101, 114, 103, 114, 111, 110, 100, 58, 
	10, 10, 10, 32, 35, 37, 42, 64, 
	70, 80, 83, 97, 100, 109, 117, 119, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 117, 10, 110, 10, 107, 10, 116, 
	10, 105, 10, 111, 10, 110, 10, 97, 
	10, 108, 10, 105, 10, 116, -61, 10, 
	-87, 10, 10, 105, 10, 116, 10, 58, 
	10, 108, 10, 97, 10, 110, 10, 103, 
	10, 32, 10, 118, 10, 117, 10, 109, 
	10, 32, 10, 83, 10, 122, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 111, 10, 32, 110, 119, 10, 101, 
	10, 114, 10, 97, 10, 110, 10, 110, 
	-61, 10, -92, 10, 10, 103, 10, 101, 
	10, 104, 10, 111, 10, 108, 10, 108, 
	108, 97, 110, 103, 32, 118, 117, 109, 
	32, 83, 122, 101, 110, 97, 114, 105, 
	111, 58, 10, 10, 10, 32, 35, 37, 
	42, 64, 70, 83, 97, 100, 109, 117, 
	119, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 117, 10, 110, 10, 107, 10, 
	116, 10, 105, 10, 111, 10, 110, 10, 
	97, 10, 108, 10, 105, 10, 116, -61, 
	10, -87, 10, 10, 105, 10, 116, 10, 
	58, 10, 122, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	32, 110, 119, 10, 101, 10, 114, 10, 
	97, 10, 110, 10, 110, -61, 10, -92, 
	10, 10, 103, 10, 101, 10, 104, 10, 
	111, 10, 108, 10, 108, 122, 101, 110, 
	97, 114, 105, 111, 58, 10, 10, 10, 
	32, 35, 37, 42, 64, 70, 72, 80, 
	83, 97, 100, 109, 117, 119, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 117, 
	10, 110, 10, 107, 10, 116, 10, 105, 
	10, 111, 10, 110, 10, 97, 10, 108, 
	10, 105, 10, 116, -61, 10, -87, 10, 
	10, 105, 10, 116, 10, 58, 10, 97, 
	10, 110, 10, 110, 10, 101, 10, 114, 
	10, 103, 10, 114, 10, 111, 10, 110, 
	10, 100, 10, 108, 10, 97, 10, 110, 
	10, 103, 10, 32, 10, 118, 10, 117, 
	10, 109, 10, 32, 10, 83, 10, 122, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 10, 32, 110, 119, 
	10, 101, 10, 114, 10, 97, 10, 110, 
	10, 110, -61, 10, -92, 10, 10, 103, 
	10, 101, 10, 104, 10, 111, 10, 108, 
	10, 108, 32, 110, 119, 101, 114, 97, 
	110, 110, -61, -92, 103, 101, 104, 111, 
	108, 108, 32, 124, 9, 13, 10, 32, 
	92, 124, 9, 13, 10, 92, 124, 10, 
	92, 10, 32, 92, 124, 9, 13, 10, 
	32, 34, 35, 37, 42, 64, 66, 70, 
	72, 80, 83, 97, 100, 109, 117, 119, 
	124, 9, 13, 0
};

static const char _lexer_single_lengths[] = {
	0, 19, 1, 1, 18, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 5, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 18, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 10, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 14, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 4, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	13, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 4, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 15, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 4, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 4, 
	3, 2, 4, 18, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 1, 1, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 21, 23, 25, 45, 47, 49, 
	52, 55, 60, 65, 70, 75, 79, 83, 
	86, 88, 90, 92, 94, 96, 98, 100, 
	102, 104, 106, 108, 110, 112, 114, 116, 
	118, 121, 124, 129, 136, 141, 143, 145, 
	147, 149, 151, 153, 155, 157, 159, 161, 
	163, 165, 172, 175, 178, 181, 184, 187, 
	190, 193, 196, 199, 202, 205, 208, 211, 
	214, 217, 220, 240, 242, 244, 246, 248, 
	250, 252, 254, 256, 258, 260, 262, 264, 
	266, 268, 270, 272, 274, 276, 288, 291, 
	294, 297, 300, 303, 306, 309, 312, 315, 
	318, 321, 324, 327, 330, 333, 336, 339, 
	342, 345, 348, 351, 354, 357, 360, 363, 
	366, 369, 372, 375, 378, 381, 384, 387, 
	390, 393, 396, 399, 402, 405, 408, 411, 
	414, 417, 420, 423, 426, 429, 432, 435, 
	438, 441, 444, 447, 450, 453, 456, 459, 
	462, 465, 468, 471, 474, 477, 480, 483, 
	486, 488, 490, 492, 494, 496, 498, 500, 
	502, 504, 506, 508, 510, 512, 528, 531, 
	534, 537, 540, 543, 546, 549, 552, 555, 
	558, 561, 564, 567, 570, 573, 576, 579, 
	582, 585, 588, 591, 594, 597, 600, 603, 
	606, 609, 612, 615, 618, 621, 624, 627, 
	630, 633, 636, 639, 642, 645, 648, 651, 
	654, 657, 660, 663, 666, 669, 672, 677, 
	680, 683, 686, 689, 692, 695, 698, 701, 
	704, 707, 710, 713, 716, 718, 720, 722, 
	724, 726, 728, 730, 732, 734, 736, 738, 
	740, 742, 744, 746, 748, 750, 752, 754, 
	756, 771, 774, 777, 780, 783, 786, 789, 
	792, 795, 798, 801, 804, 807, 810, 813, 
	816, 819, 822, 825, 828, 831, 834, 837, 
	840, 843, 846, 849, 852, 855, 858, 861, 
	864, 867, 870, 873, 876, 879, 882, 885, 
	890, 893, 896, 899, 902, 905, 908, 911, 
	914, 917, 920, 923, 926, 929, 931, 933, 
	935, 937, 939, 941, 943, 945, 947, 949, 
	966, 969, 972, 975, 978, 981, 984, 987, 
	990, 993, 996, 999, 1002, 1005, 1008, 1011, 
	1014, 1017, 1020, 1023, 1026, 1029, 1032, 1035, 
	1038, 1041, 1044, 1047, 1050, 1053, 1056, 1059, 
	1062, 1065, 1068, 1071, 1074, 1077, 1080, 1083, 
	1086, 1089, 1092, 1095, 1098, 1101, 1104, 1107, 
	1110, 1113, 1116, 1119, 1122, 1125, 1128, 1131, 
	1134, 1137, 1140, 1145, 1148, 1151, 1154, 1157, 
	1160, 1163, 1166, 1169, 1172, 1175, 1178, 1181, 
	1184, 1188, 1190, 1192, 1194, 1196, 1198, 1200, 
	1202, 1204, 1206, 1208, 1210, 1212, 1214, 1218, 
	1224, 1228, 1231, 1237, 1257
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 67, 152, 228, 301, 384, 387, 390, 
	392, 387, 398, 4, 0, 3, 0, 4, 
	0, 4, 4, 5, 15, 17, 31, 34, 
	37, 67, 152, 228, 301, 384, 387, 390, 
	392, 387, 398, 4, 0, 6, 0, 7, 
	0, 9, 8, 8, 9, 8, 8, 10, 
	10, 11, 10, 10, 10, 10, 11, 10, 
	10, 10, 10, 12, 10, 10, 10, 10, 
	13, 10, 10, 4, 14, 14, 0, 4, 
	14, 14, 0, 4, 16, 15, 4, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 23, 0, 24, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	30, 0, 404, 0, 32, 0, 4, 16, 
	33, 4, 16, 33, 0, 0, 0, 0, 
	35, 36, 4, 36, 36, 34, 35, 35, 
	4, 36, 34, 36, 0, 38, 0, 39, 
	0, 40, 0, 41, 0, 42, 0, 43, 
	0, 44, 0, 45, 0, 46, 0, 47, 
	0, 49, 48, 49, 48, 49, 49, 4, 
	50, 4, 49, 48, 49, 51, 48, 49, 
	52, 48, 49, 53, 48, 49, 54, 48, 
	49, 55, 48, 49, 56, 48, 49, 57, 
	48, 49, 58, 48, 49, 59, 48, 49, 
	60, 48, 49, 61, 48, 62, 49, 48, 
	63, 49, 48, 49, 64, 48, 49, 65, 
	48, 49, 66, 48, 4, 4, 5, 15, 
	17, 31, 34, 37, 67, 152, 228, 301, 
	384, 387, 390, 392, 387, 398, 4, 0, 
	68, 0, 69, 0, 70, 0, 71, 0, 
	72, 0, 73, 0, 74, 0, 75, 0, 
	76, 0, 77, 0, 78, 0, 79, 0, 
	80, 0, 81, 0, 82, 0, 83, 0, 
	85, 84, 85, 84, 85, 85, 4, 86, 
	4, 100, 110, 125, 135, 145, 85, 84, 
	85, 87, 84, 85, 88, 84, 85, 89, 
	84, 85, 90, 84, 85, 91, 84, 85, 
	92, 84, 85, 93, 84, 85, 94, 84, 
	85, 95, 84, 85, 96, 84, 85, 97, 
	84, 85, 98, 84, 85, 99, 84, 85, 
	4, 84, 85, 101, 84, 85, 102, 84, 
	85, 103, 84, 85, 104, 84, 85, 105, 
	84, 85, 106, 84, 85, 107, 84, 85, 
	108, 84, 85, 109, 84, 85, 66, 84, 
	85, 111, 84, 85, 112, 84, 85, 113, 
	84, 85, 114, 84, 85, 115, 84, 85, 
	116, 84, 85, 117, 84, 85, 118, 84, 
	85, 119, 84, 85, 120, 84, 85, 121, 
	84, 122, 85, 84, 123, 85, 84, 85, 
	124, 84, 85, 109, 84, 85, 126, 84, 
	85, 127, 84, 85, 128, 84, 85, 129, 
	84, 85, 130, 84, 85, 131, 84, 85, 
	132, 84, 85, 133, 84, 85, 134, 84, 
	85, 109, 84, 85, 136, 84, 85, 137, 
	84, 85, 138, 84, 85, 139, 84, 85, 
	140, 84, 85, 141, 84, 85, 142, 84, 
	85, 143, 84, 85, 144, 84, 85, 145, 
	84, 85, 146, 84, 85, 147, 84, 85, 
	148, 84, 85, 149, 84, 85, 150, 84, 
	85, 151, 84, 85, 109, 84, 153, 0, 
	154, 0, 155, 0, 156, 0, 157, 0, 
	158, 0, 159, 0, 160, 0, 161, 0, 
	162, 0, 163, 0, 165, 164, 165, 164, 
	165, 165, 4, 166, 180, 4, 181, 197, 
	207, 214, 217, 220, 222, 217, 165, 164, 
	165, 167, 164, 165, 168, 164, 165, 169, 
	164, 165, 170, 164, 165, 171, 164, 165, 
	172, 164, 165, 173, 164, 165, 174, 164, 
	165, 175, 164, 165, 176, 164, 165, 177, 
	164, 165, 178, 164, 165, 179, 164, 165, 
	4, 164, 165, 66, 164, 165, 182, 164, 
	165, 183, 164, 165, 184, 164, 165, 185, 
	164, 165, 186, 164, 165, 187, 164, 165, 
	188, 164, 165, 189, 164, 165, 190, 164, 
	165, 191, 164, 165, 192, 164, 193, 165, 
	164, 194, 165, 164, 165, 195, 164, 165, 
	196, 164, 165, 66, 164, 165, 198, 164, 
	165, 199, 164, 165, 200, 164, 165, 201, 
	164, 165, 202, 164, 165, 203, 164, 165, 
	204, 164, 165, 205, 164, 165, 206, 164, 
	165, 207, 164, 165, 208, 164, 165, 209, 
	164, 165, 210, 164, 165, 211, 164, 165, 
	212, 164, 165, 213, 164, 165, 196, 164, 
	165, 66, 180, 215, 164, 165, 216, 164, 
	165, 180, 164, 165, 218, 164, 165, 219, 
	164, 165, 180, 164, 221, 165, 164, 180, 
	165, 164, 165, 223, 164, 165, 224, 164, 
	165, 225, 164, 165, 226, 164, 165, 227, 
	164, 165, 180, 164, 229, 0, 230, 0, 
	231, 0, 232, 0, 233, 0, 234, 0, 
	235, 0, 236, 0, 237, 0, 238, 0, 
	239, 0, 240, 0, 241, 0, 242, 0, 
	243, 0, 244, 0, 245, 0, 246, 0, 
	248, 247, 248, 247, 248, 248, 4, 249, 
	263, 4, 264, 280, 287, 290, 293, 295, 
	290, 248, 247, 248, 250, 247, 248, 251, 
	247, 248, 252, 247, 248, 253, 247, 248, 
	254, 247, 248, 255, 247, 248, 256, 247, 
	248, 257, 247, 248, 258, 247, 248, 259, 
	247, 248, 260, 247, 248, 261, 247, 248, 
	262, 247, 248, 4, 247, 248, 66, 247, 
	248, 265, 247, 248, 266, 247, 248, 267, 
	247, 248, 268, 247, 248, 269, 247, 248, 
	270, 247, 248, 271, 247, 248, 272, 247, 
	248, 273, 247, 248, 274, 247, 248, 275, 
	247, 276, 248, 247, 277, 248, 247, 248, 
	278, 247, 248, 279, 247, 248, 66, 247, 
	248, 281, 247, 248, 282, 247, 248, 283, 
	247, 248, 284, 247, 248, 285, 247, 248, 
	286, 247, 248, 279, 247, 248, 66, 263, 
	288, 247, 248, 289, 247, 248, 263, 247, 
	248, 291, 247, 248, 292, 247, 248, 263, 
	247, 294, 248, 247, 263, 248, 247, 248, 
	296, 247, 248, 297, 247, 248, 298, 247, 
	248, 299, 247, 248, 300, 247, 248, 263, 
	247, 302, 0, 303, 0, 304, 0, 305, 
	0, 306, 0, 307, 0, 308, 0, 309, 
	0, 311, 310, 311, 310, 311, 311, 4, 
	312, 326, 4, 327, 343, 353, 363, 370, 
	373, 376, 378, 373, 311, 310, 311, 313, 
	310, 311, 314, 310, 311, 315, 310, 311, 
	316, 310, 311, 317, 310, 311, 318, 310, 
	311, 319, 310, 311, 320, 310, 311, 321, 
	310, 311, 322, 310, 311, 323, 310, 311, 
	324, 310, 311, 325, 310, 311, 4, 310, 
	311, 66, 310, 311, 328, 310, 311, 329, 
	310, 311, 330, 310, 311, 331, 310, 311, 
	332, 310, 311, 333, 310, 311, 334, 310, 
	311, 335, 310, 311, 336, 310, 311, 337, 
	310, 311, 338, 310, 339, 311, 310, 340, 
	311, 310, 311, 341, 310, 311, 342, 310, 
	311, 66, 310, 311, 344, 310, 311, 345, 
	310, 311, 346, 310, 311, 347, 310, 311, 
	348, 310, 311, 349, 310, 311, 350, 310, 
	311, 351, 310, 311, 352, 310, 311, 342, 
	310, 311, 354, 310, 311, 355, 310, 311, 
	356, 310, 311, 357, 310, 311, 358, 310, 
	311, 359, 310, 311, 360, 310, 311, 361, 
	310, 311, 362, 310, 311, 363, 310, 311, 
	364, 310, 311, 365, 310, 311, 366, 310, 
	311, 367, 310, 311, 368, 310, 311, 369, 
	310, 311, 342, 310, 311, 66, 326, 371, 
	310, 311, 372, 310, 311, 326, 310, 311, 
	374, 310, 311, 375, 310, 311, 326, 310, 
	377, 311, 310, 326, 311, 310, 311, 379, 
	310, 311, 380, 310, 311, 381, 310, 311, 
	382, 310, 311, 383, 310, 311, 326, 310, 
	32, 31, 385, 0, 386, 0, 31, 0, 
	388, 0, 389, 0, 31, 0, 391, 0, 
	31, 0, 393, 0, 394, 0, 395, 0, 
	396, 0, 397, 0, 31, 0, 398, 399, 
	398, 0, 403, 402, 401, 399, 402, 400, 
	0, 401, 399, 400, 0, 401, 400, 403, 
	402, 401, 399, 402, 400, 403, 403, 5, 
	15, 17, 31, 34, 37, 67, 152, 228, 
	301, 384, 387, 390, 392, 387, 398, 403, 
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
	43, 144, 57, 54, 0, 54, 0, 81, 
	84, 81, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 54, 0, 0, 54, 0, 
	0, 54, 21, 0, 130, 31, 60, 57, 
	31, 63, 57, 63, 63, 63, 63, 63, 
	63, 63, 63, 63, 63, 66, 31, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
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
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
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
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 15, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 15, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
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
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 19, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 19, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 43, 0, 43, 0, 43, 0, 
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
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 17, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 17, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
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
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 404;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"

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
    
    
#line 993 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
    
#line 1000 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
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
#line 1290 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"
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
#line 1353 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lu.c.rl"

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

void Init_gherkin_lexer_lu()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Lu", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

