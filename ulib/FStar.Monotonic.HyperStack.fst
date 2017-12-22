module FStar.Monotonic.HyperStack

open FStar.Preorder
open FStar.Monotonic.HyperHeap
module Map  = FStar.Map
module HH   = FStar.Monotonic.HyperHeap

type rid = HH.hh_rid
let root = HH.hh_root
let color (x:rid) :GTot int = HH.hh_color x
let extends (r1 r2:rid) = HH.extends r1 r2
let disjoint (r1 r2:rid) = HH.disjoint r1 r2
let includes (r1 r2:rid) = HH.includes r1 r2

let is_in (r:rid) (h:HH.t) = h `Map.contains` r

let is_stack_region r = color r > 0
let is_eternal_color c = c <= 0
let is_eternal_region r  = is_eternal_color (color r)

type sid = r:rid{is_stack_region r} //stack region ids

let is_above r1 r2      = r1 `includes` r2
let is_just_below r1 r2 = r1 `extends`  r2
let is_below r1 r2      = r2 `is_above` r1
let is_strictly_below r1 r2 = r1 `is_below` r2 && r1<>r2
let is_strictly_above r1 r2 = r1 `is_above` r2 && r1<>r2

abstract let downward_closed (h:HH.t) =
  forall (r:rid). r `is_in` h  //for any region in the memory
        ==> (r=root    //either is the root
            \/ (forall (s:rid). r `is_above` s  //or, any region beneath it
                          /\ s `is_in` h   //that is also in the memory
                     ==> (is_stack_region r = is_stack_region s))) //must be of the same flavor as itself

abstract let tip_top (tip:rid) (h:HH.t) =
  forall (r:sid). r `is_in` h <==> r `is_above` tip  

let is_tip (tip:rid) (h:HH.t) =
  (is_stack_region tip \/ tip=root)                                  //the tip is a stack region, or the root
  /\ tip `is_in` h                                                      //the tip is active
  /\ tip_top tip h                      //any other sid activation is a above (or equal to) the tip

let rid_last_component (r:rid) :GTot int
  = let open FStar.List.Tot in
    let r = HH.reveal r in
    if length r = 0 then 0
    else snd (hd r)

(*
 * AR: marking it abstract, else it has a high-chance of firing even with a pattern
 *)
abstract let rid_ctr_pred (h:HH.t) (n:int) =
  forall (r:rid).{:pattern (h `Map.contains` r)}
               h `Map.contains` r ==> rid_last_component r < n

let hh = h:HH.t{root `is_in` h /\ HH.map_invariant h /\ downward_closed h}        //the memory itself, always contains the root region, and the parent of any active region is active

noeq type mem =
  | HS : rid_ctr:int
       -> h:hh{rid_ctr_pred h rid_ctr}
       -> tip:rid{tip `is_tip` h}                                                   //the id of the current top-most region
       -> mem

(****** tip_top related lemmas ******)

// let lemma_tip_top_push_frame (tip:rid) (h:HH.t) (new_tip:rid{new_tip =!= root}) (t:Heap.heap)
//   :Lemma (requires (tip_top tip h /\ parent new_tip == tip))
//          (ensures  (tip_top new_tip (Map.upd h new_tip t)))
//   = ()

// let lemma_tip_top_same_domain (tip:rid) (h1 h2:HH.t)
//   :Lemma (requires (tip_top tip h1 /\ Set.equal (Map.domain h1) (Map.domain h2)))
//          (ensures  (tip_top tip h2))
//   = ()

// let lemma_tip_top_alloc_eternal_region (tip:rid) (h:HH.t) (r:rid{is_eternal_region r}) (t:Heap.heap)
//   :Lemma (requires (tip_top tip h))
//          (ensures  (tip_top tip (Map.upd h r t)))
//   = ()

let lemma_reveal_tip_top (m:mem) (r:sid)
  :Lemma (r `is_in` m.h <==> r `is_above` m.tip)
  = ()

(******)


(****** downward_closed related lemmas ******)

(*
 * Adding a new region preserves HH.map_invariant and downward_closed
 *)
// let lemma_downward_closed_new_region (h:HH.t) (r:rid{r =!= root}) (t:Heap.heap)
//   :Lemma (requires (let p = parent r in
//                     HH.map_invariant h /\ downward_closed h /\
//                     h `Map.contains` p /\ (p == root \/ (is_stack_region r == is_stack_region p))))
//          (ensures (let h1 = Map.upd h r t in
//                    HH.map_invariant h1 /\ downward_closed h1))
//   = ()

(*
 * Allocating refs does not change the map domain (and rid structure), so HH.map_invariant and downward_closed are retained
 *)
// let lemma_downward_closed_same_domain (h1 h2:HH.t)
//   :Lemma (requires (HH.map_invariant h1 /\ downward_closed h1 /\ Set.equal (Map.domain h1) (Map.domain h2)))
//          (ensures  (HH.map_invariant h2 /\ downward_closed h2))
//   = ()

(******)


(****** rid_ctr_pred related lemmas ******)

(*
 * Expose the meaning of the predicate itself
 *)
let lemma_rid_ctr_pred ()
  :Lemma (forall (m:mem) (r:rid).{:pattern (m.h `Map.contains` r)} m.h `Map.contains` r ==> rid_last_component r < m.rid_ctr)
  = ()

(*
 * If h1 and c1 are in rid_ctr_pred relation, and
 * - h2 is a superset of h1
 * - c2 >= c1
 * - all rids in (h2 - h1) have the last component less than c2
 * Then h2 and c2 are in the rid_ctr_pred relation
 *)
// let lemma_rid_ctr_pred_upd (h1:HH.t) (c1:int) (h2:HH.t) (c2:int)
//   :Lemma (requires (let s1 = Map.domain h1 in
//                     let s2 = Map.domain h2 in
//                     (rid_ctr_pred h1 c1 /\ Set.subset s1 s2 /\ c1 <= c2 /\
// 		     (forall (r:rid). (Set.mem r s2 /\ (not (Set.mem r s1))) ==> rid_last_component r < c2))))
//          (ensures  (rid_ctr_pred h2 c2))
//   = ()
(*****)

let empty_mem (m:HH.t) = 
  let empty_map = Map.restrict (Set.empty) m in 
  let h = Map.upd empty_map root Heap.emp in
  let tip = root in
  assume (rid_last_component root == 0);
  HS 1 h tip
 
let test0 (m:mem) (r:rid{r `is_above` m.tip}) = 
    assert (r `is_in` m.h)

let test1 (m:mem) (r:rid{r `is_above` m.tip}) =
    assert (r=root \/ is_stack_region r)

let test2 (m:mem) (r:sid{m.tip `is_above` r /\ m.tip <> r}) =
   assert (~ (r `is_in` m.h))

let dc_elim (h:HH.t{downward_closed h}) (r:rid{r `is_in` h /\ r <> root}) (s:rid)
  : Lemma (r `is_above` s /\ s `is_in` h ==> is_stack_region r = is_stack_region s)
  = ()

let test3 (m:mem) (r:rid{r <> root /\ is_eternal_region r /\ m.tip `is_above` r /\ is_stack_region m.tip})
  : Lemma (~ (r `is_in` m.h))
  = root_has_color_zero()

let test4 (m:mem) (r:rid{r <> root /\ is_eternal_region r /\ r `is_above` m.tip /\ is_stack_region m.tip})
  : Lemma (~ (r `is_in` m.h))
  = ()

let eternal_region_does_not_overlap_with_tip (m:mem) (r:rid{is_eternal_region r /\ not (HH.disjoint r m.tip) /\ r<>root /\ is_stack_region m.tip})
  : Lemma (requires True)
          (ensures (~ (r `is_in` m.h)))
  = root_has_color_zero()

let poppable m = m.tip <> root

let remove_elt (#a:eqtype) (s:Set.set a) (x:a) = Set.intersect s (Set.complement (Set.singleton x))

let popped m0 m1 =
  poppable m0
  /\ HH.parent m0.tip = m1.tip
  /\ Set.equal (Map.domain m1.h) (remove_elt (Map.domain m0.h) m0.tip)
  /\ Map.equal m1.h (Map.restrict (Map.domain m1.h) m0.h)

let pop (m0:mem{poppable m0}) : Tot mem =
  root_has_color_zero();
  let dom = remove_elt (Map.domain m0.h) m0.tip in
  let h0 = m0.h in
  let h1 = Map.restrict dom m0.h in
  let tip0 = m0.tip in
  let tip1 = HH.parent tip0 in
  assert (forall (r:sid). Map.contains h1 r ==>
  	    (forall (s:sid). includes s r ==> Map.contains h1 s));
  HS m0.rid_ctr h1 tip1

//A (reference a) may reside in the stack or heap, and may be manually managed
//Mark it private so that clients can't use its projectors etc.
//enabling extraction of mreference to just a reference in ML and pointer in C
private
noeq
type mreference' (a:Type) (rel:preorder a) =
  | MkRef : frame:rid -> mrref:HH.mrref frame a rel -> mreference' a rel

let mreference a rel = mreference' a rel

//TODO: rename to frame_of, avoiding the inconsistent use of camelCase
let frameOf (#a:Type) (#rel:preorder a) (r:mreference a rel)
  : Tot rid
  = r.frame

let mrref_of (#a:Type) (#rel:preorder a) (r:mreference a rel)
  : Tot (HH.mrref (frameOf r) a rel)
  = r.mrref

let mk_mreference (#id:rid) (#a:Type) (#rel:preorder a)
                  (r:HH.mrref id a rel)
  : Tot (mreference a rel)
  = MkRef id r

//Hopefully we can get rid of this one
let as_ref #a #rel (x:mreference a rel)
  : Tot (Heap.mref a rel)
  = HH.as_ref (mrref_of x)

//And make this one abstract
let as_addr #a #rel (x:mreference a rel)
  : GTot nat
  = Heap.addr_of (as_ref x)

let is_mm (#a:Type) (#rel:preorder a) (r:mreference a rel) : GTot bool =
  HH.is_mm (mrref_of r)

// Warning: all of the type aliases below get special support for KreMLin
// extraction. If you rename or add to this list,
// src/extraction/FStar.Extraction.Kremlin.fs needs to be updated.

//adding (not s.mm) to stackref and ref so as to keep their semantics as is
let mstackref (a:Type) (rel:preorder a) =
  s:mreference a rel{ is_stack_region (frameOf s)  && not (is_mm s) }

let mref (a:Type) (rel:preorder a) =
  s:mreference a rel{ is_eternal_region (frameOf s) && not (is_mm s) }

let mmmstackref (a:Type) (rel:preorder a) =
  s:mreference a rel{ is_stack_region (frameOf s) && is_mm s }

let mmmref (a:Type) (rel:preorder a) =
  s:mreference a rel{ is_eternal_region (frameOf s) && is_mm s }

//NS: Why do we need this one?
let s_mref (i:rid) (a:Type) (rel:preorder a) = s:mreference a rel{frameOf s = i}

(*
 * The Map.contains conjunct is necessary to prove that upd
 * returns a valid mem. In particular, without Map.contains,
 * we cannot prove the eternal regions invariant that all
 * included regions of a region are also in the map.
 *)

(*
 * AR: this used to be (is_eternal_region i \/ i `is_above` m.tip) /\ Map.contains ...
 *     As far as the memory model is concerned, this could just be Map.contains
 *     The fact that an eternal region is always contained (because of monotonicity) should be used in the ST interface
 *)
let live_region (m:mem) (i:rid) :Tot bool = Map.contains m.h i

let contains (#a:Type) (#rel:preorder a) (m:mem) (s:mreference a rel) :GTot bool =
  let i = frameOf s in
  live_region m i && (FStar.StrongExcludedMiddle.strong_excluded_middle (Heap.contains (Map.sel m.h i) (as_ref s)))

let unused_in (#a:Type) (#rel:preorder a) (r:mreference a rel) (h:mem) :GTot bool =
  HH.unused_in (mrref_of r) h.h

let contains_ref_in_its_region (#a:Type) (#rel:preorder a) (h:mem) (r:mreference a rel) :GTot bool =
  HH.contains_ref_in_its_region (mrref_of r) h.h

let fresh_ref (#a:Type) (#rel:preorder a) (r:mreference a rel) (m0:mem) (m1:mem) :Type0 =
  let i = frameOf r in
  Heap.fresh (as_ref r) (Map.sel m0.h i) (Map.sel m1.h i)

let fresh_region (i:rid) (m0 m1:mem) =
  not (m0.h `Map.contains` i) /\ m1.h `Map.contains` i

abstract val lemma_extends_fresh_disjoint: i:rid -> j:rid -> ipar:rid -> jpar:rid
                               -> m0:mem{HH.map_invariant m0.h} -> m1:mem{HH.map_invariant m1.h} ->
  Lemma (requires (fresh_region i m0 m1
                  /\ fresh_region j m0 m1
                  /\ Map.contains m0.h ipar
                  /\ Map.contains m0.h jpar
                  /\ HH.extends i ipar
                  /\ HH.extends j jpar
                  /\ i<>j))
        (ensures (HH.disjoint i j))
        [SMTPat (fresh_region i m0 m1);
         SMTPat (fresh_region j m0 m1);
         SMTPat (HH.extends i ipar);
         SMTPat (HH.extends j jpar)]
let lemma_extends_fresh_disjoint i j ipar jpar m0 m1 = ()


(*
 * AR: why is this not enforcing live_region ?
 *)
let sel (#a:Type) (#rel:preorder a) (m:mem) (s:mreference a rel)
  : GTot a
  = m.h.[mrref_of s]

let upd (#a:Type) (#rel:preorder a) (m:mem) (s:mreference a rel{live_region m (frameOf s)}) (v:a)
  : GTot mem
  = HS m.rid_ctr (m.h.[mrref_of s] <- v) m.tip

let alloc (#a:Type0) (rel:preorder a) (id:rid) (init:a) (mm:bool) (m:mem{m.h `Map.contains` id})
  :Tot (mreference a rel * mem)
  = let (r, h) = HH.alloc rel id init mm m.h in
    (mk_mreference r), (HS m.rid_ctr h m.tip)

let free (#a:Type0) (#rel:preorder a) (r:mreference a rel{is_mm r}) (m:mem{m `contains` r})
  :Tot mem
  = let i = frameOf r in
    let h = Map.sel m.h i in
    let new_h = Heap.free_mm h (as_ref r) in
    HS m.rid_ctr (Map.upd m.h i new_h) m.tip

let upd_tot (#a:Type) (#rel:preorder a) (m:mem) (r:mreference a rel{m `contains` r}) (v:a)
  :Tot mem
  = let i = frameOf r in
    let h = Map.sel m.h i in
    let new_h = Heap.upd_tot h (as_ref r) v in
    HS m.rid_ctr (Map.upd m.h i new_h) m.tip

let sel_tot (#a:Type) (#rel:preorder a) (m:mem) (r:mreference a rel{m `contains` r})
  :Tot a
  = Heap.sel_tot (Map.sel m.h (frameOf r)) (as_ref r)

let fresh_frame (m0:mem) (m1:mem) =
  not (Map.contains m0.h m1.tip) /\
  HH.parent m1.tip = m0.tip      /\
  m1.h == Map.upd m0.h m1.tip Heap.emp

let push_frame (m:mem) :Tot (m':mem{fresh_frame m m'})
  = let new_tip_rid = HH.extend m.tip m.rid_ctr 1 in
    HS (m.rid_ctr + 1) (Map.upd m.h new_tip_rid Heap.emp) new_tip_rid

let new_eternal_region (m:mem) (parent:rid{is_eternal_region parent /\ m.h `Map.contains` parent})
                       (c:option int{None? c \/ is_eternal_color (Some?.v c)})
  :Tot (t:(rid * mem){fresh_region (fst t) m (snd t)})
  = let new_rid =
      if None? c then HH.extend_monochrome parent m.rid_ctr
      else HH.extend parent m.rid_ctr (Some?.v c)
    in
    let h1 = Map.upd m.h new_rid Heap.emp in
    new_rid, HS (m.rid_ctr + 1) h1 m.tip

let lemma_sel_same_addr (#a:Type0) (#rel:preorder a) (h:mem) (r1:mreference a rel) (r2:mreference a rel)
  :Lemma (requires (frameOf r1 == frameOf r2 /\ h `contains` r1 /\ as_addr r1 = as_addr r2 /\ is_mm r1 == is_mm r2))
         (ensures  (h `contains` r2 /\ sel h r1 == sel h r2))
= let m = Map.sel h.h (frameOf r1) in
  FStar.Monotonic.Heap.lemma_sel_same_addr m (as_ref r1) (as_ref r2)

let lemma_sel_same_addr' (#a:Type0) (#rel:preorder a) (h:mem) (r1:mreference a rel) (r2:mreference a rel)
  :Lemma (requires (frameOf r1 == frameOf r2 /\ h `contains` r1 /\ as_addr r1 = as_addr r2 /\ is_mm r1 == is_mm r2))
         (ensures  (h `contains` r2 /\ sel h r1 == sel h r2))
	 [SMTPat (sel h r1); SMTPat (sel h r2)]
= let m = Map.sel h.h (frameOf r1) in
  FStar.Monotonic.Heap.lemma_sel_same_addr m (as_ref r1) (as_ref r2)

let lemma_upd_same_addr (#a:Type0) (#rel:preorder a) (h:mem) (r1 r2:mreference a rel) (x: a)
  :Lemma (requires (frameOf r1 == frameOf r2 /\ (h `contains` r1 \/ h `contains` r2) /\
                    as_addr r1 == as_addr r2 /\ is_mm r1 == is_mm r2))
         (ensures  (h `contains` r1 /\ h `contains` r2 /\ upd h r1 x == upd h r2 x))
= if StrongExcludedMiddle.strong_excluded_middle (h `contains` r1) then
    lemma_sel_same_addr h r1 r2
  else lemma_sel_same_addr h r2 r1

let lemma_upd_same_addr' (#a:Type0) (#rel:preorder a) (h:mem) (r1 r2:mreference a rel) (x: a)
  :Lemma (requires (frameOf r1 == frameOf r2 /\ (h `contains` r1 \/ h `contains` r2) /\
                    as_addr r1 == as_addr r2 /\ is_mm r1 == is_mm r2))
         (ensures  (h `contains` r1 /\ h `contains` r2 /\ upd h r1 x == upd h r2 x))
         [SMTPat (upd h r1 x); SMTPat (upd h r2 x)]
= if StrongExcludedMiddle.strong_excluded_middle (h `contains` r1) then
    lemma_sel_same_addr h r1 r2
  else lemma_sel_same_addr h r2 r1

let equal_domains (m0:mem) (m1:mem) =
  m0.tip = m1.tip /\
  Set.equal (Map.domain m0.h) (Map.domain m1.h) /\
  (forall r.{:pattern (Map.contains m0.h r) \/ (Map.contains m1.h r)}
       Map.contains m0.h r ==> Heap.equal_dom (Map.sel m0.h r) (Map.sel m1.h r))

let lemma_equal_domains_trans (m0:mem) (m1:mem) (m2:mem) : Lemma
  (requires (equal_domains m0 m1 /\ equal_domains m1 m2))
  (ensures  (equal_domains m0 m2))
  [SMTPat (equal_domains m0 m1); SMTPat (equal_domains m1 m2)]
  = ()

let equal_stack_domains (m0:mem) (m1:mem) =
  m0.tip = m1.tip /\
  (forall r. (is_stack_region r /\ r `is_above` m0.tip) ==>  //AR: TODO: this has no patterns, what's a good pattern here?
        Heap.equal_dom (Map.sel m0.h r) (Map.sel m1.h r))

let lemma_equal_stack_domains_trans (m0:mem) (m1:mem) (m2:mem) : Lemma
  (requires (equal_stack_domains m0 m1 /\ equal_stack_domains m1 m2))
  (ensures  (equal_stack_domains m0 m2))
  [SMTPat (equal_stack_domains m0 m1); SMTPat (equal_stack_domains m1 m2)]
  = ()

let modifies (s:Set.set rid) (m0:mem) (m1:mem) =
  HH.modifies_just s m0.h m1.h /\ m0.tip=m1.tip

let modifies_transitively (s:Set.set rid) (m0:mem) (m1:mem) =
  HH.modifies s m0.h m1.h /\ m0.tip=m1.tip

let heap_only (m0:mem) = m0.tip = root

let top_frame (m:mem) = Map.sel m.h m.tip

let modifies_drop_tip (m0:mem) (m1:mem) (m2:mem) (s:Set.set rid)
    : Lemma (fresh_frame m0 m1 /\
             modifies_transitively (Set.union s (Set.singleton m1.tip)) m1 m2 ==>
             modifies_transitively s m0 (pop m2))
    = ()

private let lemma_pop_is_popped (m0:mem{poppable m0})
  : Lemma (popped m0 (pop m0))
  = let m1 = pop m0 in
    assert (Set.equal (Map.domain m1.h) (remove_elt (Map.domain m0.h) m0.tip))

let modifies_one id h0 h1 = HH.modifies_one id h0.h h1.h
let modifies_ref (id:rid) (s:Set.set nat) (h0:mem) (h1:mem) =
  HH.modifies_rref id s h0.h h1.h /\ h1.tip=h0.tip

let lemma_upd_1 #a #rel (h:mem) (x:mreference a rel) (v:a{rel (sel h x) v}) : Lemma
  (requires (contains h x))
  (ensures (contains h x
            /\ modifies_one (frameOf x) h (upd h x v)
            /\ modifies_ref (frameOf x) (Set.singleton (as_addr x)) h (upd h x v)
            /\ sel (upd h x v) x == v ))
  [SMTPat (upd h x v); SMTPat (contains h x)]
  = ()

let lemma_upd_2 (#a:Type) (#rel:preorder a) (h:mem) (x:mreference a rel) (v:a{rel (sel h x) v}) : Lemma
  (requires (frameOf x = h.tip /\ x `unused_in` h))
  (ensures (frameOf x = h.tip
            /\ modifies_one h.tip h (upd h x v)
            /\ modifies_ref h.tip Set.empty h (upd h x v)
            /\ sel (upd h x v) x == v ))
  [SMTPat (upd h x v); SMTPat (x `unused_in` h)]
  = ()

val lemma_live_1: #a:Type ->  #a':Type -> #rel:preorder a -> #rel':preorder a'
                  -> h:mem -> x:mreference a rel -> x':mreference a' rel' -> Lemma
  (requires (contains h x /\ x' `unused_in` h))
  (ensures  (frameOf x <> frameOf x' \/ ~ (as_ref x === as_ref x')))
  [SMTPat (contains h x); SMTPat (x' `unused_in` h)]
let lemma_live_1 #a #a' #rel #rel' h x x' = ()

let above_tip_is_live (#a:Type) (#rel:preorder a) (m:mem) (x:mreference a rel) : Lemma
  (requires (frameOf x `is_above` m.tip))
  (ensures (frameOf x `is_in` m.h))
  = ()

let coerce_mrref (#id1:rid) (#id2:rid) (#a:Type) (#rel:preorder a)
                 (r:mrref id1 a rel{id1 == id2})
    : mrref id2 a rel
    = r

noeq type some_ref =
  | Ref : #a:Type0 -> #rel:preorder a -> mreference a rel -> some_ref

let some_refs = list some_ref

let rec regions_of_some_refs (rs:some_refs) : Tot (Set.set rid) =
  match rs with
  | [] -> Set.empty
  | (Ref r)::tl -> Set.union (Set.singleton (frameOf r)) (regions_of_some_refs tl)

let rec refs_in_region (r:rid) (rs:some_refs) : GTot (Set.set nat) =
  match rs with
  | []         -> Set.empty
  | (Ref x)::tl ->
    Set.union (if frameOf x=r then Set.singleton (as_addr x) else Set.empty)
              (refs_in_region r tl)

unfold let mods (rs:some_refs) h0 h1 =
    modifies (normalize_term (regions_of_some_refs rs)) h0 h1
  /\ (forall (r:rid). modifies_ref r (normalize_term (refs_in_region r rs)) h0 h1)

////////////////////////////////////////////////////////////////////////////////
let eternal_disjoint_from_tip (h:mem{is_stack_region h.tip})
                              (r:rid{is_eternal_region r /\
                                     r<>root /\
                                     r `is_in` h.h})
   : Lemma (HH.disjoint h.tip r)
   = ()

////////////////////////////////////////////////////////////////////////////////
#set-options "--initial_fuel 0 --max_fuel 0"
let f (a:Type0) (b:Type0) (rel_a:preorder a) (rel_b:preorder b) (rel_n:preorder nat)
                          (x:mreference a rel_a) (x':mreference a rel_a)
                          (y:mreference b rel_b) (z:mreference nat rel_n)
                          (h0:mem) (h1:mem) =
  assume (h0 `contains` x);
  assume (h0 `contains` x');
  assume (as_addr x <> as_addr x');
  assume (frameOf x == frameOf x');
  assume (frameOf x <> frameOf y);
  assume (frameOf x <> frameOf z);
  //assert (Set.equal (normalize_term (refs_in_region x.id [Ref x])) (normalize_term (Set.singleton (as_addr x))))
  assume (mods [Ref x; Ref y; Ref z] h0 h1);
  //AR: TODO: this used to be an assert, but this no longer goers through
  //since now we have set of nats, which plays badly with normalize_term
  //on one side it remains nat, on the other side the normalizer normalizes it to a refinement type
  //see for example the assertion above that doesn't succeed
  assume (modifies_ref (frameOf x) (Set.singleton (as_addr x)) h0 h1);
  assert (modifies (Set.union (Set.singleton (frameOf x))
                              (Set.union (Set.singleton (frameOf y))
                                         (Set.singleton (frameOf z)))) h0 h1);
  ()


 //--------------------------------------------------------------------------------
  //assert (sel h0 x' == sel h1 x')

(* let f2 (a:Type0) (b:Type0) (x:reference a) (y:reference b) *)
(*                         (h0:mem) (h1:mem) =  *)
(*   assume (HH.disjoint (frameOf x) (frameOf y)); *)
(*   assume (mods [Ref x; Ref y] h0 h1); *)
(*  //-------------------------------------------------------------------------------- *)
(*   assert (modifies_ref x.id (TSet.singleton (as_aref x)) h0 h1) *)

(* let rec modifies_some_refs (i:some_refs) (rs:some_refs) (h0:mem) (h1:mem) : GTot Type0 = *)
(*   match i with *)
(*   | [] -> True *)
(*   | Ref x::tl -> *)
(*     let r = x.id in *)
(*     (modifies_ref r (normalize_term (refs_in_region r rs)) h0 h1 /\ *)
(*      modifies_some_refs tl rs h0 h1) *)

(* unfold let mods_2 (rs:some_refs) h0 h1 = *)
(*     modifies (normalize_term (regions_of_some_refs rs)) h0 h1 *)
(*   /\ modifies_some_refs rs rs h0 h1 *)

(* #reset-options "--log_queries --initial_fuel 0 --max_fuel 0 --initial_ifuel 0 --max_ifuel 0" *)
(* #set-options "--debug FStar.HyperStack --debug_level print_normalized_terms" *)
(* let f3 (a:Type0) (b:Type0) (x:reference a) *)
(*                         (h0:mem) (h1:mem) =  *)
(*   assume (mods_2 [Ref x] h0 h1); *)
(*  //-------------------------------------------------------------------------------- *)
(*   assert (modifies_ref x.id (TSet.singleton (as_aref x)) h0 h1) *)


(*** Untyped views of references *)

(* Definition and ghost decidable equality *)

noeq abstract type aref: Type0 =
| ARef:
    (aref_region: rid) ->
    (aref_aref: HH.aref aref_region) ->
    aref

abstract let dummy_aref : aref = ARef _ (HH.dummy_aref root)

abstract let aref_equal
  (a1 a2: aref)
: Ghost bool
  (requires True)
  (ensures (fun b -> b == true <==> a1 == a2))
= a1.aref_region = a2.aref_region && HH.aref_equal a1.aref_aref a2.aref_aref

(* Introduction rule *)

abstract let aref_of
  (#t: Type)
  (#rel: preorder t)
  (r: mreference t rel)
: Tot aref
= ARef (frameOf r) (HH.aref_of (mrref_of r))

(* Operators lifted from reference *)

abstract let frameOf_aref
  (a: aref)
: GTot rid
= a.aref_region

abstract let frameOf_aref_of
  (#t: Type)
  (#rel: preorder t)
  (r: mreference t rel)
: Lemma
  (frameOf_aref (aref_of r) == frameOf r)
  [SMTPat (frameOf_aref (aref_of r))]
= ()

abstract let aref_as_addr
  (a: aref)
: GTot nat
= HH.addr_of_aref a.aref_aref

abstract let aref_as_addr_aref_of
  (#t: Type)
  (#rel: preorder t)
  (r: mreference t rel)
: Lemma
  (aref_as_addr (aref_of r) == as_addr r)
  [SMTPat (aref_as_addr (aref_of r))]
= HH.addr_of_aref_of (mrref_of r)

abstract let aref_is_mm
  (r: aref)
: GTot bool
= HH.aref_is_mm r.aref_aref

abstract let is_mm_aref_of
  (#t: Type)
  (#rel: preorder t)
  (r: mreference t rel)
: Lemma
  (aref_is_mm (aref_of r) == is_mm r)
  [SMTPat (aref_is_mm (aref_of r))]
= HH.is_mm_aref_of (mrref_of r)

abstract let aref_unused_in
  (a: aref)
  (h: mem)
: GTot Type0
= ~ (live_region h a.aref_region) \/
  HH.aref_unused_in a.aref_aref h.h

abstract let unused_in_aref_of
  (#t: Type)
  (#rel: preorder t)
  (r: mreference t rel)
  (h: mem)
: Lemma
  (aref_unused_in (aref_of r) h <==> unused_in r h)
  [SMTPat (aref_unused_in (aref_of r) h)]
= HH.unused_in_aref_of (mrref_of r) h.h

abstract
val contains_aref_unused_in: #a:Type -> #rel: preorder a -> h:mem -> x:mreference a rel -> y:aref -> Lemma
  (requires (contains h x /\ aref_unused_in y h))
  (ensures  (frameOf x <> frameOf_aref y \/ as_addr x <> aref_as_addr y))
  [SMTPat (contains h x); SMTPat (aref_unused_in y h)]
let contains_aref_unused_in #a #rel h x y =
  if frameOf x = frameOf_aref y
  then 
    Heap.contains_aref_unused_in (Map.sel h.h (frameOf x)) (as_ref x) (HH.as_heap_aref y.aref_aref) // HH.contains_ref_aref_unused_in h.h (mrref_of x) y.aref_aref
  else ()

(* Elimination rule *)

abstract
let aref_live_at
  (h: mem)
  (a: aref)
  (v: Type)
  (rel: preorder v)
: GTot Type0
= live_region h a.aref_region
  /\ HH.aref_live_at h.h a.aref_aref v rel

abstract
let greference_of
  (a: aref)
  (v: Type)
  (rel: preorder v)
: Ghost (mreference v rel)
  (requires (exists h . aref_live_at h a v rel))
  (ensures (fun _ -> True))
= MkRef a.aref_region (HH.grref_of a.aref_aref v rel)

abstract
let reference_of
  (h: mem)
  (a: aref)
  (v: Type)
  (rel: preorder v)
: Pure (mreference v rel)
  (requires (aref_live_at h a v rel))
  (ensures (fun x -> aref_live_at h a v rel /\ frameOf x == frameOf_aref a /\ as_addr x == aref_as_addr a /\ is_mm x == aref_is_mm a))
= MkRef a.aref_region (HH.rref_of h.h a.aref_aref v rel)

abstract
let aref_live_at_aref_of
  (h: mem)
  (#t: Type0)
  (#rel: preorder t)
  (r: mreference t rel)
: Lemma
  (aref_live_at h (aref_of r) t rel <==> contains h r)
  [SMTPat (aref_live_at h (aref_of r) t rel)]
= admit ()

abstract
let contains_greference_of
  (h: mem)
  (a: aref)
  (t: Type0)
  (rel: preorder t)
: Lemma
  (requires (exists h' . aref_live_at h' a t rel))
  (ensures ((exists h' . aref_live_at h' a t rel) /\ (contains h (greference_of a t rel) <==> aref_live_at h a t rel)))
  [SMTPatOr [
    [SMTPat (contains h (greference_of a t rel))];
    [SMTPat (aref_live_at h a t rel)];
  ]]
= admit ()

abstract
let aref_of_greference_of
  (a: aref)
  (v: Type0)
  (rel: preorder v)
: Lemma
  (requires (exists h' . aref_live_at h' a v rel))
  (ensures ((exists h' . aref_live_at h' a v rel) /\ aref_of (greference_of a v rel) == a))
  [SMTPat (aref_of (greference_of a v rel))]
= ()

(* Operators lowered to rref *)

abstract let frameOf_greference_of
  (a: aref)
  (t: Type)
  (rel: preorder t)
: Lemma
  (requires (exists h . aref_live_at h a t rel))
  (ensures ((exists h . aref_live_at h a t rel) /\ frameOf (greference_of a t rel) == frameOf_aref a))
  [SMTPat (frameOf (greference_of a t rel))]
= ()

abstract
let as_addr_greference_of
  (a: aref)
  (t: Type0)
  (rel: preorder t)
: Lemma
  (requires (exists h . aref_live_at h a t rel))
  (ensures ((exists h . aref_live_at h a t rel) /\ as_addr (greference_of a t rel) == aref_as_addr a))
  [SMTPat (as_addr (greference_of a t rel))]
= assert (addr_of (grref_of a.aref_aref t rel) == addr_of_aref a.aref_aref)

abstract
let is_mm_greference_of
  (a: aref)
  (t: Type0)
  (rel: preorder t)
: Lemma
  (requires (exists h . aref_live_at h a t rel))
  (ensures ((exists h . aref_live_at h a t rel) /\ is_mm (greference_of a t rel) == aref_is_mm a))
  [SMTPat (is_mm (greference_of a t rel))]
= ()

abstract
let unused_in_greference_of
  (a: aref)
  (t: Type0)
  (rel: preorder t)
  (h: mem)
: Lemma
  (requires (exists h . aref_live_at h a t rel))
  (ensures ((exists h . aref_live_at h a t rel) /\ (unused_in (greference_of a t rel) h <==> aref_unused_in a h)))
  [SMTPat (unused_in (greference_of a t rel) h)]
= ()

abstract
let sel_reference_of
  (a: aref)
  (v: Type0)
  (rel: preorder v)
  (h1 h2: mem)
: Lemma
  (requires (aref_live_at h1 a v rel /\ aref_live_at h2 a v rel))
  (ensures (aref_live_at h2 a v rel /\ sel h1 (reference_of h2 a v rel) == sel h1 (greference_of a v rel)))
  [SMTPat (sel h1 (reference_of h2 a v rel))]
= ()

abstract
let upd_reference_of
  (a: aref)
  (v: Type0)
  (rel: preorder v)
  (h1 h2: mem)
  (x: v)
: Lemma
  (requires (aref_live_at h1 a v rel /\ aref_live_at h2 a v rel))
  (ensures (aref_live_at h1 a v rel /\ aref_live_at h2 a v rel /\ upd h1 (reference_of h2 a v rel) x == upd h1 (greference_of a v rel) x))
  [SMTPat (upd h1 (reference_of h2 a v rel) x)]
= ()
