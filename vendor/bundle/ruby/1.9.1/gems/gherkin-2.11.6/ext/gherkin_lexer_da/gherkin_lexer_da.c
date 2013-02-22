
#line 1 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
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


#line 254 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"


/** Data **/

#line 89 "ext/gherkin_lexer_da/gherkin_lexer_da.c"
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
	123, 124, 125, 126, 127, 128, 129, 130, 
	131, 145, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 165, 167, 169, 171, 173, 
	175, 193, 194, 195, 196, 197, 198, 199, 
	200, 201, 202, 203, 218, 220, 222, 224, 
	226, 228, 230, 232, 234, 236, 238, 240, 
	242, 244, 246, 248, 250, 252, 254, 256, 
	258, 260, 262, 264, 266, 268, 270, 272, 
	274, 276, 278, 280, 282, 284, 286, 288, 
	290, 292, 294, 296, 298, 300, 302, 304, 
	306, 308, 310, 312, 314, 316, 319, 321, 
	323, 325, 327, 329, 331, 333, 335, 336, 
	337, 338, 339, 340, 341, 342, 343, 344, 
	355, 357, 359, 361, 363, 365, 367, 369, 
	371, 373, 375, 377, 379, 381, 383, 385, 
	387, 389, 391, 393, 395, 397, 399, 401, 
	403, 405, 407, 409, 411, 413, 415, 417, 
	419, 421, 423, 425, 427, 429, 431, 434, 
	436, 438, 440, 442, 444, 446, 448, 450, 
	452, 454, 456, 458, 460, 462, 464, 466, 
	468, 470, 472, 474, 475, 476, 477, 478, 
	479, 480, 481, 482, 483, 484, 491, 493, 
	495, 497, 499, 501, 503, 505, 507, 508, 
	509, 510, 511, 512, 513, 514, 515, 516, 
	517, 519, 520, 521, 522, 523, 524, 525, 
	526, 527, 528, 529, 545, 547, 549, 551, 
	553, 555, 557, 559, 561, 563, 565, 567, 
	569, 571, 573, 575, 577, 579, 581, 583, 
	585, 587, 589, 591, 593, 595, 597, 599, 
	601, 603, 605, 607, 609, 611, 613, 615, 
	617, 619, 621, 623, 625, 627, 629, 631, 
	633, 635, 637, 639, 641, 643, 645, 647, 
	649, 651, 653, 655, 657, 660, 662, 664, 
	666, 668, 670, 672, 674, 678, 684, 687, 
	689, 695, 713, 715, 717, 719, 721, 723, 
	725, 727, 729, 731, 733, 735, 737, 739, 
	741, 743, 745, 747, 749, 752, 754, 756, 
	758, 760, 762, 764, 766
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 69, 71, 77, 78, 79, 83, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 69, 71, 
	77, 78, 79, 83, 124, 9, 13, 34, 
	34, 10, 13, 10, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 13, 10, 13, 13, 
	32, 64, 9, 10, 9, 10, 13, 32, 
	64, 11, 12, 10, 32, 64, 9, 13, 
	98, 115, 116, 114, 97, 107, 116, 32, 
	83, 99, 101, 110, 97, 114, 105, 111, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 69, 71, 77, 78, 79, 83, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	32, 34, 35, 37, 42, 64, 65, 66, 
	69, 71, 77, 78, 79, 83, 124, 9, 
	13, 97, 103, 103, 114, 117, 110, 100, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 65, 69, 71, 77, 78, 79, 83, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 98, 10, 115, 10, 116, 10, 114, 
	10, 97, 10, 107, 10, 116, 10, 32, 
	10, 83, 10, 99, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 111, 
	10, 58, 10, 103, 10, 101, 10, 110, 
	10, 115, 10, 107, 10, 97, 10, 98, 
	10, 105, 10, 118, 10, 101, 10, 116, 
	10, 101, 10, 110, -61, 10, -91, 10, 
	10, 114, 10, 103, -61, 10, 99, -91, 
	10, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 101, 103, 107, 101, 
	110, 115, 107, 97, 98, 58, 10, 10, 
	10, 32, 35, 37, 64, 65, 66, 69, 
	83, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	98, 10, 115, 10, 116, 10, 114, 10, 
	97, 10, 107, 10, 116, 10, 32, 10, 
	83, 10, 99, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	58, 10, 97, 10, 103, 10, 103, 10, 
	114, 10, 117, 10, 110, 10, 100, 10, 
	103, 107, 10, 101, 10, 110, 10, 115, 
	10, 107, 10, 97, 10, 98, 10, 115, 
	10, 101, 10, 109, 10, 112, 10, 108, 
	10, 101, 10, 114, 10, 99, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 101, 115, 101, 109, 112, 108, 101, 
	114, 58, 10, 10, 10, 32, 35, 69, 
	124, 9, 13, 10, 103, 10, 101, 10, 
	110, 10, 115, 10, 107, 10, 97, 10, 
	98, 10, 58, 105, 118, 101, 116, 101, 
	110, -61, -91, 114, 103, -61, 99, -91, 
	101, 110, 97, 114, 105, 101, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 65, 
	66, 69, 71, 77, 78, 79, 83, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	98, 10, 115, 10, 116, 10, 114, 10, 
	97, 10, 107, 10, 116, 10, 32, 10, 
	83, 10, 99, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	58, 10, 97, 10, 103, 10, 103, 10, 
	114, 10, 117, 10, 110, 10, 100, 10, 
	103, 10, 101, 10, 110, 10, 115, 10, 
	107, 10, 97, 10, 98, 10, 105, 10, 
	118, 10, 101, 10, 116, 10, 101, 10, 
	110, -61, 10, -91, 10, 10, 114, 10, 
	103, -61, 10, 99, -91, 10, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 101, 32, 124, 9, 13, 10, 32, 
	92, 124, 9, 13, 10, 92, 124, 10, 
	92, 10, 32, 92, 124, 9, 13, 10, 
	32, 34, 35, 37, 42, 64, 65, 66, 
	69, 71, 77, 78, 79, 83, 124, 9, 
	13, 10, 103, 10, 101, 10, 110, 10, 
	115, 10, 107, 10, 97, 10, 98, 10, 
	58, 10, 105, 10, 118, 10, 101, 10, 
	116, 10, 101, 10, 110, -61, 10, -91, 
	10, 10, 114, 10, 103, -61, 10, 99, 
	-91, 10, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 101, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	2, 3, 3, 3, 3, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 5, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	12, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	16, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 13, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 9, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 5, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 14, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 3, 2, 
	4, 16, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 1, 0, 0, 
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
	0, 0, 0, 0, 1, 1, 0, 0, 
	1, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	48, 51, 56, 61, 66, 71, 75, 79, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 120, 125, 132, 137, 139, 141, 
	143, 145, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 165, 167, 169, 171, 173, 
	175, 189, 192, 195, 198, 201, 204, 207, 
	210, 213, 216, 219, 222, 225, 228, 231, 
	234, 252, 254, 256, 258, 260, 262, 264, 
	266, 268, 270, 272, 287, 290, 293, 296, 
	299, 302, 305, 308, 311, 314, 317, 320, 
	323, 326, 329, 332, 335, 338, 341, 344, 
	347, 350, 353, 356, 359, 362, 365, 368, 
	371, 374, 377, 380, 383, 386, 389, 392, 
	395, 398, 401, 404, 407, 410, 413, 416, 
	419, 422, 425, 428, 431, 434, 438, 441, 
	444, 447, 450, 453, 456, 459, 462, 464, 
	466, 468, 470, 472, 474, 476, 478, 480, 
	491, 494, 497, 500, 503, 506, 509, 512, 
	515, 518, 521, 524, 527, 530, 533, 536, 
	539, 542, 545, 548, 551, 554, 557, 560, 
	563, 566, 569, 572, 575, 578, 581, 584, 
	587, 590, 593, 596, 599, 602, 605, 609, 
	612, 615, 618, 621, 624, 627, 630, 633, 
	636, 639, 642, 645, 648, 651, 654, 657, 
	660, 663, 666, 669, 671, 673, 675, 677, 
	679, 681, 683, 685, 687, 689, 696, 699, 
	702, 705, 708, 711, 714, 717, 720, 722, 
	724, 726, 728, 730, 732, 734, 736, 738, 
	740, 743, 745, 747, 749, 751, 753, 755, 
	757, 759, 761, 763, 779, 782, 785, 788, 
	791, 794, 797, 800, 803, 806, 809, 812, 
	815, 818, 821, 824, 827, 830, 833, 836, 
	839, 842, 845, 848, 851, 854, 857, 860, 
	863, 866, 869, 872, 875, 878, 881, 884, 
	887, 890, 893, 896, 899, 902, 905, 908, 
	911, 914, 917, 920, 923, 926, 929, 932, 
	935, 938, 941, 944, 947, 951, 954, 957, 
	960, 963, 966, 969, 972, 976, 982, 986, 
	989, 995, 1013, 1016, 1019, 1022, 1025, 1028, 
	1031, 1034, 1037, 1040, 1043, 1046, 1049, 1052, 
	1055, 1058, 1061, 1064, 1067, 1071, 1074, 1077, 
	1080, 1083, 1086, 1089, 1092
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 15, 17, 31, 34, 
	37, 73, 141, 230, 234, 236, 239, 240, 
	316, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 15, 17, 31, 34, 37, 73, 
	141, 230, 234, 236, 239, 240, 316, 4, 
	0, 6, 0, 7, 0, 9, 8, 8, 
	9, 8, 8, 10, 10, 11, 10, 10, 
	10, 10, 11, 10, 10, 10, 10, 12, 
	10, 10, 10, 10, 13, 10, 10, 4, 
	14, 14, 0, 4, 14, 14, 0, 4, 
	16, 15, 4, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 30, 0, 348, 0, 
	32, 0, 4, 16, 33, 4, 16, 33, 
	0, 0, 0, 0, 35, 36, 4, 36, 
	36, 34, 35, 35, 4, 36, 34, 36, 
	0, 38, 0, 39, 0, 40, 0, 41, 
	0, 42, 0, 43, 0, 44, 0, 45, 
	0, 46, 0, 47, 0, 48, 0, 49, 
	0, 50, 0, 51, 0, 52, 0, 53, 
	0, 54, 0, 56, 55, 56, 55, 56, 
	56, 4, 57, 71, 4, 322, 330, 334, 
	336, 339, 340, 56, 55, 56, 58, 55, 
	56, 59, 55, 56, 60, 55, 56, 61, 
	55, 56, 62, 55, 56, 63, 55, 56, 
	64, 55, 56, 65, 55, 56, 66, 55, 
	56, 67, 55, 56, 68, 55, 56, 69, 
	55, 56, 70, 55, 56, 4, 55, 56, 
	72, 55, 4, 4, 5, 15, 17, 31, 
	34, 37, 73, 141, 230, 234, 236, 239, 
	240, 316, 4, 0, 74, 0, 75, 0, 
	76, 0, 77, 0, 78, 0, 79, 0, 
	80, 0, 81, 0, 83, 82, 83, 82, 
	83, 83, 4, 84, 98, 4, 99, 116, 
	123, 127, 129, 132, 133, 83, 82, 83, 
	85, 82, 83, 86, 82, 83, 87, 82, 
	83, 88, 82, 83, 89, 82, 83, 90, 
	82, 83, 91, 82, 83, 92, 82, 83, 
	93, 82, 83, 94, 82, 83, 95, 82, 
	83, 96, 82, 83, 97, 82, 83, 4, 
	82, 83, 72, 82, 83, 100, 82, 83, 
	101, 82, 83, 102, 82, 83, 103, 82, 
	83, 104, 82, 83, 105, 82, 83, 106, 
	82, 83, 107, 82, 83, 108, 82, 83, 
	109, 82, 83, 110, 82, 83, 111, 82, 
	83, 112, 82, 83, 113, 82, 83, 114, 
	82, 83, 115, 82, 83, 72, 82, 83, 
	117, 82, 83, 118, 82, 83, 119, 82, 
	83, 120, 82, 83, 121, 82, 83, 122, 
	82, 83, 115, 82, 83, 124, 82, 83, 
	125, 82, 83, 126, 82, 83, 98, 82, 
	83, 128, 82, 83, 98, 82, 130, 83, 
	82, 131, 83, 82, 83, 98, 82, 83, 
	98, 82, 134, 83, 135, 82, 98, 83, 
	82, 83, 136, 82, 83, 137, 82, 83, 
	138, 82, 83, 139, 82, 83, 140, 82, 
	83, 115, 82, 142, 211, 0, 143, 0, 
	144, 0, 145, 0, 146, 0, 147, 0, 
	148, 0, 149, 0, 151, 150, 151, 150, 
	151, 151, 4, 152, 4, 166, 183, 190, 
	204, 151, 150, 151, 153, 150, 151, 154, 
	150, 151, 155, 150, 151, 156, 150, 151, 
	157, 150, 151, 158, 150, 151, 159, 150, 
	151, 160, 150, 151, 161, 150, 151, 162, 
	150, 151, 163, 150, 151, 164, 150, 151, 
	165, 150, 151, 4, 150, 151, 167, 150, 
	151, 168, 150, 151, 169, 150, 151, 170, 
	150, 151, 171, 150, 151, 172, 150, 151, 
	173, 150, 151, 174, 150, 151, 175, 150, 
	151, 176, 150, 151, 177, 150, 151, 178, 
	150, 151, 179, 150, 151, 180, 150, 151, 
	181, 150, 151, 182, 150, 151, 72, 150, 
	151, 184, 150, 151, 185, 150, 151, 186, 
	150, 151, 187, 150, 151, 188, 150, 151, 
	189, 150, 151, 182, 150, 151, 191, 197, 
	150, 151, 192, 150, 151, 193, 150, 151, 
	194, 150, 151, 195, 150, 151, 196, 150, 
	151, 182, 150, 151, 198, 150, 151, 199, 
	150, 151, 200, 150, 151, 201, 150, 151, 
	202, 150, 151, 203, 150, 151, 182, 150, 
	151, 205, 150, 151, 206, 150, 151, 207, 
	150, 151, 208, 150, 151, 209, 150, 151, 
	210, 150, 151, 182, 150, 212, 0, 213, 
	0, 214, 0, 215, 0, 216, 0, 217, 
	0, 218, 0, 219, 0, 221, 220, 221, 
	220, 221, 221, 4, 222, 4, 221, 220, 
	221, 223, 220, 221, 224, 220, 221, 225, 
	220, 221, 226, 220, 221, 227, 220, 221, 
	228, 220, 221, 229, 220, 221, 72, 220, 
	231, 0, 232, 0, 233, 0, 31, 0, 
	235, 0, 31, 0, 237, 0, 238, 0, 
	31, 0, 31, 0, 241, 242, 0, 31, 
	0, 243, 0, 244, 0, 245, 0, 246, 
	0, 247, 0, 248, 0, 249, 0, 251, 
	250, 251, 250, 251, 251, 4, 252, 266, 
	4, 267, 284, 291, 298, 302, 304, 307, 
	308, 251, 250, 251, 253, 250, 251, 254, 
	250, 251, 255, 250, 251, 256, 250, 251, 
	257, 250, 251, 258, 250, 251, 259, 250, 
	251, 260, 250, 251, 261, 250, 251, 262, 
	250, 251, 263, 250, 251, 264, 250, 251, 
	265, 250, 251, 4, 250, 251, 72, 250, 
	251, 268, 250, 251, 269, 250, 251, 270, 
	250, 251, 271, 250, 251, 272, 250, 251, 
	273, 250, 251, 274, 250, 251, 275, 250, 
	251, 276, 250, 251, 277, 250, 251, 278, 
	250, 251, 279, 250, 251, 280, 250, 251, 
	281, 250, 251, 282, 250, 251, 283, 250, 
	251, 72, 250, 251, 285, 250, 251, 286, 
	250, 251, 287, 250, 251, 288, 250, 251, 
	289, 250, 251, 290, 250, 251, 283, 250, 
	251, 292, 250, 251, 293, 250, 251, 294, 
	250, 251, 295, 250, 251, 296, 250, 251, 
	297, 250, 251, 283, 250, 251, 299, 250, 
	251, 300, 250, 251, 301, 250, 251, 266, 
	250, 251, 303, 250, 251, 266, 250, 305, 
	251, 250, 306, 251, 250, 251, 266, 250, 
	251, 266, 250, 309, 251, 310, 250, 266, 
	251, 250, 251, 311, 250, 251, 312, 250, 
	251, 313, 250, 251, 314, 250, 251, 315, 
	250, 251, 283, 250, 316, 317, 316, 0, 
	321, 320, 319, 317, 320, 318, 0, 319, 
	317, 318, 0, 319, 318, 321, 320, 319, 
	317, 320, 318, 321, 321, 5, 15, 17, 
	31, 34, 37, 73, 141, 230, 234, 236, 
	239, 240, 316, 321, 0, 56, 323, 55, 
	56, 324, 55, 56, 325, 55, 56, 326, 
	55, 56, 327, 55, 56, 328, 55, 56, 
	329, 55, 56, 72, 55, 56, 331, 55, 
	56, 332, 55, 56, 333, 55, 56, 71, 
	55, 56, 335, 55, 56, 71, 55, 337, 
	56, 55, 338, 56, 55, 56, 71, 55, 
	56, 71, 55, 341, 56, 342, 55, 71, 
	56, 55, 56, 343, 55, 56, 344, 55, 
	56, 345, 55, 56, 346, 55, 56, 347, 
	55, 56, 329, 55, 0, 0
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
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 144, 57, 54, 0, 54, 
	0, 78, 33, 84, 78, 84, 84, 84, 
	84, 84, 84, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 19, 0, 54, 
	19, 0, 130, 31, 60, 57, 31, 63, 
	57, 63, 63, 63, 63, 63, 63, 63, 
	63, 66, 31, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 144, 57, 54, 0, 
	54, 0, 72, 33, 84, 72, 84, 84, 
	84, 84, 84, 84, 84, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 15, 
	0, 54, 15, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 15, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 0, 54, 
	0, 0, 54, 0, 54, 0, 0, 54, 
	0, 0, 0, 54, 0, 0, 0, 54, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 0, 0, 43, 0, 43, 
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
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 13, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 144, 57, 54, 
	0, 54, 0, 81, 84, 81, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 21, 0, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 43, 0, 43, 
	0, 43, 0, 43, 0, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 0, 
	43, 0, 43, 0, 43, 0, 43, 144, 
	57, 54, 0, 54, 0, 75, 33, 84, 
	75, 84, 84, 84, 84, 84, 84, 84, 
	84, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 17, 0, 54, 17, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 17, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 0, 0, 0, 43, 
	54, 37, 37, 87, 37, 37, 43, 0, 
	39, 0, 43, 0, 0, 54, 0, 0, 
	39, 0, 0, 54, 0, 93, 90, 41, 
	96, 90, 96, 96, 96, 96, 96, 96, 
	96, 96, 99, 0, 43, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 54, 
	0, 0, 54, 19, 0, 54, 0, 0, 
	54, 0, 0, 54, 0, 0, 54, 0, 
	0, 54, 0, 0, 54, 0, 0, 0, 
	54, 0, 0, 54, 0, 54, 0, 0, 
	54, 0, 0, 0, 54, 0, 0, 0, 
	54, 0, 54, 0, 0, 54, 0, 0, 
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
	43, 43, 43, 43, 43
};

static const int lexer_start = 1;
static const int lexer_first_final = 348;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 258 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"

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
    
    
#line 902 "ext/gherkin_lexer_da/gherkin_lexer_da.c"
	{
	cs = lexer_start;
	}

#line 425 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
    
#line 909 "ext/gherkin_lexer_da/gherkin_lexer_da.c"
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
#line 83 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 89 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 93 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 98 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));
    int type_len = LEN(docstring_content_type_start, PTR_TO(docstring_content_type_end));

    if (len < 0) len = 0;
    if (type_len < 0) len = 0;

    store_docstring_content(listener, lexer->start_col, PTR_TO(docstring_content_type_start), type_len, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 108 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{ 
    MARK(docstring_content_type_start, p);
  }
	break;
	case 5:
#line 112 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{ 
    MARK(docstring_content_type_end, p);
  }
	break;
	case 6:
#line 116 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 7:
#line 120 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 8:
#line 124 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 9:
#line 128 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 10:
#line 132 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 12:
#line 143 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 13:
#line 148 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 14:
#line 153 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 15:
#line 158 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 16:
#line 162 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 17:
#line 168 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 18:
#line 175 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 19:
#line 179 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 20:
#line 185 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 21:
#line 189 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
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
#line 203 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 23:
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
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
#line 1199 "ext/gherkin_lexer_da/gherkin_lexer_da.c"
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
#line 207 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"
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
#line 1262 "ext/gherkin_lexer_da/gherkin_lexer_da.c"
		}
	}
	}

	_out: {}
	}

#line 426 "/Users/ahellesoy/github/gherkin/tasks/../ragel/i18n/da.c.rl"

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

void Init_gherkin_lexer_da()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Da", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

