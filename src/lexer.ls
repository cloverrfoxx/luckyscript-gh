/*/ -=-= LuckyScript Lexer =-=-
            It's Real!
    Placeholder text
/*/

/* -= logic starts here =- */

tokenpart_t={};
tokenpart_t.pos=null;
tokenpart_t.type=null;
tokenpart_t.value=null;

TokenPart(pos=0, type='Unknown', value=null) = {
    part = new outer.tokenpart_t;
    part.pos = pos;
    part.type = type;
    part.value = value;
    part.classID = 'TokenPart';
    return part
};

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

kws = {
    'if': 'KW.if',
    'else': 'KW.else',
    'while': 'KW.while',
    'repeat': 'KW.repeat',
    'for': 'KW.for',
    'continue': 'KW.continue',
    'break': 'KW.break',
    'in': 'KW.in',
    'not': 'Not',
    'and': 'And',
    'or': 'Or',
    'return': 'KW.return',
    'new': 'KW.new'/*,
    'class': 'KW.class',
    'private': 'KW.private',
    'public': 'KW.public',
    'switch': 'KW.switch',
    'case': 'KW.case',
    'default': 'KW.default',
    'try': 'KW.try',
    'catch': 'KW.catch',
    'throw': 'KW.throw'*/
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
    '/': 'Slash',//'Div',
    '*': 'Asterisk',//'Mul',
    '^': 'Exponent',//'Exp',
    '%': 'Percent',//'Mod',
    '.': 'Dot',
    ',': 'Comma',
    ':': 'Colon',
    ';': 'Semi',
    '@': 'Pointer'//'Ptr'
};

ws=char(9)+'\n '+char(13);

lexer_c={};
Lexer() = {
    lexer = new outer.lexer_c;
    Token = @outer.Token;
    TokenPart = @outer.TokenPart;

    src = '';
    src_l = 0;
    pos = 0;
    
    // state
    s_state = [];
    state = 0;

    // tokens
    s_tokens = [];
    tokens = [];
    //buffer = '';

    // curr token
    s_curr = [];
    curr = null;

    ws=outer.ws;
    kws=outer.kws;
    signs_s=outer.signs_s;
    signs_l=outer.signs_l;

    lexer.reset() = {
        outer.src = '';
        outer.src_l = 0;
        outer.pos = 0;
        outer.s_state = [];
        outer.state = 0;
        outer.s_tokens = [];
        outer.tokens = [];
        outer.s_curr = [];
        outer.curr = null;
        return outer.lexer
    };

    lexer.done() =
        return state == 0 && pos>=src_l;

    pushState() =
        outer.s_state += [outer.state];

    popState() = {
        if s_state == []
            outer.state = 0
        else {
            outer.state = s_state[-1];
            outer.s_state = s_state[:-1]
        }
    };

    /*clrBuf() =
        if buffer {
            r = buffer;
            outer.buffer = '';
            return r
        };
    
    addBuf(c) = {
        outer.buffer += c
    };*/

    /*handleChars() = {
        buf = clrBuf();
        ls=lower(buf);
        if ls=='null'
            return Token(bufpos, 'Null')
        else if ls=='true'
            return Token(bufpos, 'Bool', 1)
        else if ls=='false'
            return Token(bufpos, 'Bool', 0)
        else if hasIndex(kws,ls)
            return Token(bufpos, kws[ls])
        else
            return Token(bufpos, 'ID', buf)
    };*/

    handleDefState(c,c2) = {
        // if pos >= src_l {
        //     outer.pos++;
        //     return
        // };
        // prelim skip ws
        if c==ws[0] || c==ws[1] || c==ws[2] || c==ws[3] {
            outer.pos++
        }
        // skip comments
        else if c2 == '/*' {
            // TODO
            pushState();
            outer.state = 11; // multiline comment
            outer.pos+=2
        }
        else if c2 == '//' {
            // TODO
            outer.pos+=2;
            while pos < src_l && src[pos] != '\n' outer.pos++;
            if pos >= src_l return;
            outer.pos+=1
        }
        // handle state starters
        else if c == '(' {
            outer.tokens += [Token(pos,'LParen')];
            pushState();
            outer.state = 1; // paren
            outer.pos++
        }
        else if c == '{' {
            outer.tokens += [Token(pos, 'LCurly')];
            pushState();
            outer.state = 2; // curly
            outer.pos++
        }
        else if c == '[' {
            outer.tokens += [Token(pos, 'LSquare')];
            pushState();
            outer.state = 3; // square
            outer.pos++
        }
        else if c == "'" {
            if curr
                outer.s_curr += [curr];
            outer.curr = Token(pos, 'String', '');
            pushState();
            outer.state = 4; // string squote
            outer.pos++
        }
        else if c == '"' {
            if curr
                outer.s_curr += [curr];
            outer.curr = Token(pos, 'String', '');
            pushState();
            outer.state = 5; // string dquote
            outer.pos++
        }
        else if c2 == "f'" {
            if curr
                outer.s_curr += [curr];
            outer.curr = Token(pos, 'FString', []);
            pushState();
            outer.state = 6; // f-string, 7 = formatter
            outer.pos+=2
        }
        else if is_match(c,'[a-zA-Z_]') {
            // addBuf(c);
            if curr
                outer.s_curr += [curr];
            outer.curr = Token(pos, 'ID', '');
            pushState();
            outer.state = 8 // id
        }
        else if is_match(c, '[0-9]') {
            // addBuf(c);
            if curr
                outer.s_curr += [curr];
            outer.curr = Token(pos, 'Int', '');
            pushState();
            outer.state = 9 // int, 10 = float
        }
        // handle simple tokens
        else if hasIndex(signs_l,c2) {
            outer.tokens += [Token(pos, signs_l[c2])];
            outer.pos+=2
        }
        else if hasIndex(signs_s,c) {
            outer.tokens += [Token(pos, signs_s[c])];
            outer.pos++
        }
        else {
            print("HERE!!! "+pos+", c = "+c+", c2 = "+c2);
            outer.tokens += [Token(pos, 'Unknown', c)];
            outer.pos++
        }
    };

    handleEsc() = {
        if pos+1 >= src_l return null;
        c = src[pos+1];
        if c == 'n' {
            outer.pos+=2;
            return '\n'
        }
        else if c == 't' {
            outer.pos+=2;
            return char(9)
        }
        else if c == 'r' {
            outer.pos+=2;
            return char(13)
        }
        else if c == 'u' {
            if pos+6 >= src_l return null;
            c = src[pos+2:pos+6];
            outer.pos+=6;
            return char(val(c))
        }
        else if c == 'x' {
            if pos+4 >= src_l return null;
            c = src[pos+2:pos+4];
            // TODO
            outer.pos+=4;
            return '\\xPLACEHOLDER'
        }
        else {
            outer.pos+=2;
            return c
        }
    };

    lexer.lex(input) = {
        outer.src+=input;
        outer.src_l=len(outer.src);

        while pos <= src_l {
            if pos < src_l {
                c = src[pos];
                c2 = src[pos:pos+2]
            } else {
                c = null;
                c2 = null
            };
            /*print("loop");
            print("state: "+state+" s_state: "+s_state);
            print("tokens: "+tokens+" s_tokens: "+s_tokens);
            print("token: "+curr+" s_token: "+s_curr);
            print("pos: "+pos+", c: "+c+", c2: "+c2);
            //user_input("press enter to continue");
            print()*/

            if state == 0 {
                if pos >= src_l break;
                handleDefState(c,c2)
            } // DEFAULT STATE

            else if state == 11 {
                if pos >= src_l break;
                if c2 == '*/' {
                    popState();
                    outer.pos++
                };
                outer.pos++
            } // MULTILINE COMMENT

            else if state == 1 {
                if pos >= src_l break;
                if c == ')' {
                    outer.tokens += [Token(pos, 'RParen')];
                    popState();
                    outer.pos++
                } else
                    handleDefState(c,c2)
            } // PAREN

            else if state == 2 {
                if pos >= src_l break;
                if c == '}' {
                    outer.tokens += [Token(pos, 'RCurly')];
                    popState();
                    outer.pos++
                } else
                    handleDefState(c,c2)
            } // CURLY

            else if state == 3 {
                if pos >= src_l break;
                if c == ']' {
                    outer.tokens += [Token(pos, 'RSquare')];
                    popState();
                    outer.pos++
                } else
                    handleDefState(c,c2)
            } // SQUARE

            else if state == 4 {
                if pos >= src_l break;
                if c == "'" {
                    outer.tokens += [outer.curr];
                    outer.curr = null;
                    if outer.s_curr != [] {
                        outer.curr = s_curr[-1];
                        outer.s_curr = s_curr[:-1]
                    };
                    popState();
                    outer.pos++
                }
                else if c == '\\' {
                    c = handleEsc();
                    if c == null break;
                    outer.curr.value += c;
                } else {
                    outer.curr.value += c;
                    outer.pos++
                }
            } // SQUOTE

            else if state == 5 {
                if pos >= src_l break;
                if c == '"' {
                    outer.tokens += [outer.curr];
                    outer.curr = null;
                    if outer.s_curr != [] {
                        outer.curr = s_curr[-1];
                        outer.s_curr = s_curr[:-1]
                    };
                    popState();
                    outer.pos++
                }
                else if c == '\\' {
                    c = handleEsc();
                    if c == null break;
                    outer.curr.value += c;
                } else {
                    outer.curr.value += c;
                    outer.pos++
                }
            } // DQUOTE

            else if state == 6 {
                if pos >= src_l break;
                if c == "'" {
                    outer.tokens += [outer.curr];
                    outer.curr = null;
                    if outer.s_curr != [] {
                        outer.curr = s_curr[-1];
                        outer.s_curr = s_curr[:-1]
                    };
                    popState();
                    outer.pos++
                }
                else if c2 == '${' {
                    pushState();
                    outer.state = 7; // 7 = formatter

                    // outer.tokens should always be initialized
                    outer.s_tokens += [outer.tokens];
                    outer.tokens = [];

                    outer.curr.value += [TokenPart(pos, 'Formatter')];

                    outer.pos += 2
                }
                else if c == '\\' {
                    c = handleEsc();
                    if c == null break;
                    outer.curr.value += c;
                } else {
                    if curr.value == [] or curr.value[-1].type != 'Chars'
                        curr.value += [TokenPart(pos, 'Chars', '')];
                    curr.value[-1].value += c;
                    outer.pos++
                }
            } // F-STRING

            else if state == 7 {
                if pos >= src_l break;
                if c == '}' {
                    popState();

                    curr.value[-1].value = outer.tokens;

                    outer.tokens = [];
                    if outer.s_tokens != [] {
                        outer.tokens = s_tokens[-1];
                        outer.s_tokens = s_tokens[:-1]
                    };

                    outer.pos++
                }
                else
                    handleDefState(c,c2)
            } // FORMATTER

            else if state == 8 {
                if pos >= src_l || !is_match(c,'[a-zA-Z0-9_]') {
                    popState();

                    ls = lower(curr.value);

                    if ls == 'null' {
                        curr.type='Null';
                        curr.value = null
                    }
                    else if ls == 'true' {
                        curr.type='Bool';
                        curr.value = 1
                    }
                    else if ls == 'false' {
                        curr.type='Bool';
                        curr.value = 0
                    }
                    else if hasIndex(kws,ls)
                        curr.type=kws[ls];
                    outer.tokens += [curr];

                    outer.curr = null;
                    if outer.s_curr != [] {
                        outer.curr = s_curr[-1];
                        outer.s_curr = s_curr[:-1]
                    }
                } else {
                    curr.value+=c;
                    outer.pos++
                }
            } // ID

            else if state == 9 {
                if c == '.' {
                    outer.state=10;
                    curr.value+='.';
                    outer.pos++
                }
                else if pos >= src_l || !is_match(c,'[0-9]') {
                    popState();

                    curr.value = val(curr.value);

                    outer.tokens += [curr];

                    outer.curr = null;
                    if outer.s_curr != [] {
                        outer.curr = s_curr[-1];
                        outer.s_curr = s_curr[:-1]
                    }
                }
                else {
                    curr.value+=c;
                    outer.pos++
                }
            } // INT

            else if state == 10 {
                if pos >= src_l || !is_match(c, '[0-9]') {
                    popState();

                    curr.value = val(curr.value);

                    outer.tokens += [curr];

                    outer.curr = null;
                    if outer.s_curr != [] {
                        outer.curr = s_curr[-1];
                        outer.s_curr = s_curr[:-1]
                    }
                }
                else {
                    curr.value+=c;
                    outer.pos++
                }
            } // FLOAT
        };

        while s_state != [] && s_state[-1] == 0 popState(); //outer.s_state = s_state[:-1];
        if s_state!=[] return 0 else return outer.tokens
    };

    return lexer
};