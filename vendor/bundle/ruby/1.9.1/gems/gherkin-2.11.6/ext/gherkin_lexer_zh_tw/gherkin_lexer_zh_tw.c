
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
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
	0, 0, 16, 19, 20, 21, 22, 23, 
	25, 27, 42, 46, 47, 49, 51, 52, 
	53, 54, 55, 57, 58, 59, 60, 62, 
	63, 64, 65, 66, 67, 68, 69, 70, 
	83, 86, 88, 90, 92, 94, 109, 110, 
	111, 113, 114, 115, 116, 117, 118, 119, 
	120, 121, 134, 137, 139, 141, 143, 145, 
	147, 149, 151, 153, 158, 160, 163, 166, 
	168, 170, 172, 174, 177, 179, 181, 183, 
	186, 188, 190, 192, 194, 196, 198, 200, 
	202, 204, 206, 208, 210, 212, 214, 216, 
	218, 220, 222, 224, 226, 228, 230, 232, 
	234, 236, 238, 240, 242, 244, 246, 248, 
	250, 252, 254, 256, 258, 260, 262, 264, 
	266, 267, 268, 269, 270, 271, 272, 273, 
	275, 277, 282, 287, 292, 297, 301, 305, 
	307, 308, 309, 310, 311, 312, 313, 314, 
	315, 316, 317, 318, 319, 320, 321, 322, 
	323, 328, 335, 340, 344, 350, 353, 355, 
	361, 376, 378, 380, 382, 384, 389, 391, 
	394, 397, 399, 401, 403, 405, 408, 410, 
	412, 414, 416, 418, 420, 422, 424, 426, 
	428, 430, 432, 434, 436, 438, 440, 442, 
	444, 446, 448, 450, 452, 454, 456, 458, 
	460, 462, 464, 466, 468, 470, 472, 474, 
	476, 478, 480, 482, 484, 485, 486, 499, 
	502, 504, 506, 508, 510, 512, 514, 516, 
	518, 523, 525, 528, 531, 533, 535, 537, 
	539, 542, 544, 546, 548, 551, 553, 555, 
	557, 559, 561, 563, 565, 567, 569, 571, 
	573, 575, 577, 579, 581, 583, 585, 587, 
	590, 592, 594, 596, 598, 600, 602, 604, 
	606, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 626, 628, 630, 632, 634, 636, 
	638, 640, 641, 642, 643, 644, 645, 646, 
	656, 658, 660, 662, 664, 666, 668, 671, 
	674, 676, 678, 680, 683, 685, 687, 689, 
	691, 693, 695, 697, 699, 701, 703, 705, 
	707, 709, 711, 713, 715, 717, 719, 721, 
	723, 725, 727, 729, 731, 733, 735, 737, 
	739, 741, 743, 745, 746, 747, 748, 749, 
	750, 751, 752, 753, 754, 755, 756, 757, 
	758, 759, 760, 761, 762, 763, 770, 772, 
	774, 776, 778, 780, 782, 783, 784
};

static const char _lexer_trans_keys[] = {
	-28, -27, -25, -24, -23, -17, 10, 32, 
	34, 35, 37, 42, 64, 124, 9, 13, 
	-72, -67, -66, -90, -28, -72, -108, 10, 
	13, 10, 13, -28, -27, -25, -24, -23, 
	10, 32, 34, 35, 37, 42, 64, 124, 
	9, 13, -127, -118, -112, -96, -121, -27, 
	-24, -90, -82, -126, -102, -88, -83, -121, 
	-97, -26, -100, -84, -27, 58, -92, -89, 
	-25, -74, -79, 58, 10, 10, -28, -27, 
	-25, -24, -23, 10, 32, 35, 37, 42, 
	64, 9, 13, -72, -67, 10, -90, 10, 
	-28, 10, -72, 10, -108, 10, -28, -27, 
	-25, -24, -23, 10, 32, 34, 35, 37, 
	42, 64, 124, 9, 13, -107, -74, -128, 
	-125, -116, -116, -26, -103, -81, 58, 10, 
	10, -28, -27, -25, -24, -23, 10, 32, 
	35, 37, 42, 64, 9, 13, -72, -67, 
	10, -90, 10, -28, 10, -72, 10, -108, 
	10, -122, 10, -26, 10, -104, 10, -81, 
	10, -127, -118, -112, -96, 10, -121, 10, 
	-27, -24, 10, -90, -82, 10, -126, 10, 
	-102, 10, -88, 10, -83, 10, -121, -97, 
	10, -26, 10, -100, 10, -84, 10, -27, 
	10, 58, -92, 10, -89, 10, -25, 10, 
	-74, 10, -79, 10, 10, 58, -24, 10, 
	-125, 10, -67, 10, -116, 10, -26, 10, 
	-103, 10, -76, 10, -26, 10, -103, 10, 
	-81, 10, -107, 10, -74, 10, -128, 10, 
	-116, 10, -126, 10, -93, 10, -23, 10, 
	-70, 10, -68, 10, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, -126, -93, -23, -70, -68, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 13, 32, 64, 9, 10, 
	9, 10, 13, 32, 64, 11, 12, 10, 
	32, 64, 9, 13, 32, 124, 9, 13, 
	10, 32, 92, 124, 9, 13, 10, 92, 
	124, 10, 92, 10, 32, 92, 124, 9, 
	13, -28, -27, -25, -24, -23, 10, 32, 
	34, 35, 37, 42, 64, 124, 9, 13, 
	-122, 10, -26, 10, -104, 10, -81, 10, 
	-127, -118, -112, -96, 10, -121, 10, -27, 
	-24, 10, -90, -82, 10, -126, 10, -102, 
	10, -88, 10, -83, 10, -121, -97, 10, 
	-26, 10, -100, 10, -84, 10, 10, 58, 
	-24, 10, -125, 10, -67, 10, -116, 10, 
	-26, 10, -103, 10, -76, 10, -26, 10, 
	-103, 10, -81, 10, -107, 10, -74, 10, 
	-128, 10, -116, 10, -126, 10, -93, 10, 
	-23, 10, -70, 10, -68, 10, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, 10, 10, -28, -27, 
	-25, -24, -23, 10, 32, 35, 37, 42, 
	64, 9, 13, -72, -67, 10, -90, 10, 
	-28, 10, -72, 10, -108, 10, -122, 10, 
	-26, 10, -104, 10, -81, 10, -127, -118, 
	-112, -96, 10, -121, 10, -27, -24, 10, 
	-90, -82, 10, -126, 10, -102, 10, -88, 
	10, -83, 10, -121, -97, 10, -26, 10, 
	-100, 10, -84, 10, -27, 10, 58, -92, 
	10, -89, 10, -25, 10, -74, 10, -79, 
	10, 10, 58, -24, 10, -125, 10, -67, 
	10, -116, 10, -26, 10, -103, 10, -76, 
	10, -26, 10, -103, 10, -81, 10, -107, 
	10, -74, 10, -128, -125, 10, -116, 10, 
	-116, 10, -26, 10, -103, 10, -81, 10, 
	-126, 10, -93, 10, -23, 10, -70, 10, 
	-68, 10, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	-24, -125, -67, 58, 10, 10, -28, -27, 
	-24, 10, 32, 35, 37, 64, 9, 13, 
	-66, 10, -117, 10, -27, 10, -83, 10, 
	-112, 10, 10, 58, -118, -96, 10, -121, 
	-97, 10, -26, 10, -100, 10, -84, 10, 
	-27, 10, 58, -92, 10, -89, 10, -25, 
	10, -74, 10, -79, 10, -24, 10, -125, 
	10, -67, 10, -76, 10, -26, 10, -103, 
	10, -81, 10, -125, 10, -116, 10, -26, 
	10, -103, 10, -81, 10, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, -116, -26, -103, -76, -26, -103, -81, 
	-122, -26, -104, -81, -117, -27, -83, -112, 
	58, 10, 10, -27, 10, 32, 35, 124, 
	9, 13, -118, 10, -97, 10, -24, 10, 
	-125, 10, -67, 10, 10, 58, -69, -65, 
	0
};

static const char _lexer_single_lengths[] = {
	0, 14, 3, 1, 1, 1, 1, 2, 
	2, 13, 4, 1, 2, 2, 1, 1, 
	1, 1, 2, 1, 1, 1, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 11, 
	3, 2, 2, 2, 2, 13, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 11, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 5, 2, 3, 3, 2, 
	2, 2, 2, 3, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	3, 5, 3, 2, 4, 3, 2, 4, 
	13, 2, 2, 2, 2, 5, 2, 3, 
	3, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 11, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	5, 2, 3, 3, 2, 2, 2, 2, 
	3, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 8, 
	2, 2, 2, 2, 2, 2, 3, 3, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 5, 2, 2, 
	2, 2, 2, 2, 1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
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
	0, 0, 0, 0, 0, 0, 1, 0, 
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
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 16, 20, 22, 24, 26, 28, 
	31, 34, 49, 54, 56, 59, 62, 64, 
	66, 68, 70, 73, 75, 77, 79, 82, 
	84, 86, 88, 90, 92, 94, 96, 98, 
	111, 115, 118, 121, 124, 127, 142, 144, 
	146, 149, 151, 153, 155, 157, 159, 161, 
	163, 165, 178, 182, 185, 188, 191, 194, 
	197, 200, 203, 206, 212, 215, 219, 223, 
	226, 229, 232, 235, 239, 242, 245, 248, 
	252, 255, 258, 261, 264, 267, 270, 273, 
	276, 279, 282, 285, 288, 291, 294, 297, 
	300, 303, 306, 309, 312, 315, 318, 321, 
	324, 327, 330, 333, 336, 339, 342, 345, 
	348, 351, 354, 357, 360, 363, 366, 369, 
	372, 374, 376, 378, 380, 382, 384, 386, 
	389, 392, 397, 402, 407, 412, 416, 420, 
	423, 425, 427, 429, 431, 433, 435, 437, 
	439, 441, 443, 445, 447, 449, 451, 453, 
	455, 460, 467, 472, 476, 482, 486, 489, 
	495, 510, 513, 516, 519, 522, 528, 531, 
	535, 539, 542, 545, 548, 551, 555, 558, 
	561, 564, 567, 570, 573, 576, 579, 582, 
	585, 588, 591, 594, 597, 600, 603, 606, 
	609, 612, 615, 618, 621, 624, 627, 630, 
	633, 636, 639, 642, 645, 648, 651, 654, 
	657, 660, 663, 666, 669, 671, 673, 686, 
	690, 693, 696, 699, 702, 705, 708, 711, 
	714, 720, 723, 727, 731, 734, 737, 740, 
	743, 747, 750, 753, 756, 760, 763, 766, 
	769, 772, 775, 778, 781, 784, 787, 790, 
	793, 796, 799, 802, 805, 808, 811, 814, 
	818, 821, 824, 827, 830, 833, 836, 839, 
	842, 845, 848, 851, 854, 857, 860, 863, 
	866, 869, 872, 875, 878, 881, 884, 887, 
	890, 893, 895, 897, 899, 901, 903, 905, 
	915, 918, 921, 924, 927, 930, 933, 937, 
	941, 944, 947, 950, 954, 957, 960, 963, 
	966, 969, 972, 975, 978, 981, 984, 987, 
	990, 993, 996, 999, 1002, 1005, 1008, 1011, 
	1014, 1017, 1020, 1023, 1026, 1029, 1032, 1035, 
	1038, 1041, 1044, 1047, 1049, 1051, 1053, 1055, 
	1057, 1059, 1061, 1063, 1065, 1067, 1069, 1071, 
	1073, 1075, 1077, 1079, 1081, 1083, 1090, 1093, 
	1096, 1099, 1102, 1105, 1108, 1110, 1112
};

static const short _lexer_trans_targs[] = {
	2, 10, 38, 40, 112, 348, 9, 9, 
	117, 127, 129, 143, 144, 147, 9, 0, 
	3, 330, 334, 0, 4, 0, 5, 0, 
	6, 0, 7, 0, 9, 128, 8, 9, 
	128, 8, 2, 10, 38, 40, 112, 9, 
	9, 117, 127, 129, 143, 144, 147, 9, 
	0, 11, 18, 323, 326, 0, 12, 0, 
	13, 16, 0, 14, 15, 0, 7, 0, 
	7, 0, 17, 0, 7, 0, 19, 273, 
	0, 20, 0, 21, 0, 22, 0, 23, 
	204, 0, 24, 0, 25, 0, 26, 0, 
	27, 0, 28, 0, 29, 0, 31, 30, 
	31, 30, 32, 157, 180, 182, 184, 31, 
	31, 9, 189, 203, 9, 31, 30, 33, 
	153, 31, 30, 34, 31, 30, 35, 31, 
	30, 36, 31, 30, 37, 31, 30, 2, 
	10, 38, 40, 112, 9, 9, 117, 127, 
	129, 143, 144, 147, 9, 0, 39, 0, 
	7, 0, 41, 42, 0, 4, 0, 43, 
	0, 44, 0, 45, 0, 46, 0, 47, 
	0, 49, 48, 49, 48, 50, 59, 88, 
	90, 92, 49, 49, 9, 97, 111, 9, 
	49, 48, 51, 55, 49, 48, 52, 49, 
	48, 53, 49, 48, 54, 49, 48, 37, 
	49, 48, 56, 49, 48, 57, 49, 48, 
	58, 49, 48, 37, 49, 48, 60, 67, 
	81, 84, 49, 48, 61, 49, 48, 62, 
	65, 49, 48, 63, 64, 49, 48, 37, 
	49, 48, 37, 49, 48, 66, 49, 48, 
	37, 49, 48, 68, 78, 49, 48, 69, 
	49, 48, 70, 49, 48, 71, 49, 48, 
	72, 49, 37, 48, 73, 49, 48, 74, 
	49, 48, 75, 49, 48, 76, 49, 48, 
	77, 49, 48, 49, 37, 48, 79, 49, 
	48, 80, 49, 48, 77, 49, 48, 82, 
	49, 48, 83, 49, 48, 63, 49, 48, 
	85, 49, 48, 86, 49, 48, 87, 49, 
	48, 71, 49, 48, 89, 49, 48, 37, 
	49, 48, 91, 49, 48, 52, 49, 48, 
	93, 49, 48, 94, 49, 48, 95, 49, 
	48, 96, 49, 48, 37, 49, 48, 49, 
	98, 48, 49, 99, 48, 49, 100, 48, 
	49, 101, 48, 49, 102, 48, 49, 103, 
	48, 49, 104, 48, 49, 105, 48, 49, 
	106, 48, 49, 107, 48, 49, 108, 48, 
	49, 109, 48, 49, 110, 48, 49, 9, 
	48, 49, 37, 48, 113, 0, 114, 0, 
	115, 0, 116, 0, 7, 0, 118, 0, 
	119, 0, 121, 120, 120, 121, 120, 120, 
	122, 122, 123, 122, 122, 122, 122, 123, 
	122, 122, 122, 122, 124, 122, 122, 122, 
	122, 125, 122, 122, 9, 126, 126, 0, 
	9, 126, 126, 0, 9, 128, 127, 9, 
	0, 130, 0, 131, 0, 132, 0, 133, 
	0, 134, 0, 135, 0, 136, 0, 137, 
	0, 138, 0, 139, 0, 140, 0, 141, 
	0, 142, 0, 350, 0, 7, 0, 0, 
	0, 0, 0, 145, 146, 9, 146, 146, 
	144, 145, 145, 9, 146, 144, 146, 0, 
	147, 148, 147, 0, 152, 151, 150, 148, 
	151, 149, 0, 150, 148, 149, 0, 150, 
	149, 152, 151, 150, 148, 151, 149, 2, 
	10, 38, 40, 112, 152, 152, 117, 127, 
	129, 143, 144, 147, 152, 0, 154, 31, 
	30, 155, 31, 30, 156, 31, 30, 37, 
	31, 30, 158, 165, 173, 176, 31, 30, 
	159, 31, 30, 160, 163, 31, 30, 161, 
	162, 31, 30, 37, 31, 30, 37, 31, 
	30, 164, 31, 30, 37, 31, 30, 166, 
	170, 31, 30, 167, 31, 30, 168, 31, 
	30, 169, 31, 30, 31, 37, 30, 171, 
	31, 30, 172, 31, 30, 169, 31, 30, 
	174, 31, 30, 175, 31, 30, 161, 31, 
	30, 177, 31, 30, 178, 31, 30, 179, 
	31, 30, 169, 31, 30, 181, 31, 30, 
	37, 31, 30, 183, 31, 30, 34, 31, 
	30, 185, 31, 30, 186, 31, 30, 187, 
	31, 30, 188, 31, 30, 37, 31, 30, 
	31, 190, 30, 31, 191, 30, 31, 192, 
	30, 31, 193, 30, 31, 194, 30, 31, 
	195, 30, 31, 196, 30, 31, 197, 30, 
	31, 198, 30, 31, 199, 30, 31, 200, 
	30, 31, 201, 30, 31, 202, 30, 31, 
	9, 30, 31, 37, 30, 206, 205, 206, 
	205, 207, 216, 245, 247, 253, 206, 206, 
	9, 258, 272, 9, 206, 205, 208, 212, 
	206, 205, 209, 206, 205, 210, 206, 205, 
	211, 206, 205, 37, 206, 205, 213, 206, 
	205, 214, 206, 205, 215, 206, 205, 37, 
	206, 205, 217, 224, 238, 241, 206, 205, 
	218, 206, 205, 219, 222, 206, 205, 220, 
	221, 206, 205, 37, 206, 205, 37, 206, 
	205, 223, 206, 205, 37, 206, 205, 225, 
	235, 206, 205, 226, 206, 205, 227, 206, 
	205, 228, 206, 205, 229, 206, 37, 205, 
	230, 206, 205, 231, 206, 205, 232, 206, 
	205, 233, 206, 205, 234, 206, 205, 206, 
	37, 205, 236, 206, 205, 237, 206, 205, 
	234, 206, 205, 239, 206, 205, 240, 206, 
	205, 220, 206, 205, 242, 206, 205, 243, 
	206, 205, 244, 206, 205, 228, 206, 205, 
	246, 206, 205, 37, 206, 205, 248, 249, 
	206, 205, 209, 206, 205, 250, 206, 205, 
	251, 206, 205, 252, 206, 205, 234, 206, 
	205, 254, 206, 205, 255, 206, 205, 256, 
	206, 205, 257, 206, 205, 37, 206, 205, 
	206, 259, 205, 206, 260, 205, 206, 261, 
	205, 206, 262, 205, 206, 263, 205, 206, 
	264, 205, 206, 265, 205, 206, 266, 205, 
	206, 267, 205, 206, 268, 205, 206, 269, 
	205, 206, 270, 205, 206, 271, 205, 206, 
	9, 205, 206, 37, 205, 274, 0, 275, 
	0, 276, 0, 277, 0, 279, 278, 279, 
	278, 280, 286, 304, 279, 279, 9, 309, 
	9, 279, 278, 281, 279, 278, 282, 279, 
	278, 283, 279, 278, 284, 279, 278, 285, 
	279, 278, 279, 37, 278, 287, 300, 279, 
	278, 288, 297, 279, 278, 289, 279, 278, 
	290, 279, 278, 291, 279, 278, 292, 279, 
	37, 278, 293, 279, 278, 294, 279, 278, 
	295, 279, 278, 296, 279, 278, 285, 279, 
	278, 298, 279, 278, 299, 279, 278, 285, 
	279, 278, 301, 279, 278, 302, 279, 278, 
	303, 279, 278, 291, 279, 278, 305, 279, 
	278, 306, 279, 278, 307, 279, 278, 308, 
	279, 278, 285, 279, 278, 279, 310, 278, 
	279, 311, 278, 279, 312, 278, 279, 313, 
	278, 279, 314, 278, 279, 315, 278, 279, 
	316, 278, 279, 317, 278, 279, 318, 278, 
	279, 319, 278, 279, 320, 278, 279, 321, 
	278, 279, 322, 278, 279, 9, 278, 324, 
	0, 325, 0, 14, 0, 327, 0, 328, 
	0, 329, 0, 22, 0, 331, 0, 332, 
	0, 333, 0, 7, 0, 335, 0, 336, 
	0, 337, 0, 338, 0, 339, 0, 341, 
	340, 341, 340, 342, 341, 341, 9, 9, 
	341, 340, 343, 341, 340, 344, 341, 340, 
	345, 341, 340, 346, 341, 340, 347, 341, 
	340, 341, 37, 340, 349, 0, 9, 0, 
	0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	29, 29, 29, 29, 29, 0, 54, 0, 
	5, 1, 0, 29, 1, 35, 0, 43, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 149, 126, 57, 110, 
	23, 0, 29, 29, 29, 29, 29, 54, 
	0, 5, 1, 0, 29, 1, 35, 0, 
	43, 0, 0, 0, 0, 43, 0, 43, 
	0, 0, 43, 0, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 84, 84, 84, 84, 84, 54, 
	0, 78, 33, 84, 78, 0, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 19, 54, 0, 63, 
	63, 63, 63, 63, 130, 31, 60, 57, 
	31, 63, 57, 66, 31, 43, 0, 43, 
	0, 43, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 144, 57, 54, 0, 84, 84, 84, 
	84, 84, 54, 0, 72, 33, 84, 72, 
	0, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 15, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 15, 54, 0, 0, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 0, 54, 0, 15, 
	54, 0, 15, 54, 0, 0, 54, 0, 
	15, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 15, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 54, 15, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 15, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 15, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 15, 
	0, 54, 15, 0, 0, 43, 0, 43, 
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
	96, 96, 96, 96, 54, 0, 93, 90, 
	41, 96, 90, 99, 0, 43, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 19, 
	54, 0, 0, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	0, 54, 0, 19, 54, 0, 19, 54, 
	0, 0, 54, 0, 19, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 54, 19, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	19, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 19, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	19, 0, 54, 19, 0, 144, 57, 54, 
	0, 84, 84, 84, 84, 84, 54, 0, 
	75, 33, 84, 75, 0, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 17, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 17, 
	54, 0, 0, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	0, 54, 0, 17, 54, 0, 17, 54, 
	0, 0, 54, 0, 17, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 17, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	17, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 17, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 17, 54, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	17, 0, 54, 17, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 84, 84, 84, 54, 0, 69, 33, 
	69, 0, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 54, 13, 0, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	13, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 13, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 84, 54, 0, 81, 81, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 54, 21, 0, 0, 43, 0, 43, 
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
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 350;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"

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
    
    
#line 911 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
    
#line 918 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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
#line 1208 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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
#line 1271 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"

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

void Init_gherkin_lexer_zh_tw()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Zh_tw", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

