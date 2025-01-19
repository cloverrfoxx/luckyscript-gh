/*/
    LuckyScript CLI
    This is a rough transpiler interface for now.
    Later features will include proper LuckyScript syntax,
    interpreting and REPL
    and then some!
/*/

/* -= logic starts here =- */

import_code('/root/LuckyScript/argparse/argparse.so');
import_code('/root/foxlib/logger.so');
logger=Logger;
//public={};
import_code('/root/LuckyScript/lky/lib/lexer.so');
import_code('/root/LuckyScript/lky/lib/parser.so');
import_code('/root/LuckyScript/lky/lib/transpiler.so');

LS={};

LS.Version='0.1.12';
LS.arrow="»";
LS.printHeaders=1;

LS.err(section,line,text,message,file)={
    if !section section='Unknown';
    if !message message='Unknown Error';
    s=text[line.line.real:line.pos.real+1];
    if !file file='REPL';
    print(char(160));
    logger.err(file+' > Lucky.'+section+' error '+line.line.disp+':'+line.pos.disp+'. '+message);
    print(s);
    print( (' '*(line.pos.disp-1))+'^')
};

LS.getLine(text,sub=null)={
    if sub==null sub=0;
    if sub>=text.len() sub=text.len()-1;
    line={
        'line': {
            'real': 0,
            'disp': 1
        },
        'pos': {
            'real': sub,
            'disp': 0
        }
    };
    textPre = text[:sub];
    lines = textPre.split('\n');
    line.line.disp = lines.len();
    line.line.real = textPre.lastIndexOf('\n');
    line.pos.disp = 1+lines[-1].len();
    return line
};

LS.header()={
    if !LS.printHeaders return;
    print(
        '<#ffa>[LuckyScript V'+LS.Version+']</color>\n'
        + '[Host: Command Line on <#aaf>Ellipse</color>]\n'
        + '[By <#ffa>Clover</color>]'
    );
    LS.printHeaders = 0
};

LS.printHelp() = print(
        'Usage: '+program_path+' [option] ... [file] [-o file]\n'
        + 'Options and arguments:\n'
        + '-?, -h, --help        : Print this help message and exit.\n'
        + '-o, --output file     : Output file.\n'
        + '-d, --clean           : Delete generated source file.\n'
        + '-i, --importable      : Allow Import.\n'
        // + '-l --link file : Add file to imports list.\n'
        + '-n, --dryrun          : Don\'t run; only echo.\n'
        + '-s, --silent, --quiet : Silence output.\n'
        + 'file                  : Program read from script file.'
    );

// TODO add Imports = [] support
LS.transpile(IFile,OFile,Importable=false,Clean=false)={
    dir=current_path;
    oname=OFile.split('/')[-1]+'.src';
    if OFile.indexOf('/')!=null dir+='/'+parent_path(OFile);
    if OFile[0]=='/' dir=parent_path(OFile);

    ifile = get_shell.host_computer.File(IFile);
    if !ifile {
        logger.err('Error opening file: '+IFile);
        return -1;
    };

    if !globals.Dryrun get_shell.host_computer.touch(dir, oname);
    if !globals.Dryrun ofile = get_shell.host_computer.File(dir+'/'+oname);
    if !globals.Dryrun && !ofile {
        logger.err('Error opening file: '+OFile);
        return -1;
    };

    lexer = Lexer();
    parser = Parser();
    content = ifile.get_content();

    if !globals.Silent logger.info('[Transpiling '+ifile.path()+' to '+dir+'/'+OFile.split('/')[-1]+'...]');

    tokens = lexer.lex(content);
    tree = parser.parse(tokens);
    if tree.err {
        LS.err('Parser',LS.getLine(content,parser.errpos),content,tree.err,IFile);
        exit()
    };

    transpiled = Transpile(tree.value);

    if !globals.Dryrun test = ofile.set_content(transpiled);
    if !globals.Dryrun && typeof(test)=='string' {
        logger.err(test);
        exit()
    };

    if !globals.Dryrun test = get_shell.build(ofile.path(), dir, Importable);
    if !globals.Dryrun && test.len() {
        logger.err(test);
        exit()
    };
    if !globals.Dryrun && Clean ofile.delete();
    if !globals.Silent logger.info('<#ffa>[Done!]</color>');
    return 0
};

IFile=null;
// Imports=[];
Importable=false;
Clean=false;
output=null;
Dryrun=false;
Silent=false;

// i=0;
// while params.len() > i {
//     arg = params[i];
//     if arg=='-h' or arg=='-?' or arg=='--help' {
//         LS.header();
//         LS.printHelp();
//         exit()

//     } else if arg=='-s' || arg=='--silent' || arg=='--quiet' {
//         Silent = true;
//         LS.printHeaders = false;

//     } else if arg=='-n' || arg=='--dryrun' {
//         Dryrun = true;
    
//     } else if arg=='-i' || arg=='--importable' {
//         Importable=true

//     } else if arg=='-d' || arg=='--clean' {
//         Clean=true

//     } else if arg=='-o' || arg=='--output' {
//         i++;
//         if params.len()<=i {
//             logger.err('Output File expected after '+arg+' option');
//             exit()
//         } else
//             output = params[i]

//     } else if arg=='-l' || arg=='--load' {
//         i++;
//         if params.len()<=i {
//             logger.err('File expected after '+arg+' option');
//             exit()
//         } else
//             Imports.push(params[i])

//     } else if arg[0]!='-' {
//         IFile=arg

//     } else {
//         logger.err('Unknown option: '+arg);
//         exit()
//     };
//     i++
// };

argparse = ArgParser();

result = argparse
    .addArg(['--help'], false, ['h', '?'])
    .addArg(['--silent','--quiet'], false, ['s'])
    .addArg(['--dryrun'], false, ['n'])
    .addArg(['--importable'], false, ['i'])
    .addArg(['--clean'], false, ['d'])
    .addArg(['--output'], null, ['o'])
    .addPositional('file')
    .parse(params);

if result {
    logger.err(result);
    exit()
};

IFile = argparse.getPositional('file');
Importable = argparse.getValue('--importable');
Clean = argparse.getValue('--clean');
output = argparse.getValue('--output');
Dryrun = argparse.getValue('--dryrun');
Silent = argparse.getValue('--silent');

LS.printHeaders = !Silent;

if argparse.getValue('--help') {
    LS.header();
    LS.printHelp();
    exit()
};

LS.header();

if output {
    if !IFile {
        logger.err('No Input file specified.');
        exit()
    };
    LS.transpile(IFile,output,Importable,/*Imports,*/Clean)
} else {
    LS.printHelp()
}