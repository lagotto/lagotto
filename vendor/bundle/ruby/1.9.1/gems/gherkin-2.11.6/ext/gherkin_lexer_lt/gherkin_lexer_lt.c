
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_lt/gherkin_lexer_lt.c"
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
	115, 116, 117, 118, 119, 121, 122, 123, 
	124, 125, 126, 127, 128, 129, 130, 131, 
	132, 133, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 165, 167, 169, 171, 173, 
	175, 177, 195, 196, 197, 198, 199, 200, 
	201, 202, 203, 204, 205, 206, 207, 208, 
	215, 217, 219, 221, 223, 225, 227, 229, 
	231, 232, 233, 234, 235, 236, 237, 238, 
	239, 250, 252, 254, 256, 258, 260, 262, 
	264, 266, 268, 270, 272, 274, 276, 278, 
	280, 282, 284, 286, 288, 290, 292, 294, 
	296, 298, 300, 302, 304, 306, 308, 310, 
	312, 314, 316, 318, 321, 323, 325, 327, 
	329, 331, 333, 335, 337, 339, 341, 343, 
	346, 349, 351, 353, 355, 357, 359, 361, 
	363, 365, 367, 369, 371, 373, 375, 377, 
	379, 380, 381, 382, 383, 384, 385, 387, 
	389, 390, 391, 392, 393, 394, 395, 396, 
	397, 398, 399, 400, 401, 402, 403, 417, 
	419, 421, 423, 425, 427, 429, 431, 433, 
	435, 437, 439, 441, 443, 445, 447, 449, 
	451, 453, 455, 457, 459, 461, 463, 465, 
	468, 470, 472, 474, 476, 478, 480, 482, 
	484, 486, 488, 490, 492, 494, 496, 498, 
	500, 501, 502, 503, 504, 518, 520, 522, 
	524, 526, 528, 530, 532, 534, 536, 538, 
	540, 542, 544, 546, 548, 550, 552, 554, 
	556, 558, 560, 562, 565, 567, 569, 571, 
	573, 575, 577, 579, 581, 583, 585, 588, 
	590, 592, 594, 596, 598, 600, 602, 604, 
	606, 608, 610, 613, 615, 617, 619, 621, 
	623, 625, 627, 629, 631, 633, 635, 637, 
	638, 639, 640, 641, 642, 643, 644, 645, 
	649, 655, 658, 660, 666, 684, 686, 688, 
	690, 692, 694, 696, 698, 700, 702, 705, 
	707, 709, 711, 713, 715, 717, 719, 721, 
	723, 725, 727, 729, 732, 734, 736, 738, 
	740, 742, 744, 746, 748, 750, 752, 754, 
	756, 758, 760
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	66, 68, 73, 75, 80, 83, 84, 86, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 66, 68, 73, 75, 
	80, 83, 84, 86, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	101, 116, 117, 111, 116, 97, 114, 97, 
	111, 105, 110, 116, 101, 107, 115, 116, 
	97, 115, 58, 10, 10, 10, 32, 35, 
	37, 42, 64, 66, 68, 73, 75, 83, 
	84, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 32, 34, 35, 37, 42, 64, 
	66, 68, 73, 75, 80, 83, 84, 86, 
	124, 9, 13, 97, 118, 121, 122, 100, 
	-59, -66, 105, 97, 105, 58, 10, 10, 
	10, 32, 35, 83, 124, 9, 13, 10, 
	97, 10, 118, 10, 121, 10, 98, -60, 
	10, -105, 10, 10, 58, 97, 99, 118, 
	121, 98, -60, -105, 58, 10, 10, 10, 
	32, 35, 37, 64, 75, 80, 83, 86, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 111, 
	10, 110, 10, 116, 10, 101, 10, 107, 
	10, 115, 10, 116, 10, 97, 10, 115, 
	10, 58, 10, 97, 10, 118, 10, 121, 
	10, 122, 10, 100, -59, 10, -66, 10, 
	10, 105, 10, 97, 10, 105, 10, 97, 
	99, 10, 118, 10, 121, 10, 98, -60, 
	10, -105, 10, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 106, 10, 
	97, 117, 10, 105, 117, 10, 115, 10, 
	32, -59, 10, -95, 10, 10, 97, 10, 
	98, 10, 108, 10, 111, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 97, 10, 
	110, 10, 116, 101, 110, 97, 114, 105, 
	106, 97, 117, 105, 117, 115, 32, -59, 
	-95, 97, 98, 108, 111, 110, 97, 115, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 66, 68, 73, 75, 83, 84, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	101, 10, 116, 10, 117, 10, 111, 10, 
	116, 10, 97, 10, 114, 10, 97, 10, 
	105, 10, 97, 99, 10, 118, 10, 121, 
	10, 98, -60, 10, -105, 10, 10, 58, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 106, 10, 117, 10, 115, 
	10, 97, 10, 100, 115, 58, 10, 10, 
	10, 32, 35, 37, 42, 64, 66, 68, 
	73, 75, 83, 84, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, 10, 101, 10, 116, 
	10, 117, 10, 111, 10, 116, 10, 97, 
	10, 114, 10, 97, 111, 10, 105, 10, 
	110, 10, 116, 10, 101, 10, 107, 10, 
	115, 10, 116, 10, 97, 10, 115, 10, 
	58, 10, 97, 99, 10, 118, 10, 121, 
	10, 98, -60, 10, -105, 10, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 106, 10, 97, 117, 10, 117, 10, 
	115, 10, 32, -59, 10, -95, 10, 10, 
	97, 10, 98, 10, 108, 10, 111, 10, 
	110, 10, 97, 10, 100, 97, 100, 97, 
	114, 105, 97, 110, 116, 32, 124, 9, 
	13, 10, 32, 92, 124, 9, 13, 10, 
	92, 124, 10, 92, 10, 32, 92, 124, 
	9, 13, 10, 32, 34, 35, 37, 42, 
	64, 66, 68, 73, 75, 80, 83, 84, 
	86, 124, 9, 13, 10, 101, 10, 116, 
	10, 117, 10, 111, 10, 116, 10, 97, 
	10, 114, 10, 97, 10, 105, 10, 97, 
	99, 10, 118, 10, 121, 10, 98, -60, 
	10, -105, 10, 10, 58, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	106, 10, 97, 117, 10, 117, 10, 115, 
	10, 32, -59, 10, -95, 10, 10, 97, 
	10, 98, 10, 108, 10, 111, 10, 110, 
	10, 97, 10, 115, 10, 97, 10, 100, 
	0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 12, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 16, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 5, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	9, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 12, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 12, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	4, 3, 2, 4, 16, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
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
	0, 0, 0, 0, 0, 0, 1, 0, 
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
	1, 0, 0, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 139, 141, 
	143, 145, 147, 149, 151, 154, 156, 158, 
	160, 162, 164, 166, 168, 170, 172, 174, 
	176, 178, 192, 195, 198, 201, 204, 207, 
	210, 213, 216, 219, 222, 225, 228, 231, 
	234, 237, 255, 257, 259, 261, 263, 265, 
	267, 269, 271, 273, 275, 277, 279, 281, 
	288, 291, 294, 297, 300, 303, 306, 309, 
	312, 314, 316, 318, 320, 322, 324, 326, 
	328, 339, 342, 345, 348, 351, 354, 357, 
	360, 363, 366, 369, 372, 375, 378, 381, 
	384, 387, 390, 393, 396, 399, 402, 405, 
	408, 411, 414, 417, 420, 423, 426, 429, 
	432, 435, 438, 441, 445, 448, 451, 454, 
	457, 460, 463, 466, 469, 472, 475, 478, 
	482, 486, 489, 492, 495, 498, 501, 504, 
	507, 510, 513, 516, 519, 522, 525, 528, 
	531, 533, 535, 537, 539, 541, 543, 546, 
	549, 551, 553, 555, 557, 559, 561, 563, 
	565, 567, 569, 571, 573, 575, 577, 591, 
	594, 597, 600, 603, 606, 609, 612, 615, 
	618, 621, 624, 627, 630, 633, 636, 639, 
	642, 645, 648, 651, 654, 657, 660, 663, 
	667, 670, 673, 676, 679, 682, 685, 688, 
	691, 694, 697, 700, 703, 706, 709, 712, 
	715, 717, 719, 721, 723, 737, 740, 743, 
	746, 749, 752, 755, 758, 761, 764, 767, 
	770, 773, 776, 779, 782, 785, 788, 791, 
	794, 797, 800, 803, 807, 810, 813, 816, 
	819, 822, 825, 828, 831, 834, 837, 841, 
	844, 847, 850, 853, 856, 859, 862, 865, 
	868, 871, 874, 878, 881, 884, 887, 890, 
	893, 896, 899, 902, 905, 908, 911, 914, 
	916, 918, 920, 922, 924, 926, 928, 930, 
	934, 940, 944, 947, 953, 971, 974, 977, 
	980, 983, 986, 989, 992, 995, 998, 1002, 
	1005, 1008, 1011, 1014, 1017, 1020, 1023, 1026, 
	1029, 1032, 1035, 1038, 1042, 1045, 1048, 1051, 
	1054, 1057, 1060, 1063, 1066, 1069, 1072, 1075, 
	1078, 1081, 1084
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 39, 43, 44, 74, 95, 295, 297, 
	303, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 39, 
	43, 44, 74, 95, 295, 297, 303, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 346, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 0, 31, 0, 40, 0, 41, 
	0, 42, 0, 31, 0, 31, 0, 45, 
	46, 0, 31, 0, 47, 0, 48, 0, 
	49, 0, 50, 0, 51, 0, 52, 0, 
	53, 0, 54, 0, 55, 0, 57, 56, 
	57, 56, 57, 57, 4, 58, 72, 4, 
	309, 311, 315, 316, 318, 344, 57, 56, 
	57, 59, 56, 57, 60, 56, 57, 61, 
	56, 57, 62, 56, 57, 63, 56, 57, 
	64, 56, 57, 65, 56, 57, 66, 56, 
	57, 67, 56, 57, 68, 56, 57, 69, 
	56, 57, 70, 56, 57, 71, 56, 57, 
	4, 56, 57, 73, 56, 4, 4, 5, 
	15, 17, 31, 34, 37, 39, 43, 44, 
	74, 95, 295, 297, 303, 4, 0, 75, 
	0, 76, 0, 77, 0, 78, 0, 79, 
	0, 80, 0, 81, 0, 82, 0, 83, 
	0, 84, 0, 85, 0, 87, 86, 87, 
	86, 87, 87, 4, 88, 4, 87, 86, 
	87, 89, 86, 87, 90, 86, 87, 91, 
	86, 87, 92, 86, 93, 87, 86, 94, 
	87, 86, 87, 73, 86, 96, 168, 0, 
	97, 0, 98, 0, 99, 0, 100, 0, 
	101, 0, 102, 0, 104, 103, 104, 103, 
	104, 104, 4, 105, 4, 119, 129, 139, 
	162, 104, 103, 104, 106, 103, 104, 107, 
	103, 104, 108, 103, 104, 109, 103, 104, 
	110, 103, 104, 111, 103, 104, 112, 103, 
	104, 113, 103, 104, 114, 103, 104, 115, 
	103, 104, 116, 103, 104, 117, 103, 104, 
	118, 103, 104, 4, 103, 104, 120, 103, 
	104, 121, 103, 104, 122, 103, 104, 123, 
	103, 104, 124, 103, 104, 125, 103, 104, 
	126, 103, 104, 127, 103, 104, 128, 103, 
	104, 73, 103, 104, 130, 103, 104, 131, 
	103, 104, 132, 103, 104, 133, 103, 104, 
	134, 103, 135, 104, 103, 136, 104, 103, 
	104, 137, 103, 104, 138, 103, 104, 128, 
	103, 104, 140, 145, 103, 104, 141, 103, 
	104, 142, 103, 104, 143, 103, 144, 104, 
	103, 128, 104, 103, 104, 146, 103, 104, 
	147, 103, 104, 148, 103, 104, 149, 103, 
	104, 150, 103, 104, 151, 103, 104, 152, 
	127, 103, 104, 128, 153, 103, 104, 154, 
	103, 104, 155, 103, 156, 104, 103, 157, 
	104, 103, 104, 158, 103, 104, 159, 103, 
	104, 160, 103, 104, 161, 103, 104, 126, 
	103, 104, 163, 103, 104, 164, 103, 104, 
	165, 103, 104, 166, 103, 104, 167, 103, 
	104, 137, 103, 169, 0, 170, 0, 171, 
	0, 172, 0, 173, 0, 174, 0, 175, 
	232, 0, 84, 176, 0, 177, 0, 178, 
	0, 179, 0, 180, 0, 181, 0, 182, 
	0, 183, 0, 184, 0, 185, 0, 186, 
	0, 187, 0, 188, 0, 190, 189, 190, 
	189, 190, 190, 4, 191, 205, 4, 206, 
	208, 212, 213, 215, 230, 190, 189, 190, 
	192, 189, 190, 193, 189, 190, 194, 189, 
	190, 195, 189, 190, 196, 189, 190, 197, 
	189, 190, 198, 189, 190, 199, 189, 190, 
	200, 189, 190, 201, 189, 190, 202, 189, 
	190, 203, 189, 190, 204, 189, 190, 4, 
	189, 190, 73, 189, 190, 207, 189, 190, 
	205, 189, 190, 209, 189, 190, 210, 189, 
	190, 211, 189, 190, 205, 189, 190, 205, 
	189, 190, 214, 189, 190, 205, 189, 190, 
	216, 222, 189, 190, 217, 189, 190, 218, 
	189, 190, 219, 189, 220, 190, 189, 221, 
	190, 189, 190, 73, 189, 190, 223, 189, 
	190, 224, 189, 190, 225, 189, 190, 226, 
	189, 190, 227, 189, 190, 228, 189, 190, 
	229, 189, 190, 221, 189, 190, 231, 189, 
	190, 211, 189, 233, 0, 234, 0, 236, 
	235, 236, 235, 236, 236, 4, 237, 251, 
	4, 252, 254, 258, 259, 270, 293, 236, 
	235, 236, 238, 235, 236, 239, 235, 236, 
	240, 235, 236, 241, 235, 236, 242, 235, 
	236, 243, 235, 236, 244, 235, 236, 245, 
	235, 236, 246, 235, 236, 247, 235, 236, 
	248, 235, 236, 249, 235, 236, 250, 235, 
	236, 4, 235, 236, 73, 235, 236, 253, 
	235, 236, 251, 235, 236, 255, 235, 236, 
	256, 235, 236, 257, 235, 236, 251, 235, 
	236, 251, 235, 236, 260, 261, 235, 236, 
	251, 235, 236, 262, 235, 236, 263, 235, 
	236, 264, 235, 236, 265, 235, 236, 266, 
	235, 236, 267, 235, 236, 268, 235, 236, 
	269, 235, 236, 73, 235, 236, 271, 276, 
	235, 236, 272, 235, 236, 273, 235, 236, 
	274, 235, 275, 236, 235, 269, 236, 235, 
	236, 277, 235, 236, 278, 235, 236, 279, 
	235, 236, 280, 235, 236, 281, 235, 236, 
	282, 235, 236, 283, 268, 235, 236, 284, 
	235, 236, 285, 235, 236, 286, 235, 287, 
	236, 235, 288, 236, 235, 236, 289, 235, 
	236, 290, 235, 236, 291, 235, 236, 292, 
	235, 236, 267, 235, 236, 294, 235, 236, 
	257, 235, 296, 0, 42, 0, 298, 0, 
	299, 0, 300, 0, 301, 0, 302, 0, 
	82, 0, 303, 304, 303, 0, 308, 307, 
	306, 304, 307, 305, 0, 306, 304, 305, 
	0, 306, 305, 308, 307, 306, 304, 307, 
	305, 308, 308, 5, 15, 17, 31, 34, 
	37, 39, 43, 44, 74, 95, 295, 297, 
	303, 308, 0, 57, 310, 56, 57, 72, 
	56, 57, 312, 56, 57, 313, 56, 57, 
	314, 56, 57, 72, 56, 57, 72, 56, 
	57, 317, 56, 57, 72, 56, 57, 319, 
	325, 56, 57, 320, 56, 57, 321, 56, 
	57, 322, 56, 323, 57, 56, 324, 57, 
	56, 57, 73, 56, 57, 326, 56, 57, 
	327, 56, 57, 328, 56, 57, 329, 56, 
	57, 330, 56, 57, 331, 56, 57, 332, 
	343, 56, 57, 333, 56, 57, 334, 56, 
	57, 335, 56, 336, 57, 56, 337, 57, 
	56, 57, 338, 56, 57, 339, 56, 57, 
	340, 56, 57, 341, 56, 57, 342, 56, 
	57, 343, 56, 57, 324, 56, 57, 345, 
	56, 57, 314, 56, 0, 0
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
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 54, 0, 72, 33, 84, 72, 
	84, 84, 84, 84, 84, 84, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	15, 0, 54, 15, 0, 130, 31, 60, 
	57, 31, 63, 57, 63, 63, 63, 63, 
	63, 63, 63, 63, 66, 31, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 54, 0, 81, 84, 81, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 21, 0, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 144, 57, 54, 0, 
	54, 0, 69, 33, 69, 84, 84, 84, 
	84, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 13, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 13, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	0, 43, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 54, 0, 78, 33, 84, 78, 84, 
	84, 84, 84, 84, 84, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 19, 
	0, 54, 19, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 19, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 75, 33, 84, 
	75, 84, 84, 84, 84, 84, 84, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 17, 0, 54, 17, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 17, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 0, 0, 43, 54, 37, 
	37, 87, 37, 37, 43, 0, 39, 0, 
	43, 0, 0, 54, 0, 0, 39, 0, 
	0, 54, 0, 93, 90, 41, 96, 90, 
	96, 96, 96, 96, 96, 96, 96, 96, 
	99, 0, 43, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
	0, 54, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 54, 
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
	43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 346;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"

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
    
    
#line 900 "ext/gherkin_lexer_lt/gherkin_lexer_lt.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
    
#line 907 "ext/gherkin_lexer_lt/gherkin_lexer_lt.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
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
#line 1197 "ext/gherkin_lexer_lt/gherkin_lexer_lt.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"
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
#line 1260 "ext/gherkin_lexer_lt/gherkin_lexer_lt.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/lt.c.rl"

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

void Init_gherkin_lexer_lt()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Lt", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

