/*/ -=-= LuckyScript Transpiler =-=-
                Oh boy.
    Placeholder text
/*/

/* -= logic starts here =- */

Transpile(node,ind=0,alt=0)={
    type=node.classID;
    s=char(9)*ind;
    if type=='StateList' {
        s='';
        for child in node.states {
            if __child_idx!=0 s+='\n';
            s+=Transpile(child,ind)
        };
        return s
    } else if type=='IfState' {
        if alt s='';
        s+='if '+Transpile(node.cond,ind+1).trim()+' then';
        if indexOf(['StateList','IfState','WhileState','ForState','ForInState'],node.blk.classID)!=null
        || alt
        || (node.alt
        && indexOf(['StateList','IfState','WhileState','ForState','ForInState'],node.alt.classID)!=null) {
            s+='\n'+Transpile(node.blk,ind+1);
            if node.alt {
                s+='\n'+(char(9)*ind)+'else';
                if node.alt.classID=='IfState' s+=' '+Transpile(node.alt,ind,1) else s+='\n'+Transpile(node.alt,ind+1)
            };
            if !alt s+='\n'+(char(9)*ind)+'end if'
        } else {
            s+=' '+Transpile(node.blk,ind+1).trim();
            if node.alt {
                //if node.alt.classID=='IfState' exit('Transpiler Error: Cannot do a single line if-else if!');
                s+=' else '+Transpile(node.alt,ind+1).trim()
            }
        };
        return s
    } else if type=='ContinueState' {
        return s+'continue'
    } else if type=='BreakState' {
        return s+'break'
    } else if type=='ForState' {
        // continue..
    } else if type=='ForInState' {
        s+='for '+Transpile(node.init,ind+1).trim()+' in '+Transpile(node.array,ind+1).trim();
        s+='\n'+Transpile(node.blk,ind+1);
        return s+'\n'+(char(9)*ind)+'end for'
    } else if type=='WhileState' {
        s+='while '+Transpile(node.cond,ind+1).trim();
        s+='\n'+Transpile(node.blk,ind+1);
        return s+'\n'+(char(9)*ind)+'end while'
    } else if type=='ReturnState' {
        return s+'return '+Transpile(node.val,ind+1).trim()
    } else if type=='NewState' {
        return s+'new '+Transpile(node.object,ind+1).trim()
    } else if type=='Encapsulate' {
        return s+'('+Transpile(node.expr,ind+1).trim()+')'
    } else if type=='BinOp' {
        l=Transpile(node.l,ind+1);
        r=Transpile(node.r,ind+1);
        op=node.op;

        if op=='Assign' && node.l.classID=='Func' {
            name=Transpile(node.l.target,ind+1);
            s+=name+'=function(';
            for arg in node.l.args {
                if __arg_idx!=0 s+=',';
                s+=Transpile(arg,ind+1).trim()
            };
            s+=')'+'\n'+r;
            return s+'\n'+(char(9)*ind)+'end function'
        };
        s+=l;
        if op=='Or' {
            s+=' or '
        } else if op=='And' {
            s+=' and '
        } else if op=='GEqual' {
            s+='>='
        } else if op=='LEqual' {
            s+='<='
        } else if op=='Equal' {
            s+='=='
        } else if op=='NEqual' {
            s+='!='
        } else if op=='Greater' {
            s+='>'
        } else if op=='Lesser' {
            s+='<'
        } else if op=='Plus' {
            s+='+'
        } else if op=='Minus' {
            s+='-'
        } else if op=='Asterisk' {
            s+='*'
        } else if op=='Slash' {
            s+='/'
        } else if op=='Percent' {
            s+='%'
        } else if op=='Exponent' {
            s+='^'
        } else if op=='Assign' {
            s+='='
        } else if op=='Append' {
            s+='='+l+'+'
        } else if op=='AssignMul' {
            s+='='+l+'*'
        } else if op=='AssignDiv' {
            s+='='+l+'/'
        } else if op=='AssignMod' {
            s+='='+l+'%'
        } else if op=='AssignExp' {
            s+='='+l+'^'
        } else if op=='Detach' {
            s+='='+l+'-'
        };
        return s+r.trim()
    } else if type=='UnaryOp' {
        ex=Transpile(node.ex,ind+1).trim();
        op=node.op;
        if op=='Plus' {
            s='+'
        } else if op=='Minus' {
            s='-'
        } else if op=='Not' {
            s='not '
        } else if op=='Pointer' {
            s='@'
        };
        s+=ex;
        if op=='Inc' {
            s+='='+ex+'+1'
        } else if op=='Dec' {
            s+='='+ex+'-1'
        };
        return s
    } else if type=='IndexOp' {
        r=Transpile(node.r,ind+1);
        s=Transpile(node.l,ind+1);
        if node.resolv s+='['+r.trim()+']' else s+='.'+node.r.value;
        return s
    } else if type=='Slice' {
        s+=Transpile(node.target,ind+1)+'[';
        if node.startIdx!=0 s+=Transpile(node.startIdx,ind+1).trim();
        s+=':';
        if node.endIdx!=0 s+=Transpile(node.endIdx,ind+1).trim();
        return s+']'
    } else if type=='Func' {
        s+=Transpile(node.target,ind+1)+'(';
        for arg in node.args {
            if __arg_idx!=0 s+=',';
            s+=Transpile(arg,ind+1).trim()
        };
        return s+')'
    } else if type=='ID' || type=='Type' {
        if node.token.type=='String' return '"'+(node.token.value.replace('"','""'))+'"';
        if node.token.type=='Null' return 'null';
        return str(node.token.value)
    } else if type=='Array' {
        s+='[';
        for child in node.children {
            if __child_idx!=0 s+=',';
            s+=Transpile(child,ind+1).trim()
        };
        return s+']'
    } else if type=='Dict' {
        s+='{';
        for child in node.children {
            if __child_idx!=0 s+=',';
            s+=Transpile(child[0],ind+1).trim()+':'+Transpile(child[1],ind+1).trim();
        };
        return s+'}'
    } else {
        return ''
    }
};
//public.Transpile=@Transpile