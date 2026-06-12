#include "tree_sitter/parser.h"
#include <wctype.h>
#include <string.h>
#include <stdlib.h>

/**
 * External scanner for AutoHotkey grammar.
 */

enum TokenType {
  STATEMENT_END,
  FORCE_EXPR_START,
  FORCE_EXPR_BOUNDARY,
  BLOCK_AFTER_NEWLINE,
};

typedef struct {
  bool in_force_expression;
} Scanner;

void *tree_sitter_autohotkey_external_scanner_create() {
  Scanner *scanner = (Scanner *)calloc(1, sizeof(Scanner));
  scanner->in_force_expression = false;
  return scanner;
}

void tree_sitter_autohotkey_external_scanner_destroy(void *payload) {
  if (payload) {
    free(payload);
  }
}

unsigned tree_sitter_autohotkey_external_scanner_serialize(void *payload, char *buffer) {
  Scanner *scanner = (Scanner *)payload;
  if (scanner && buffer) {
    buffer[0] = scanner->in_force_expression ? 1 : 0;
    return 1;
  }
  return 0;
}

void tree_sitter_autohotkey_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  Scanner *scanner = (Scanner *)payload;
  if (scanner && buffer && length > 0) {
    scanner->in_force_expression = buffer[0] == 1;
  }
}

static bool is_identifier_start(int32_t c) {
  return iswalpha(c) || c == '_';
}

static bool is_identifier_char(int32_t c) {
  return iswalnum(c) || c == '_';
}

bool tree_sitter_autohotkey_external_scanner_scan(
  void *payload,
  TSLexer *lexer,
  const bool *valid_symbols
) {
  Scanner *scanner = (Scanner *)payload;

  // Detect force expression start: % <space>
  if (valid_symbols[FORCE_EXPR_START] && !scanner->in_force_expression) {
    while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
      lexer->advance(lexer, true);
    }
    if (lexer->lookahead == '%') {
      lexer->advance(lexer, false);
      if (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
        lexer->mark_end(lexer);
        lexer->advance(lexer, true);
        scanner->in_force_expression = true;
        lexer->result_symbol = FORCE_EXPR_START;
        return true;
      }
    }
  }

  // Detect force expression boundary: , or newline
  if (valid_symbols[FORCE_EXPR_BOUNDARY] && scanner->in_force_expression) {
    while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
      lexer->advance(lexer, true);
    }
    if (lexer->lookahead == ',' || lexer->lookahead == '\n' ||
        lexer->lookahead == '\r' || lexer->eof(lexer)) {
      lexer->mark_end(lexer);
      scanner->in_force_expression = false;
      lexer->result_symbol = FORCE_EXPR_BOUNDARY;
      return true;
    }
  }

  // Combined check for BLOCK_AFTER_NEWLINE and STATEMENT_END
  bool block_valid = valid_symbols[BLOCK_AFTER_NEWLINE];
  bool stmt_end_valid = valid_symbols[STATEMENT_END];
  if (!block_valid && !stmt_end_valid) return false;

  while (lexer->lookahead == ' ' || lexer->lookahead == '\t') lexer->advance(lexer, true);
  if (stmt_end_valid && lexer->lookahead == ';') {
    lexer->mark_end(lexer);
    lexer->result_symbol = STATEMENT_END;
    return true;
  }
  if (lexer->lookahead != '\n' && lexer->lookahead != '\r') return false;

  lexer->mark_end(lexer);
  if (lexer->lookahead == '\r') lexer->advance(lexer, true);
  if (lexer->lookahead == '\n') lexer->advance(lexer, true);

  while (lexer->lookahead == '\n' || lexer->lookahead == '\r' ||
         lexer->lookahead == ' ' || lexer->lookahead == '\t') {
    lexer->advance(lexer, true);
  }

  if (lexer->eof(lexer)) {
    if (stmt_end_valid) {
      lexer->result_symbol = STATEMENT_END;
      return true;
    }
    return false;
  }
  if (lexer->lookahead == '{') {
    if (block_valid) {
      lexer->result_symbol = BLOCK_AFTER_NEWLINE;
      return true;
    }
    if (stmt_end_valid) {
      lexer->result_symbol = STATEMENT_END;
      return true;
    }
    return false;
  }
  if (!stmt_end_valid) return false;
  if (lexer->lookahead == '(') return false;
  lexer->result_symbol = STATEMENT_END;
  return true;
}
