ProgramNode(0...46)(
  ScopeNode(0...0)([]),
  StatementsNode(0...46)(
    [AndNode(0...19)(
       CallNode(0...7)(
         CallNode(4...7)(
           nil,
           nil,
           IDENTIFIER(4...7)("foo"),
           nil,
           nil,
           nil,
           nil,
           "foo"
         ),
         nil,
         KEYWORD_NOT(0...3)("not"),
         nil,
         nil,
         nil,
         nil,
         "!"
       ),
       CallNode(12...19)(
         CallNode(16...19)(
           nil,
           nil,
           IDENTIFIER(16...19)("bar"),
           nil,
           nil,
           nil,
           nil,
           "bar"
         ),
         nil,
         KEYWORD_NOT(12...15)("not"),
         nil,
         nil,
         nil,
         nil,
         "!"
       ),
       KEYWORD_AND(8...11)("and")
     ),
     CallNode(21...37)(
       AndNode(25...36)(
         CallNode(25...28)(
           nil,
           nil,
           IDENTIFIER(25...28)("foo"),
           nil,
           nil,
           nil,
           nil,
           "foo"
         ),
         CallNode(33...36)(
           nil,
           nil,
           IDENTIFIER(33...36)("bar"),
           nil,
           nil,
           nil,
           nil,
           "bar"
         ),
         KEYWORD_AND(29...32)("and")
       ),
       nil,
       KEYWORD_NOT(21...24)("not"),
       PARENTHESIS_LEFT(24...25)("("),
       nil,
       PARENTHESIS_RIGHT(36...37)(")"),
       nil,
       "!"
     ),
     CallNode(39...46)(
       CallNode(43...46)(
         nil,
         nil,
         IDENTIFIER(43...46)("foo"),
         nil,
         nil,
         nil,
         nil,
         "foo"
       ),
       nil,
       KEYWORD_NOT(39...42)("not"),
       nil,
       nil,
       nil,
       nil,
       "!"
     )]
  )
)
