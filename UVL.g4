grammar UVL;

tokens {
	INDENT,
	DEDENT
}

@lexer::header {
from antlr_denter.DenterHelper import DenterHelper
from UVLParser import UVLParser
}
@lexer::members {
class UVLDenter(DenterHelper):
    def __init__(self, lexer, nl_token, indent_token, dedent_token, ignore_eof):
        super().__init__(nl_token, indent_token, dedent_token, ignore_eof)
        self.lexer: UVLLexer = lexer

    def pull_token(self):
        return super(UVLLexer, self.lexer).nextToken()

denter = None

def nextToken(self):
    if not self.denter:
        self.denter = self.UVLDenter(self, self.NL, UVLParser.INDENT, UVLParser.DEDENT, True)
    return self.denter.next_token()

}

// parser rules
feature_model: imports? features constraints? EOF?;

//features block
features: 'features' INDENT child DEDENT;

child: feature_spec (INDENT relation* (DEDENT | EOF ))?;
relation: relation_spec (INDENT child* (DEDENT | EOF ))?;

feature_spec: ref attributes? NL?;
ref: (WORD '.')* WORD;
attributes: '{}' | '{' attribute (',' attribute)* '}';
attribute: key ('"' value '"')?;
key: WORD;
value: (BOOLEAN | NUMBER | WORD | VECTOR);

relation_spec: RELATION_WORD;

//constraints block constraints block
constraints: 'constraints' INDENT (constraint NL?)* (DEDENT|EOF);

constraint:
	negation
	| conjunction
	| disjuction
	| implication
	| equivalence
	| requires
	| excludes;

negation: '!' WORD;
conjunction: WORD '&' WORD;
disjuction: WORD '|' WORD;
implication: WORD '=>' WORD;
equivalence: WORD '<=>' WORD;
requires: WORD 'requires' WORD;
excludes: WORD 'excludes' WORD;

// imports blocK

imports: 'imports' INDENT imp* DEDENT;

imp: imp_spec ('as' WORD)? NL?;
imp_spec: WORD '.' WORD ('.' WORD)*;

//lexer rules
fragment INT: '0' | ([1-9][0-9]*);

RELATION_WORD: (
		'alternative'
		| 'or'
		| 'optional'
		| 'mandatory'
		| ('[' (INT '..')? (INT | '*') ']')
	);

WORD: [a-zA-Z][a-zA-Z0-9_]*;
BOOLEAN: 'true' | 'false';
NUMBER: '0' | ([1-9][0-9]* ('.' [0-9]+)?);
VECTOR: '[' ((BOOLEAN | NUMBER | WORD | VECTOR) (',')?)* ']';

NL: ('\r'? '\n' ' '* | '\r'? '\n' '\t'*);
WS: [ ]+ -> skip;
