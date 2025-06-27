/*/ -=-= LuckyScript Parser =-=-
          Abstract Reality
    0.2.0
/*/

import_code('/root/LuckyScript/lky/lib/ast.map');

/* -= logic starts here =- */

parser_c={};
Parser()={
    parser = new outer.parser_c;
    ast = outer.AST;

    // frames
    Frame(tokens)=
        return {
            'tokens': tokens,
            'len': len(tokens),
            'pos': 0
        };
    s_frame = [];
    frame = null;
    root_frame = null;

    pushFrame(tokens)={
        outer.s_frame+=[frame];
        outer.frame = Frame(tokens);
    };

    popFrame()=
        if s_frame==[]
            outer.frame=root_frame
        else {
            outer.frame=s_frame[-1];
            outer.s_frame=s_frame[:-1]
        };

    advance()=
        if frame.pos < frame.len {
            frame.pos++;
            return 1
        } else
            return Bail();
    
    expect(types)={
        if frame.pos >= frame.len return advance();
        tok = frame.tokens[frame.pos];
        tt = tok.type;

        if types[1:]==[] {
            type = types[-1];
            if tt != type
                return Syn(tok, type)
        } else {
            if indexOf(types,tt)==null
                return Syn(tok, 'any of '+join(types,', '))
        };
        advance();
        return tok
    };

    parser.error = null;

    Err(msg='Unknown Error', firstToken, lastToken)=
        parser.error = {
            'msg': msg,
            'first': firstToken,
            'last': lastToken
        };

    Bail()={
        if frame.tokens == [] token=null else token=frame.tokens[-1];
        Err('Unexpected end of input', token, token)
    };
    
    Syn(token, expected)=
        Err('Syntax error: Got '+token.type+', expected '+expected, token, token);

    parsers={};

    parsers.statelist()={
        states=[];
        while frame.pos < frame.len {
            while frame.pos < frame.len && frame.tokens[frame.pos].type=='Semi'
                advance();
            if frame.pos >= frame.len break;
            node = parsers.state();
            if !node return;
            states+=[node]
        };

        return ast.StateList(states)
    };

    parsers.state()={
        tt=frame.tokens[frame.pos].type;
        if tt=='KW.if'
            node = parsers.ifstate()
        else if tt=='KW.for'
            node = parsers.forstate()
        else if tt=='KW.while'
            node = parsers.whilestate()
        else if tt=='KW.return'
            node = parsers.returnstate()
        else if tt=='KW.continue' {
            advance();
            return ast.ContinueState()
        }
        else if tt=='KW.break' {
            advance();
            return ast.BreakState()
        }
        else
            node = parsers.assign();
        return node
    };

    parsers.ifstate()={
        advance();
        cond=parsers.assign();
        if !cond return;

        if frame.pos >= frame.len return Bail();
        if frame.tokens[frame.pos].type=='LCurly'
            blk = parsers.block()
        else
            blk = parsers.state();
        if !blk return;

        alt=null;
        if frame.pos < frame.len && frame.tokens[frame.pos].type=='KW.else' {
            advance();
            if frame.pos >= frame.len return Bail();

            if frame.tokens[frame.pos].type=='KW.if'
                alt = parsers.ifstate()
            else if frame.tokens[frame.pos].type=='LCurly'
                alt = parsers.block()
            else
                alt = parsers.state();
            if !alt return;
        };

        return ast.IfState(cond, blk, alt)
    };

    parsers.block()={
        expect(['LCurly']);

        states=[];
        while frame.pos < frame.len && frame.tokens[frame.pos].type!='RCurly' {
            while frame.pos < frame.len && frame.tokens[frame.pos].type=='Semi'
                advance();
            if frame.pos >= frame.len break;
            node=parsers.state();
            if !node return;
            states+=[node]
        };

        if expect(['RCurly']) return ast.StateList(states) else return
    };

    parsers.forstate()={
        advance();

        //init=parsers.id(); // swap to tuple eventually
        //if !init return;
        tok=expect(['ID']);
        if !tok return;
        init=ast.ID(tok);

        if frame.pos >= frame.len return Bail();
        if !expect(['KW.in']) return;

        item=parsers.condition(); // swap to tuple eventually
        if !item return;

        if frame.pos >= frame.len return Bail();
        if frame.tokens[frame.pos].type == 'LCurly'
            blk = parsers.block()
        else
            blk = parsers.state();
        if blk return ast.ForInState(init, item, blk) else return
    };

    parsers.whilestate()={
        advance();

        cond = parsers.condition(); // swap to tuple eventually?
        if !cond return;

        if frame.pos >= frame.len return Bail();
        if frame.tokens[frame.pos].type=='LCurly'
            blk = parsers.block()
        else
            blk = parsers.state();
        if blk return ast.WhileState(cond,blk) else return
    };

    parsers.returnstate()={
        advance();

        val = parsers.condition();
        if !val return;

        return ast.ReturnState(val)
    };

    parsers._expr(ops,f)={
        node=f();
        if !node return;

        while frame.pos < frame.len {
            op = frame.tokens[frame.pos].type;
            if indexOf(ops, op)==null break;
            advance();
            ex=f();
            if !ex return;
            node = ast.BinOp(node,op,ex)
        };

        return node
    };

    parsers.assign()={
        node=parsers.condition();
        if !node return;

        if frame.pos < frame.len && indexOf([
            'Assign',
            'Append',
            'AssignMul',
            'AssignDiv',
            'AssignMod',
            'AssignExp',
            'Detach'
        ],frame.tokens[frame.pos].type)!=null {
            op=frame.tokens[frame.pos];
            advance();

            if frame.pos >= frame.len return Bail();
            if node.classID=='FuncAssign' {
                if op.type!='Assign' return Syn(op, 'Assign');
                if frame.tokens[frame.pos].type=='LCurly'
                    blk=parsers.block()
                else
                    blk=parsers.state();
                if blk return ast.BinOp(node,op.type,blk) else return
            } else {
                r=parsers.condition(); // replace with parsers.tuple();
                if r return ast.BinOp(node,op.type,r) else return
            }
        } else return node
    };

    /*/
        TODO parser.tuple()={};
        && replace instances of parsers.condition();
        with parsers.tuple();
    /*/

    parsers.condition()=return parsers._expr([
        'And',
        'Or'
    ], parsers['comparison']);

    parsers.comparison()=return parsers._expr([
        'GEqual',
        'LEqual',
        'Equal',
        'NEqual',
        'Greater',
        'Lesser'
    ], parsers['expression']);

    parsers.expression()=return parsers._expr([
        'Plus',
        'Minus'
    ], parsers['term']);

    parsers.term()=return parsers._expr([
        'Mul',
        'Div',
        'Mod'
    ], parsers['exponent']);

    parsers.exponent()=return parsers._expr([
        'Exp'
    ], parsers['unary']);

    parsers.unary()={
        if frame.pos < frame.len && indexOf([
            'Plus',
            'Minus',
            'Not',
            'Inc',
            'Dec',
            'Ptr'
        ],frame.tokens[frame.pos].type)!=null {
            op=frame.tokens[frame.pos].type;
            advance();
            node = parsers.unary();
            if !node return;
            return ast.UnaryOp(op,node)
        };

        node = parsers.newstate();
        if !node return;

        if frame.pos < frame.len && indexOf(['Inc', 'Dec'],frame.tokens[frame.pos].type)!=null {
            node = ast.UnaryOp(frame.tokens[frame.pos].type,node);
            advance()
        };
        return node
    };

    parsers.newstate()={
        if frame.tokens[frame.pos].type=='KW.new' {
            advance();
            node = parsers.varops();
            if node return ast.NewState(node) else return;
        } else
            return parsers.varops()
    };

    parsers.varops()={
        node = parsers.factor();
        if !node return;

        while frame.pos < frame.len
        && indexOf(['Dot', 'LSquare', 'LParen'], frame.tokens[frame.pos].type)!=null {
            
            if frame.tokens[frame.pos].type=='Dot' {
                advance();
                tok = expect(['ID']);
                if !tok return;
                node = ast.IndexOp(node,0,tok)
            } else if frame.tokens[frame.pos].type=='LSquare' {
                advance();
                startIdx=null;
                endIdx=null;
                if frame.pos < frame.len && frame.tokens[frame.pos].type=='Colon' {
                    advance();
                    startIdx=0;
                    endIdx=parsers.condition();
                    if !endIdx return
                } else {
                    startIdx=parsers.condition();
                    if !startIdx return;
                    if frame.pos < frame.len && frame.tokens[frame.pos].type=='Colon' {
                        advance();
                        endIdx=0;
                        if frame.pos < frame.len && frame.tokens[frame.pos].type!='RSquare' {
                            endIdx=parsers.condition();
                            if !endIdx return;
                        }
                    }
                };
                if !expect(['RSquare']) return;
                if endIdx==null
                    node=ast.IndexOp(node,1,startIdx)
                else
                    node=ast.Slice(node,startIdx,endIdx)
            } else if frame.tokens[frame.pos].type=='LParen' {
                advance();
                lookAheadPos = frame.pos;
                nest = 0;
                while lookAheadPos < frame.len {
                    if frame.tokens[lookAheadPos].type == 'LParen'
                        nest++
                    else if frame.tokens[lookAheadPos].type == 'RParen'
                        if nest == 0
                            break
                        else
                            nest--;
                    lookAheadPos++
                };
                if lookAheadPos >= frame.len return Bail();
                args=[];
                if lookAheadPos+1 >= frame.len || frame.tokens[lookAheadPos+1].type != 'Assign' {
                    parsefn = parsers['condition'];
                    astfn = ast['Func']
                } else {
                    parsefn = parsers['constructor'];
                    astfn = ast['FuncAssign']
                };

                while frame.pos < frame.len && frame.tokens[frame.pos].type!='RParen' {
                    arg = parsefn();
                    if arg args += [arg] else return;
                    if frame.pos >= frame.len return Bail();
                    if indexOf(['Comma','RParen'],frame.tokens[frame.pos].type)==null break; //!expect(['Comma', 'RParen']) return
                    if frame.tokens[frame.pos].type=='Comma' advance();
                };

                if !expect(['RParen']) return; //type!='RParen' return Bail();
                node = astfn(node,args)
            }
        };

        return node
    };

    /*/
        parsers.tuple() here?
    /*/

    parsers.constructor()={
        tok = expect(['ID']);
        if !tok return;
        node = ast.ID(tok);
        if frame.pos < frame.len && frame.tokens[frame.pos].type == 'Assign' {
            advance();
            if frame.pos >= frame.len return Bail();
            rhs = parsers.condition();
            if rhs return ast.Constructor(node, rhs) else return
        } else return node
    };

    parsers.factor()={
        if frame.pos < frame.len && frame.tokens[frame.pos].type=='LParen' {
            advance();
            node = parsers.condition(); // replace with parsers.tuple();
            if !node return;

            if !expect(['RParen']) return;
            return ast.Cap(node)
        } else
            return parsers.primary()
    };

    parsers.primary()={
        if frame.pos >= frame.len return Bail();

        tok = frame.tokens[frame.pos];
        if tok.type=='ID'
            return ast.ID(expect(['ID']))
        else if indexOf(['Null', 'Bool', 'String', 'Int'],tok.type)!=null
            return ast.Type(expect([tok.type]))
        else if tok.type=='FString' {
            advance();
            elems=[];
            exprs=[];
            for part in tok.value
                if part.type == 'Chars'
                    elems+=[part.value]
                else if part.type == 'Formatter' {
                    pushFrame(part.value);
                    node=parsers.condition(); // replace with parser.tuple();
                    if node exprs+=[node] else return;
                    popFrame();
                };
            return ast.FString(elems,exprs)
        }
        else if tok.type=='LSquare' {
            advance();

            if frame.pos >= frame.len return Bail();

            type = frame.tokens[frame.pos].type;
            parts=[];
            while frame.pos < frame.len && frame.tokens[frame.pos].type!='RSquare' {
                part = parsers.condition();
                if part parts+=[part] else return;
                if frame.pos >= frame.len return Bail();
                if indexOf(['Comma','RSquare'],frame.tokens[frame.pos].type)==null break; //!expect(['Comma', 'RSquare']) return
                if frame.tokens[frame.pos].type=='Comma' advance()
            };

            if !expect(['RSquare']) return; //type!='RSquare' return Bail();
            return ast.Array(parts)
        }
        else if tok.type=='LCurly' {
            advance();

            if frame.pos >= frame.len return Bail();

            parts=[];
            while frame.pos < frame.len && frame.tokens[frame.pos].type!='RCurly' {
                lhs = parsers.condition();
                if !lhs return;

                if !expect(['Colon']) return;

                rhs = parsers.condition();
                if !rhs return;

                if frame.pos >= frame.len return Bail();
                if indexOf(['Comma','RCurly'],frame.tokens[frame.pos].type)==null break; //!expect(['Comma', 'RCurly']) return;
                if frame.tokens[frame.pos].type=='Comma' advance();
                parts += [{'key': lhs, 'value': rhs}]
            };

            if !expect(['RCurly']) return; //type!='RCurly' return Bail();
            return ast.Dict(parts)
        }
        else
            return ast.NoOp()
    };

    parser.parse(tokens)={
        outer.s_frame = [];
        outer.frame = Frame(tokens);
        outer.root_frame = frame;
        parser.error=null;

        return parsers.statelist()
    };

    return parser
};