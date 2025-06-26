/*/ -=-= LuckyScript Lexer =-=-
            It's Real!
    0.2.0
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
    '@': 'Pointer',//'Ptr'
    '(': 'LParen',
    ')': 'RParen',
    '{': 'LCurly',
    '}': 'RCurly',
    '[': 'LSquare',
    ']': 'RSquare'
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

    // frame stack
    Frame(state) =
        return {
            'state': state,
            'buffer': '',
            'tokens': [],
            'token': null,
            'parts': [],
            'pos': 0
        };
    s_frame = [];
    frame = Frame(0);
    root_frame = frame;

    pushFrame(state) = {
        outer.s_frame += [outer.frame];
        outer.frame = outer.Frame(state);
        frame.pos = pos
    };

    popFrame() = {
        if s_frame == []
            outer.frame = root_frame
        else {
            outer.frame = s_frame[-1];
            outer.s_frame = s_frame[:-1]
        }
    };

    ws=outer.ws;
    kws=outer.kws;
    signs_s=outer.signs_s;
    signs_l=outer.signs_l;

    lexer.reset() = {
        outer.src = '';
        outer.src_l = 0;
        outer.pos = 0;
        outer.s_frame = [];
        outer.frame = Frame(0);
        outer.root_frame = outer.frame;
        return outer.lexer
    };

    lexer.done() =
        return frame.state == 0 && pos>=src_l;

    handleDefState(c,c2) = {
        // prelim skip ws
        if indexOf(ws,c)!=null {
            while pos < src_l && indexOf(ws,src[pos])!=null
                outer.pos++
        }
        // skip comments
        else if c2 == '//' {
            outer.pos+=2;
            while pos < src_l && src[pos] != '\n'
                outer.pos++;
            if pos >= src_l return;
            outer.pos++
        }
        else if c2 == '/*' {
            pushFrame(1); // multiline comment
            outer.pos+=2;
            while pos < src_l && src[pos:pos+2] != '*/'
                outer.pos++;
            if pos >= src_l return;
            popFrame();
            outer.pos+=2
        }
        // handle state starters
        else if c == "'" {
            pushFrame(2); // string squote
            outer.pos++;
            if pos >= src_l return;
            c = src[pos];
            while pos < src_l && c != "'" {
                if c == '\\' {
                    c = handleEsc();
                    if c == null break
                } else
                    outer.pos++;
                frame.buffer += c;
                if pos < src_l c = src[pos]
            };
            if c != "'" || pos >= src_l return;
            token = Token(frame.pos, 'String', frame.buffer);
            popFrame();
            frame.tokens += [token];
            outer.pos++
        }
        else if c == '"' {
            pushFrame(3); // string dquote
            outer.pos++;
            if pos >= src_l return;
            c = src[pos];
            while pos < src_l && c != '"' {
                if c == '\\' {
                    c = handleEsc();
                    if c == null break
                } else
                    outer.pos++;
                frame.buffer += c;
                if pos < src_l c = src[pos]
            };
            if c != '"' || pos >= src_l return;
            token = Token(frame.pos, 'String', frame.buffer);
            popFrame();
            frame.tokens += [token];
            outer.pos++
        }
        /*else if c2 == "f'" {
            pushFrame(4); // f-string, 5 = formatter
            outer.pos+=2
        }*/
        else if indexOf('abcdefghijklmnopqrstuvwxyz_',lower(c))!=null {
            sp = pos;
            while pos < src_l && indexOf('abcdefghijklmnopqrstuvwxyz0123456789_',lower(src[pos]))!=null
                outer.pos++;
            buffer = src[sp:pos];
            ls = lower(buffer);

            if ls == 'null'
                frame.tokens += [Token(sp, 'Null')]
            else if ls == 'true'
                frame.tokens += [Token(sp, 'Bool', 1)]
            else if ls == 'false'
                frame.tokens += [Token(sp, 'Bool', 0)]
            else if hasIndex(kws,ls)
                frame.tokens += [Token(sp, kws[ls])]
            else
                frame.tokens += [Token(sp, 'ID', buffer)]
        }
        else if indexOf('0123456789',c)!=null {
            sp = pos;
            d = 0;
            while pos < src_l && indexOf("0123456789.", src[pos])!=null {
                if c == '.' {
                    if d break;
                    d = 1
                };
                outer.pos++
            };
            frame.tokens += [Token(sp, 'Int', val(src[sp:pos]))]
        }
        // handle simple tokens
        else if hasIndex(signs_l,c2) {
            frame.tokens += [Token(pos, signs_l[c2])];
            outer.pos+=2
        }
        else if hasIndex(signs_s,c) {
            frame.tokens += [Token(pos, signs_s[c])];
            outer.pos++
        }
        else {
            frame.tokens += [Token(pos, 'Unknown', c)];
            outer.pos++
        }
    };

    handleEsc() = {
        if pos+1 >= src_l return null;
        c = src[pos+1];
        if c == 'n' {
            outer.pos+=2;
            return char(10)
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

        while pos < src_l {
            c = src[pos];
            c2 = src[pos:pos+2];
            /*print("loop");
            print("frame:\n"+frame);
            print("s_frame:\n"+s_frame);
            print("pos: "+pos+", c: "+c+", c2: "+c2);
            //user_input("press enter to continue");
            print();*/

            if frame.state == 0 {
                handleDefState(c,c2)
            } // DEFAULT STATE

            else if frame.state == 1 {
                while pos < src_l && src[pos:pos+2] != '*/'
                    outer.pos++;
                if pos >= src_l break;
                popFrame();
                outer.pos+=2
            } // MULTILINE COMMENT

            else if frame.state == 2 {
                while pos < src_l && c != "'" {
                    if c == '\\' {
                        c = handleEsc();
                        if c == null break
                    } else
                        outer.pos++;
                    frame.buffer += c;
                    if pos < src_l c = src[pos]
                };
                if c != "'" || pos >= src_l break;
                token = Token(frame.pos, 'String', frame.buffer);
                popFrame();
                frame.tokens += [token];
                outer.pos++
            } // SQUOTE

            else if frame.state == 3 {
                while pos < src_l && c != '"' {
                    if c == '\\' {
                        c = handleEsc();
                        if c == null break
                    } else
                        outer.pos++;
                    frame.buffer += c;
                    if pos < src_l c = src[pos]
                };
                if c != '"' || pos >= src_l break;
                token = Token(frame.pos, 'String', frame.buffer);
                popFrame();
                frame.tokens += [token];
                outer.pos++
            } // DQUOTE

            /*else if frame.state == 4 {
                if pos >= src_l break;
                if c == "'" {
                    token = Token(frame.pos, 'FString', frame.parts);
                    popFrame();
                    frame.tokens += [token];
                    outer.pos++
                }
                else if c2 == '${' {
                    pushFrame(5);
                    outer.pos += 2
                }
                else if c == '\\' {
                    c = handleEsc();
                    if c == null break;
                    frame.buffer += c;
                } else {
                    if frame.parts == [] or frame.parts[-1].type != 'Chars'
                        frame.parts += [TokenPart(pos, 'Chars', '')];
                    frame.parts[-1].value += c;
                    outer.pos++
                }
            } // F-STRING

            else if frame.state == 5 {
                if pos >= src_l break;
                if c == '}' {
                    part = TokenPart(frame.pos, 'Formatter', frame.tokens);

                    popFrame();

                    frame.parts += [part];

                    outer.pos++
                }
                else
                    handleDefState(c,c2)
            } // FORMATTER*/
        };

        while s_frame != [] && frame.state == 0 popFrame();
        if s_frame != [] return 0 else return frame.tokens
    };

    return lexer
};