;; extends

; The upstream query paints the word operators as symbols (cyan). They read as
; keywords: `x as T`, `x is T`, `x !is T`, `x in xs`, `for (i in xs)`.
(as_expression
  ["as" "as?"] @keyword.operator)

(check_expression
  ["is" "in" "!"] @keyword.operator)

(for_statement
  "in" @keyword.operator)

; Generic brackets are brackets, not comparison operators: `Map<String, Int>`.
(type_arguments
  ["<" ">"] @punctuation.bracket)
