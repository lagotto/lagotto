
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_id/gherkin_lexer_id.c"
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
	113, 114, 115, 116, 117, 118, 125, 127, 
	129, 131, 133, 135, 152, 154, 156, 157, 
	158, 159, 160, 161, 175, 177, 179, 181, 
	183, 185, 187, 189, 191, 193, 195, 197, 
	199, 201, 203, 205, 208, 210, 212, 214, 
	216, 218, 220, 222, 224, 226, 228, 230, 
	232, 234, 236, 238, 240, 242, 244, 246, 
	248, 250, 252, 255, 257, 259, 261, 263, 
	265, 267, 269, 271, 273, 274, 275, 276, 
	277, 278, 279, 280, 281, 282, 283, 284, 
	295, 297, 299, 301, 303, 305, 307, 309, 
	311, 313, 315, 317, 319, 321, 323, 325, 
	327, 329, 331, 333, 335, 337, 339, 341, 
	343, 345, 347, 349, 351, 353, 355, 357, 
	359, 361, 363, 366, 368, 370, 372, 374, 
	376, 378, 379, 380, 381, 382, 383, 384, 
	385, 386, 387, 388, 389, 390, 391, 393, 
	394, 395, 396, 397, 398, 399, 400, 401, 
	402, 416, 418, 420, 422, 424, 426, 428, 
	430, 432, 434, 436, 438, 440, 442, 444, 
	446, 449, 451, 453, 455, 457, 459, 461, 
	463, 465, 467, 469, 471, 473, 475, 477, 
	479, 481, 483, 485, 487, 489, 491, 493, 
	495, 497, 499, 500, 501, 515, 517, 519, 
	521, 523, 525, 527, 529, 531, 533, 535, 
	537, 539, 541, 543, 545, 548, 551, 553, 
	555, 557, 559, 561, 563, 565, 567, 569, 
	571, 573, 575, 577, 579, 581, 583, 585, 
	587, 589, 591, 593, 595, 597, 600, 602, 
	604, 606, 608, 610, 612, 614, 616, 618, 
	619, 620, 621, 625, 631, 634, 636, 642, 
	659
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	67, 68, 70, 75, 77, 83, 84, 124, 
	9, 13, -69, -65, 10, 32, 34, 35, 
	37, 42, 64, 67, 68, 70, 75, 77, 
	83, 84, 124, 9, 13, 34, 34, 10, 
	13, 10, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 9, 13, 10, 32, 9, 13, 10, 
	13, 10, 95, 70, 69, 65, 84, 85, 
	82, 69, 95, 69, 78, 68, 95, 37, 
	32, 10, 13, 10, 13, 13, 32, 64, 
	9, 10, 9, 10, 13, 32, 64, 11, 
	12, 10, 32, 64, 9, 13, 111, 110, 
	116, 111, 104, 58, 10, 10, 10, 32, 
	35, 70, 124, 9, 13, 10, 105, 10, 
	116, 10, 117, 10, 114, 10, 58, 10, 
	32, 34, 35, 37, 42, 64, 67, 68, 
	70, 75, 77, 83, 84, 124, 9, 13, 
	97, 101, 110, 115, 97, 114, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 68, 
	70, 75, 77, 83, 84, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, 10, 97, 101, 
	10, 110, 10, 110, 10, 103, 10, 97, 
	10, 105, 10, 116, 10, 117, 10, 114, 
	10, 58, 10, 101, 10, 116, 10, 105, 
	10, 107, 10, 97, 10, 97, 10, 107, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 10, 32, 58, 10, 
	107, 10, 111, 10, 110, 10, 115, 10, 
	101, 10, 112, 10, 97, 10, 112, 10, 
	105, 110, 103, 97, 110, 105, 116, 117, 
	114, 58, 10, 10, 10, 32, 35, 37, 
	64, 67, 68, 70, 83, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 111, 10, 110, 10, 
	116, 10, 111, 10, 104, 10, 58, 10, 
	97, 10, 115, 10, 97, 10, 114, 10, 
	105, 10, 116, 10, 117, 10, 107, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 111, 10, 32, 58, 10, 107, 
	10, 111, 10, 110, 10, 115, 10, 101, 
	10, 112, 101, 116, 105, 107, 97, 97, 
	107, 101, 110, 97, 114, 105, 111, 32, 
	58, 107, 111, 110, 115, 101, 112, 58, 
	10, 10, 10, 32, 35, 37, 42, 64, 
	68, 70, 75, 77, 83, 84, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 97, 
	101, 10, 110, 10, 110, 10, 103, 10, 
	97, 10, 105, 10, 116, 10, 117, 10, 
	114, 10, 58, 10, 101, 10, 116, 10, 
	105, 10, 107, 10, 97, 10, 97, 10, 
	107, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 111, 10, 97, 10, 
	112, 10, 105, 10, 10, 10, 32, 35, 
	37, 42, 64, 68, 70, 75, 77, 83, 
	84, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 97, 101, 10, 110, 115, 10, 
	97, 10, 114, 10, 58, 10, 110, 10, 
	103, 10, 97, 10, 110, 10, 105, 10, 
	116, 10, 117, 10, 101, 10, 116, 10, 
	105, 10, 107, 10, 97, 10, 97, 10, 
	107, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 111, 10, 32, 58, 
	10, 107, 10, 111, 10, 110, 10, 115, 
	10, 101, 10, 112, 10, 97, 10, 112, 
	10, 105, 97, 112, 105, 32, 124, 9, 
	13, 10, 32, 92, 124, 9, 13, 10, 
	92, 124, 10, 92, 10, 32, 92, 124, 
	9, 13, 10, 32, 34, 35, 37, 42, 
	64, 67, 68, 70, 75, 77, 83, 84, 
	124, 9, 13, 0
};

static const char _lexer_single_lengths[] = {
	0, 16, 1, 1, 15, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 5, 2, 2, 
	2, 2, 2, 15, 2, 2, 1, 1, 
	1, 1, 1, 12, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 9, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	12, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 12, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 2, 4, 3, 2, 4, 15, 
	0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
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
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 1, 1, 0, 0, 1, 1, 
	0
};

static const short _lexer_index_offsets[] = {
	0, 0, 18, 20, 22, 39, 41, 43, 
	46, 49, 54, 59, 64, 69, 73, 77, 
	80, 82, 84, 86, 88, 90, 92, 94, 
	96, 98, 100, 102, 104, 106, 108, 110, 
	112, 115, 118, 123, 130, 135, 137, 139, 
	141, 143, 145, 147, 149, 151, 158, 161, 
	164, 167, 170, 173, 190, 193, 196, 198, 
	200, 202, 204, 206, 220, 223, 226, 229, 
	232, 235, 238, 241, 244, 247, 250, 253, 
	256, 259, 262, 265, 269, 272, 275, 278, 
	281, 284, 287, 290, 293, 296, 299, 302, 
	305, 308, 311, 314, 317, 320, 323, 326, 
	329, 332, 335, 339, 342, 345, 348, 351, 
	354, 357, 360, 363, 366, 368, 370, 372, 
	374, 376, 378, 380, 382, 384, 386, 388, 
	399, 402, 405, 408, 411, 414, 417, 420, 
	423, 426, 429, 432, 435, 438, 441, 444, 
	447, 450, 453, 456, 459, 462, 465, 468, 
	471, 474, 477, 480, 483, 486, 489, 492, 
	495, 498, 501, 505, 508, 511, 514, 517, 
	520, 523, 525, 527, 529, 531, 533, 535, 
	537, 539, 541, 543, 545, 547, 549, 552, 
	554, 556, 558, 560, 562, 564, 566, 568, 
	570, 584, 587, 590, 593, 596, 599, 602, 
	605, 608, 611, 614, 617, 620, 623, 626, 
	629, 633, 636, 639, 642, 645, 648, 651, 
	654, 657, 660, 663, 666, 669, 672, 675, 
	678, 681, 684, 687, 690, 693, 696, 699, 
	702, 705, 708, 710, 712, 726, 729, 732, 
	735, 738, 741, 744, 747, 750, 753, 756, 
	759, 762, 765, 768, 771, 775, 779, 782, 
	785, 788, 791, 794, 797, 800, 803, 806, 
	809, 812, 815, 818, 821, 824, 827, 830, 
	833, 836, 839, 842, 845, 848, 852, 855, 
	858, 861, 864, 867, 870, 873, 876, 879, 
	881, 883, 885, 889, 895, 899, 902, 908, 
	925
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 52, 112, 161, 166, 167, 279, 282, 
	4, 0, 3, 0, 4, 0, 4, 4, 
	5, 15, 17, 31, 34, 37, 52, 112, 
	161, 166, 167, 279, 282, 4, 0, 6, 
	0, 7, 0, 9, 8, 8, 9, 8, 
	8, 10, 10, 11, 10, 10, 10, 10, 
	11, 10, 10, 10, 10, 12, 10, 10, 
	10, 10, 13, 10, 10, 4, 14, 14, 
	0, 4, 14, 14, 0, 4, 16, 15, 
	4, 0, 18, 0, 19, 0, 20, 0, 
	21, 0, 22, 0, 23, 0, 24, 0, 
	25, 0, 26, 0, 27, 0, 28, 0, 
	29, 0, 30, 0, 288, 0, 32, 0, 
	4, 16, 33, 4, 16, 33, 0, 0, 
	0, 0, 35, 36, 4, 36, 36, 34, 
	35, 35, 4, 36, 34, 36, 0, 38, 
	0, 39, 0, 40, 0, 41, 0, 42, 
	0, 43, 0, 45, 44, 45, 44, 45, 
	45, 4, 46, 4, 45, 44, 45, 47, 
	44, 45, 48, 44, 45, 49, 44, 45, 
	50, 44, 45, 51, 44, 4, 4, 5, 
	15, 17, 31, 34, 37, 52, 112, 161, 
	166, 167, 279, 282, 4, 0, 53, 108, 
	0, 31, 54, 0, 55, 0, 56, 0, 
	57, 0, 59, 58, 59, 58, 59, 59, 
	4, 60, 74, 4, 75, 80, 85, 90, 
	91, 105, 59, 58, 59, 61, 58, 59, 
	62, 58, 59, 63, 58, 59, 64, 58, 
	59, 65, 58, 59, 66, 58, 59, 67, 
	58, 59, 68, 58, 59, 69, 58, 59, 
	70, 58, 59, 71, 58, 59, 72, 58, 
	59, 73, 58, 59, 4, 58, 59, 51, 
	58, 59, 76, 77, 58, 59, 74, 58, 
	59, 78, 58, 59, 79, 58, 59, 76, 
	58, 59, 81, 58, 59, 82, 58, 59, 
	83, 58, 59, 84, 58, 59, 51, 58, 
	59, 86, 58, 59, 87, 58, 59, 88, 
	58, 59, 89, 58, 59, 74, 58, 59, 
	88, 58, 59, 92, 58, 59, 93, 58, 
	59, 94, 58, 59, 95, 58, 59, 96, 
	58, 59, 97, 58, 59, 98, 58, 59, 
	99, 51, 58, 59, 100, 58, 59, 101, 
	58, 59, 102, 58, 59, 103, 58, 59, 
	104, 58, 59, 84, 58, 59, 106, 58, 
	59, 107, 58, 59, 74, 58, 109, 0, 
	110, 0, 111, 0, 31, 0, 113, 0, 
	114, 0, 115, 0, 116, 0, 117, 0, 
	119, 118, 119, 118, 119, 119, 4, 120, 
	4, 134, 140, 144, 147, 119, 118, 119, 
	121, 118, 119, 122, 118, 119, 123, 118, 
	119, 124, 118, 119, 125, 118, 119, 126, 
	118, 119, 127, 118, 119, 128, 118, 119, 
	129, 118, 119, 130, 118, 119, 131, 118, 
	119, 132, 118, 119, 133, 118, 119, 4, 
	118, 119, 135, 118, 119, 136, 118, 119, 
	137, 118, 119, 138, 118, 119, 139, 118, 
	119, 51, 118, 119, 141, 118, 119, 142, 
	118, 119, 143, 118, 119, 139, 118, 119, 
	145, 118, 119, 146, 118, 119, 143, 118, 
	119, 148, 118, 119, 149, 118, 119, 150, 
	118, 119, 151, 118, 119, 152, 118, 119, 
	153, 118, 119, 154, 118, 119, 155, 51, 
	118, 119, 156, 118, 119, 157, 118, 119, 
	158, 118, 119, 159, 118, 119, 160, 118, 
	119, 139, 118, 162, 0, 163, 0, 164, 
	0, 165, 0, 31, 0, 164, 0, 168, 
	0, 169, 0, 170, 0, 171, 0, 172, 
	0, 173, 0, 174, 0, 175, 226, 0, 
	176, 0, 177, 0, 178, 0, 179, 0, 
	180, 0, 181, 0, 182, 0, 184, 183, 
	184, 183, 184, 184, 4, 185, 199, 4, 
	200, 205, 210, 215, 216, 223, 184, 183, 
	184, 186, 183, 184, 187, 183, 184, 188, 
	183, 184, 189, 183, 184, 190, 183, 184, 
	191, 183, 184, 192, 183, 184, 193, 183, 
	184, 194, 183, 184, 195, 183, 184, 196, 
	183, 184, 197, 183, 184, 198, 183, 184, 
	4, 183, 184, 51, 183, 184, 201, 202, 
	183, 184, 199, 183, 184, 203, 183, 184, 
	204, 183, 184, 201, 183, 184, 206, 183, 
	184, 207, 183, 184, 208, 183, 184, 209, 
	183, 184, 51, 183, 184, 211, 183, 184, 
	212, 183, 184, 213, 183, 184, 214, 183, 
	184, 199, 183, 184, 213, 183, 184, 217, 
	183, 184, 218, 183, 184, 219, 183, 184, 
	220, 183, 184, 221, 183, 184, 222, 183, 
	184, 209, 183, 184, 224, 183, 184, 225, 
	183, 184, 199, 183, 228, 227, 228, 227, 
	228, 228, 4, 229, 243, 4, 244, 253, 
	256, 261, 262, 276, 228, 227, 228, 230, 
	227, 228, 231, 227, 228, 232, 227, 228, 
	233, 227, 228, 234, 227, 228, 235, 227, 
	228, 236, 227, 228, 237, 227, 228, 238, 
	227, 228, 239, 227, 228, 240, 227, 228, 
	241, 227, 228, 242, 227, 228, 4, 227, 
	228, 51, 227, 228, 245, 249, 227, 228, 
	243, 246, 227, 228, 247, 227, 228, 248, 
	227, 228, 51, 227, 228, 250, 227, 228, 
	251, 227, 228, 252, 227, 228, 243, 227, 
	228, 254, 227, 228, 255, 227, 228, 247, 
	227, 228, 257, 227, 228, 258, 227, 228, 
	259, 227, 228, 260, 227, 228, 243, 227, 
	228, 259, 227, 228, 263, 227, 228, 264, 
	227, 228, 265, 227, 228, 266, 227, 228, 
	267, 227, 228, 268, 227, 228, 269, 227, 
	228, 270, 51, 227, 228, 271, 227, 228, 
	272, 227, 228, 273, 227, 228, 274, 227, 
	228, 275, 227, 228, 248, 227, 228, 277, 
	227, 228, 278, 227, 228, 243, 227, 280, 
	0, 281, 0, 31, 0, 282, 283, 282, 
	0, 287, 286, 285, 283, 286, 284, 0, 
	285, 283, 284, 0, 285, 284, 287, 286, 
	285, 283, 286, 284, 287, 287, 5, 15, 
	17, 31, 34, 37, 52, 112, 161, 166, 
	167, 279, 282, 287, 0, 0, 0
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
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 81, 84, 81, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 21, 0, 130, 31, 60, 
	57, 31, 63, 57, 63, 63, 63, 63, 
	63, 63, 63, 66, 31, 43, 0, 0, 
	43, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 144, 57, 54, 0, 54, 0, 
	72, 33, 84, 72, 84, 84, 84, 84, 
	84, 84, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 15, 0, 54, 15, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 15, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 15, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 69, 33, 
	69, 84, 84, 84, 84, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 13, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 13, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 13, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 78, 33, 84, 78, 
	84, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	19, 0, 54, 19, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 19, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 144, 57, 54, 0, 
	54, 0, 75, 33, 84, 75, 84, 84, 
	84, 84, 84, 84, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 17, 0, 
	54, 17, 0, 54, 0, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 17, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 17, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	43, 0, 43, 0, 43, 0, 0, 0, 
	43, 54, 37, 37, 87, 37, 37, 43, 
	0, 39, 0, 43, 0, 0, 54, 0, 
	0, 39, 0, 0, 54, 0, 93, 90, 
	41, 96, 90, 96, 96, 96, 96, 96, 
	96, 96, 99, 0, 43, 0, 0
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
	43
};

static const int lexer_start = 1;
static const int lexer_first_final = 288;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"

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
    
    
#line 812 "ext/gherkin_lexer_id/gherkin_lexer_id.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
    
#line 819 "ext/gherkin_lexer_id/gherkin_lexer_id.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
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
#line 1109 "ext/gherkin_lexer_id/gherkin_lexer_id.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"
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
#line 1172 "ext/gherkin_lexer_id/gherkin_lexer_id.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/id.c.rl"

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

void Init_gherkin_lexer_id()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Id", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

