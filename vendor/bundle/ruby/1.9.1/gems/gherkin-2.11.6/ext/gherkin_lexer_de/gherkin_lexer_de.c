
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
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
	116, 117, 118, 119, 120, 121, 122, 123, 
	124, 125, 126, 127, 128, 129, 130, 131, 
	132, 133, 134, 135, 142, 144, 146, 148, 
	150, 152, 154, 156, 158, 160, 162, 164, 
	166, 168, 170, 172, 190, 191, 192, 193, 
	194, 195, 196, 197, 198, 199, 200, 201, 
	202, 203, 204, 205, 206, 207, 208, 209, 
	220, 222, 224, 226, 228, 230, 232, 234, 
	236, 238, 240, 242, 244, 246, 248, 250, 
	252, 254, 256, 258, 260, 262, 264, 266, 
	268, 270, 272, 274, 276, 278, 280, 282, 
	284, 286, 288, 290, 292, 294, 296, 298, 
	300, 302, 304, 306, 308, 310, 312, 314, 
	316, 318, 320, 322, 325, 327, 329, 331, 
	333, 335, 337, 339, 341, 343, 344, 345, 
	346, 347, 348, 349, 350, 351, 352, 353, 
	354, 355, 356, 357, 358, 359, 360, 361, 
	362, 377, 379, 381, 383, 385, 387, 389, 
	391, 393, 395, 397, 399, 401, 403, 405, 
	407, 410, 412, 414, 416, 418, 420, 422, 
	424, 426, 428, 430, 432, 434, 436, 438, 
	440, 442, 444, 446, 448, 450, 452, 454, 
	456, 458, 460, 462, 464, 466, 468, 470, 
	472, 474, 476, 478, 480, 482, 484, 486, 
	488, 490, 492, 494, 496, 498, 501, 503, 
	505, 507, 509, 511, 513, 515, 517, 519, 
	521, 523, 524, 525, 526, 527, 528, 529, 
	530, 532, 533, 534, 549, 551, 553, 555, 
	557, 559, 561, 563, 565, 567, 569, 571, 
	573, 575, 577, 579, 582, 584, 586, 588, 
	590, 592, 594, 596, 598, 600, 602, 604, 
	606, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 626, 628, 630, 632, 634, 636, 
	639, 641, 643, 645, 647, 649, 651, 653, 
	655, 657, 659, 661, 663, 665, 667, 669, 
	671, 673, 675, 677, 679, 681, 683, 685, 
	688, 690, 692, 694, 696, 698, 700, 702, 
	704, 706, 708, 710, 711, 712, 713, 714, 
	715, 716, 717, 718, 719, 720, 721, 736, 
	738, 740, 742, 744, 746, 748, 750, 752, 
	754, 756, 758, 760, 762, 764, 766, 769, 
	771, 773, 775, 777, 779, 781, 783, 785, 
	787, 789, 791, 793, 795, 797, 799, 801, 
	803, 805, 807, 809, 811, 813, 815, 817, 
	819, 821, 823, 825, 827, 829, 831, 833, 
	835, 837, 839, 841, 843, 845, 847, 849, 
	851, 853, 855, 857, 859, 861, 863, 864, 
	865, 866, 870, 876, 879, 881, 887, 905
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 68, 70, 71, 83, 85, 87, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 68, 70, 
	71, 83, 85, 87, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	98, 110, 101, 114, 103, 101, 110, 111, 
	109, 109, 101, 110, 101, 105, 115, 112, 
	105, 101, 108, 101, 58, 10, 10, 10, 
	32, 35, 70, 124, 9, 13, 10, 117, 
	10, 110, 10, 107, 10, 116, 10, 105, 
	10, 111, 10, 110, 10, 97, 10, 108, 
	10, 105, 10, 116, -61, 10, -92, 10, 
	10, 116, 10, 58, 10, 32, 34, 35, 
	37, 42, 64, 65, 66, 68, 70, 71, 
	83, 85, 87, 124, 9, 13, 97, 110, 
	117, 110, 107, 116, 105, 111, 110, 97, 
	108, 105, 116, -61, -92, 116, 58, 10, 
	10, 10, 32, 35, 37, 64, 66, 70, 
	71, 83, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 101, 10, 105, 10, 115, 10, 112, 
	10, 105, 10, 101, 10, 108, 10, 101, 
	10, 58, 10, 117, 10, 110, 10, 107, 
	10, 116, 10, 105, 10, 111, 10, 110, 
	10, 97, 10, 108, 10, 105, 10, 116, 
	-61, 10, -92, 10, 10, 116, 10, 114, 
	10, 117, 10, 110, 10, 100, 10, 108, 
	10, 97, 10, 103, 10, 122, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 111, 10, 58, 103, 10, 114, 10, 
	117, 10, 110, 10, 100, 10, 114, 10, 
	105, 10, 115, 10, 115, 101, 114, 103, 
	101, 98, 101, 110, 32, 115, 101, 105, 
	117, 110, 100, 108, 97, 103, 101, 58, 
	10, 10, 10, 32, 35, 37, 42, 64, 
	65, 68, 70, 71, 83, 85, 87, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	98, 110, 10, 101, 10, 114, 10, 103, 
	10, 101, 10, 110, 10, 111, 10, 109, 
	10, 109, 10, 101, 10, 110, 10, 97, 
	10, 110, 10, 117, 10, 110, 10, 107, 
	10, 116, 10, 105, 10, 111, 10, 110, 
	10, 97, 10, 108, 10, 105, 10, 116, 
	-61, 10, -92, 10, 10, 116, 10, 58, 
	10, 101, 10, 103, 10, 101, 10, 98, 
	10, 101, 10, 110, 10, 32, 10, 115, 
	10, 101, 10, 105, 10, 122, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 111, 10, 58, 103, 10, 114, 10, 
	117, 10, 110, 10, 100, 10, 114, 10, 
	105, 10, 115, 10, 115, 10, 110, 10, 
	100, 10, 101, 122, 101, 110, 97, 114, 
	105, 111, 58, 103, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 68, 70, 71, 
	83, 85, 87, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 98, 110, 10, 101, 
	10, 114, 10, 103, 10, 101, 10, 110, 
	10, 111, 10, 109, 10, 109, 10, 101, 
	10, 110, 10, 97, 10, 110, 10, 117, 
	10, 110, 10, 107, 10, 116, 10, 105, 
	10, 111, 10, 110, 10, 97, 10, 108, 
	10, 105, 10, 116, -61, 10, -92, 10, 
	10, 116, 10, 58, 10, 101, 114, 10, 
	103, 10, 101, 10, 98, 10, 101, 10, 
	110, 10, 32, 10, 115, 10, 101, 10, 
	105, 10, 117, 10, 110, 10, 100, 10, 
	108, 10, 97, 10, 103, 10, 101, 10, 
	122, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 111, 10, 58, 103, 
	10, 114, 10, 117, 10, 110, 10, 100, 
	10, 114, 10, 105, 10, 115, 10, 115, 
	10, 110, 10, 100, 10, 101, 114, 117, 
	110, 100, 114, 105, 115, 115, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 65, 
	68, 70, 71, 83, 85, 87, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 98, 
	110, 10, 101, 10, 114, 10, 103, 10, 
	101, 10, 110, 10, 111, 10, 109, 10, 
	109, 10, 101, 10, 110, 10, 97, 10, 
	110, 10, 117, 10, 110, 10, 107, 10, 
	116, 10, 105, 10, 111, 10, 110, 10, 
	97, 10, 108, 10, 105, 10, 116, -61, 
	10, -92, 10, 10, 116, 10, 58, 10, 
	101, 10, 103, 10, 101, 10, 98, 10, 
	101, 10, 110, 10, 32, 10, 115, 10, 
	101, 10, 105, 10, 122, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 110, 10, 100, 10, 101, 110, 
	100, 101, 32, 124, 9, 13, 10, 32, 
	92, 124, 9, 13, 10, 92, 124, 10, 
	92, 10, 32, 92, 124, 9, 13, 10, 
	32, 34, 35, 37, 42, 64, 65, 66, 
	68, 70, 71, 83, 85, 87, 124, 9, 
	13, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 5, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 16, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 9, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	13, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 13, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 13, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 2, 4, 3, 2, 4, 16, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
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
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 0, 0, 1, 1, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 140, 142, 
	144, 146, 148, 150, 152, 154, 156, 158, 
	160, 162, 164, 166, 168, 170, 172, 174, 
	176, 178, 180, 182, 189, 192, 195, 198, 
	201, 204, 207, 210, 213, 216, 219, 222, 
	225, 228, 231, 234, 252, 254, 256, 258, 
	260, 262, 264, 266, 268, 270, 272, 274, 
	276, 278, 280, 282, 284, 286, 288, 290, 
	301, 304, 307, 310, 313, 316, 319, 322, 
	325, 328, 331, 334, 337, 340, 343, 346, 
	349, 352, 355, 358, 361, 364, 367, 370, 
	373, 376, 379, 382, 385, 388, 391, 394, 
	397, 400, 403, 406, 409, 412, 415, 418, 
	421, 424, 427, 430, 433, 436, 439, 442, 
	445, 448, 451, 454, 458, 461, 464, 467, 
	470, 473, 476, 479, 482, 485, 487, 489, 
	491, 493, 495, 497, 499, 501, 503, 505, 
	507, 509, 511, 513, 515, 517, 519, 521, 
	523, 538, 541, 544, 547, 550, 553, 556, 
	559, 562, 565, 568, 571, 574, 577, 580, 
	583, 587, 590, 593, 596, 599, 602, 605, 
	608, 611, 614, 617, 620, 623, 626, 629, 
	632, 635, 638, 641, 644, 647, 650, 653, 
	656, 659, 662, 665, 668, 671, 674, 677, 
	680, 683, 686, 689, 692, 695, 698, 701, 
	704, 707, 710, 713, 716, 719, 723, 726, 
	729, 732, 735, 738, 741, 744, 747, 750, 
	753, 756, 758, 760, 762, 764, 766, 768, 
	770, 773, 775, 777, 792, 795, 798, 801, 
	804, 807, 810, 813, 816, 819, 822, 825, 
	828, 831, 834, 837, 841, 844, 847, 850, 
	853, 856, 859, 862, 865, 868, 871, 874, 
	877, 880, 883, 886, 889, 892, 895, 898, 
	901, 904, 907, 910, 913, 916, 919, 922, 
	926, 929, 932, 935, 938, 941, 944, 947, 
	950, 953, 956, 959, 962, 965, 968, 971, 
	974, 977, 980, 983, 986, 989, 992, 995, 
	999, 1002, 1005, 1008, 1011, 1014, 1017, 1020, 
	1023, 1026, 1029, 1032, 1034, 1036, 1038, 1040, 
	1042, 1044, 1046, 1048, 1050, 1052, 1054, 1069, 
	1072, 1075, 1078, 1081, 1084, 1087, 1090, 1093, 
	1096, 1099, 1102, 1105, 1108, 1111, 1114, 1118, 
	1121, 1124, 1127, 1130, 1133, 1136, 1139, 1142, 
	1145, 1148, 1151, 1154, 1157, 1160, 1163, 1166, 
	1169, 1172, 1175, 1178, 1181, 1184, 1187, 1190, 
	1193, 1196, 1199, 1202, 1205, 1208, 1211, 1214, 
	1217, 1220, 1223, 1226, 1229, 1232, 1235, 1238, 
	1241, 1244, 1247, 1250, 1253, 1256, 1259, 1261, 
	1263, 1265, 1269, 1275, 1279, 1282, 1288, 1306
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 48, 76, 78, 156, 249, 414, 416, 
	417, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 48, 
	76, 78, 156, 249, 414, 416, 417, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 423, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 40, 0, 39, 0, 31, 0, 
	41, 0, 42, 0, 43, 0, 44, 0, 
	45, 0, 46, 0, 47, 0, 31, 0, 
	49, 0, 50, 0, 51, 0, 52, 0, 
	53, 0, 54, 0, 55, 0, 56, 0, 
	57, 0, 59, 58, 59, 58, 59, 59, 
	4, 60, 4, 59, 58, 59, 61, 58, 
	59, 62, 58, 59, 63, 58, 59, 64, 
	58, 59, 65, 58, 59, 66, 58, 59, 
	67, 58, 59, 68, 58, 59, 69, 58, 
	59, 70, 58, 59, 71, 58, 72, 59, 
	58, 73, 59, 58, 59, 74, 58, 59, 
	75, 58, 4, 4, 5, 15, 17, 31, 
	34, 37, 48, 76, 78, 156, 249, 414, 
	416, 417, 4, 0, 77, 0, 47, 0, 
	79, 0, 80, 0, 81, 0, 82, 0, 
	83, 0, 84, 0, 85, 0, 86, 0, 
	87, 0, 88, 0, 89, 0, 90, 0, 
	91, 0, 92, 0, 93, 0, 95, 94, 
	95, 94, 95, 95, 4, 96, 4, 110, 
	119, 133, 140, 95, 94, 95, 97, 94, 
	95, 98, 94, 95, 99, 94, 95, 100, 
	94, 95, 101, 94, 95, 102, 94, 95, 
	103, 94, 95, 104, 94, 95, 105, 94, 
	95, 106, 94, 95, 107, 94, 95, 108, 
	94, 95, 109, 94, 95, 4, 94, 95, 
	111, 94, 95, 112, 94, 95, 113, 94, 
	95, 114, 94, 95, 115, 94, 95, 116, 
	94, 95, 117, 94, 95, 118, 94, 95, 
	75, 94, 95, 120, 94, 95, 121, 94, 
	95, 122, 94, 95, 123, 94, 95, 124, 
	94, 95, 125, 94, 95, 126, 94, 95, 
	127, 94, 95, 128, 94, 95, 129, 94, 
	95, 130, 94, 131, 95, 94, 132, 95, 
	94, 95, 118, 94, 95, 134, 94, 95, 
	135, 94, 95, 136, 94, 95, 137, 94, 
	95, 138, 94, 95, 139, 94, 95, 117, 
	94, 95, 141, 94, 95, 142, 94, 95, 
	143, 94, 95, 144, 94, 95, 145, 94, 
	95, 146, 94, 95, 147, 94, 95, 75, 
	148, 94, 95, 149, 94, 95, 150, 94, 
	95, 151, 94, 95, 152, 94, 95, 153, 
	94, 95, 154, 94, 95, 155, 94, 95, 
	118, 94, 157, 166, 0, 158, 0, 159, 
	0, 160, 0, 161, 0, 162, 0, 163, 
	0, 164, 0, 165, 0, 31, 0, 167, 
	0, 168, 0, 169, 0, 170, 0, 171, 
	0, 172, 0, 173, 0, 174, 0, 176, 
	175, 176, 175, 176, 176, 4, 177, 191, 
	4, 192, 203, 205, 220, 230, 246, 248, 
	176, 175, 176, 178, 175, 176, 179, 175, 
	176, 180, 175, 176, 181, 175, 176, 182, 
	175, 176, 183, 175, 176, 184, 175, 176, 
	185, 175, 176, 186, 175, 176, 187, 175, 
	176, 188, 175, 176, 189, 175, 176, 190, 
	175, 176, 4, 175, 176, 75, 175, 176, 
	193, 195, 175, 176, 194, 175, 176, 191, 
	175, 176, 196, 175, 176, 197, 175, 176, 
	198, 175, 176, 199, 175, 176, 200, 175, 
	176, 201, 175, 176, 202, 175, 176, 191, 
	175, 176, 204, 175, 176, 202, 175, 176, 
	206, 175, 176, 207, 175, 176, 208, 175, 
	176, 209, 175, 176, 210, 175, 176, 211, 
	175, 176, 212, 175, 176, 213, 175, 176, 
	214, 175, 176, 215, 175, 176, 216, 175, 
	217, 176, 175, 218, 176, 175, 176, 219, 
	175, 176, 75, 175, 176, 221, 175, 176, 
	222, 175, 176, 223, 175, 176, 224, 175, 
	176, 225, 175, 176, 226, 175, 176, 227, 
	175, 176, 228, 175, 176, 229, 175, 176, 
	191, 175, 176, 231, 175, 176, 232, 175, 
	176, 233, 175, 176, 234, 175, 176, 235, 
	175, 176, 236, 175, 176, 237, 175, 176, 
	75, 238, 175, 176, 239, 175, 176, 240, 
	175, 176, 241, 175, 176, 242, 175, 176, 
	243, 175, 176, 244, 175, 176, 245, 175, 
	176, 219, 175, 176, 247, 175, 176, 191, 
	175, 176, 204, 175, 250, 0, 251, 0, 
	252, 0, 253, 0, 254, 0, 255, 0, 
	256, 0, 257, 339, 0, 259, 258, 259, 
	258, 259, 259, 4, 260, 274, 4, 275, 
	286, 288, 303, 320, 336, 338, 259, 258, 
	259, 261, 258, 259, 262, 258, 259, 263, 
	258, 259, 264, 258, 259, 265, 258, 259, 
	266, 258, 259, 267, 258, 259, 268, 258, 
	259, 269, 258, 259, 270, 258, 259, 271, 
	258, 259, 272, 258, 259, 273, 258, 259, 
	4, 258, 259, 75, 258, 259, 276, 278, 
	258, 259, 277, 258, 259, 274, 258, 259, 
	279, 258, 259, 280, 258, 259, 281, 258, 
	259, 282, 258, 259, 283, 258, 259, 284, 
	258, 259, 285, 258, 259, 274, 258, 259, 
	287, 258, 259, 285, 258, 259, 289, 258, 
	259, 290, 258, 259, 291, 258, 259, 292, 
	258, 259, 293, 258, 259, 294, 258, 259, 
	295, 258, 259, 296, 258, 259, 297, 258, 
	259, 298, 258, 259, 299, 258, 300, 259, 
	258, 301, 259, 258, 259, 302, 258, 259, 
	75, 258, 259, 304, 313, 258, 259, 305, 
	258, 259, 306, 258, 259, 307, 258, 259, 
	308, 258, 259, 309, 258, 259, 310, 258, 
	259, 311, 258, 259, 312, 258, 259, 274, 
	258, 259, 314, 258, 259, 315, 258, 259, 
	316, 258, 259, 317, 258, 259, 318, 258, 
	259, 319, 258, 259, 302, 258, 259, 321, 
	258, 259, 322, 258, 259, 323, 258, 259, 
	324, 258, 259, 325, 258, 259, 326, 258, 
	259, 327, 258, 259, 75, 328, 258, 259, 
	329, 258, 259, 330, 258, 259, 331, 258, 
	259, 332, 258, 259, 333, 258, 259, 334, 
	258, 259, 335, 258, 259, 302, 258, 259, 
	337, 258, 259, 274, 258, 259, 287, 258, 
	340, 0, 341, 0, 342, 0, 343, 0, 
	344, 0, 345, 0, 346, 0, 347, 0, 
	348, 0, 350, 349, 350, 349, 350, 350, 
	4, 351, 365, 4, 366, 377, 379, 394, 
	404, 411, 413, 350, 349, 350, 352, 349, 
	350, 353, 349, 350, 354, 349, 350, 355, 
	349, 350, 356, 349, 350, 357, 349, 350, 
	358, 349, 350, 359, 349, 350, 360, 349, 
	350, 361, 349, 350, 362, 349, 350, 363, 
	349, 350, 364, 349, 350, 4, 349, 350, 
	75, 349, 350, 367, 369, 349, 350, 368, 
	349, 350, 365, 349, 350, 370, 349, 350, 
	371, 349, 350, 372, 349, 350, 373, 349, 
	350, 374, 349, 350, 375, 349, 350, 376, 
	349, 350, 365, 349, 350, 378, 349, 350, 
	376, 349, 350, 380, 349, 350, 381, 349, 
	350, 382, 349, 350, 383, 349, 350, 384, 
	349, 350, 385, 349, 350, 386, 349, 350, 
	387, 349, 350, 388, 349, 350, 389, 349, 
	350, 390, 349, 391, 350, 349, 392, 350, 
	349, 350, 393, 349, 350, 75, 349, 350, 
	395, 349, 350, 396, 349, 350, 397, 349, 
	350, 398, 349, 350, 399, 349, 350, 400, 
	349, 350, 401, 349, 350, 402, 349, 350, 
	403, 349, 350, 365, 349, 350, 405, 349, 
	350, 406, 349, 350, 407, 349, 350, 408, 
	349, 350, 409, 349, 350, 410, 349, 350, 
	393, 349, 350, 412, 349, 350, 365, 349, 
	350, 378, 349, 415, 0, 31, 0, 77, 
	0, 417, 418, 417, 0, 422, 421, 420, 
	418, 421, 419, 0, 420, 418, 419, 0, 
	420, 419, 422, 421, 420, 418, 421, 419, 
	422, 422, 5, 15, 17, 31, 34, 37, 
	48, 76, 78, 156, 249, 414, 416, 417, 
	422, 0, 0, 0
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
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	81, 84, 81, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	21, 0, 130, 31, 60, 57, 31, 63, 
	57, 63, 63, 63, 63, 63, 63, 63, 
	63, 66, 31, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 69, 33, 69, 84, 
	84, 84, 84, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 13, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	13, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 13, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 72, 33, 84, 
	72, 84, 84, 84, 84, 84, 84, 84, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 15, 0, 54, 15, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 54, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	15, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 0, 43, 144, 57, 54, 
	0, 54, 0, 75, 33, 84, 75, 84, 
	84, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	17, 0, 54, 17, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	17, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 17, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	78, 33, 84, 78, 84, 84, 84, 84, 
	84, 84, 84, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	19, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 0, 0, 43, 54, 37, 37, 
	87, 37, 37, 43, 0, 39, 0, 43, 
	0, 0, 54, 0, 0, 39, 0, 0, 
	54, 0, 93, 90, 41, 96, 90, 96, 
	96, 96, 96, 96, 96, 96, 96, 99, 
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
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 423;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"

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
    
    
#line 1019 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
    
#line 1026 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
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
#line 1316 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"
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
#line 1379 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/de.c.rl"

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

void Init_gherkin_lexer_de()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "De", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

