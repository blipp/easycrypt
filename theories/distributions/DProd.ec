(* --------------------------------------------------------------------
 * Copyright (c) - 2012--2016 - IMDEA Software Institute
 * Copyright (c) - 2012--2018 - Inria
 * Copyright (c) - 2012--2018 - Ecole Polytechnique
 *
 * Distributed under the terms of the CeCILL-B-V1 license
 * -------------------------------------------------------------------- *)

(* -------------------------------------------------------------------- *)
require import AllCore List Distr StdRing StdOrder.
(*---*) import RField RealOrder RealSeries StdBigop.Bigreal BRA.

pragma +implicits.
pragma -oldip.

(* -------------------------------------------------------------------- *)
abstract theory ProdSampling.
type t1, t2.

op d1 : t1 distr.
op d2 : t2 distr.

module S = {
  proc sample () : t1 * t2 = {
    var r;

    r <$ d1 `*` d2;
    return r;
  }

  proc sample2 () : t1 * t2 = {
    var r1, r2;

    r1 = $ d1;
    r2 = $ d2;
    return (r1,r2);
  }
}.

(* -------------------------------------------------------------------- *)
equiv sample_sample2 : S.sample ~ S.sample2 : true ==> ={res}.
proof.
bypr (res{1}) (res{2}) => // &m1 &m2 a.
have ->: Pr[S.sample() @ &m1 : res = a] = mu1 (d1 `*` d2) a.
+ by byphoare=> //=; proc; rnd; skip. 
elim: a=> a1 a2; have -> := dprod1E d1 d2 a1 a2.
byphoare=> //=.
proc; seq  1: (r1 = a1) (mu1 d1 a1) (mu1 d2 a2) _ 0%r true=> //=.
+ by rnd.  
+ by rnd.
by hoare; auto=> /> ? ->.
qed.
end ProdSampling.

(* -------------------------------------------------------------------- *)
abstract theory DLetSampling.
type t, u.

op dt : t distr.
op du : t -> u distr.

module SampleDep = {
  proc sample2() : t * u = {
    var t, u;

    t <$ dt;
    u <$ du t;
    return (t, u);
  }

  proc sample() : u = {
    var t, u;

    t <$ dt;
    u <$ du t;
    return u;
  }
}.

module SampleDLet = {
  proc sample2() : t * u = {
    var tu;

    tu <$ dlet dt (fun t => dunit t `*` du t);
    return tu;
  }

  proc sample() : u = {
    var u;

    u <$ dlet dt du;
    return u;
  }
}.

(* -------------------------------------------------------------------- *)
equiv SampleDepDLet2 :
  SampleDep.sample2 ~ SampleDLet.sample2 : true ==> ={res}.
proof.
pose F := mu1 (dlet dt (fun t => dunit t `*` du t)).
bypr (res{1}) (res{2}) => // &m1 &m2 x.
have ->: Pr[SampleDLet.sample2() @ &m2 : res = x] = F x.
+ by byphoare=> //=; proc; rnd; skip. 
case: x => x1 x2; have -> : F (x1, x2) = mu1 dt x1 * mu1 (du x1) x2.
+ rewrite /F dlet1E /= 1?(@sumD1 _ x1) /=.
  * apply: (@summable_le (mu1 dt)) => /=; first by apply: summable_mu1.
    by move=> x; rewrite normrM ler_pimulr ?normr_ge0 ?ger0_norm.
  rewrite dprod1E dunit1E /= sum0_eq //= => x; case: (x = x1) => //=.
  by move=> ne_x_x1; rewrite dprod1E dunit1E ne_x_x1.
byphoare=> //=; proc; seq 1:
  (t = x1) (mu1 dt x1) (mu1 (du x1) x2) _ 0%r true=> //=.
+ by rnd.  
+ by rnd.
by hoare; auto=> /> ? ->.
qed.

(* --------------------------------------------------------------------- *)
equiv SampleDep :
  SampleDep.sample ~ SampleDep.sample2 : true ==> res{1} = res{2}.`2.
proof. by proc=> /=; sim. qed.

(* -------------------------------------------------------------------- *)
equiv SampleDLet :
  SampleDLet.sample ~ SampleDLet.sample2 : true ==> res{1} = res{2}.`2.
proof.
bypr (res{1}) (res{2}.`2) => //= &m1 &m2 x.
have ->: Pr[SampleDLet.sample() @ &m1 : res = x] = mu1 (dlet dt du) x.
+ by byphoare=> //=; proc; rnd; skip.
suff ->//: Pr[SampleDLet.sample2() @ &m2 : res.`2 = x] = mu1 (dlet dt du) x.
byphoare=> //=; proc; rnd; skip => /=; rewrite dlet1E dletE_swap /=.
apply: eq_sum => y /=; rewrite (@sumD1 _ (y, x)) /=.
+ by apply/summable_cond/summableZ/summable_mass. 
rewrite !massE dprod1E dunit1E sum0_eq //=.
case=> y' x' /=; case: (x' = x) => //= ->>.
case: (y' = y) => //= ne_y'y; rewrite !massE dprod1E.
by rewrite dunit1E (@eq_sym y) ne_y'y.
qed.

equiv SampleDepDLet :
  SampleDep.sample ~ SampleDLet.sample : true ==> ={res}.
proof.
transitivity SampleDep.sample2
  (true ==> res{1} = res{2}.`2)
  (true ==> res{2} = res{1}.`2) => //; first exact SampleDep.
transitivity SampleDLet.sample2
  (true ==> ={res})
  (true ==> res{2} = res{1}.`2) => //.
+ exact SampleDepDLet2.
+ by symmetry; exact SampleDLet.
qed.

end DLetSampling.
