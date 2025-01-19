/*/ -=-= LuckyScript Parser =-=-
         Abstract Reality
    Placeholder text
/*/

import_code('/root/LuckyScript/lky/lib/ast.map');

/* -= logic starts here =- */

parser_t={};
Parser()={
    parser = new outer.parser_t;
    ast = outer.AST;

    // token handling
    t = null;
    t_l = 0;
    pos = 0;

    err(msg='Unknown error',pos)=
        return {'err':msg, 'value':0, 'pos':pos};

    ok(value)=
        return {'err':0, 'value':value};

    bail()={
        outer.parser.errpos=t[-1].pos;
        return outer.err('Out of tokens.')
    };

    syn(p,ttype,expected)={
        outer.parser.errpos=p;
        return outer.err('Invalid syntax: Got '+ttype+', expected '+expected)
    };

    parsers={};

    parsers.statelist()={
        states=[];
        while t_l>pos {
            if t[pos].type=='Semi' {
                outer.pos++;
                continue
            };
            child=outer.parsers.state();
            if child.err return child else push(states,child.value);
            if t_l>pos && t[pos].type!='Semi' return outer.syn(t[pos].pos,t[pos].type,'Semi')
        };

        if states[1:]==[] return outer.ok(states[0])
            else return outer.ok(outer.ast.StateList(states))
    };

    parsers.state()={
        token=t[pos].type;
        if token=='KW.if' {
            node=outer.parsers.ifstate()
        } else if token=='KW.for' {
            node=outer.parsers.forstate()
        } else if token=='KW.while' {
            node=outer.parsers.whilestate()
        } else if token=='KW.return' {
            node=outer.parsers.returnstate()
        } else if token=='KW.continue' {
            outer.pos++;
            return outer.ok(outer.ast.ContinueState())
        } else if token=='KW.break' {
            outer.pos++;
            return outer.ok(outer.ast.BreakState())
        } else {
            node=outer.parsers.condition()
        };
        return node
    };

    parsers.ifstate()={
        outer.pos++;
        cond=outer.parsers.condition();
        if cond.err return cond;

        if t_l<=pos return outer.bail();
        if t[pos].type=='LCurly' 
            blk=outer.parsers.block()
            else blk=outer.parsers.state();
        if blk.err return blk;

        alt=null;
        if t_l>pos && t[pos].type=='KW.else' {
            outer.pos++;
            if t_l<=pos return outer.bail();

            if t[pos].type=='KW.if' {
                alt=outer.parsers.ifstate()
            } else if t[pos].type=='LCurly' {
                alt=outer.parsers.block()
            } else {
                alt=outer.parsers.state()
            };
            if alt.err return alt;
            alt=alt.value
        };
        return outer.ok(outer.ast.IfState(cond.value,blk.value,alt))
    };

    parsers.block()={
        if t_l<=pos return outer.bail();
        if t[pos].type!='LCurly' return outer.syn(t[pos].pos,t[pos].type,'LCurly');
        outer.pos++;

        states=[];
        while t_l>pos && t[pos].type!='RCurly' {
            if t[pos].type=='Semi' {
                outer.pos++;
                continue
            };
            child=outer.parsers.state();
            if child.err return child else push(states,child.value);
            if pos<t_l && indexOf(['Semi','RCurly'],t[pos].type)==null
                return outer.syn(t[pos].pos,t[pos].type,'RCurly or Semi')
        };

        if t_l<=pos return outer.bail();
        if t[pos].type!='RCurly' return outer.syn(t[pos].pos,t[pos].type,'RCurly');
        outer.pos++;

        return outer.ok(outer.ast.StateList(states))
    };

    parsers.forstate()={
        outer.pos++;

        init=outer.parsers.condition();
        if init.err return init;

        if t_l<=pos return outer.bail();
        if t[pos].type!='KW.in' return outer.syn(t[pos].pos,t[pos].type,'KW.in');
        outer.pos++;

        array=outer.parsers.condition();
        if array.err return array;

        if t_l<=pos return outer.bail();
        if t[pos].type=='LCurly'
            blk=outer.parsers.block()
            else blk=outer.parsers.state();
        if blk.err return blk;

        return outer.ok(outer.ast.ForInState(init.value,array.value,blk.value))
    };

    parsers.whilestate()={
        outer.pos++;

        cond=outer.parsers.condition();
        if cond.err return cond;

        if t_l<=pos return outer.bail();
        if t[pos].type=='LCurly'
            blk=outer.parsers.block()
            else blk=outer.parsers.state();
        if blk.err return blk;
        
        return outer.ok(outer.ast.WhileState(cond.value,blk.value))
    };

    parsers.returnstate()={
        outer.pos++;

        val=outer.parsers.condition();
        if val.err return val;

        return outer.ok(outer.ast.ReturnState(val.value))
    };

    parsers._expr(ops,f)={
        node=f();
        if node.err return node;
        node=node.value;

        while t_l>pos {
            op=t[pos].type;
            if indexOf(ops,op)==null break;
            outer.pos++;
            ex=f();
            if ex.err return ex;
            node=outer.ast.BinOp(node,op,ex.value)
        };

        return outer.ok(node)
    };

    /*/
        TODO parser.tuple()={}
        && replace instances of outer.parsers.condition()
        with outer.parsers.tuple()
    /*/

    parsers.condition()=return outer.parsers._expr([
        'And',
        'Or'
    ],outer.parsers['comparison']);

    parsers.comparison()=return outer.parsers._expr([
        'GEqual',
        'LEqual',
        'Equal',
        'NEqual',
        'Greater',
        'Lesser'
    ],outer.parsers['expression']);

    parsers.expression()=return outer.parsers._expr([
        'Plus',
        'Minus'
    ],outer.parsers['term']);
    
    parsers.term()=return outer.parsers._expr([
        'Asterisk',
        'Slash',
        'Percent'
    ],outer.parsers['exponent']);

    parsers.exponent()=return outer.parsers._expr([
        'Exponent'
    ],outer.parsers['assignment']);

    parsers.assignment()={
        node=outer.parsers.unary();
        if node.err return node;
        node=node.value;

        if t_l>pos && indexOf([
            'Assign',
            'Append',
            'AssignMul',
            'AssignDiv',
            'AssignMod',
            'AssignExp',
            'Detach'
        ],t[pos].type)!=null {
            op=t[pos].type;
            outer.pos++;

            if t_l<=pos return outer.bail();
            if node.classID=='Func' {
                if op!='Assign' return outer.syn(t[pos].pos,t[pos].type,'Assign');
                if t_l<=pos return outer.bail();
                if t[pos].type=='LCurly'
                    blk=outer.parsers.block()
                    else blk=outer.parsers.state();
                if blk.err return blk;
                node=outer.ast.BinOp(node,op,blk.value)
            } else {
                r=outer.parsers.condition();
                if r.err return r;
                node=outer.ast.BinOp(node,op,r.value)
            }
        };

        return outer.ok(node)
    };

    /*/
        TODO parser.pointerops()
        check @ as pointer, backtrack and try as func decl
        something like that ig
    /*/

    parsers.unary()={
        if t_l>pos && indexOf([
            'Plus',
            'Minus',
            'Not',
            'Inc',
            'Dec',
            'Pointer'
        ],t[pos].type)!=null {
            op=t[pos].type;
            outer.pos++;
            node=outer.parsers.unary();
            if node.err return node;
            return outer.ok(outer.ast.UnaryOp(op,node.value))
        };

        node=outer.parsers.newstate();
        if node.err return node;
        node=node.value;

        if t_l>pos && indexOf(['Inc','Dec'],t[pos].type)!=null {
            node=outer.ast.UnaryOp(t[pos].type,node);
            outer.pos++
        };
        return outer.ok(node)
    };

    parsers.newstate()={
        type=t[pos].type;
        if type=='KW.new'
            outer.pos++;
        node=outer.parsers.varops();
        if node.err return node;
        if type=='KW.new'
            return outer.ok(outer.ast.NewState(node.value))
            else return node;
    };

    parsers.varops()={
        node=outer.parsers.factor();
        if node.err return node;
        node=node.value;

        while t_l>pos {
            op=t[pos].type;
            if indexOf(['Dot','LSquare','LParen'],op)==null break;
            outer.pos++;

            if op=='Dot' {
                if t_l<=pos return outer.bail();
                if t[pos].type!='ID' return outer.syn(t[pos].pos,t[pos].type,'ID');
                node=outer.ast.IndexOp(node,0,t[pos]);
                outer.pos++
            } else if op=='LSquare' {
                startIdx=null;
                endIdx=null;
                if t_l>pos && t[pos].type=='Colon' {
                    outer.pos++;
                    startIdx=0;
                    endIdx=outer.parsers.condition();
                    if endIdx.err return endIdx;
                    endIdx=endIdx.value
                } else {
                    startIdx=outer.parsers.condition();
                    if startIdx.err return startIdx;
                    startIdx=startIdx.value;
                    if t_l>pos && t[pos].type=='Colon' {
                        outer.pos++;
                        endIdx=0;
                        if t_l>pos && t[pos].type!='RSquare' {
                            endIdx=outer.parsers.condition();
                            if endIdx.err return endIdx;
                            endIdx=endIdx.value
                        }
                    }
                };
                if t_l<=pos return outer.bail();
                if t[pos].type!='RSquare' return outer.syn(t[pos].pos,t[pos].type,'RSquare');
                outer.pos++;
                if endIdx==null node=outer.ast.IndexOp(node,1,startIdx)
                    else node=outer.ast.Slice(node,startIdx,endIdx)
            } else if op=='LParen' {
                args=[];
                while t_l>pos && t[pos].type!='RParen' {
                    arg=outer.parsers.condition();
                    if arg.err return arg else push(args,arg.value);
                    if t_l<=pos return outer.bail();
                    if indexOf(['Comma','RParen'],t[pos].type)==null
                        return outer.syn(t[pos].pos,t[pos].type,'RParen or Comma');
                    if t[pos].type=='Comma' outer.pos++
                };

                if t_l<=pos return outer.bail();
                if t[pos].type!='RParen' return outer.syn(t[pos].pos,t[pos].type,'RParen');
                outer.pos++;
                node=outer.ast.Func(node,args)
            }
        };

        return outer.ok(node)
    };

    parsers.factor()={
        if t_l>pos and t[pos].type=='LParen' {
            outer.pos++;
            node=outer.parsers.condition();
            if node.err return node;

            if t_l<=pos return outer.bail();
            if t[pos].type!='RParen' return outer.syn(t[pos].pos,t[pos].type,'RParen');
            outer.pos++;
            node=outer.ast.Cap(node.value)
        } else {
            node=outer.parsers.primary();
            if node.err return node;
            node=node.value
        };
        return outer.ok(node)
    };

    parsers.primary()={
        if t_l<=pos return outer.bail();

        token=t[pos];
        node=outer.ast.NoOp();
        if token.type=='ID' {
            node=outer.ast.ID(token);
            outer.pos++
        } else if indexOf(['Null','Bool','String','Int'],token.type)!=null {
            node=outer.ast.Type(token);
            outer.pos++
        } else if token.type=='LSquare' {
            outer.pos++;

            children=[];
            while t_l>pos && t[pos].type!='RSquare' {
                child=outer.parsers.condition();
                if child.err return child else push(children,child.value);
                if t_l<=pos return outer.bail();
                if indexOf(['RSquare','Comma'],t[pos].type)==null
                    return outer.syn(t[pos].pos,t[pos].type,'RSquare or Comma');
                if t[pos].type=='Comma' outer.pos++;
            };

            if t_l<=pos return outer.bail();
            if t[pos].type!='RSquare' return outer.syn(t[pos].pos,t[pos].type,'RSquare');
            outer.pos++;
            node=outer.ast.Array(children)
        } else if token.type=='LCurly' {
            outer.pos++;

            children=[];
            while t_l>pos && t[pos].type!='RCurly' {
                left=outer.parsers.condition();
                if left.err return left;

                if t_l<=pos return outer.bail();
                if t[pos].type!='Colon'
                    return outer.syn(t[pos].pos,t[pos].type,'Colon');
                outer.pos++;

                right=outer.parsers.condition();
                if right.err return right else push(children,[left.value,right.value]);
                if t_l<=pos return outer.bail();
                if indexOf(['RCurly','Comma'],t[pos].type)==null
                    return outer.syn(t[pos].pos,t[pos].type,'RCurly or Comma');
                if t[pos].type=='Comma' outer.pos++
            };

            if t_l<=pos return outer.bail();
            if t[pos].type!='RCurly' return outer.syn(t[pos].pos,t[pos].type,'RCurly');
            outer.pos++;
            node=outer.ast.Dict(children)
        };
        return outer.ok(node)
    };

    parser.parse(tokens)={
        outer.t=tokens;
        outer.t_l=len(tokens);
        outer.pos=0;
        return outer.parsers.statelist()
    };

    return parser
};
//public.Parser=@Parser