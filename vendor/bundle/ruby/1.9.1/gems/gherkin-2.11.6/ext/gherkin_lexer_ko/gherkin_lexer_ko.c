
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
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
	0, 0, 15, 17, 18, 19, 21, 22, 
	23, 24, 25, 27, 29, 43, 47, 48, 
	49, 50, 52, 53, 54, 55, 56, 57, 
	58, 59, 60, 61, 62, 63, 64, 65, 
	77, 80, 82, 84, 87, 89, 91, 93, 
	95, 109, 112, 113, 114, 115, 116, 117, 
	118, 119, 120, 121, 122, 124, 125, 126, 
	127, 128, 129, 130, 131, 132, 133, 145, 
	148, 150, 152, 155, 157, 159, 161, 163, 
	165, 167, 169, 171, 173, 175, 177, 179, 
	181, 185, 187, 189, 191, 194, 196, 198, 
	200, 202, 204, 206, 209, 211, 213, 215, 
	217, 219, 221, 223, 225, 227, 229, 231, 
	233, 235, 237, 239, 241, 243, 245, 247, 
	249, 251, 253, 255, 257, 259, 261, 263, 
	265, 267, 269, 271, 273, 275, 277, 279, 
	281, 282, 283, 295, 298, 300, 302, 305, 
	307, 309, 311, 313, 315, 317, 319, 321, 
	323, 325, 327, 329, 331, 336, 338, 340, 
	342, 345, 347, 349, 351, 353, 355, 357, 
	359, 361, 363, 365, 368, 370, 372, 374, 
	376, 378, 380, 382, 384, 386, 388, 391, 
	393, 395, 397, 399, 401, 403, 405, 407, 
	409, 411, 413, 415, 417, 419, 421, 423, 
	425, 427, 429, 431, 433, 435, 437, 439, 
	441, 443, 445, 447, 449, 451, 453, 455, 
	456, 457, 458, 459, 466, 468, 470, 472, 
	474, 476, 478, 479, 480, 481, 482, 483, 
	484, 485, 486, 487, 488, 489, 490, 491, 
	493, 495, 500, 505, 510, 515, 519, 523, 
	525, 526, 527, 528, 529, 530, 531, 532, 
	533, 534, 535, 536, 537, 538, 539, 540, 
	541, 546, 553, 558, 562, 568, 571, 573, 
	579, 593, 595, 597, 599, 601, 603, 605, 
	607, 609, 611, 615, 617, 619, 621, 624, 
	626, 628, 630, 632, 634, 636, 639, 641, 
	643, 645, 647, 649, 651, 653, 655, 657, 
	659, 662, 664, 666, 668, 670, 672, 674, 
	676, 678, 680, 682, 684, 686, 688, 690, 
	692, 694, 696, 698, 700, 702, 704, 706, 
	708, 710, 712, 714, 716, 718, 720, 722, 
	724, 726, 727, 728, 729, 730, 731, 732, 
	733, 734, 735, 736, 737, 747, 749, 751, 
	753, 755, 757, 759, 761, 763, 765, 767, 
	769, 772, 774, 776, 778, 780, 782, 784, 
	786, 788, 790, 792, 795, 797, 799, 801, 
	803, 805, 807, 809, 811, 813, 815, 817, 
	819, 821, 823, 825, 827, 829, 831, 833, 
	835, 837, 838, 839
};

static const char _lexer_trans_keys[] = {
	-22, -21, -20, -19, -17, 10, 32, 34, 
	35, 37, 42, 64, 124, 9, 13, -73, 
	-72, -72, -21, -97, -90, -84, -21, -87, 
	-76, 10, 13, 10, 13, -22, -21, -20, 
	-19, 10, 32, 34, 35, 37, 42, 64, 
	124, 9, 13, -117, -89, -88, -80, -88, 
	-116, -20, -107, -99, -67, -68, -68, -20, 
	-96, -128, -80, -22, -78, -67, 58, 10, 
	10, -22, -21, -20, -19, 10, 32, 35, 
	37, 42, 64, 9, 13, -73, -72, 10, 
	-72, 10, -21, 10, -97, -90, 10, -84, 
	10, -21, 10, -87, 10, -76, 10, -22, 
	-21, -20, -19, 10, 32, 34, 35, 37, 
	42, 64, 124, 9, 13, -117, -104, -95, 
	-100, -21, -126, -104, -21, -90, -84, -20, 
	-104, -92, 32, 58, -22, -80, -100, -20, 
	-102, -108, 58, 10, 10, -22, -21, -20, 
	-19, 10, 32, 35, 37, 42, 64, 9, 
	13, -73, -72, 10, -72, 10, -21, 10, 
	-97, -90, 10, -84, 10, -21, 10, -87, 
	10, -76, 10, -84, 10, -22, 10, -77, 
	10, -96, 10, -80, 10, -21, 10, -118, 
	10, -91, 10, 10, 58, -117, -89, -88, 
	10, -88, 10, -116, 10, -20, 10, -107, 
	-99, 10, -67, 10, -68, 10, -68, 10, 
	-20, 10, -96, 10, -128, 10, -117, -95, 
	10, -100, 10, -21, 10, -126, 10, -104, 
	10, -21, 10, -90, 10, -84, 10, -20, 
	10, -104, 10, -92, 10, -80, 10, -22, 
	10, -79, 10, -107, 10, -104, 10, -20, 
	10, -89, 10, -128, 10, -21, 10, -89, 
	10, -116, 10, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 10, -22, -21, -20, -19, 10, 
	32, 35, 37, 42, 64, 9, 13, -73, 
	-72, 10, -72, 10, -21, 10, -97, -90, 
	10, -84, 10, -21, 10, -87, 10, -76, 
	10, -84, 10, -22, 10, -77, 10, -96, 
	10, -80, 10, -21, 10, -118, 10, -91, 
	10, 10, 58, -117, -89, -88, -80, 10, 
	-88, 10, -116, 10, -20, 10, -107, -99, 
	10, -67, 10, -68, 10, -68, 10, -20, 
	10, -96, 10, -128, 10, -80, 10, -22, 
	10, -78, 10, -67, 10, -117, -95, 10, 
	-100, 10, -21, 10, -126, 10, -104, 10, 
	-21, 10, -90, 10, -84, 10, -20, 10, 
	-104, 10, -92, 10, 10, 32, 58, -22, 
	10, -80, 10, -100, 10, -20, 10, -102, 
	10, -108, 10, -80, 10, -22, 10, -79, 
	10, -107, 10, -104, 10, -20, 10, -89, 
	10, -128, 10, -21, 10, -89, 10, -116, 
	10, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, -120, 
	58, 10, 10, -22, 10, 32, 35, 124, 
	9, 13, -72, 10, -80, 10, -21, 10, 
	-118, 10, -91, 10, 10, 58, -80, -22, 
	-79, -107, -104, -20, -89, -128, -21, -89, 
	-116, 34, 34, 10, 13, 10, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 9, 13, 10, 
	32, 9, 13, 10, 13, 10, 95, 70, 
	69, 65, 84, 85, 82, 69, 95, 69, 
	78, 68, 95, 37, 32, 13, 32, 64, 
	9, 10, 9, 10, 13, 32, 64, 11, 
	12, 10, 32, 64, 9, 13, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, -22, -21, -20, -19, 10, 
	32, 34, 35, 37, 42, 64, 124, 9, 
	13, -84, 10, -22, 10, -77, 10, -96, 
	10, -80, 10, -21, 10, -118, 10, -91, 
	10, 10, 58, -117, -89, -88, 10, -88, 
	10, -116, 10, -20, 10, -107, -99, 10, 
	-67, 10, -68, 10, -68, 10, -20, 10, 
	-96, 10, -128, 10, -117, -95, 10, -100, 
	10, -21, 10, -126, 10, -104, 10, -21, 
	10, -90, 10, -84, 10, -20, 10, -104, 
	10, -92, 10, 10, 32, 58, -22, 10, 
	-80, 10, -100, 10, -20, 10, -102, 10, 
	-108, 10, -80, 10, -22, 10, -79, 10, 
	-107, 10, -104, 10, -20, 10, -89, 10, 
	-128, 10, -21, 10, -89, 10, -116, 10, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, -84, -22, 
	-77, -96, -80, -21, -118, -91, 58, 10, 
	10, -22, -21, -20, 10, 32, 35, 37, 
	64, 9, 13, -72, 10, -80, 10, -21, 
	10, -118, 10, -91, 10, 10, 58, -80, 
	10, -80, 10, -22, 10, -78, 10, -67, 
	10, -117, -104, 10, -100, 10, -21, 10, 
	-126, 10, -104, 10, -21, 10, -90, 10, 
	-84, 10, -20, 10, -104, 10, -92, 10, 
	10, 32, 58, -22, 10, -80, 10, -100, 
	10, -20, 10, -102, 10, -108, 10, -120, 
	10, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 13, 2, 1, 1, 2, 1, 1, 
	1, 1, 2, 2, 12, 4, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 10, 
	3, 2, 2, 3, 2, 2, 2, 2, 
	12, 3, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 10, 3, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 10, 3, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 5, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 5, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	3, 5, 3, 2, 4, 3, 2, 4, 
	12, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 4, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 8, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 1, 1, 1, 0, 0, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 15, 18, 20, 22, 25, 27, 
	29, 31, 33, 36, 39, 53, 58, 60, 
	62, 64, 67, 69, 71, 73, 75, 77, 
	79, 81, 83, 85, 87, 89, 91, 93, 
	105, 109, 112, 115, 119, 122, 125, 128, 
	131, 145, 149, 151, 153, 155, 157, 159, 
	161, 163, 165, 167, 169, 172, 174, 176, 
	178, 180, 182, 184, 186, 188, 190, 202, 
	206, 209, 212, 216, 219, 222, 225, 228, 
	231, 234, 237, 240, 243, 246, 249, 252, 
	255, 260, 263, 266, 269, 273, 276, 279, 
	282, 285, 288, 291, 295, 298, 301, 304, 
	307, 310, 313, 316, 319, 322, 325, 328, 
	331, 334, 337, 340, 343, 346, 349, 352, 
	355, 358, 361, 364, 367, 370, 373, 376, 
	379, 382, 385, 388, 391, 394, 397, 400, 
	403, 405, 407, 419, 423, 426, 429, 433, 
	436, 439, 442, 445, 448, 451, 454, 457, 
	460, 463, 466, 469, 472, 478, 481, 484, 
	487, 491, 494, 497, 500, 503, 506, 509, 
	512, 515, 518, 521, 525, 528, 531, 534, 
	537, 540, 543, 546, 549, 552, 555, 559, 
	562, 565, 568, 571, 574, 577, 580, 583, 
	586, 589, 592, 595, 598, 601, 604, 607, 
	610, 613, 616, 619, 622, 625, 628, 631, 
	634, 637, 640, 643, 646, 649, 652, 655, 
	657, 659, 661, 663, 670, 673, 676, 679, 
	682, 685, 688, 690, 692, 694, 696, 698, 
	700, 702, 704, 706, 708, 710, 712, 714, 
	717, 720, 725, 730, 735, 740, 744, 748, 
	751, 753, 755, 757, 759, 761, 763, 765, 
	767, 769, 771, 773, 775, 777, 779, 781, 
	783, 788, 795, 800, 804, 810, 814, 817, 
	823, 837, 840, 843, 846, 849, 852, 855, 
	858, 861, 864, 869, 872, 875, 878, 882, 
	885, 888, 891, 894, 897, 900, 904, 907, 
	910, 913, 916, 919, 922, 925, 928, 931, 
	934, 938, 941, 944, 947, 950, 953, 956, 
	959, 962, 965, 968, 971, 974, 977, 980, 
	983, 986, 989, 992, 995, 998, 1001, 1004, 
	1007, 1010, 1013, 1016, 1019, 1022, 1025, 1028, 
	1031, 1034, 1036, 1038, 1040, 1042, 1044, 1046, 
	1048, 1050, 1052, 1054, 1056, 1066, 1069, 1072, 
	1075, 1078, 1081, 1084, 1087, 1090, 1093, 1096, 
	1099, 1103, 1106, 1109, 1112, 1115, 1118, 1121, 
	1124, 1127, 1130, 1133, 1137, 1140, 1143, 1146, 
	1149, 1152, 1155, 1158, 1161, 1164, 1167, 1170, 
	1173, 1176, 1179, 1182, 1185, 1188, 1191, 1194, 
	1197, 1200, 1202, 1204
};

static const short _lexer_trans_targs[] = {
	2, 13, 41, 221, 385, 12, 12, 229, 
	239, 241, 255, 256, 259, 12, 0, 3, 
	333, 0, 4, 0, 5, 0, 6, 329, 
	0, 7, 0, 8, 0, 9, 0, 10, 
	0, 12, 240, 11, 12, 240, 11, 2, 
	13, 41, 221, 12, 12, 229, 239, 241, 
	255, 256, 259, 12, 0, 14, 15, 20, 
	24, 0, 10, 0, 16, 0, 17, 0, 
	18, 19, 0, 10, 0, 10, 0, 21, 
	0, 22, 0, 23, 0, 10, 0, 25, 
	0, 26, 0, 27, 0, 28, 0, 29, 
	0, 31, 30, 31, 30, 32, 274, 285, 
	306, 31, 31, 12, 314, 328, 12, 31, 
	30, 33, 269, 31, 30, 34, 31, 30, 
	35, 31, 30, 36, 265, 31, 30, 37, 
	31, 30, 38, 31, 30, 39, 31, 30, 
	40, 31, 30, 2, 13, 41, 221, 12, 
	12, 229, 239, 241, 255, 256, 259, 12, 
	0, 42, 207, 218, 0, 43, 0, 44, 
	0, 45, 0, 46, 0, 47, 0, 48, 
	0, 49, 0, 50, 0, 51, 0, 52, 
	0, 53, 128, 0, 54, 0, 55, 0, 
	56, 0, 57, 0, 58, 0, 59, 0, 
	60, 0, 62, 61, 62, 61, 63, 80, 
	91, 105, 62, 62, 12, 113, 127, 12, 
	62, 61, 64, 75, 62, 61, 65, 62, 
	61, 66, 62, 61, 67, 71, 62, 61, 
	68, 62, 61, 69, 62, 61, 70, 62, 
	61, 40, 62, 61, 72, 62, 61, 73, 
	62, 61, 74, 62, 61, 40, 62, 61, 
	76, 62, 61, 77, 62, 61, 78, 62, 
	61, 79, 62, 61, 62, 40, 61, 81, 
	82, 87, 62, 61, 40, 62, 61, 83, 
	62, 61, 84, 62, 61, 85, 86, 62, 
	61, 40, 62, 61, 40, 62, 61, 88, 
	62, 61, 89, 62, 61, 90, 62, 61, 
	40, 62, 61, 92, 102, 62, 61, 93, 
	62, 61, 94, 62, 61, 95, 62, 61, 
	96, 62, 61, 97, 62, 61, 98, 62, 
	61, 99, 62, 61, 100, 62, 61, 101, 
	62, 61, 79, 62, 61, 103, 62, 61, 
	104, 62, 61, 70, 62, 61, 106, 62, 
	61, 107, 62, 61, 108, 62, 61, 109, 
	62, 61, 110, 62, 61, 111, 62, 61, 
	112, 62, 61, 40, 62, 61, 62, 114, 
	61, 62, 115, 61, 62, 116, 61, 62, 
	117, 61, 62, 118, 61, 62, 119, 61, 
	62, 120, 61, 62, 121, 61, 62, 122, 
	61, 62, 123, 61, 62, 124, 61, 62, 
	125, 61, 62, 126, 61, 62, 12, 61, 
	62, 40, 61, 130, 129, 130, 129, 131, 
	148, 163, 184, 130, 130, 12, 192, 206, 
	12, 130, 129, 132, 143, 130, 129, 133, 
	130, 129, 134, 130, 129, 135, 139, 130, 
	129, 136, 130, 129, 137, 130, 129, 138, 
	130, 129, 40, 130, 129, 140, 130, 129, 
	141, 130, 129, 142, 130, 129, 40, 130, 
	129, 144, 130, 129, 145, 130, 129, 146, 
	130, 129, 147, 130, 129, 130, 40, 129, 
	149, 150, 155, 159, 130, 129, 40, 130, 
	129, 151, 130, 129, 152, 130, 129, 153, 
	154, 130, 129, 40, 130, 129, 40, 130, 
	129, 156, 130, 129, 157, 130, 129, 158, 
	130, 129, 40, 130, 129, 160, 130, 129, 
	161, 130, 129, 162, 130, 129, 147, 130, 
	129, 164, 181, 130, 129, 165, 130, 129, 
	166, 130, 129, 167, 130, 129, 168, 130, 
	129, 169, 130, 129, 170, 130, 129, 171, 
	130, 129, 172, 130, 129, 173, 130, 129, 
	174, 130, 129, 130, 175, 40, 129, 176, 
	130, 129, 177, 130, 129, 178, 130, 129, 
	179, 130, 129, 180, 130, 129, 147, 130, 
	129, 182, 130, 129, 183, 130, 129, 138, 
	130, 129, 185, 130, 129, 186, 130, 129, 
	187, 130, 129, 188, 130, 129, 189, 130, 
	129, 190, 130, 129, 191, 130, 129, 40, 
	130, 129, 130, 193, 129, 130, 194, 129, 
	130, 195, 129, 130, 196, 129, 130, 197, 
	129, 130, 198, 129, 130, 199, 129, 130, 
	200, 129, 130, 201, 129, 130, 202, 129, 
	130, 203, 129, 130, 204, 129, 130, 205, 
	129, 130, 12, 129, 130, 40, 129, 208, 
	0, 209, 0, 211, 210, 211, 210, 212, 
	211, 211, 12, 12, 211, 210, 213, 211, 
	210, 214, 211, 210, 215, 211, 210, 216, 
	211, 210, 217, 211, 210, 211, 40, 210, 
	219, 0, 220, 0, 9, 0, 222, 0, 
	223, 0, 224, 0, 225, 0, 226, 0, 
	227, 0, 228, 0, 10, 0, 230, 0, 
	231, 0, 233, 232, 232, 233, 232, 232, 
	234, 234, 235, 234, 234, 234, 234, 235, 
	234, 234, 234, 234, 236, 234, 234, 234, 
	234, 237, 234, 234, 12, 238, 238, 0, 
	12, 238, 238, 0, 12, 240, 239, 12, 
	0, 242, 0, 243, 0, 244, 0, 245, 
	0, 246, 0, 247, 0, 248, 0, 249, 
	0, 250, 0, 251, 0, 252, 0, 253, 
	0, 254, 0, 387, 0, 10, 0, 0, 
	0, 0, 0, 257, 258, 12, 258, 258, 
	256, 257, 257, 12, 258, 256, 258, 0, 
	259, 260, 259, 0, 264, 263, 262, 260, 
	263, 261, 0, 262, 260, 261, 0, 262, 
	261, 264, 263, 262, 260, 263, 261, 2, 
	13, 41, 221, 264, 264, 229, 239, 241, 
	255, 256, 259, 264, 0, 266, 31, 30, 
	267, 31, 30, 268, 31, 30, 40, 31, 
	30, 270, 31, 30, 271, 31, 30, 272, 
	31, 30, 273, 31, 30, 31, 40, 30, 
	275, 276, 281, 31, 30, 40, 31, 30, 
	277, 31, 30, 278, 31, 30, 279, 280, 
	31, 30, 40, 31, 30, 40, 31, 30, 
	282, 31, 30, 283, 31, 30, 284, 31, 
	30, 40, 31, 30, 286, 303, 31, 30, 
	287, 31, 30, 288, 31, 30, 289, 31, 
	30, 290, 31, 30, 291, 31, 30, 292, 
	31, 30, 293, 31, 30, 294, 31, 30, 
	295, 31, 30, 296, 31, 30, 31, 297, 
	40, 30, 298, 31, 30, 299, 31, 30, 
	300, 31, 30, 301, 31, 30, 302, 31, 
	30, 273, 31, 30, 304, 31, 30, 305, 
	31, 30, 39, 31, 30, 307, 31, 30, 
	308, 31, 30, 309, 31, 30, 310, 31, 
	30, 311, 31, 30, 312, 31, 30, 313, 
	31, 30, 40, 31, 30, 31, 315, 30, 
	31, 316, 30, 31, 317, 30, 31, 318, 
	30, 31, 319, 30, 31, 320, 30, 31, 
	321, 30, 31, 322, 30, 31, 323, 30, 
	31, 324, 30, 31, 325, 30, 31, 326, 
	30, 31, 327, 30, 31, 12, 30, 31, 
	40, 30, 330, 0, 331, 0, 332, 0, 
	10, 0, 334, 0, 335, 0, 336, 0, 
	337, 0, 338, 0, 340, 339, 340, 339, 
	341, 347, 352, 340, 340, 12, 371, 12, 
	340, 339, 342, 340, 339, 343, 340, 339, 
	344, 340, 339, 345, 340, 339, 346, 340, 
	339, 340, 40, 339, 348, 340, 339, 349, 
	340, 339, 350, 340, 339, 351, 340, 339, 
	346, 340, 339, 353, 370, 340, 339, 354, 
	340, 339, 355, 340, 339, 356, 340, 339, 
	357, 340, 339, 358, 340, 339, 359, 340, 
	339, 360, 340, 339, 361, 340, 339, 362, 
	340, 339, 363, 340, 339, 340, 364, 40, 
	339, 365, 340, 339, 366, 340, 339, 367, 
	340, 339, 368, 340, 339, 369, 340, 339, 
	346, 340, 339, 346, 340, 339, 340, 372, 
	339, 340, 373, 339, 340, 374, 339, 340, 
	375, 339, 340, 376, 339, 340, 377, 339, 
	340, 378, 339, 340, 379, 339, 340, 380, 
	339, 340, 381, 339, 340, 382, 339, 340, 
	383, 339, 340, 384, 339, 340, 12, 339, 
	386, 0, 12, 0, 0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	29, 29, 29, 29, 0, 54, 0, 5, 
	1, 0, 29, 1, 35, 0, 43, 0, 
	0, 43, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 149, 126, 57, 110, 23, 0, 29, 
	29, 29, 29, 54, 0, 5, 1, 0, 
	29, 1, 35, 0, 43, 0, 0, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 84, 84, 84, 
	84, 54, 0, 72, 33, 84, 72, 0, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	15, 54, 0, 63, 63, 63, 63, 130, 
	31, 60, 57, 31, 63, 57, 66, 31, 
	43, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 84, 84, 
	84, 84, 54, 0, 78, 33, 84, 78, 
	0, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 19, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 19, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 19, 0, 0, 
	0, 0, 54, 0, 19, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 19, 54, 0, 19, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	19, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 19, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 19, 0, 
	54, 19, 0, 144, 57, 54, 0, 84, 
	84, 84, 84, 54, 0, 75, 33, 84, 
	75, 0, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 17, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 17, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 17, 0, 
	0, 0, 0, 0, 54, 0, 17, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 17, 54, 0, 17, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 17, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 54, 0, 17, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 17, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 17, 0, 54, 17, 0, 0, 
	43, 0, 43, 144, 57, 54, 0, 84, 
	54, 0, 81, 81, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 21, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 139, 48, 9, 106, 11, 0, 
	134, 45, 45, 45, 3, 122, 33, 33, 
	33, 0, 122, 33, 33, 33, 0, 122, 
	33, 0, 33, 0, 102, 7, 7, 43, 
	54, 0, 0, 43, 114, 25, 0, 54, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 43, 
	43, 43, 43, 0, 27, 118, 27, 27, 
	51, 27, 0, 54, 0, 1, 0, 43, 
	0, 0, 0, 43, 54, 37, 37, 87, 
	37, 37, 43, 0, 39, 0, 43, 0, 
	0, 54, 0, 0, 39, 0, 0, 96, 
	96, 96, 96, 54, 0, 93, 90, 41, 
	96, 90, 99, 0, 43, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 15, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 15, 0, 
	0, 0, 0, 54, 0, 15, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 15, 54, 0, 15, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 15, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	15, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 15, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 15, 0, 54, 
	15, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 144, 57, 54, 0, 
	84, 84, 84, 54, 0, 69, 33, 69, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 54, 13, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 13, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	0, 43, 0, 43, 0, 0
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
	43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 387;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"

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
    
    
#line 964 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
    
#line 971 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
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
#line 1261 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"
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
#line 1324 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/ko.c.rl"

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

void Init_gherkin_lexer_ko()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Ko", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

