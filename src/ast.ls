/*/ -=-= LuckyScript AST =-=-
          Plant A Seed
    Placeholder text
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
    node._print(i=0) = return (' '*i)+node.classID+':'
        + '\n'+node.cond._print(i+2)
        + '\n'+node.blk._print(i+2)
        + '\n'+node.alt._print();
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

AST.NewState(object)={
    node = new outer.ast_t;
    node.classID='NewState';
    node.object=object;
    node._print(i=0) = return (' '*i)+node.classID+':'
        + '\n'+node.object._print(i+2);
    return node
};

AST.ForState()={
    node = new outer.ast_t;
    node.classID='ForState';
    node._print(i=0) = return (' '*i)+node.classID+':';
    return node
};
AST.ForInState(init,array,blk)={
    node = new outer.ast_t;
    node.classID='ForInState';
    node.init=init;
    node.array=array;
    node.blk=blk;
    node._print(i=0) = return (' '*i)+node.classID+':'
        + '\n'+node.init._print(i+2)
        + '\n'+node.array._print(i+2)
        + '\n'+node.blk._print(i+2);
    return node
};
AST.WhileState(cond,blk)={
    node = new outer.ast_t;
    node.classID='WhileState';
    node.cond=cond;
    node.blk=blk;
    node._print(i=0) = return (' '*i)+node.classID+':'
        + '\n'+node.cond._print(i+2)
        + '\n'+node.blk._print(i+2);
    return node
};

AST.ReturnState(val)={
    node = new outer.ast_t;
    node.classID='ReturnState';
    node.val=val;
    node._print(i=0) = return (' '*i)+node.classID+':'
        + '\n'+node.val._print(i+2);
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
    node._print(i=0) = return (' '*i)+node.classID+':'+node.op
        + '\n'+node.l._print(i+2)
        + '\n'+node.r._print(i+2);
    return node
};
AST.UnaryOp(op,ex)={
    node = new outer.ast_t;
    node.classID='UnaryOp';
    node.op=op;
    node.ex=ex;
    node._print(i=0) = return (' '*i)+node.classID+':'+node.op
        + '\n'+node.ex._print(i+2);
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
            + '\n'+node.l._print(i+2);
        if node.r.classID=='Token' s+='\n'+(' '*i)+node.r.value
            else s+='\n'+node.r._print(i+2);
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
            + '\n'+node.target._print(i+2);
        if typeof(node.startIdx)=='number' s+='\n'+(' '*i+2)+node.startIdx
            else s+='\n'+node.startIdx._print(i+2);
        if typeof(node.endIdx)=='number' s+='\n'+(' '*i+2)+node.endIdx
            else s+='\n'+node.endIdx._print(i+2);
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
            + '\n'+node.target._print(i+2);
        for arg in node.args s+='\n'+arg._print(i+2);
        return s
    };
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
    node._print(i=0) = return (' '*i)+node.token.type+':'+node.token.value;
    return node
};

AST.Array(children)={
    node = new outer.ast_t;
    node.classID='Array';
    node.children=children;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for child in node.children s+='\n'+child._print(i+2);
        return s
    };
    return node
};

AST.Dict(children)={
    node = new outer.ast_t;
    node.classID='Dict';
    node.children=children;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for child in node.children s+='\n'+child[0]._print(i+2)
            +':'+'\n'+child[1]._print(i+2);
        return s
    };
    return node
};

AST.Tuple(children)={
    node = new outer.ast_t;
    node.classID='Tuple';
    node.children=children;
    node._print(i=0)={
        s=(' '*i)+node.classID+':';
        for child in node.children s+='\n'+child._print(i+2);
        return s
    };
    return node
}