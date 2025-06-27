/*/ -=-= LuckyScript AST =-=-
          Plant A Seed
    0.2.0
/*/

/* -= logic starts here =- */
ast_t={};

AST={};
AST.StateList(states)={
    node = new outer.ast_t;
    node.classID='StateList';
    node.states=states;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for state in node.states s+='\n'+state._print(i+2);
        return s
    };
    return node
};

AST.IfState(cond,blk,alt)={
    node = new outer.ast_t;
    node.classID='IfState';
    node.cond=cond;
    node.blk=blk;
    node.alt=alt;
    node._print(i=0)={
        s=(' '*i)+node.classID+':'
        +'\n'+node.cond._print(i+2)
        +'\n'+node.blk._print(i+2);
        if node.alt s+='\n'+node.alt._print(i);
        return s
    };
    return node
};

AST.ContinueState()={
    node = new outer.ast_t;
    node.classID='ContinueState';
    node._print(i=0) = return (' '*i)+node.classID;
    return node
};
AST.BreakState()={
    node = new outer.ast_t;
    node.classID='BreakState';
    node._print(i=0) = return (' '*i)+node.classID;
    return node
};

AST.NewState(obj)={
    node = new outer.ast_t;
    node.classID='NewState';
    node.obj=obj;
    node._print(i=0) = return (' '*i)+node.classID+':'
        +'\n'+node.obj._print(i+2);
    return node
};

AST.ForState()={
    node = new outer.ast_t;
    node.classID='ForState';
    node._print(i=0) = return (' '*i)+node.classID+':WIP';
    return node
};
AST.ForInState(init, item, blk)={
    node = new outer.ast_t;
    node.classID='ForInState';
    node.init=init;
    node.item=item;
    node.blk=blk;
    node._print(i=0)=
        return (' '*i)+node.classID+':'
        +'\n'+node.init._print(i+2)
        +'\n'+node.item._print(i+2)
        +'\n'+node.blk._print(i+2);
    return node
};
AST.WhileState(cond,blk)={
    node = new outer.ast_t;
    node.classID='WhileState';
    node.cond=cond;
    node.blk=blk;
    node._print(i=0)=
        return (' '*i)+node.classID+':'
        +'\n'+node.cond._print(i+2)
        +'\n'+node.blk._print(i+2);
    return node
};

AST.ReturnState(val)={
    node = new outer.ast_t;
    node.classID='ReturnState';
    node.val=val;
    node._print(i=0)=
        return (' '*i)+node.classID+':'
        +'\n'+node.val._print(i+2);
    return node
};

AST.Cap(expr)={
    node = new outer.ast_t;
    node.classID='Encapsulate';
    node.expr=expr;
    node._print(i=0) = return (' '*i)+node.classID+':'
        + '\n'+node.expr._print(i+2);
    return node
};
AST.BinOp(l,op,r)={
    node = new outer.ast_t;
    node.classID='BinOp';
    node.l=l;
    node.op=op;
    node.r=r;
    node._print(i=0)=
        return (' '*i)+node.classID+':'+node.op
        +'\n'+node.l._print(i+2)
        +'\n'+node.r._print(i+2);
    return node
};
AST.UnaryOp(op,ex)={
    node = new outer.ast_t;
    node.classID='UnaryOp';
    node.op=op;
    node.ex=ex;
    node._print(i=0)=
        return (' '*i)+node.classID+':'+node.op
        +'\n'+node.ex._print(i+2);
    return node
};
AST.NoOp()={
    node = new outer.ast_t;
    node.classID='NoOp';
    node._print(i=0) = return (' '*i)+node.classID;
    return node
};

AST.IndexOp(l,resolv,r)={
    node = new outer.ast_t;
    node.classID='IndexOp';
    node.l=l;
    node.resolv=resolv;
    node.r=r;
    node._print(i=0)={
        s=(' '*i)+node.classID+':'+node.resolv
        +'\n'+node.l._print(i+2)+'\n';
        if node.r.classID=='Token' s+=(' '*i+2)+node.r.value
        else s+=node.r._print(i+2);
        return s
    };
    return node
};
AST.Slice(target,si,ei)={
    node = new outer.ast_t;
    node.classID='Slice';
    node.target=target;
    node.startIdx=si;
    node.endIdx=ei;
    node._print(i=0)={
        s=(' '*i)+node.classID+':'
        +'\n'+node.target._print(i+2)+'\n';
        if node.startIdx == 0 s+=(' '*i+2)+node.startIdx
        else s+=node.startIdx._print(i+2);
        s+='\n';
        if node.endIdx == 0 s+=(' '*i+2)+node.endIdx
        else s+=node.endIdx._print(i+2);
        return s
    };
    return node
};

AST.Func(target,args)={
    node = new outer.ast_t;
    node.classID='Func';
    node.target=target;
    node.args=args;
    node._print(i=0)={
        s=(' '*i)+node.classID+':'
        +'\n'+node.target._print(i+2);
        for arg in node.args s+='\n'+arg._print(i+2);
        return s
    };
    return node
};
AST.FuncAssign(target,args)={
    node = new outer.ast_t;
    node.classID='FuncAssign';
    node.target=target;
    node.args=args;
    node._print(i=0)={
        s=(' '*i)+node.classID+':'
        +'\n'+node.target._print(i+2);
        for arg in node.args s+='\n'+arg._print(i+2);
        return s
    };
    return node
};
AST.Constructor(id,default)={
    node = new outer.ast_t;
    node.classID='Constructor';
    node.id=id;
    node.default=default;
    node._print(i=0)=
        return (' '*i)+node.classID+':'
        +'\n'+node.id._print(i+2)
        +'\n'+node.default._print(i+2);
    return node
};

AST.ID(id)={
    node = new outer.ast_t;
    node.classID='ID';
    node.token=id;
    node._print(i=0) = return (' '*i)+node.classID+':'+node.token.value;
    return node
};
AST.Type(t)={
    node = new outer.ast_t;
    node.classID='Type';
    node.token=t;
    node._print(i=0) = return (' '*i)+node.classID+':'+node.token.value;
    return node
};
AST.FString(elems,exprs)={
    node = new outer.ast_t;
    node.classID='FString';
    node.elems=elems;
    node.exprs=exprs;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for part in node.elems+node.exprs s+='\n'+part._print(i+2);
        return s
    };
    return node
};
AST.Array(parts)={
    node = new outer.ast_t;
    node.classID='Array';
    node.parts=parts;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for part in node.parts s+='\n'+part._print(i+2);
        return s
    };
    return node
};
AST.Dict(parts)={
    node = new outer.ast_t;
    node.classID='Dict';
    node.parts=parts;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for part in node.parts s+='\n'+part.key._print(i+2)+':\n'+part.value._print(i+2);
        return s
    };
    return node
};
AST.Tuple(parts)={
    node = new outer.ast_t;
    node.classID='Tuple';
    node.parts=parts;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for part in node.parts s+='\n'+part._print(i+2);
        return s
    };
    return node
};