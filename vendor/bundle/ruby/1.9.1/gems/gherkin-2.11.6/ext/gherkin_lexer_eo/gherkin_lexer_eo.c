
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_eo/gherkin_lexer_eo.c"
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
	0, 0, 17, 18, 19, 35, 36, 37, 
	39, 41, 46, 51, 56, 61, 65, 69, 
	71, 72, 73, 74, 75, 76, 77, 78, 
	79, 80, 81, 82, 83, 84, 85, 86, 
	87, 89, 91, 96, 103, 108, 109, 111, 
	112, 113, 114, 115, 116, 117, 118, 119, 
	120, 121, 122, 123, 124, 125, 126, 127, 
	128, 135, 137, 139, 141, 143, 145, 147, 
	163, 164, 165, 166, 167, 168, 169, 181, 
	183, 185, 187, 189, 191, 193, 195, 197, 
	199, 201, 203, 205, 207, 209, 211, 213, 
	216, 218, 220, 222, 224, 226, 228, 231, 
	233, 235, 237, 239, 241, 243, 245, 247, 
	249, 251, 253, 255, 257, 259, 261, 263, 
	265, 267, 269, 271, 273, 276, 279, 281, 
	283, 285, 287, 289, 290, 291, 292, 293, 
	294, 295, 296, 297, 298, 299, 300, 301, 
	302, 303, 304, 305, 306, 307, 308, 309, 
	310, 311, 312, 324, 326, 328, 330, 332, 
	334, 336, 338, 340, 342, 344, 346, 348, 
	350, 352, 354, 356, 359, 361, 363, 365, 
	367, 369, 371, 373, 375, 378, 380, 382, 
	384, 386, 388, 390, 393, 395, 397, 399, 
	401, 403, 404, 405, 406, 407, 408, 409, 
	410, 411, 424, 426, 428, 430, 432, 434, 
	436, 438, 440, 442, 444, 446, 448, 450, 
	452, 454, 456, 459, 461, 463, 465, 467, 
	469, 471, 473, 475, 477, 479, 482, 484, 
	486, 488, 490, 492, 494, 496, 498, 500, 
	502, 504, 506, 508, 510, 512, 514, 516, 
	518, 520, 523, 526, 528, 530, 532, 534, 
	536, 537, 538, 539, 540, 541, 542, 543, 
	544, 556, 558, 560, 562, 564, 566, 568, 
	570, 572, 574, 576, 578, 580, 582, 584, 
	586, 588, 590, 592, 594, 596, 598, 600, 
	602, 604, 606, 608, 610, 612, 614, 616, 
	618, 620, 622, 624, 626, 628, 630, 632, 
	634, 636, 638, 640, 642, 644, 646, 648, 
	650, 652, 654, 658, 664, 667, 669, 675, 
	691
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	68, 69, 70, 75, 83, 84, 124, 9, 
	13, -69, -65, 10, 32, 34, 35, 37, 
	42, 64, 68, 69, 70, 75, 83, 84, 
	124, 9, 13, 34, 34, 10, 13, 10, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 9, 
	13, 10, 32, 9, 13, 10, 13, 10, 
	95, 70, 69, 65, 84, 85, 82, 69, 
	95, 69, 78, 68, 95, 37, 32, 10, 
	13, 10, 13, 13, 32, 64, 9, 10, 
	9, 10, 13, 32, 64, 11, 12, 10, 
	32, 64, 9, 13, 111, 32, 110, 105, 
	116, 97, -60, -75, 111, 107, 122, 101, 
	109, 112, 108, 111, 106, 58, 10, 10, 
	10, 32, 35, 84, 124, 9, 13, 10, 
	114, 10, 97, 10, 106, 10, 116, 10, 
	111, 10, 58, 10, 32, 34, 35, 37, 
	42, 64, 68, 69, 70, 75, 83, 84, 
	124, 9, 13, 111, 110, 111, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 68, 
	75, 83, 84, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 111, 10, 32, 110, 
	10, 105, 10, 116, 10, 97, -60, 10, 
	-75, 10, 10, 111, 10, 97, 111, 10, 
	106, 10, 110, 10, 116, 10, 117, 10, 
	114, 10, 111, 10, 32, 10, 100, 10, 
	101, 10, 32, 10, 108, 10, 97, 10, 
	32, 10, 115, 10, 99, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 111, 10, 
	58, 10, 99, 101, 10, 32, 100, 10, 
	114, 10, 97, 10, 106, 10, 116, 97, 
	111, 106, 110, 116, 117, 114, 111, 32, 
	100, 101, 32, 108, 97, 32, 115, 99, 
	101, 110, 97, 114, 111, 58, 10, 10, 
	10, 32, 35, 37, 42, 64, 68, 75, 
	83, 84, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 111, 10, 32, 110, 10, 
	105, 10, 116, 10, 97, -60, 10, -75, 
	10, 10, 111, 10, 97, 10, 106, 10, 
	99, 101, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 111, 10, 58, 10, 32, 
	100, 10, 114, 10, 97, 10, 106, 10, 
	116, 99, 101, 101, 110, 97, 114, 111, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 68, 70, 75, 83, 84, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 111, 
	10, 32, 110, 10, 105, 10, 116, 10, 
	97, -60, 10, -75, 10, 10, 111, 10, 
	111, 10, 110, 10, 111, 10, 58, 10, 
	97, 111, 10, 106, 10, 110, 10, 116, 
	10, 117, 10, 114, 10, 111, 10, 32, 
	10, 100, 10, 101, 10, 32, 10, 108, 
	10, 97, 10, 32, 10, 115, 10, 99, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 99, 101, 10, 32, 100, 10, 114, 
	10, 97, 10, 106, 10, 116, 32, 100, 
	114, 97, 106, 116, 111, 58, 10, 10, 
	10, 32, 35, 37, 64, 69, 70, 75, 
	83, 84, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 107, 10, 122, 10, 101, 10, 109, 
	10, 112, 10, 108, 10, 111, 10, 106, 
	10, 58, 10, 111, 10, 110, 10, 111, 
	10, 111, 10, 110, 10, 116, 10, 117, 
	10, 114, 10, 111, 10, 32, 10, 100, 
	10, 101, 10, 32, 10, 108, 10, 97, 
	10, 32, 10, 115, 10, 99, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 114, 
	10, 97, 10, 106, 10, 116, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, 10, 32, 34, 35, 37, 
	42, 64, 68, 69, 70, 75, 83, 84, 
	124, 9, 13, 0
};

static const char _lexer_single_lengths[] = {
	0, 15, 1, 1, 14, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	5, 2, 2, 2, 2, 2, 2, 14, 
	1, 1, 1, 1, 1, 1, 10, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 3, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 10, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 11, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 3, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	10, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 4, 3, 2, 4, 14, 
	0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 1, 
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
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 0, 0, 1, 1, 
	0
};

static const short _lexer_index_offsets[] = {
	0, 0, 17, 19, 21, 37, 39, 41, 
	44, 47, 52, 57, 62, 67, 71, 75, 
	78, 80, 82, 84, 86, 88, 90, 92, 
	94, 96, 98, 100, 102, 104, 106, 108, 
	110, 113, 116, 121, 128, 133, 135, 138, 
	140, 142, 144, 146, 148, 150, 152, 154, 
	156, 158, 160, 162, 164, 166, 168, 170, 
	172, 179, 182, 185, 188, 191, 194, 197, 
	213, 215, 217, 219, 221, 223, 225, 237, 
	240, 243, 246, 249, 252, 255, 258, 261, 
	264, 267, 270, 273, 276, 279, 282, 285, 
	289, 292, 295, 298, 301, 304, 307, 311, 
	314, 317, 320, 323, 326, 329, 332, 335, 
	338, 341, 344, 347, 350, 353, 356, 359, 
	362, 365, 368, 371, 374, 378, 382, 385, 
	388, 391, 394, 397, 399, 401, 403, 405, 
	407, 409, 411, 413, 415, 417, 419, 421, 
	423, 425, 427, 429, 431, 433, 435, 437, 
	439, 441, 443, 455, 458, 461, 464, 467, 
	470, 473, 476, 479, 482, 485, 488, 491, 
	494, 497, 500, 503, 507, 510, 513, 516, 
	519, 522, 525, 528, 531, 535, 538, 541, 
	544, 547, 550, 553, 557, 560, 563, 566, 
	569, 572, 574, 576, 578, 580, 582, 584, 
	586, 588, 601, 604, 607, 610, 613, 616, 
	619, 622, 625, 628, 631, 634, 637, 640, 
	643, 646, 649, 653, 656, 659, 662, 665, 
	668, 671, 674, 677, 680, 683, 687, 690, 
	693, 696, 699, 702, 705, 708, 711, 714, 
	717, 720, 723, 726, 729, 732, 735, 738, 
	741, 744, 748, 752, 755, 758, 761, 764, 
	767, 769, 771, 773, 775, 777, 779, 781, 
	783, 795, 798, 801, 804, 807, 810, 813, 
	816, 819, 822, 825, 828, 831, 834, 837, 
	840, 843, 846, 849, 852, 855, 858, 861, 
	864, 867, 870, 873, 876, 879, 882, 885, 
	888, 891, 894, 897, 900, 903, 906, 909, 
	912, 915, 918, 921, 924, 927, 930, 933, 
	936, 939, 942, 946, 952, 956, 959, 965, 
	981
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 45, 64, 122, 184, 248, 306, 4, 
	0, 3, 0, 4, 0, 4, 4, 5, 
	15, 17, 31, 34, 37, 45, 64, 122, 
	184, 248, 306, 4, 0, 6, 0, 7, 
	0, 9, 8, 8, 9, 8, 8, 10, 
	10, 11, 10, 10, 10, 10, 11, 10, 
	10, 10, 10, 12, 10, 10, 10, 10, 
	13, 10, 10, 4, 14, 14, 0, 4, 
	14, 14, 0, 4, 16, 15, 4, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 23, 0, 24, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	30, 0, 312, 0, 32, 0, 4, 16, 
	33, 4, 16, 33, 0, 0, 0, 0, 
	35, 36, 4, 36, 36, 34, 35, 35, 
	4, 36, 34, 36, 0, 38, 0, 32, 
	39, 0, 40, 0, 41, 0, 42, 0, 
	43, 0, 44, 0, 31, 0, 46, 0, 
	47, 0, 48, 0, 49, 0, 50, 0, 
	51, 0, 52, 0, 53, 0, 54, 0, 
	56, 55, 56, 55, 56, 56, 4, 57, 
	4, 56, 55, 56, 58, 55, 56, 59, 
	55, 56, 60, 55, 56, 61, 55, 56, 
	62, 55, 56, 63, 55, 4, 4, 5, 
	15, 17, 31, 34, 37, 45, 64, 122, 
	184, 248, 306, 4, 0, 65, 0, 66, 
	0, 67, 0, 68, 0, 70, 69, 70, 
	69, 70, 70, 4, 71, 85, 4, 86, 
	94, 116, 118, 70, 69, 70, 72, 69, 
	70, 73, 69, 70, 74, 69, 70, 75, 
	69, 70, 76, 69, 70, 77, 69, 70, 
	78, 69, 70, 79, 69, 70, 80, 69, 
	70, 81, 69, 70, 82, 69, 70, 83, 
	69, 70, 84, 69, 70, 4, 69, 70, 
	63, 69, 70, 87, 69, 70, 63, 88, 
	69, 70, 89, 69, 70, 90, 69, 70, 
	91, 69, 92, 70, 69, 93, 70, 69, 
	70, 85, 69, 70, 95, 96, 69, 70, 
	85, 69, 70, 97, 69, 70, 98, 69, 
	70, 99, 69, 70, 100, 69, 70, 101, 
	69, 70, 102, 69, 70, 103, 69, 70, 
	104, 69, 70, 105, 69, 70, 106, 69, 
	70, 107, 69, 70, 108, 69, 70, 109, 
	69, 70, 110, 69, 70, 111, 69, 70, 
	112, 69, 70, 113, 69, 70, 114, 69, 
	70, 115, 69, 70, 63, 69, 70, 110, 
	117, 69, 70, 63, 85, 69, 70, 119, 
	69, 70, 120, 69, 70, 121, 69, 70, 
	114, 69, 123, 124, 0, 31, 0, 125, 
	0, 126, 0, 127, 0, 128, 0, 129, 
	0, 130, 0, 131, 0, 132, 0, 133, 
	0, 134, 0, 135, 0, 136, 0, 137, 
	0, 138, 0, 139, 0, 140, 0, 141, 
	0, 142, 0, 143, 0, 144, 0, 146, 
	145, 146, 145, 146, 146, 4, 147, 161, 
	4, 162, 170, 172, 180, 146, 145, 146, 
	148, 145, 146, 149, 145, 146, 150, 145, 
	146, 151, 145, 146, 152, 145, 146, 153, 
	145, 146, 154, 145, 146, 155, 145, 146, 
	156, 145, 146, 157, 145, 146, 158, 145, 
	146, 159, 145, 146, 160, 145, 146, 4, 
	145, 146, 63, 145, 146, 163, 145, 146, 
	63, 164, 145, 146, 165, 145, 146, 166, 
	145, 146, 167, 145, 168, 146, 145, 169, 
	146, 145, 146, 161, 145, 146, 171, 145, 
	146, 161, 145, 146, 173, 179, 145, 146, 
	174, 145, 146, 175, 145, 146, 176, 145, 
	146, 177, 145, 146, 178, 145, 146, 63, 
	145, 146, 63, 161, 145, 146, 181, 145, 
	146, 182, 145, 146, 183, 145, 146, 177, 
	145, 185, 247, 0, 186, 0, 187, 0, 
	188, 0, 189, 0, 190, 0, 191, 0, 
	193, 192, 193, 192, 193, 193, 4, 194, 
	208, 4, 209, 217, 221, 241, 243, 193, 
	192, 193, 195, 192, 193, 196, 192, 193, 
	197, 192, 193, 198, 192, 193, 199, 192, 
	193, 200, 192, 193, 201, 192, 193, 202, 
	192, 193, 203, 192, 193, 204, 192, 193, 
	205, 192, 193, 206, 192, 193, 207, 192, 
	193, 4, 192, 193, 63, 192, 193, 210, 
	192, 193, 63, 211, 192, 193, 212, 192, 
	193, 213, 192, 193, 214, 192, 215, 193, 
	192, 216, 193, 192, 193, 208, 192, 193, 
	218, 192, 193, 219, 192, 193, 220, 192, 
	193, 63, 192, 193, 222, 223, 192, 193, 
	208, 192, 193, 224, 192, 193, 225, 192, 
	193, 226, 192, 193, 227, 192, 193, 228, 
	192, 193, 229, 192, 193, 230, 192, 193, 
	231, 192, 193, 232, 192, 193, 233, 192, 
	193, 234, 192, 193, 235, 192, 193, 236, 
	192, 193, 237, 192, 193, 238, 192, 193, 
	239, 192, 193, 240, 192, 193, 219, 192, 
	193, 237, 242, 192, 193, 63, 208, 192, 
	193, 244, 192, 193, 245, 192, 193, 246, 
	192, 193, 219, 192, 32, 31, 0, 249, 
	0, 250, 0, 251, 0, 252, 0, 253, 
	0, 254, 0, 256, 255, 256, 255, 256, 
	256, 4, 257, 4, 271, 280, 283, 297, 
	302, 256, 255, 256, 258, 255, 256, 259, 
	255, 256, 260, 255, 256, 261, 255, 256, 
	262, 255, 256, 263, 255, 256, 264, 255, 
	256, 265, 255, 256, 266, 255, 256, 267, 
	255, 256, 268, 255, 256, 269, 255, 256, 
	270, 255, 256, 4, 255, 256, 272, 255, 
	256, 273, 255, 256, 274, 255, 256, 275, 
	255, 256, 276, 255, 256, 277, 255, 256, 
	278, 255, 256, 279, 255, 256, 63, 255, 
	256, 281, 255, 256, 282, 255, 256, 279, 
	255, 256, 284, 255, 256, 285, 255, 256, 
	286, 255, 256, 287, 255, 256, 288, 255, 
	256, 289, 255, 256, 290, 255, 256, 291, 
	255, 256, 292, 255, 256, 293, 255, 256, 
	294, 255, 256, 295, 255, 256, 296, 255, 
	256, 297, 255, 256, 298, 255, 256, 299, 
	255, 256, 300, 255, 256, 301, 255, 256, 
	282, 255, 256, 303, 255, 256, 304, 255, 
	256, 305, 255, 256, 282, 255, 306, 307, 
	306, 0, 311, 310, 309, 307, 310, 308, 
	0, 309, 307, 308, 0, 309, 308, 311, 
	310, 309, 307, 310, 308, 311, 311, 5, 
	15, 17, 31, 34, 37, 45, 64, 122, 
	184, 248, 306, 311, 0, 0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	0, 54, 0, 5, 1, 0, 29, 1, 
	29, 29, 29, 29, 29, 29, 35, 0, 
	43, 0, 43, 0, 43, 54, 0, 5, 
	1, 0, 29, 1, 29, 29, 29, 29, 
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
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 81, 84, 
	81, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 21, 0, 130, 31, 60, 
	57, 31, 63, 57, 63, 63, 63, 63, 
	63, 63, 66, 31, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 54, 0, 72, 33, 84, 72, 84, 
	84, 84, 84, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 15, 0, 54, 
	15, 0, 54, 0, 0, 54, 15, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 15, 0, 54, 0, 
	0, 0, 54, 15, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 0, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 78, 33, 84, 
	78, 84, 84, 84, 84, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 19, 
	0, 54, 19, 0, 54, 0, 0, 54, 
	19, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 19, 
	0, 54, 19, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	144, 57, 54, 0, 54, 0, 75, 33, 
	84, 75, 84, 84, 84, 84, 84, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 17, 0, 54, 17, 0, 54, 0, 
	0, 54, 17, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 17, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 17, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 69, 33, 69, 84, 84, 84, 84, 
	84, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 13, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 0, 
	0, 43, 54, 37, 37, 87, 37, 37, 
	43, 0, 39, 0, 43, 0, 0, 54, 
	0, 0, 39, 0, 0, 54, 0, 93, 
	90, 41, 96, 90, 96, 96, 96, 96, 
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
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43
};

static const int lexer_start = 1;
static const int lexer_first_final = 312;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"

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
    
    
#line 845 "ext/gherkin_lexer_eo/gherkin_lexer_eo.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
    
#line 852 "ext/gherkin_lexer_eo/gherkin_lexer_eo.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
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
#line 1142 "ext/gherkin_lexer_eo/gherkin_lexer_eo.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"
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
#line 1205 "ext/gherkin_lexer_eo/gherkin_lexer_eo.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/eo.c.rl"

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

void Init_gherkin_lexer_eo()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Eo", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

