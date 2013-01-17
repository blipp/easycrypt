%{
  open EcParsetree

  let error pos msg =
    let msg =
      Printf.sprintf "%s: %s" (Location.tostring pos) msg
    in
      failwith msg

  let mk_lced loc v = { pl_loc = loc; pl_desc = v; }

  let pqsymb_of_psymb (x : psymbol) : pqsymbol =
    mk_lced x.pl_loc ([], x.pl_desc)

  let pqsymb_of_symb loc x : pqsymbol =
    mk_lced loc ([], x)

  let mk_mod ?modtype params body = Pm_struct {
    ps_params    = params;
    ps_signature = modtype;
    ps_body      = body;
  }

  let mk_tydecl (tyvars, name) body = {
    pty_name   = name;
    pty_tyvars = tyvars;
    pty_body   = body;
  }

  let peget loc ti e1 e2    = 
    PEapp (pqsymb_of_symb loc EcCoreLib.s_get, ti, [e1; e2])
  let peset loc ti e1 e2 e3 = 
    PEapp (pqsymb_of_symb loc EcCoreLib.s_set, ti, [e1; e2; e3])

  let pfget loc e1 e2    = PFapp (pqsymb_of_symb loc EcCoreLib.s_get, [e1; e2])
  let pfset loc e1 e2 e3 = PFapp (pqsymb_of_symb loc EcCoreLib.s_get, [e1; e2; e3])

  let mk_loc loc e = 
    { pl_desc = e;  pl_loc  = loc;}

  let pe_nil loc ti = 
    mk_loc loc (PEident (pqsymb_of_symb loc EcCoreLib.s_nil, ti))

  let pe_cons loc e1 e2 = 
    mk_loc loc (PEapp (pqsymb_of_symb loc EcCoreLib.s_cons, None, [e1; e2]))
      
  let pelist loc ti (es : pexpr    list) : pexpr    = 
    List.fold_right (fun e1 e2 -> pe_cons loc e1 e2) es (pe_nil loc ti)

  let pfe_nil loc = 
    mk_loc loc (PFident (pqsymb_of_symb loc EcCoreLib.s_nil))

  let pfe_cons loc e1 e2 = 
    mk_loc loc (PFapp (pqsymb_of_symb loc EcCoreLib.s_cons, [e1; e2]))

  let pflist loc (es : pformula list) : pformula = 
    List.fold_right (fun e1 e2 -> pfe_cons loc e1 e2) es (pfe_nil loc)

  let mk_axiom p k = 
    { pa_name = fst p; pa_formula = snd p; pa_kind = k }
%}

%token <EcSymbols.symbol>  IDENT
%token <EcSymbols.qsymbol> QIDENT

%token <int> NUM
%token <string> PRIM_IDENT
%token <string> STRING

(* Tokens + keywords *)
// %token ABSTRACT
%token UNDERSCORE
%token ADMIT
// %token ADVERSARY
%token AND
%token ARROW
%token AS
// %token ASPEC
%token ASSERT
%token AXIOM
%token LEMMA
%token PROOF
%token BACKSLASH
// %token BITSTR
// %token CHECKPROOF
%token CLAIM
%token CLONE
%token CNST
%token COLON
%token COMMA
%token COMPUTE
%token DOT
%token DOTDOT
%token DROP
%token ELSE
%token END
%token EOF
%token EQ
// %token EQEQLBRACKET
// %token EQUIV
%token EXPORT
%token EXIST
%token FORALL
%token FUN
%token IF
%token IFF
%token IMPL
%token IMPORT
%token IN
// %token INCLUDE
// %token INTERFACE
// %token KW_AND
%token LBRACKET
%token LEFTARROW
// %token LEMMA
%token LET
%token LKEY
// %token LLIMP
%token LPAREN
%token MINUS
%token MODULE
%token NE
%token NOT
%token OP
%token OR
%token PIPE
%token POP
// %token PR
%token PRED
// %token PROVER
%token QUESTION
%token RBRACKET
// %token RBRACKETLLIMP
// %token REMOVE
%token RETURN
%token REQUIRE
// %token USE
%token RKEY
%token RKEY_HAT
// %token ROI
%token RPAREN
%token SAME
%token SEMICOLON
// %token SET
%token STAR
%token THEN
%token THEORY
// %token TILD
%token TYPE
// %token UNSET
// %token UPTO
%token USING
%token VAR
// %token WHERE
%token WHILE
// %token WITH
%token PR

(* Tactics *)
// %token ABORT
// %token ALL
// %token APP
// %token APPLY
// %token APRHL
// %token ASSIGN
// %token AT
%token AUTO
// %token AUTOSYNC
// %token BACKWARDS
// %token BY
// %token CALL
// %token CASE
// %token CHECK
// %token CONDF
// %token CONDT
// %token DERANDOMIZE
// %token EAGER
// %token EQOBSIN
// %token FORWARDS
%token IDTAC
%token RIGHT
%token LEFT
%token TRIVIAL
%token INTROS
%token ASSUMPTION
%token SPLIT
%token ELIM
// %token IFNEG
// %token IFSYNC
// %token INLINE
// %token LAST
// %token OPAQUE
// %token PRHL
%token PRINT
// %token RANDOM
%token SAVE
// %token SIMPL
// %token SP
// %token SPLITWHILE
// %token SWAP
// %token TIMEOUT
// %token TRANSPARENT
// %token TRY
// %token UNDO
// %token UNFOLD
// %token UNROLL
// %token WP
%token WHY3

%token <string> OP1 OP2 OP3 OP4
%token LTCOLON GT

%nonassoc COMMA ELSE

%nonassoc IN
%right IMPL IFF
%right OR
%right AND

%nonassoc NOT
%left EQ NE OP1 GT

%right QUESTION
%left OP2 MINUS
%left OP3 STAR
%left OP4 

%nonassoc prec_prefix_op
%nonassoc RKEY_HAT

%type <EcParsetree.global> global
%type <EcParsetree.prog * bool> prog

%start prog global
%%

(* -------------------------------------------------------------------- *)
%inline ident      : x=loc(IDENT)      { x };
%inline number     : n=NUM             { n };
%inline prim_ident : x=loc(PRIM_IDENT) { x };

qident:
| x=loc(IDENT)  { pqsymb_of_psymb x }
| x=loc(QIDENT) { x }
;

(* -------------------------------------------------------------------- *)
%inline ident_list1: aout=plist1(ident, COMMA) { aout };

%inline prim_ident_list1: aout=plist1(prim_ident, COMMA) { aout };

(* -------------------------------------------------------------------- *)
%inline binop:
| EQ      { "="  }
| MINUS   { "-"  }
| AND     { "&&" }
| OR      { "||" }
| STAR    { "*"  }
| GT      { ">"  }
| x=OP1   { x    }
| x=OP2   { x    }
| x=OP3   { x    }
| x=OP4   { x    }
;

(* -------------------------------------------------------------------- *)
prog_num:
| LKEY n=number RKEY { 
  if n > 0 then n else 
  error
    (Location.make $startpos(n) $endpos(n))
    "variable side must be greater than 0"
  }
;

(* -------------------------------------------------------------------- *)
(* Expressions: program expression, real expression                     *)
tvar_instance:
| x=prim_ident EQ ty=loc(type_exp) { x,ty }
;

tvars_instance_kind:
| lt = plist1(loc(type_exp), COMMA) { TVIunamed lt }
| lt = plist1(tvar_instance, COMMA) { TVInamed lt }
;

%inline tvars_app:
| LTCOLON k=tvars_instance_kind GT { Some k }
| empty                            { None }
;

lpattern:
| x=ident { LPSymbol x }
| LPAREN p=plist2(ident, COMMA) RPAREN { LPTuple p }
;

sexp:
| n=number
   { PEint n }

| x=qident ti=tvars_app 
   { PEident (x,ti) }

| se=loc(sexp) LBRACKET ti=tvars_app e=loc(exp) RBRACKET
   { peget (Location.make $startpos $endpos) ti se e }

| se=loc(sexp) LBRACKET ti=tvars_app e1=loc(exp) LEFTARROW e2=loc(exp) RBRACKET  
   { peset (Location.make $startpos $endpos) ti se e1 e2 }

| x=qident ti=tvars_app LPAREN es=exp_list0 RPAREN
   { PEapp (x, ti, es) }

| LPAREN es=exp_list2 RPAREN
   { PEtuple es }

| LPAREN e=exp RPAREN
   { e }

| LBRACKET ti=tvars_app es=loc(p_exp_sm_list0) RBRACKET  
   { (pelist es.pl_loc ti es.pl_desc).pl_desc }
| PIPE e =loc(exp) PIPE 
    { PEapp (pqsymb_of_symb e.pl_loc EcCoreLib.s_abs, None, [e]) }
;

op1:
| OP1      { $1 }
| GT       { ">" }
;

exp:
| e=sexp { e }

| op=loc(NOT) ti=tvars_app e=loc(exp) (* %prec NOT *)
   { PEapp (pqsymb_of_symb op.pl_loc "!", ti, [e]) }

| op=loc(MINUS) ti=tvars_app e=loc(exp) %prec prec_prefix_op
   { PEapp (pqsymb_of_symb op.pl_loc EcCoreLib.s_opp, ti, [e]) }

| e1=loc(exp) op=loc(op1) ti=tvars_app e2=loc(exp) %prec OP1
    { PEapp (pqsymb_of_psymb op, ti, [e1; e2]) }

| e1=loc(exp) op=loc(OP2) ti=tvars_app e2=loc(exp) 
    { PEapp (pqsymb_of_psymb op, ti, [e1; e2]) }

| e1=loc(exp) op=loc(OP3) ti=tvars_app e2=loc(exp) 
    { PEapp (pqsymb_of_psymb op, ti, [e1; e2]) }

| e1=loc(exp) op=loc(OP4) ti=tvars_app e2=loc(exp) 
    { PEapp (pqsymb_of_psymb op, ti, [e1; e2]) }

| e1=loc(exp) op=loc(IMPL) ti=tvars_app e2=loc(exp)
    { PEapp (pqsymb_of_symb op.pl_loc "=>" , ti, [e1; e2]) }

| e1=loc(exp) op=loc(IFF) ti=tvars_app e2=loc(exp) 
    { PEapp (pqsymb_of_symb op.pl_loc "<=>", ti, [e1; e2]) }

| e1=loc(exp) op=loc(OR) ti=tvars_app e2=loc(exp)  
    { PEapp (pqsymb_of_symb op.pl_loc "||" , ti, [e1; e2]) }

| e1=loc(exp) op=loc(AND) ti=tvars_app e2=loc(exp) 
    { PEapp (pqsymb_of_symb op.pl_loc "&&" , ti, [e1; e2]) }

| e1=loc(exp) op=loc(EQ) ti=tvars_app e2=loc(exp)  
    { PEapp (pqsymb_of_symb op.pl_loc "="  , ti, [e1; e2]) }

| e1=loc(exp) op=loc(NE) ti=tvars_app e2=loc(exp)  
    { PEapp (pqsymb_of_symb op.pl_loc "<>" , ti, [e1; e2]) }

| e1=loc(exp) op=loc(MINUS) ti=tvars_app e2=loc(exp) 
    { PEapp (pqsymb_of_symb op.pl_loc "-"  , ti, [e1; e2]) }

| e1=loc(exp) op=loc(STAR) ti=tvars_app e2=loc(exp)  
    { PEapp (pqsymb_of_symb op.pl_loc "*"  , ti, [e1; e2]) }

| c=loc(exp) QUESTION e1=loc(exp) COLON e2=loc(exp) %prec OP2
| IF c=loc(exp) THEN e1=loc(exp) ELSE e2=loc(exp)
   { PEif (c, e1, e2) }

| LET p=lpattern EQ e1=loc(exp) IN e2=loc(exp)
   { PElet (p, e1, e2) }

| LKEY n1=number COMMA n2=number RKEY
    { if   n1 = 0 && n2 = 1
      then PEflip
      else error (Location.make $startpos $endpos) "malformed bool random" }

| LKEY n1=number COMMA n2=number RKEY_HAT e=loc(exp)
    { if   n1 = 0 && n2 = 1
      then PEbitstr e
      else error (Location.make $startpos $endpos) "malformed random bitstring" }

| LBRACKET e1=loc(exp) DOTDOT e2=loc(exp) RBRACKET
    { PEinter (e1, e2) }

| LPAREN re=loc(exp) BACKSLASH e=loc(exp) RPAREN
    { PEexcepted (re, e) }
;

(* -------------------------------------------------------------------- *)
%inline p_exp_sm_list0: aout=plist0(loc(exp), SEMICOLON) { aout }

%inline exp_list0: aout=plist0(loc(exp), COMMA) { aout }
// %inline exp_list1: aout=plist1(loc(exp), COMMA) { aout }
%inline exp_list2: aout=plist2(loc(exp), COMMA) { aout }

(* -------------------------------------------------------------------- *)
(* Formulas                                                             *)

sform:
| n=number
   { PFint n }

| x=qident
   { PFident x }

| se=loc(sform) LBRACKET e=loc(form) RBRACKET
   { pfget (Location.make $startpos $endpos) se e }

| se=loc(sform) LBRACKET e1=loc(form) LEFTARROW e2=loc(form) RBRACKET
   { pfset (Location.make $startpos $endpos) se e1 e2 }

| x=qident LPAREN es=form_list0 RPAREN
   { PFapp (x, es) }

| x=loc(sform) LKEY s=prog_num RKEY
   { PFside (x, s) }

| LPAREN es=form_list2 RPAREN
   { PFtuple es }

| LPAREN e=form RPAREN
   { e }

| LBRACKET es=loc(p_form_sm_list0) RBRACKET
   { (pflist es.pl_loc es.pl_desc).pl_desc }

| PIPE e =loc(form) PIPE 
    { PFapp (pqsymb_of_symb e.pl_loc EcCoreLib.s_abs, [e]) }
| PR LBRACKET x=fct_game pn=prog_num COLON f=loc(form) RBRACKET 
    { PFprob(x,pn,f) }
                          
form:
| e=sform { e }

| op=loc(NOT) e=loc(form) { PFapp (pqsymb_of_symb op.pl_loc "!", [e]) }

| op=loc(MINUS) e=loc(form) %prec prec_prefix_op
   { PFapp (pqsymb_of_symb op.pl_loc "-", [e]) }
| e1=loc(form) op=loc(op1) e2=loc(form)  { PFapp (pqsymb_of_psymb op, [e1; e2]) } %prec OP1
| e1=loc(form) op=loc(OP2) e2=loc(form)  { PFapp (pqsymb_of_psymb op, [e1; e2]) }
| e1=loc(form) op=loc(OP3) e2=loc(form)  { PFapp (pqsymb_of_psymb op, [e1; e2]) }
| e1=loc(form) op=loc(OP4) e2=loc(form)  { PFapp (pqsymb_of_psymb op, [e1; e2]) }
| e1=loc(form) op=loc(IMPL) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "=>" , [e1; e2]) }
| e1=loc(form) op=loc(IFF) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "<=>", [e1; e2]) }
| e1=loc(form) op=loc(OR) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "||" , [e1; e2]) }
| e1=loc(form) op=loc(AND) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "&&" , [e1; e2]) }
| e1=loc(form) op=loc(EQ   ) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "="  , [e1; e2]) }
| e1=loc(form) op=loc(NE   ) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "<>" , [e1; e2]) }

| e1=loc(form) op=loc(MINUS) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "-" , [e1; e2]) }
| e1=loc(form) op=loc(STAR ) e2=loc(form)  { PFapp (pqsymb_of_symb op.pl_loc "*" , [e1; e2]) }

| c=loc(form) QUESTION e1=loc(form) COLON e2=loc(form) %prec OP2 { PFif (c, e1, e2) }
| IF c=loc(form) THEN e1=loc(form) ELSE e2=loc(form)             { PFif (c, e1, e2) }

| LET p=lpattern EQ e1=loc(form) IN e2=loc(form) { PFlet (p, e1, e2) }

| FORALL pd=param_decl1 COMMA e=loc(form) { PFforall(pd, e) }
| FORALL pd=mem_decl   COMMA e=loc(form) { PFforallm(pd, e) }
| EXIST  pd=param_decl1 COMMA e=loc(form) { PFexists(pd, e) }
| EXIST  pd=mem_decl   COMMA e=loc(form) { PFexistsm(pd, e) }
;

%inline p_form_sm_list0: aout=plist0(loc(form), SEMICOLON) { aout }
%inline form_list0: aout=plist0(loc(form), COMMA) { aout }
%inline form_list2: aout=plist2(loc(form), COMMA) { aout }

fct_game: (* Extend with functor application ... *)
| x=qident { x }
;

typed_mem:
| pn=prog_num COLON fg=fct_game { pn,fg }
;
mem_decl:
| LPAREN aout=plist1(typed_mem, COMMA) RPAREN { aout }
;
(* -------------------------------------------------------------------- *)
(* Type expressions                                                     *)

simpl_type_exp:
| UNDERSCORE                  { PTunivar       }
| x=qident                    { PTnamed x      }
| x=prim_ident                { PTvar x        }
| tya=type_args x=qident      { PTapp (x, tya) }
| LPAREN ty=type_exp RPAREN   { ty             }
;

type_args:
| ty=loc(simpl_type_exp)                          { [ty] }
| LPAREN tys=plist2(loc(type_exp), COMMA) RPAREN  { tys  }
;

type_exp:
| ty=simpl_type_exp                    { ty }
| ty=plist2(loc(simpl_type_exp), STAR) { PTtuple ty }
;

(* -------------------------------------------------------------------- *)
(* Parameter declarations                                              *)

typed_vars:
| xs=ident_list1 COLON ty=loc(type_exp) { List.map (fun v -> (v, ty)) xs }
;

param_decl:
| LPAREN aout=plist0(typed_vars, COMMA) RPAREN { List.flatten aout }
;

param_decl1:
| LPAREN aout=plist1(typed_vars, COMMA) RPAREN { List.flatten aout }
;


(* -------------------------------------------------------------------- *)
(* Statements                                                           *)

lvalue:
| x=qident                                           { PLvSymbol x      }
| LPAREN p=plist2(qident, COMMA) RPAREN              { PLvTuple p       }
| x=qident LBRACKET ti=tvars_app e=loc(exp) RBRACKET { PLvMap(x, ti, e) }
;

base_instr:
| f=qident LPAREN es=exp_list0 RPAREN
    { PScall (f, es) }

| x=lvalue EQ e=loc(exp)
    { PSasgn (x, e) }

| ASSERT LPAREN c=loc(exp) RPAREN 
     { PSassert c }
;

instr:
| bi=base_instr SEMICOLON                            { bi }
| IF LPAREN c=loc(exp) RPAREN b1=block ELSE b2=block { PSif (c, b1, b2) }
| IF LPAREN c=loc(exp) RPAREN b =block               { PSif (c, b , []) }
| WHILE LPAREN c=loc(exp) RPAREN b=block             { PSwhile (c, b) }
;

block:
| i=base_instr SEMICOLON { [i] }
| LKEY stmt=stmt RKEY    { stmt }
;

stmt: aout=instr* { aout }

(* -------------------------------------------------------------------- *)
(* Module definition                                                    *)

var_decl:
| VAR xs=ident_list1 COLON ty=loc(type_exp) { (xs, ty) }
;

loc_decl:
| VAR xs=ident_list1 COLON ty=loc(type_exp) SEMICOLON
     { (xs, ty, None  ) }

| VAR xs=ident_list1 COLON ty=loc(type_exp) EQ e=loc(exp) SEMICOLON
     { (xs, ty, Some e) }
;

ret_stmt:
| RETURN e=loc(exp) SEMICOLON { Some e }
| empty                       { None }
;

fun_def_body:
| LKEY decl=loc_decl* s=stmt rs=ret_stmt RKEY
    { { pfb_locals = decl;
        pfb_body   = s   ;
        pfb_return = rs  ; }
    }
;

fun_decl:
| x=ident pd=param_decl COLON ty=loc(type_exp)
    { { pfd_name     = x   ;
        pfd_tyargs   = pd  ;
        pfd_tyresult = ty  ;
        pfd_uses     = None; }
    }
;

mod_item:
| v=var_decl
    { Pst_var v }

| m=mod_def
    { let x, m = m in Pst_mod (x, m) }

| FUN decl=fun_decl EQ body=fun_def_body
    { Pst_fun (decl, body) }

| FUN x=ident EQ f=qident
    { Pst_alias (x, f) }
;

(* -------------------------------------------------------------------- *)
(* Modules                                                              *)

mod_body:
| LKEY stt=mod_item* RKEY { stt }
;

mod_def:
| MODULE x=ident EQ body=mod_body
    { (x, mk_mod [] body) }

| MODULE x=ident EQ m=qident
    { (x, Pm_ident (m, [])) }

| MODULE x=ident EQ m=qident LPAREN a=plist1(qident, COMMA) RPAREN
    { (x, Pm_ident (m, a)) }

| MODULE x=ident LPAREN a=plist1(sig_arg, COMMA) RPAREN EQ body=mod_body
    { (x, mk_mod a body) }
;

(* -------------------------------------------------------------------- *)
(* Modules interfaces                                                   *)

sig_def:
| MODULE TYPE x=ident EQ i=sig_body
    { (x, i) }

| MODULE TYPE x=ident LPAREN a=plist1(sig_arg, COMMA) RPAREN EQ i=signature
    { (x, Pty_func (a, i)) }
;

sig_arg:
| x=ident COLON i=qident { (x, i) }
;

sig_body:
| x=qident LPAREN a=plist1(qident, COMMA) RPAREN
    { Pty_app (x, a) }

| x=signature
   { Pty_sig x }
;

signature:
| LKEY x=signature_item* RKEY { x }
;

signature_item:
| VAR decl=ivar_decl
    { `VariableDecl decl }

| FUN decl=ifun_decl
    { `FunctionDecl decl }
;

ifun_decl:
| x=ident pd=param_decl COLON ty=loc(type_exp)
    { { pfd_name     = x   ;
        pfd_tyargs   = pd  ;
        pfd_tyresult = ty  ;
        pfd_uses     = None; }
    }

| x=ident pd=param_decl COLON ty=loc(type_exp) LKEY us=qident* RKEY
    { { pfd_name     = x      ;
        pfd_tyargs   = pd     ;
        pfd_tyresult = ty     ;
        pfd_uses     = Some us; }
    }
;

ivar_decl:
| x=ident COLON ty=loc(type_exp)
    { { pvd_name = x; pvd_type = ty } }
;

(* -------------------------------------------------------------------- *)
(* EcTypes declarations / definitions                                   *)

poly_type_decl:
| empty                              { []  }
| x=prim_ident                       { [x] }
| LPAREN xs=prim_ident_list1 RPAREN  { xs  }
;

type_decl:
| TYPE tydecl=poly_type_decl x=ident { (tydecl, x) }
;

type_decl_or_def:
| td=type_decl { mk_tydecl td None }
| td=type_decl EQ te=loc(type_exp) { mk_tydecl td (Some te) }
;

(* -------------------------------------------------------------------- *)
(* Operator definitions                                                 *)

op_tydom:
| LPAREN RPAREN                                  { [  ] }
| ty=loc(type_exp)                               { [ty] }
| LPAREN tys=plist2(loc(type_exp), COMMA) RPAREN { tys  }
;

op_sig:
| dom=op_tydom ARROW codom=loc(type_exp) { (Some dom, codom) }
;

op_ident:
| x=ident { x }
| LBRACKET x=loc(binop) RBRACKET { x }
;

tyvars_decl:
| LBRACKET tyvars=prim_ident* RBRACKET { Some tyvars }
| empty { None }
    
operator:
| OP x=op_ident tyvars=tyvars_decl COLON sty=op_sig {
    { po_name   = x      ;
      po_tyvars = tyvars ;
      po_dom    = fst sty;
      po_codom  = snd sty;
      po_body   = None   ;
      po_prob   = false  ; }
  }

| OP x=op_ident tyvars=tyvars_decl p=param_decl1 COLON codom=loc(type_exp)
    EQ b=loc(exp) {
    { po_name   = x      ;
      po_tyvars = tyvars ;
      po_dom    = Some(List.map snd p);
      po_codom  = codom  ;
      po_body   = Some(List.map fst p, b);
      po_prob   = false  ; }
  }

| POP x=ident tyvars=tyvars_decl COLON sty=op_sig {
    { po_name   = x      ;
      po_tyvars = tyvars ;
      po_dom = fst sty   ;
      po_codom = snd sty ;
      po_body  = None    ;
      po_prob   = true   ; }
  }

| CNST x=ident tyvars=tyvars_decl COLON ty=loc(type_exp) {
    { po_name   = x    ;
      po_tyvars = tyvars   ;
      po_dom = None    ;
      po_codom = ty    ;
      po_body = None   ;
      po_prob   = false; }
  }
| CNST x=ident tyvars=tyvars_decl COLON ty=loc(type_exp) EQ e=loc(exp) {
    { po_name   = x     ;
      po_tyvars = tyvars;
      po_dom = None     ;
      po_codom = ty     ;
      po_body = Some([], e) ;
      po_prob   = false ; }
  }
;

predicate:
| PRED x = op_ident { 
  { pp_name = x;
    pp_tyvars = None;
    pp_dom = None;
    pp_body = None; }
  }
| PRED x = op_ident EQ f=loc(form) {
  { pp_name = x;
    pp_tyvars = None;
    pp_dom = None;
    pp_body = Some([], f) }
  }
| PRED x = op_ident tyvars=tyvars_decl COLON sty = op_tydom { 
  { pp_name = x;
    pp_tyvars = tyvars;
    pp_dom = Some sty;
    pp_body = None;
  }
  } 
| PRED x = op_ident tyvars=tyvars_decl params=param_decl1 EQ f=loc(form) { 
  { pp_name = x;
    pp_tyvars = tyvars;
    pp_dom = Some(List.map snd params);
    pp_body =Some(List.map fst params, f) }
  }
;

(* -------------------------------------------------------------------- *)
(* Global entries                                                       *)

%inline ident_exp:
| x=ident COMMA e=loc(exp) { (x, e) }
;

real_hint:
| USING x=ident { Husing x }
| ADMIT         { Hadmit }
| COMPUTE       { Hcompute }
| COMPUTE n=NUM e1=loc(exp) COMMA e2=loc(exp)
                { Hfailure (n, e1, e2, []) }
| COMPUTE n=NUM e1=loc(exp) COMMA e2=loc(exp) COLON l=plist1(ident_exp, COLON)
                { Hfailure (n, e1, e2, l) }
| SPLIT         { Hsplit }
| SAME          { Hsame }
| AUTO          { Hauto }
| empty         { Hnone }
;

claim:
| CLAIM x=ident COLON e=loc(exp) h=real_hint { (x, (e, h)) }
;

%inline axiom_decl: x=ident COLON e=loc(form) { x,e };

axiom:
| AXIOM p=axiom_decl       { mk_axiom p PAxiom  } 
| LEMMA p=axiom_decl       { mk_axiom p PLemma  }
| LEMMA p=axiom_decl PROOF { mk_axiom p PILemma } 
;

(* -------------------------------------------------------------------- *)
(* Theory interactive manipulation                                      *)

theory_open    : THEORY  x=ident  { x }
theory_close   : END     x=ident  { x }
theory_require : REQUIRE x=ident  { x }
theory_import  : IMPORT  x=qident { x }
theory_export  : EXPORT  x=qident { x }

theory_w3:
| IMPORT WHY3 path=string_list r=plist0(renaming,SEMICOLON)
    { 
      let l = List.rev path in
      let th = List.hd l in
      let path = List.rev (List.tl l) in
      path,th,r }
;

renaming:
| TYPE l=string_list AS s=STRING { l, RNty, s }
| OP   l=string_list AS s=STRING { l, RNop, s }
| AXIOM l=string_list AS s=STRING {l, RNpr, s }
;

%inline string_list: l=plist1(STRING,empty) { l };

(* -------------------------------------------------------------------- *)
(* tactic                                                               *)


assumption_args:
| empty                  { None  , None }
| p=qident tvi=tvars_app { Some p, tvi }
;

underscore_or_ident:
| UNDERSCORE { None }
| s=IDENT   { Some s }
;

intro_args: l=plist1(loc(underscore_or_ident),empty) { l };

exists_args: l=plist1(loc(form), COMMA) { l };

underscore_or_form:
| UNDERSCORE   { None }
| f=loc(sform)  { Some f }
;

elim_kind:
| p=qident tvi=tvars_app            { ElimHyp(p,tvi)  }
| COLON LPAREN f=loc(form) RPAREN   { ElimForm f }
;
elim_args:
| empty { [] }
| LPAREN l=plist1(underscore_or_form, COMMA) RPAREN { l }
;

tactic:
| IDTAC                        { Pidtac }
| ASSUMPTION a=assumption_args { Passumption a } 
| TRIVIAL                      { Ptrivial }
| INTROS a=intro_args          { Pintro a }
| SPLIT                        { Psplit }
| EXIST  a=exists_args         { Pexists a }
| LEFT                         { Pleft }
| RIGHT                        { Pright }
| ELIM k=elim_kind a=elim_args { Pelim { elim_kind = k; elim_args = a } } 
| LPAREN s=tactics RPAREN      { Pseq s } 
;
tactics:
| t=loc(tactic)                        { [t] }
| t=loc(tactic) SEMICOLON ts=tactics2  { t::ts }
;

tactics0:
(* | empty           { Pidtac } *)
| ts=tactics      { Pseq ts } 
;
%inline tactics2: ts=plist1(tactic2, SEMICOLON) { ts };
tsubgoal: LBRACKET ts=plist0(loc(tactics0),PIPE) RBRACKET { Psubgoal ts };
tactic2: 
| ts=loc(tsubgoal) { ts }
| t=loc(tactic)    { t } 
;


(* -------------------------------------------------------------------- *)
(* Theory cloning                                                       *)

theory_clone:
| CLONE x=qident { (x, None) }
| CLONE x=qident AS y=ident { (x, Some y) }
;

(* -------------------------------------------------------------------- *)
(* Printing                                                             *)
print:
| TYPE   qs=qident { Pr_ty qs }
| OP     qs=qident { Pr_op qs }
| THEORY qs=qident { Pr_th qs }
| PRED   qs=qident { Pr_pr qs } 
| AXIOM  qs=qident { Pr_ax qs }
;

(* -------------------------------------------------------------------- *)
(* Global entries                                                       *)

global_:
| theory_open      { GthOpen    $1 }
| theory_close     { GthClose   $1 }
| theory_require   { GthRequire $1 }
| theory_import    { GthImport  $1 }
| theory_export    { GthExport  $1 }
| theory_clone     { GthClone   $1 }
| theory_w3        { GthW3      $1 }
| mod_def          { Gmodule    $1 }
| sig_def          { Ginterface $1 }
| type_decl_or_def { Gtype      $1 }
| operator         { Goperator  $1 }
| predicate        { Gpredicate $1 }
| axiom            { Gaxiom     $1 }
| claim            { Gclaim     $1 }
| tactics          { Gtactics   $1 }
| SAVE             { Gsave         }
| PRINT p=print    { Gprint     p  }
;

stop:
| EOF { }
| DROP DOT { }
;

global:
| g=global_ DOT { g }
;

prog:
| g=global { ([g], false) }
| stop     { ([ ], true ) }
| error    { error (Location.make $startpos $endpos) "Parsing error" }
;

(* -------------------------------------------------------------------- *)
%inline plist0(X, S):
| aout=separated_list(S, X) { aout }
;

%inline plist1(X, S):
| aout=separated_nonempty_list(S, X) { aout }
;

%inline plist2(X, S):
| x=X S xs=plist1(X, S) { x :: xs }
;

%inline empty:
| /**/ { () }
;

(* -------------------------------------------------------------------- *)
%inline loc(X):
| x=X {
    { pl_desc = x;
      pl_loc  = Location.make $startpos $endpos;
    }
  }
;
