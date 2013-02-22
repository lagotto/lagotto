
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
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
	0, 0, 12, 19, 20, 22, 23, 24, 
	25, 27, 29, 40, 41, 42, 44, 46, 
	51, 56, 61, 66, 70, 74, 76, 77, 
	78, 79, 80, 81, 82, 83, 84, 85, 
	86, 87, 88, 89, 90, 91, 96, 103, 
	108, 112, 118, 121, 123, 129, 140, 142, 
	143, 144, 145, 146, 147, 148, 149, 150, 
	151, 152, 153, 154, 155, 156, 157, 158, 
	159, 160, 161, 162, 163, 164, 165, 166, 
	167, 168, 175, 177, 179, 181, 183, 185, 
	187, 189, 191, 193, 195, 206, 207, 208, 
	209, 210, 211, 212, 213, 214, 215, 216, 
	217, 218, 219, 220, 221, 222, 223, 232, 
	238, 240, 243, 245, 247, 249, 252, 254, 
	256, 258, 260, 262, 264, 266, 268, 270, 
	272, 274, 276, 278, 280, 282, 284, 286, 
	288, 290, 292, 294, 296, 300, 302, 304, 
	306, 308, 310, 312, 314, 316, 318, 320, 
	322, 324, 326, 328, 330, 332, 334, 336, 
	338, 340, 342, 344, 346, 348, 350, 352, 
	354, 356, 358, 360, 362, 364, 366, 368, 
	370, 372, 374, 376, 377, 380, 381, 382, 
	383, 384, 385, 386, 387, 388, 389, 390, 
	391, 392, 393, 394, 395, 396, 397, 398, 
	399, 400, 409, 415, 417, 420, 422, 424, 
	426, 429, 431, 433, 435, 437, 439, 441, 
	443, 445, 447, 449, 451, 453, 455, 457, 
	459, 461, 463, 465, 467, 469, 471, 473, 
	476, 478, 480, 482, 484, 486, 488, 490, 
	492, 494, 496, 498, 500, 502, 504, 506, 
	508, 510, 512, 514, 516, 518, 520, 522, 
	524, 526, 528, 530, 531, 532, 533, 534, 
	535, 536, 537, 538, 539, 547, 551, 553, 
	555, 557, 559, 561, 563, 565, 567, 569, 
	571, 573, 575, 577, 579, 581, 583, 585, 
	587, 591, 593, 595, 597, 599, 601, 603, 
	605, 607, 609, 611, 613, 615, 617, 619, 
	621, 623, 625, 627, 629, 631, 633, 635, 
	637, 639, 641, 643, 645, 647, 649, 651, 
	653, 655, 657, 659, 661, 663, 665, 666, 
	667, 668, 669, 670, 671, 672, 673, 674, 
	683, 690, 692, 695, 697, 699, 701, 704, 
	706, 708, 710, 712, 714, 716, 718, 720, 
	722, 724, 726, 728, 730, 732, 734, 736, 
	738, 740, 742, 744, 746, 748, 750, 752, 
	754, 756, 758, 762, 764, 766, 768, 770, 
	772, 774, 776, 778, 780, 782, 784, 786, 
	788, 790, 792, 794, 796, 798, 800, 802, 
	804, 806, 808, 810, 812, 814, 816, 818, 
	820, 822, 824, 826, 828, 830, 832, 834, 
	836, 837, 838
};

static const char _lexer_trans_keys[] = {
	-41, -17, 10, 32, 34, 35, 37, 42, 
	64, 124, 9, 13, -112, -111, -109, -107, 
	-101, -88, -86, -41, -111, -106, -41, -100, 
	32, 10, 13, 10, 13, -41, 10, 32, 
	34, 35, 37, 42, 64, 124, 9, 13, 
	34, 34, 10, 13, 10, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 9, 13, 10, 32, 
	9, 13, 10, 13, 10, 95, 70, 69, 
	65, 84, 85, 82, 69, 95, 69, 78, 
	68, 95, 37, 13, 32, 64, 9, 10, 
	9, 10, 13, 32, 64, 11, 12, 10, 
	32, 64, 9, 13, 32, 124, 9, 13, 
	10, 32, 92, 124, 9, 13, 10, 92, 
	124, 10, 92, 10, 32, 92, 124, 9, 
	13, -41, 10, 32, 34, 35, 37, 42, 
	64, 124, 9, 13, -41, 32, -103, -41, 
	-108, -41, -103, -41, -96, -41, -86, -41, 
	-97, -41, -107, -41, -110, -41, -98, -41, 
	-112, -41, -107, -41, -86, 58, 10, 10, 
	-41, 10, 32, 35, 124, 9, 13, -86, 
	10, -41, 10, -101, 10, -41, 10, -107, 
	10, -41, 10, -96, 10, -41, 10, -108, 
	10, 10, 58, -41, 10, 32, 34, 35, 
	37, 42, 64, 124, 9, 13, -41, -110, 
	-41, -99, -41, -112, -41, -87, -41, -88, 
	-41, -89, -41, -94, 58, 10, 10, -41, 
	10, 32, 35, 37, 42, 64, 9, 13, 
	-112, -111, -107, -101, -86, 10, -41, 10, 
	-111, -106, 10, -41, 10, -100, 10, 10, 
	32, -41, 10, 32, -103, 10, -41, 10, 
	-108, 10, -41, 10, -103, 10, -41, 10, 
	-96, 10, -41, 10, -86, 10, -41, 10, 
	-97, 10, -41, 10, -110, 10, -41, 10, 
	-99, 10, -41, 10, -112, 10, -41, 10, 
	-87, 10, -41, 10, -88, 10, -41, 10, 
	-111, -101, -88, 10, -41, 10, -96, 10, 
	-41, 10, -103, 10, -41, 10, -86, 10, 
	10, 32, -41, 10, -86, 10, -41, 10, 
	-88, 10, -41, 10, -105, 10, -41, 10, 
	-103, 10, -41, 10, -87, 10, 10, 58, 
	-41, 10, -107, 10, -41, 10, -96, 10, 
	-41, 10, -108, 10, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	-41, -111, -101, -88, -41, -96, -41, -103, 
	-41, -86, 32, -41, -86, -41, -88, -41, 
	-105, -41, -103, -41, -87, 58, 10, 10, 
	-41, 10, 32, 35, 37, 42, 64, 9, 
	13, -112, -111, -107, -101, -86, 10, -41, 
	10, -111, -106, 10, -41, 10, -100, 10, 
	10, 32, -41, 10, 32, -103, 10, -41, 
	10, -108, 10, -41, 10, -103, 10, -41, 
	10, -96, 10, -41, 10, -86, 10, -41, 
	10, -97, 10, -41, 10, -110, 10, -41, 
	10, -99, 10, -41, 10, -112, 10, -41, 
	10, -87, 10, -41, 10, -88, 10, -41, 
	10, -101, -88, 10, -41, 10, -107, 10, 
	-41, 10, -96, 10, -41, 10, -108, 10, 
	10, 58, -41, 10, -105, 10, -41, 10, 
	-103, 10, -41, 10, -87, 10, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, -41, -107, -41, -96, -41, -108, 
	58, 10, 10, -41, 10, 32, 35, 37, 
	64, 9, 13, -109, -88, -86, 10, -41, 
	10, -107, 10, -41, 10, -110, 10, -41, 
	10, -98, 10, -41, 10, -112, 10, -41, 
	10, -107, 10, -41, 10, -86, 10, 10, 
	58, -41, 10, -89, 10, -41, 10, -94, 
	10, -41, 10, -111, -101, -88, 10, -41, 
	10, -96, 10, -41, 10, -103, 10, -41, 
	10, -86, 10, 10, 32, -41, 10, -86, 
	10, -41, 10, -88, 10, -41, 10, -105, 
	10, -41, 10, -103, 10, -41, 10, -87, 
	10, -41, 10, -107, 10, -41, 10, -96, 
	10, -41, 10, -108, 10, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, -41, -105, -41, -103, -41, -87, 58, 
	10, 10, -41, 10, 32, 35, 37, 42, 
	64, 9, 13, -112, -111, -107, -101, -88, 
	-86, 10, -41, 10, -111, -106, 10, -41, 
	10, -100, 10, 10, 32, -41, 10, 32, 
	-103, 10, -41, 10, -108, 10, -41, 10, 
	-103, 10, -41, 10, -96, 10, -41, 10, 
	-86, 10, -41, 10, -97, 10, -41, 10, 
	-110, 10, -41, 10, -99, 10, -41, 10, 
	-112, 10, -41, 10, -87, 10, -41, 10, 
	-88, 10, -41, 10, -89, 10, -41, 10, 
	-94, 10, 10, 58, -41, 10, -111, -101, 
	-88, 10, -41, 10, -96, 10, -41, 10, 
	-103, 10, -41, 10, -86, 10, 10, 32, 
	-41, 10, -86, 10, -41, 10, -88, 10, 
	-41, 10, -105, 10, -41, 10, -103, 10, 
	-41, 10, -87, 10, -41, 10, -107, 10, 
	-41, 10, -96, 10, -41, 10, -108, 10, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 10, 7, 1, 2, 1, 1, 1, 
	2, 2, 9, 1, 1, 2, 2, 3, 
	3, 3, 3, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 3, 5, 3, 
	2, 4, 3, 2, 4, 9, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 5, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 9, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 7, 6, 
	2, 3, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 4, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 7, 6, 2, 3, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 6, 4, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 7, 
	7, 2, 3, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 4, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 1, 
	1, 1, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 1, 
	1, 1, 0, 0, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
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
	0, 0, 0, 0, 1, 0, 0, 0, 
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
	0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 12, 20, 22, 25, 27, 29, 
	31, 34, 37, 48, 50, 52, 55, 58, 
	63, 68, 73, 78, 82, 86, 89, 91, 
	93, 95, 97, 99, 101, 103, 105, 107, 
	109, 111, 113, 115, 117, 119, 124, 131, 
	136, 140, 146, 150, 153, 159, 170, 173, 
	175, 177, 179, 181, 183, 185, 187, 189, 
	191, 193, 195, 197, 199, 201, 203, 205, 
	207, 209, 211, 213, 215, 217, 219, 221, 
	223, 225, 232, 235, 238, 241, 244, 247, 
	250, 253, 256, 259, 262, 273, 275, 277, 
	279, 281, 283, 285, 287, 289, 291, 293, 
	295, 297, 299, 301, 303, 305, 307, 316, 
	323, 326, 330, 333, 336, 339, 343, 346, 
	349, 352, 355, 358, 361, 364, 367, 370, 
	373, 376, 379, 382, 385, 388, 391, 394, 
	397, 400, 403, 406, 409, 414, 417, 420, 
	423, 426, 429, 432, 435, 438, 441, 444, 
	447, 450, 453, 456, 459, 462, 465, 468, 
	471, 474, 477, 480, 483, 486, 489, 492, 
	495, 498, 501, 504, 507, 510, 513, 516, 
	519, 522, 525, 528, 530, 534, 536, 538, 
	540, 542, 544, 546, 548, 550, 552, 554, 
	556, 558, 560, 562, 564, 566, 568, 570, 
	572, 574, 583, 590, 593, 597, 600, 603, 
	606, 610, 613, 616, 619, 622, 625, 628, 
	631, 634, 637, 640, 643, 646, 649, 652, 
	655, 658, 661, 664, 667, 670, 673, 676, 
	680, 683, 686, 689, 692, 695, 698, 701, 
	704, 707, 710, 713, 716, 719, 722, 725, 
	728, 731, 734, 737, 740, 743, 746, 749, 
	752, 755, 758, 761, 763, 765, 767, 769, 
	771, 773, 775, 777, 779, 787, 792, 795, 
	798, 801, 804, 807, 810, 813, 816, 819, 
	822, 825, 828, 831, 834, 837, 840, 843, 
	846, 851, 854, 857, 860, 863, 866, 869, 
	872, 875, 878, 881, 884, 887, 890, 893, 
	896, 899, 902, 905, 908, 911, 914, 917, 
	920, 923, 926, 929, 932, 935, 938, 941, 
	944, 947, 950, 953, 956, 959, 962, 964, 
	966, 968, 970, 972, 974, 976, 978, 980, 
	989, 997, 1000, 1004, 1007, 1010, 1013, 1017, 
	1020, 1023, 1026, 1029, 1032, 1035, 1038, 1041, 
	1044, 1047, 1050, 1053, 1056, 1059, 1062, 1065, 
	1068, 1071, 1074, 1077, 1080, 1083, 1086, 1089, 
	1092, 1095, 1098, 1103, 1106, 1109, 1112, 1115, 
	1118, 1121, 1124, 1127, 1130, 1133, 1136, 1139, 
	1142, 1145, 1148, 1151, 1154, 1157, 1160, 1163, 
	1166, 1169, 1172, 1175, 1178, 1181, 1184, 1187, 
	1190, 1193, 1196, 1199, 1202, 1205, 1208, 1211, 
	1214, 1216, 1218
};

static const short _lexer_trans_targs[] = {
	2, 400, 10, 10, 11, 21, 23, 7, 
	37, 40, 10, 0, 3, 48, 58, 85, 
	89, 95, 171, 0, 4, 0, 5, 46, 
	0, 6, 0, 7, 0, 8, 0, 10, 
	22, 9, 10, 22, 9, 2, 10, 10, 
	11, 21, 23, 7, 37, 40, 10, 0, 
	12, 0, 13, 0, 15, 14, 14, 15, 
	14, 14, 16, 16, 17, 16, 16, 16, 
	16, 17, 16, 16, 16, 16, 18, 16, 
	16, 16, 16, 19, 16, 16, 10, 20, 
	20, 0, 10, 20, 20, 0, 10, 22, 
	21, 10, 0, 24, 0, 25, 0, 26, 
	0, 27, 0, 28, 0, 29, 0, 30, 
	0, 31, 0, 32, 0, 33, 0, 34, 
	0, 35, 0, 36, 0, 402, 0, 0, 
	0, 0, 0, 38, 39, 10, 39, 39, 
	37, 38, 38, 10, 39, 37, 39, 0, 
	40, 41, 40, 0, 45, 44, 43, 41, 
	44, 42, 0, 43, 41, 42, 0, 43, 
	42, 45, 44, 43, 41, 44, 42, 2, 
	45, 45, 11, 21, 23, 7, 37, 40, 
	45, 0, 47, 8, 0, 7, 0, 49, 
	0, 50, 0, 51, 0, 52, 0, 53, 
	0, 54, 0, 55, 0, 56, 0, 57, 
	0, 7, 0, 59, 0, 60, 0, 61, 
	0, 62, 0, 63, 0, 64, 0, 65, 
	0, 66, 0, 67, 0, 68, 0, 69, 
	0, 70, 0, 71, 0, 73, 72, 73, 
	72, 74, 73, 73, 10, 10, 73, 72, 
	75, 73, 72, 76, 73, 72, 77, 73, 
	72, 78, 73, 72, 79, 73, 72, 80, 
	73, 72, 81, 73, 72, 82, 73, 72, 
	83, 73, 72, 73, 84, 72, 2, 10, 
	10, 11, 21, 23, 7, 37, 40, 10, 
	0, 86, 0, 87, 0, 88, 0, 7, 
	0, 90, 0, 91, 0, 92, 0, 93, 
	0, 94, 0, 7, 0, 96, 0, 97, 
	0, 98, 0, 99, 0, 100, 0, 102, 
	101, 102, 101, 103, 102, 102, 10, 157, 
	108, 10, 102, 101, 104, 111, 121, 125, 
	131, 102, 101, 105, 102, 101, 106, 109, 
	102, 101, 107, 102, 101, 108, 102, 101, 
	102, 84, 101, 110, 102, 84, 101, 108, 
	102, 101, 112, 102, 101, 113, 102, 101, 
	114, 102, 101, 115, 102, 101, 116, 102, 
	101, 117, 102, 101, 118, 102, 101, 119, 
	102, 101, 120, 102, 101, 108, 102, 101, 
	122, 102, 101, 123, 102, 101, 124, 102, 
	101, 108, 102, 101, 126, 102, 101, 127, 
	102, 101, 128, 102, 101, 129, 102, 101, 
	130, 102, 101, 108, 102, 101, 132, 102, 
	101, 133, 151, 144, 102, 101, 134, 102, 
	101, 135, 102, 101, 136, 102, 101, 137, 
	102, 101, 138, 102, 101, 139, 102, 101, 
	102, 140, 101, 141, 102, 101, 142, 102, 
	101, 143, 102, 101, 144, 102, 101, 145, 
	102, 101, 146, 102, 101, 147, 102, 101, 
	148, 102, 101, 149, 102, 101, 150, 102, 
	101, 102, 84, 101, 152, 102, 101, 153, 
	102, 101, 154, 102, 101, 155, 102, 101, 
	156, 102, 101, 150, 102, 101, 102, 158, 
	101, 102, 159, 101, 102, 160, 101, 102, 
	161, 101, 102, 162, 101, 102, 163, 101, 
	102, 164, 101, 102, 165, 101, 102, 166, 
	101, 102, 167, 101, 102, 168, 101, 102, 
	169, 101, 102, 170, 101, 102, 10, 101, 
	172, 0, 173, 251, 318, 0, 174, 0, 
	175, 0, 176, 0, 177, 0, 178, 0, 
	179, 0, 180, 0, 181, 0, 182, 0, 
	183, 0, 184, 0, 185, 0, 186, 0, 
	187, 0, 188, 0, 189, 0, 190, 0, 
	191, 0, 193, 192, 193, 192, 194, 193, 
	193, 10, 237, 199, 10, 193, 192, 195, 
	202, 212, 216, 222, 193, 192, 196, 193, 
	192, 197, 200, 193, 192, 198, 193, 192, 
	199, 193, 192, 193, 84, 192, 201, 193, 
	84, 192, 199, 193, 192, 203, 193, 192, 
	204, 193, 192, 205, 193, 192, 206, 193, 
	192, 207, 193, 192, 208, 193, 192, 209, 
	193, 192, 210, 193, 192, 211, 193, 192, 
	199, 193, 192, 213, 193, 192, 214, 193, 
	192, 215, 193, 192, 199, 193, 192, 217, 
	193, 192, 218, 193, 192, 219, 193, 192, 
	220, 193, 192, 221, 193, 192, 199, 193, 
	192, 223, 193, 192, 224, 231, 193, 192, 
	225, 193, 192, 226, 193, 192, 227, 193, 
	192, 228, 193, 192, 229, 193, 192, 230, 
	193, 192, 193, 84, 192, 232, 193, 192, 
	233, 193, 192, 234, 193, 192, 235, 193, 
	192, 236, 193, 192, 230, 193, 192, 193, 
	238, 192, 193, 239, 192, 193, 240, 192, 
	193, 241, 192, 193, 242, 192, 193, 243, 
	192, 193, 244, 192, 193, 245, 192, 193, 
	246, 192, 193, 247, 192, 193, 248, 192, 
	193, 249, 192, 193, 250, 192, 193, 10, 
	192, 252, 0, 253, 0, 254, 0, 255, 
	0, 256, 0, 257, 0, 258, 0, 260, 
	259, 260, 259, 261, 260, 260, 10, 304, 
	10, 260, 259, 262, 275, 279, 260, 259, 
	263, 260, 259, 264, 260, 259, 265, 260, 
	259, 266, 260, 259, 267, 260, 259, 268, 
	260, 259, 269, 260, 259, 270, 260, 259, 
	271, 260, 259, 272, 260, 259, 273, 260, 
	259, 274, 260, 259, 260, 84, 259, 276, 
	260, 259, 277, 260, 259, 278, 260, 259, 
	274, 260, 259, 280, 260, 259, 281, 298, 
	292, 260, 259, 282, 260, 259, 283, 260, 
	259, 284, 260, 259, 285, 260, 259, 286, 
	260, 259, 287, 260, 259, 260, 288, 259, 
	289, 260, 259, 290, 260, 259, 291, 260, 
	259, 292, 260, 259, 293, 260, 259, 294, 
	260, 259, 295, 260, 259, 296, 260, 259, 
	297, 260, 259, 274, 260, 259, 299, 260, 
	259, 300, 260, 259, 301, 260, 259, 302, 
	260, 259, 303, 260, 259, 274, 260, 259, 
	260, 305, 259, 260, 306, 259, 260, 307, 
	259, 260, 308, 259, 260, 309, 259, 260, 
	310, 259, 260, 311, 259, 260, 312, 259, 
	260, 313, 259, 260, 314, 259, 260, 315, 
	259, 260, 316, 259, 260, 317, 259, 260, 
	10, 259, 319, 0, 320, 0, 321, 0, 
	322, 0, 323, 0, 324, 0, 325, 0, 
	327, 326, 327, 326, 328, 327, 327, 10, 
	386, 333, 10, 327, 326, 329, 336, 346, 
	350, 356, 361, 327, 326, 330, 327, 326, 
	331, 334, 327, 326, 332, 327, 326, 333, 
	327, 326, 327, 84, 326, 335, 327, 84, 
	326, 333, 327, 326, 337, 327, 326, 338, 
	327, 326, 339, 327, 326, 340, 327, 326, 
	341, 327, 326, 342, 327, 326, 343, 327, 
	326, 344, 327, 326, 345, 327, 326, 333, 
	327, 326, 347, 327, 326, 348, 327, 326, 
	349, 327, 326, 333, 327, 326, 351, 327, 
	326, 352, 327, 326, 353, 327, 326, 354, 
	327, 326, 355, 327, 326, 333, 327, 326, 
	357, 327, 326, 358, 327, 326, 359, 327, 
	326, 360, 327, 326, 327, 84, 326, 362, 
	327, 326, 363, 380, 374, 327, 326, 364, 
	327, 326, 365, 327, 326, 366, 327, 326, 
	367, 327, 326, 368, 327, 326, 369, 327, 
	326, 327, 370, 326, 371, 327, 326, 372, 
	327, 326, 373, 327, 326, 374, 327, 326, 
	375, 327, 326, 376, 327, 326, 377, 327, 
	326, 378, 327, 326, 379, 327, 326, 360, 
	327, 326, 381, 327, 326, 382, 327, 326, 
	383, 327, 326, 384, 327, 326, 385, 327, 
	326, 360, 327, 326, 327, 387, 326, 327, 
	388, 326, 327, 389, 326, 327, 390, 326, 
	327, 391, 326, 327, 392, 326, 327, 393, 
	326, 327, 394, 326, 327, 395, 326, 327, 
	396, 326, 327, 397, 326, 327, 398, 326, 
	327, 399, 326, 327, 10, 326, 401, 0, 
	10, 0, 0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	29, 0, 54, 0, 5, 1, 0, 29, 
	1, 35, 0, 43, 0, 0, 0, 0, 
	0, 0, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 149, 
	126, 57, 110, 23, 0, 29, 54, 0, 
	5, 1, 0, 29, 1, 35, 0, 43, 
	0, 43, 0, 43, 139, 48, 9, 106, 
	11, 0, 134, 45, 45, 45, 3, 122, 
	33, 33, 33, 0, 122, 33, 33, 33, 
	0, 122, 33, 0, 33, 0, 102, 7, 
	7, 43, 54, 0, 0, 43, 114, 25, 
	0, 54, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 43, 
	43, 43, 43, 0, 27, 118, 27, 27, 
	51, 27, 0, 54, 0, 1, 0, 43, 
	0, 0, 0, 43, 54, 37, 37, 87, 
	37, 37, 43, 0, 39, 0, 43, 0, 
	0, 54, 0, 0, 39, 0, 0, 96, 
	54, 0, 93, 90, 41, 96, 90, 99, 
	0, 43, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 84, 54, 0, 81, 81, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 54, 21, 0, 63, 130, 
	31, 60, 57, 31, 63, 57, 66, 31, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 84, 54, 0, 72, 33, 
	84, 72, 0, 0, 0, 0, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	54, 15, 0, 0, 54, 15, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 54, 15, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 15, 0, 
	0, 43, 0, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 84, 54, 
	0, 78, 33, 84, 78, 0, 0, 0, 
	0, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 54, 19, 0, 0, 54, 
	19, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 54, 19, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 19, 
	0, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 84, 54, 0, 69, 33, 
	69, 0, 0, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 13, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	13, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 84, 54, 0, 75, 
	33, 84, 75, 0, 0, 0, 0, 0, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 54, 17, 0, 0, 54, 17, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 17, 0, 0, 
	54, 0, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 0, 43, 
	0, 43, 0, 0
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
	43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 402;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"

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
    
    
#line 978 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
    
#line 985 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
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
#line 1275 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"
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
#line 1338 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/he.c.rl"

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

void Init_gherkin_lexer_he()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "He", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

