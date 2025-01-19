/*/ -=-= LuckyScript Lexer =-=-
             It's Real!
    Placeholder text
/*/

/* -= logic starts here =- */

token_t={};
token_t.pos=null;
token_t.type=null;
token_t.value=null;

Token(pos=0, type='Unknown', value=null) = {
    token = new outer.token_t;
    token.pos = pos;
    token.type = type;
    token.value = value;
    token.classID = 'Token';
    return token
};
//public.Token=@Token;

chars = {
    '{': 'LCurly',
    '}': 'RCurly',
    '[': 'LSquare',
    ']': 'RSquare',
    '(': 'LParen',
    ')': 'RParen',
    '*': 'Asterisk',
    '^': 'Exponent',
    '%': 'Percent',
    '.': 'Dot',
    ',': 'Comma',
    ':': 'Colon',
    ';': 'Semi',
    '@': 'Pointer'/*,
    */
};
kws = {
    'if': 'KW.if',
    'else': 'KW.else',
    'while': 'KW.while',
    'for': 'KW.for',
    'continue': 'KW.continue',
    'break': 'KW.break',
    'in': 'KW.in',
    'return': 'KW.return',
    'new': 'KW.new'/*,
    * 'class': 'KW.class',
    * 'private': 'KW.private',
    * 'public': 'KW.public',
    * 'switch': 'KW.switch',
    * 'case': 'KW.case',
    * 'default': 'KW.default',
    * 'try': 'KW.try',
    * 'catch': 'KW.catch',
    * 'throw': 'KW.throw'*/
};
signs_l = {
    '>=': 'GEqual',
    '<=': 'LEqual',
    '==': 'Equal',
    '!=': 'NEqual',
    '||': 'Or',
    '&&': 'And',
    '++': 'Inc',
    '--': 'Dec',
    '+=': 'Append',
    '*=': 'AssignMul',
    '/=': 'AssignDiv',
    '%=': 'AssignMod',
    '^=': 'AssignExp',
    '-=': 'Detach'
};
signs_s = {
    '>': 'Greater',
    '<': 'Lesser',
    '=': 'Assign',
    '!': 'Not',
    '+': 'Plus',
    '-': 'Minus',
    '/': 'Slash'
};

ws=char(9)+'\n'+char(32)+char(13);

lexer_c={};
Lexer() = {
    lexer = new outer.lexer_c;
    Token = @outer.Token;

    src = '';
    src_l = 0;
    pos = 0;
    open_stack = [];
    tokens = [];
    ws = outer.ws;
    chars = outer.chars;
    kws = outer.kws;
    signs_l = outer.signs_l;
    signs_s = outer.signs_s;

    lexer.reset() = {
        outer.src='';
        outer.src_l=0;
        outer.pos=0;
        outer.open_stack=[];
        outer.tokens=[];
        return outer.lexer
    };

    lexer.lex(input) = {
        outer.src+=input;
        outer.src_l=len(outer.src);

        while pos<src_l {
            c=src[pos];
            c2=src[pos:pos+2];

            if c==ws[0] {
                outer.pos++
            } else if c==ws[1] {
                if open_stack!=[] && open_stack[-1]==0 pop(outer.open_stack);
                outer.pos++
            } else if c==ws[2] {
                outer.pos++
            } else if c==ws[3] {
                outer.pos++
            } else if c2=='*/' && open_stack!=[] && open_stack[-1]==1 {
                pop(outer.open_stack);
                outer.pos+=2
            } else if open_stack!=[] && (open_stack[-1]==0 || open_stack[-1]==1) {
                outer.pos++
            } else if c2 == '//' {
                push(outer.open_stack,0);
                outer.pos+=2
            } else if c2 == '/*' {
                push(outer.open_stack,1);
                outer.pos+=2
            }
            else if c=='"' || c=="'" {
                s='';
                sp=pos;
                outer.pos++;
                while pos<src_l && src[pos]!=c {
                    if src[pos:pos+2]=='\\n' {
                        outer.pos+=2;
                        s+='\n';
                        continue
                    } else if src[pos]=='\\' {
                        outer.pos++;
                        if pos>=src_l break
                    };
                    s+=src[pos];
                    outer.pos++;
                };
                outer.pos++;
                push(outer.tokens,Token(sp,'String',s))
            }
            else if hasIndex(chars,c) {
                /*if c=='{' {
                    push(outer.open_stack, 3)
                } else if c=='[' {
                    push(outer.open_stack, 4)
                } else if c=='(' {
                    push(outer.open_stack, 5)
                } else if c=='}' && (open_stack!=[] && open_stack[-1]==3) {
                    pop(outer.open_stack)
                } else if c==']' && (open_stack!=[] && open_stack[-1]==4) {
                    pop(outer.open_stack)
                } else if c==')' && (open_stack!=[] && open_stack[-1]==5) {
                    pop(outer.open_stack)
                };*/
                push(outer.tokens,Token(pos,chars[c]));
                outer.pos++;
            }
            else if indexOf('abcdefghijklmnopqrstuvwxyz_',lower(c))!=null {
                sp=pos;
                while pos<src_l
                  && indexOf('abcdefghijklmnopqrstuvwxyz0123456789_',lower(src[pos]))!=null
                    outer.pos++;
                s=src[sp:pos];
                ls=lower(s);

                if ls=='or'
                    push(outer.tokens,Token(sp,'Or'))
                else if ls=='and'
                    push(outer.tokens,Token(sp,'And'))
                else if ls=='not'
                    push(outer.tokens,Token(sp,'Not'))
                else if ls=='null'
                    push(outer.tokens,Token(sp,'Null'))
                else if ls=='true'
                    push(outer.tokens,Token(sp,'Bool',1))
                else if ls=='false'
                    push(outer.tokens,Token(sp,'Bool',0))
                else if hasIndex(kws,ls)
                    push(outer.tokens,Token(sp,kws[ls]))
                else
                    push(outer.tokens,Token(sp,'ID',s))
            }
            else if typeof(to_int(c))=='number' {
                sp=pos;
                d=0;
                while pos<src_l && (typeof(to_int(src[pos]))=='number' || src[pos]=='.') {
                    if src[pos]=='.' {
                        if d break;
                        d=1
                    };
                    outer.pos++
                };
                push(outer.tokens,Token(sp,'Int',val(src[sp:pos])))
            }
            else if hasIndex(signs_l,c2) {
                push(outer.tokens,Token(pos,signs_l[c2]));
                outer.pos+=2
            }
            else if hasIndex(signs_s,c) {
                push(outer.tokens,Token(pos,signs_s[c]));
                outer.pos++
            }
            else {
                push(outer.tokens,Token(pos,'Unknown',c));
                outer.pos++
            }
        };

        while open_stack!=[] && open_stack[-1]==0 pop(open_stack);
        if open_stack!=[] return 0 else return outer.tokens
    };

    return lexer
};
//public.Lexer=@Lexer