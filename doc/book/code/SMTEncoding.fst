module SMTEncoding

let false_boolean = false
let true_boolean = true

let add3 (x y z:int) : int = x + y + z
open FStar.Mul
let rec factorial (n:nat) : nat =
  if n = 0 then 1
  else n * factorial (n - 1)

let test = assert (factorial 1 == 1)

assume Factorial_unbounded: forall (x:nat). exists (y:nat). factorial y > x

#push-options "--fuel 4 --ifuel 0 --query_stats --log_queries --z3rlimit_factor 2"
#restart-solver
let _test_query_stats = assert (factorial 3 == 6)

type unat = 
  | Z : unat
  | S : (prec:unat) -> unat

#push-options "--ifuel 0"

let rec as_nat (x:unat) : nat = 
  allow_inversion unat;
  match x with
  | S x -> 1 + as_nat x
  | Z -> 0
#pop-options

// let fact_positive = forall (x:nat). factorial x >= 1
// let fact_positive_2 = forall (x:nat).{:pattern (factorial x)} factorial x >= 1

// let fact_unbounded = forall (n:nat). exists (x:nat). factorial x >= n

// let fact_unbounded2 = forall (n:nat). exists (x:nat). {:pattern (factorial x >= n)} factorial x >= n

let id (x:Type0) = x

let force_a_query = assert (id True)

