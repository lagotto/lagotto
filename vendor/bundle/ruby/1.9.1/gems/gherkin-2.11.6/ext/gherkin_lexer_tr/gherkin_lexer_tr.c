
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
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
	0, 0, 20, 21, 23, 24, 25, 26, 
	27, 28, 29, 30, 31, 32, 39, 41, 
	43, 45, 47, 49, 51, 53, 55, 74, 
	93, 94, 95, 97, 99, 104, 109, 114, 
	119, 123, 127, 129, 130, 131, 132, 133, 
	134, 135, 136, 137, 138, 139, 140, 141, 
	142, 143, 144, 145, 147, 149, 154, 161, 
	166, 167, 168, 169, 170, 171, 172, 173, 
	174, 175, 176, 177, 178, 179, 180, 181, 
	182, 183, 184, 185, 186, 187, 188, 189, 
	190, 191, 192, 193, 194, 195, 211, 213, 
	215, 217, 219, 221, 223, 225, 227, 229, 
	231, 233, 235, 237, 239, 241, 243, 245, 
	247, 249, 251, 253, 255, 257, 259, 261, 
	263, 265, 267, 269, 271, 273, 275, 277, 
	279, 281, 283, 285, 287, 289, 291, 293, 
	295, 297, 299, 301, 303, 305, 307, 309, 
	311, 313, 315, 317, 319, 322, 324, 326, 
	328, 330, 332, 334, 336, 338, 340, 342, 
	343, 344, 345, 346, 347, 348, 349, 350, 
	351, 352, 353, 354, 356, 357, 358, 359, 
	360, 361, 362, 363, 364, 365, 366, 367, 
	368, 384, 386, 388, 390, 392, 394, 396, 
	398, 400, 402, 404, 406, 408, 410, 412, 
	414, 416, 418, 420, 422, 424, 426, 428, 
	430, 432, 434, 436, 438, 440, 442, 444, 
	446, 448, 450, 452, 454, 456, 458, 460, 
	462, 464, 466, 468, 470, 472, 474, 476, 
	478, 480, 482, 484, 486, 488, 490, 492, 
	494, 495, 496, 513, 515, 517, 519, 521, 
	523, 525, 527, 529, 531, 533, 535, 537, 
	539, 541, 543, 545, 547, 549, 551, 553, 
	555, 557, 559, 561, 563, 565, 567, 569, 
	571, 573, 575, 577, 579, 581, 583, 585, 
	587, 589, 591, 593, 595, 597, 599, 601, 
	603, 605, 607, 609, 611, 613, 615, 617, 
	619, 621, 623, 625, 627, 629, 631, 633, 
	635, 638, 640, 642, 644, 646, 648, 650, 
	652, 654, 656, 658, 659, 663, 669, 672, 
	674, 680, 699, 700, 701, 702, 703, 704, 
	705, 706, 707, 717, 719, 722, 724, 726, 
	728, 730, 732, 734, 736, 738, 740, 742, 
	744, 746, 748, 750, 752, 754, 756, 758, 
	760, 762, 764, 766, 768, 770, 772, 774, 
	776, 778, 780, 782, 784, 786, 788, 790, 
	792, 794, 796, 798, 800, 803, 805, 807, 
	809, 811, 813, 815, 817, 819, 821, 822, 
	823
};

static const char _lexer_trans_keys[] = {
	-61, -17, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 69, 70, 71, 79, 83, 
	86, 124, 9, 13, -106, 114, 122, 110, 
	101, 107, 108, 101, 114, 58, 10, 10, 
	-61, 10, 32, 35, 124, 9, 13, -106, 
	10, 10, 122, 10, 101, 10, 108, 10, 
	108, 10, 105, 10, 107, 10, 58, -61, 
	10, 32, 34, 35, 37, 42, 64, 65, 
	68, 69, 70, 71, 79, 83, 86, 124, 
	9, 13, -61, 10, 32, 34, 35, 37, 
	42, 64, 65, 68, 69, 70, 71, 79, 
	83, 86, 124, 9, 13, 34, 34, 10, 
	13, 10, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 9, 13, 10, 32, 9, 13, 10, 
	13, 10, 95, 70, 69, 65, 84, 85, 
	82, 69, 95, 69, 78, 68, 95, 37, 
	32, 10, 13, 10, 13, 13, 32, 64, 
	9, 10, 9, 10, 13, 32, 64, 11, 
	12, 10, 32, 64, 9, 13, 109, 97, 
	105, 121, 101, 108, 105, 109, 32, 107, 
	105, -60, -97, 101, 114, 97, 107, 97, 
	116, 101, -61, -89, 109, 105, -59, -97, 
	58, 10, 10, -61, 10, 32, 35, 37, 
	42, 64, 65, 68, 69, 70, 79, 83, 
	86, 9, 13, -106, 10, 10, 122, 10, 
	101, 10, 108, 10, 108, 10, 105, 10, 
	107, 10, 58, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 109, 10, 97, 10, 105, 10, 
	121, 10, 101, 10, 108, 10, 105, 10, 
	109, 10, 32, 10, 107, 10, 105, -60, 
	10, -97, 10, 10, 101, 10, 114, 10, 
	97, 10, 107, 10, 97, 10, 116, 10, 
	32, 10, 122, 10, 97, 10, 109, 10, 
	97, 10, 110, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 121, 10, 111, 10, 
	32, 58, 10, 116, 10, 97, 10, 115, 
	10, 108, 10, 97, -60, 10, -97, 10, 
	-60, 10, -79, 10, 10, 101, 32, 122, 
	97, 109, 97, 110, 101, 110, 97, 114, 
	121, 111, 32, 58, 116, 97, 115, 108, 
	97, -60, -97, -60, -79, 58, 10, 10, 
	-61, 10, 32, 35, 37, 42, 64, 65, 
	68, 69, 70, 79, 83, 86, 9, 13, 
	-106, 10, 10, 122, 10, 101, 10, 108, 
	10, 108, 10, 105, 10, 107, 10, 58, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 109, 
	10, 97, 10, 105, 10, 121, 10, 101, 
	10, 108, 10, 105, 10, 109, 10, 32, 
	10, 107, 10, 105, -60, 10, -97, 10, 
	10, 101, 10, 114, 10, 97, 10, 107, 
	10, 97, 10, 116, 10, 32, 10, 122, 
	10, 97, 10, 109, 10, 97, 10, 110, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 121, 10, 111, 10, 101, 10, 10, 
	-61, 10, 32, 35, 37, 42, 64, 65, 
	68, 69, 70, 71, 79, 83, 86, 9, 
	13, -106, 10, 10, 122, 10, 101, 10, 
	108, 10, 108, 10, 105, 10, 107, 10, 
	58, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	109, 10, 97, 10, 105, 10, 121, 10, 
	101, 10, 108, 10, 105, 10, 109, 10, 
	32, 10, 107, 10, 105, -60, 10, -97, 
	10, 10, 101, 10, 114, 10, 97, 10, 
	107, 10, 97, 10, 116, 10, 101, -61, 
	10, -89, 10, 10, 109, 10, 105, -59, 
	10, -97, 10, 10, 32, 10, 122, 10, 
	97, 10, 109, 10, 97, 10, 110, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	121, 10, 111, 10, 32, 58, 10, 116, 
	10, 97, 10, 115, 10, 108, 10, 97, 
	-60, 10, -97, 10, -60, 10, -79, 10, 
	10, 101, 101, 32, 124, 9, 13, 10, 
	32, 92, 124, 9, 13, 10, 92, 124, 
	10, 92, 10, 32, 92, 124, 9, 13, 
	-61, 10, 32, 34, 35, 37, 42, 64, 
	65, 68, 69, 70, 71, 79, 83, 86, 
	124, 9, 13, 101, 108, 108, 105, 107, 
	58, 10, 10, -61, 10, 32, 35, 37, 
	64, 71, 83, 9, 13, -106, 10, 10, 
	114, 122, 10, 110, 10, 101, 10, 107, 
	10, 108, 10, 101, 10, 114, 10, 58, 
	10, 101, 10, 108, 10, 108, 10, 105, 
	10, 107, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 101, 
	-61, 10, -89, 10, 10, 109, 10, 105, 
	-59, 10, -97, 10, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 121, 10, 111, 
	10, 32, 58, 10, 116, 10, 97, 10, 
	115, 10, 108, 10, 97, -60, 10, -97, 
	10, -60, 10, -79, 10, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 18, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 5, 2, 2, 
	2, 2, 2, 2, 2, 2, 17, 17, 
	1, 1, 2, 2, 3, 3, 3, 3, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 2, 2, 3, 5, 3, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 14, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	14, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 15, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 2, 4, 3, 2, 
	4, 17, 1, 1, 1, 1, 1, 1, 
	1, 1, 8, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 0, 0, 1, 1, 1, 1, 
	1, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 1, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 1, 1, 0, 0, 
	1, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0
};

static const short _lexer_index_offsets[] = {
	0, 0, 20, 22, 25, 27, 29, 31, 
	33, 35, 37, 39, 41, 43, 50, 53, 
	56, 59, 62, 65, 68, 71, 74, 93, 
	112, 114, 116, 119, 122, 127, 132, 137, 
	142, 146, 150, 153, 155, 157, 159, 161, 
	163, 165, 167, 169, 171, 173, 175, 177, 
	179, 181, 183, 185, 188, 191, 196, 203, 
	208, 210, 212, 214, 216, 218, 220, 222, 
	224, 226, 228, 230, 232, 234, 236, 238, 
	240, 242, 244, 246, 248, 250, 252, 254, 
	256, 258, 260, 262, 264, 266, 282, 285, 
	288, 291, 294, 297, 300, 303, 306, 309, 
	312, 315, 318, 321, 324, 327, 330, 333, 
	336, 339, 342, 345, 348, 351, 354, 357, 
	360, 363, 366, 369, 372, 375, 378, 381, 
	384, 387, 390, 393, 396, 399, 402, 405, 
	408, 411, 414, 417, 420, 423, 426, 429, 
	432, 435, 438, 441, 444, 448, 451, 454, 
	457, 460, 463, 466, 469, 472, 475, 478, 
	480, 482, 484, 486, 488, 490, 492, 494, 
	496, 498, 500, 502, 505, 507, 509, 511, 
	513, 515, 517, 519, 521, 523, 525, 527, 
	529, 545, 548, 551, 554, 557, 560, 563, 
	566, 569, 572, 575, 578, 581, 584, 587, 
	590, 593, 596, 599, 602, 605, 608, 611, 
	614, 617, 620, 623, 626, 629, 632, 635, 
	638, 641, 644, 647, 650, 653, 656, 659, 
	662, 665, 668, 671, 674, 677, 680, 683, 
	686, 689, 692, 695, 698, 701, 704, 707, 
	710, 712, 714, 731, 734, 737, 740, 743, 
	746, 749, 752, 755, 758, 761, 764, 767, 
	770, 773, 776, 779, 782, 785, 788, 791, 
	794, 797, 800, 803, 806, 809, 812, 815, 
	818, 821, 824, 827, 830, 833, 836, 839, 
	842, 845, 848, 851, 854, 857, 860, 863, 
	866, 869, 872, 875, 878, 881, 884, 887, 
	890, 893, 896, 899, 902, 905, 908, 911, 
	914, 918, 921, 924, 927, 930, 933, 936, 
	939, 942, 945, 948, 950, 954, 960, 964, 
	967, 973, 992, 994, 996, 998, 1000, 1002, 
	1004, 1006, 1008, 1018, 1021, 1025, 1028, 1031, 
	1034, 1037, 1040, 1043, 1046, 1049, 1052, 1055, 
	1058, 1061, 1064, 1067, 1070, 1073, 1076, 1079, 
	1082, 1085, 1088, 1091, 1094, 1097, 1100, 1103, 
	1106, 1109, 1112, 1115, 1118, 1121, 1124, 1127, 
	1130, 1133, 1136, 1139, 1142, 1146, 1149, 1152, 
	1155, 1158, 1161, 1164, 1167, 1170, 1173, 1175, 
	1177
};

static const short _lexer_trans_targs[] = {
	2, 374, 23, 23, 24, 34, 36, 50, 
	53, 56, 58, 67, 71, 75, 151, 157, 
	307, 308, 23, 0, 3, 0, 4, 314, 
	0, 5, 0, 6, 0, 7, 0, 8, 
	0, 9, 0, 10, 0, 11, 0, 13, 
	12, 13, 12, 14, 13, 13, 23, 23, 
	13, 12, 15, 13, 12, 13, 16, 12, 
	13, 17, 12, 13, 18, 12, 13, 19, 
	12, 13, 20, 12, 13, 21, 12, 13, 
	22, 12, 2, 23, 23, 24, 34, 36, 
	50, 53, 56, 58, 67, 71, 75, 151, 
	157, 307, 308, 23, 0, 2, 23, 23, 
	24, 34, 36, 50, 53, 56, 58, 67, 
	71, 75, 151, 157, 307, 308, 23, 0, 
	25, 0, 26, 0, 28, 27, 27, 28, 
	27, 27, 29, 29, 30, 29, 29, 29, 
	29, 30, 29, 29, 29, 29, 31, 29, 
	29, 29, 29, 32, 29, 29, 23, 33, 
	33, 0, 23, 33, 33, 0, 23, 35, 
	34, 23, 0, 37, 0, 38, 0, 39, 
	0, 40, 0, 41, 0, 42, 0, 43, 
	0, 44, 0, 45, 0, 46, 0, 47, 
	0, 48, 0, 49, 0, 376, 0, 51, 
	0, 23, 35, 52, 23, 35, 52, 0, 
	0, 0, 0, 54, 55, 23, 55, 55, 
	53, 54, 54, 23, 55, 53, 55, 0, 
	57, 0, 50, 0, 59, 0, 60, 0, 
	61, 0, 62, 0, 63, 0, 64, 0, 
	65, 0, 66, 0, 50, 0, 68, 0, 
	69, 0, 70, 0, 64, 0, 72, 0, 
	73, 0, 74, 0, 50, 0, 76, 0, 
	77, 0, 78, 0, 79, 0, 80, 0, 
	81, 0, 82, 0, 83, 0, 85, 84, 
	85, 84, 86, 85, 85, 23, 94, 108, 
	23, 109, 111, 120, 124, 128, 134, 150, 
	85, 84, 87, 85, 84, 85, 88, 84, 
	85, 89, 84, 85, 90, 84, 85, 91, 
	84, 85, 92, 84, 85, 93, 84, 85, 
	22, 84, 85, 95, 84, 85, 96, 84, 
	85, 97, 84, 85, 98, 84, 85, 99, 
	84, 85, 100, 84, 85, 101, 84, 85, 
	102, 84, 85, 103, 84, 85, 104, 84, 
	85, 105, 84, 85, 106, 84, 85, 107, 
	84, 85, 23, 84, 85, 22, 84, 85, 
	110, 84, 85, 108, 84, 85, 112, 84, 
	85, 113, 84, 85, 114, 84, 85, 115, 
	84, 85, 116, 84, 85, 117, 84, 85, 
	118, 84, 85, 119, 84, 85, 108, 84, 
	121, 85, 84, 122, 85, 84, 85, 123, 
	84, 85, 117, 84, 85, 125, 84, 85, 
	126, 84, 85, 127, 84, 85, 108, 84, 
	85, 129, 84, 85, 130, 84, 85, 131, 
	84, 85, 132, 84, 85, 133, 84, 85, 
	108, 84, 85, 135, 84, 85, 136, 84, 
	85, 137, 84, 85, 138, 84, 85, 139, 
	84, 85, 140, 84, 85, 141, 22, 84, 
	85, 142, 84, 85, 143, 84, 85, 144, 
	84, 85, 145, 84, 85, 146, 84, 147, 
	85, 84, 148, 85, 84, 149, 85, 84, 
	93, 85, 84, 85, 108, 84, 152, 0, 
	153, 0, 154, 0, 155, 0, 156, 0, 
	50, 0, 158, 0, 159, 0, 160, 0, 
	161, 0, 162, 0, 163, 0, 164, 232, 
	0, 165, 0, 166, 0, 167, 0, 168, 
	0, 169, 0, 170, 0, 171, 0, 172, 
	0, 173, 0, 174, 0, 176, 175, 176, 
	175, 177, 176, 176, 23, 185, 199, 23, 
	200, 202, 211, 215, 219, 225, 231, 176, 
	175, 178, 176, 175, 176, 179, 175, 176, 
	180, 175, 176, 181, 175, 176, 182, 175, 
	176, 183, 175, 176, 184, 175, 176, 22, 
	175, 176, 186, 175, 176, 187, 175, 176, 
	188, 175, 176, 189, 175, 176, 190, 175, 
	176, 191, 175, 176, 192, 175, 176, 193, 
	175, 176, 194, 175, 176, 195, 175, 176, 
	196, 175, 176, 197, 175, 176, 198, 175, 
	176, 23, 175, 176, 22, 175, 176, 201, 
	175, 176, 199, 175, 176, 203, 175, 176, 
	204, 175, 176, 205, 175, 176, 206, 175, 
	176, 207, 175, 176, 208, 175, 176, 209, 
	175, 176, 210, 175, 176, 199, 175, 212, 
	176, 175, 213, 176, 175, 176, 214, 175, 
	176, 208, 175, 176, 216, 175, 176, 217, 
	175, 176, 218, 175, 176, 199, 175, 176, 
	220, 175, 176, 221, 175, 176, 222, 175, 
	176, 223, 175, 176, 224, 175, 176, 199, 
	175, 176, 226, 175, 176, 227, 175, 176, 
	228, 175, 176, 229, 175, 176, 230, 175, 
	176, 184, 175, 176, 199, 175, 234, 233, 
	234, 233, 235, 234, 234, 23, 243, 257, 
	23, 258, 260, 269, 273, 277, 284, 290, 
	306, 234, 233, 236, 234, 233, 234, 237, 
	233, 234, 238, 233, 234, 239, 233, 234, 
	240, 233, 234, 241, 233, 234, 242, 233, 
	234, 22, 233, 234, 244, 233, 234, 245, 
	233, 234, 246, 233, 234, 247, 233, 234, 
	248, 233, 234, 249, 233, 234, 250, 233, 
	234, 251, 233, 234, 252, 233, 234, 253, 
	233, 234, 254, 233, 234, 255, 233, 234, 
	256, 233, 234, 23, 233, 234, 22, 233, 
	234, 259, 233, 234, 257, 233, 234, 261, 
	233, 234, 262, 233, 234, 263, 233, 234, 
	264, 233, 234, 265, 233, 234, 266, 233, 
	234, 267, 233, 234, 268, 233, 234, 257, 
	233, 270, 234, 233, 271, 234, 233, 234, 
	272, 233, 234, 266, 233, 234, 274, 233, 
	234, 275, 233, 234, 276, 233, 234, 257, 
	233, 234, 278, 233, 279, 234, 233, 280, 
	234, 233, 234, 281, 233, 234, 282, 233, 
	283, 234, 233, 242, 234, 233, 234, 285, 
	233, 234, 286, 233, 234, 287, 233, 234, 
	288, 233, 234, 289, 233, 234, 257, 233, 
	234, 291, 233, 234, 292, 233, 234, 293, 
	233, 234, 294, 233, 234, 295, 233, 234, 
	296, 233, 234, 297, 22, 233, 234, 298, 
	233, 234, 299, 233, 234, 300, 233, 234, 
	301, 233, 234, 302, 233, 303, 234, 233, 
	304, 234, 233, 305, 234, 233, 242, 234, 
	233, 234, 257, 233, 50, 0, 308, 309, 
	308, 0, 313, 312, 311, 309, 312, 310, 
	0, 311, 309, 310, 0, 311, 310, 313, 
	312, 311, 309, 312, 310, 2, 313, 313, 
	24, 34, 36, 50, 53, 56, 58, 67, 
	71, 75, 151, 157, 307, 308, 313, 0, 
	315, 0, 316, 0, 317, 0, 318, 0, 
	319, 0, 320, 0, 322, 321, 322, 321, 
	323, 322, 322, 23, 337, 23, 351, 358, 
	322, 321, 324, 322, 321, 322, 325, 332, 
	321, 322, 326, 321, 322, 327, 321, 322, 
	328, 321, 322, 329, 321, 322, 330, 321, 
	322, 331, 321, 322, 22, 321, 322, 333, 
	321, 322, 334, 321, 322, 335, 321, 322, 
	336, 321, 322, 331, 321, 322, 338, 321, 
	322, 339, 321, 322, 340, 321, 322, 341, 
	321, 322, 342, 321, 322, 343, 321, 322, 
	344, 321, 322, 345, 321, 322, 346, 321, 
	322, 347, 321, 322, 348, 321, 322, 349, 
	321, 322, 350, 321, 322, 23, 321, 322, 
	352, 321, 353, 322, 321, 354, 322, 321, 
	322, 355, 321, 322, 356, 321, 357, 322, 
	321, 331, 322, 321, 322, 359, 321, 322, 
	360, 321, 322, 361, 321, 322, 362, 321, 
	322, 363, 321, 322, 364, 321, 322, 365, 
	22, 321, 322, 366, 321, 322, 367, 321, 
	322, 368, 321, 322, 369, 321, 322, 370, 
	321, 371, 322, 321, 372, 322, 321, 373, 
	322, 321, 331, 322, 321, 375, 0, 23, 
	0, 0, 0
};

static const unsigned char _lexer_trans_actions[] = {
	29, 0, 54, 0, 5, 1, 0, 29, 
	1, 29, 29, 29, 29, 29, 29, 29, 
	29, 35, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 84, 54, 0, 81, 81, 
	0, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	21, 0, 63, 130, 31, 60, 57, 31, 
	63, 57, 63, 63, 63, 63, 63, 63, 
	63, 63, 66, 31, 43, 29, 54, 0, 
	5, 1, 0, 29, 1, 29, 29, 29, 
	29, 29, 29, 29, 29, 35, 0, 43, 
	0, 43, 0, 43, 139, 48, 9, 106, 
	11, 0, 134, 45, 45, 45, 3, 122, 
	33, 33, 33, 0, 122, 33, 33, 33, 
	0, 122, 33, 0, 33, 0, 102, 7, 
	7, 43, 54, 0, 0, 43, 114, 25, 
	0, 54, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 149, 126, 57, 110, 23, 0, 43, 
	43, 43, 43, 0, 27, 118, 27, 27, 
	51, 27, 0, 54, 0, 1, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 144, 57, 
	54, 0, 84, 54, 0, 72, 33, 84, 
	72, 84, 84, 84, 84, 84, 84, 84, 
	0, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	15, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 15, 0, 54, 15, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 15, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 54, 0, 0, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 84, 54, 0, 78, 33, 84, 78, 
	84, 84, 84, 84, 84, 84, 84, 0, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 19, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 19, 0, 54, 19, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 144, 57, 
	54, 0, 84, 54, 0, 75, 33, 84, 
	75, 84, 84, 84, 84, 84, 84, 84, 
	84, 0, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 17, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 17, 0, 54, 17, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 54, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 17, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 54, 0, 0, 0, 43, 0, 0, 
	0, 43, 54, 37, 37, 87, 37, 37, 
	43, 0, 39, 0, 43, 0, 0, 54, 
	0, 0, 39, 0, 0, 96, 54, 0, 
	93, 90, 41, 96, 90, 96, 96, 96, 
	96, 96, 96, 96, 96, 99, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 144, 57, 54, 0, 
	84, 54, 0, 69, 33, 69, 84, 84, 
	0, 0, 0, 54, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 13, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 13, 0, 54, 
	0, 0, 0, 54, 0, 0, 54, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	13, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 43, 0, 
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
	43
};

static const int lexer_start = 1;
static const int lexer_first_final = 376;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"

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
    
    
#line 951 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
    
#line 958 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
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
#line 1248 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"
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
#line 1311 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/tr.c.rl"

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

void Init_gherkin_lexer_tr()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Tr", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

