(* Final Exam --- December 27, 2021  
You are allowed to search and use any property provided in the 
standard library of Coq. *)

(* 10195101525 邓文倩 *)

Require Import Nat.
Require Import List.
From Coq Require Import Lia.

Notation "[ ]" := nil. 
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).


Definition admit {T: Type} : T.  Admitted.

(* 0. 用到的引理 *)
Theorem plus_comm : forall n m : nat,
  n + m = m + n.
Proof.
  intros n m. induction n as [|n' IHn'].
  - simpl. rewrite <- plus_n_O. reflexivity.
  - simpl. rewrite IHn'. rewrite plus_n_Sm. reflexivity.
Qed.

Theorem mult_1_r : forall n:nat,
  n = n * 1.
Proof.
  intros n. induction n as [|n' IHn'].
  - simpl. reflexivity.
  - simpl. rewrite <- IHn'. reflexivity. 
Qed.

Theorem mult_1_n : forall n : nat,
  n * 1 = 1 * n.
Proof. 
  intros n. induction n.
  - simpl. reflexivity.
  - simpl. f_equal. rewrite <- mult_1_r. rewrite plus_comm. simpl. reflexivity.
Qed.

Theorem add_assoc : forall n m p : nat,
  n + (m + p) = (n + m) + p.
Proof.
  intros n m p.
  induction n as [| n' IHn'].
  - reflexivity.
  - simpl. rewrite IHn'. reflexivity.
Qed.

Theorem mult_0_r : forall n:nat,
  n * 0 = 0.
Proof.
  intros n. induction n as [|n' IHn'].
  - simpl. reflexivity.
  - simpl. rewrite -> IHn'. reflexivity. 
Qed.

(* 1. Prove the following fact about natural numbers. *)

Lemma mul_2_r : forall  n : nat, 
  (n + 1) * 2 = n + n + 2.
Proof. 
  intros n. induction n as [| n' IH].
  - simpl. reflexivity.
  - simpl. rewrite IH. f_equal. rewrite <- plus_Sn_m. rewrite plus_n_Sm. reflexivity.
Qed.


(* 2. Define a function called squared so that (squared n) returns true 
iff n is a squared number, i.e. n = n' * n' for some n'. *)

Fixpoint find_num (n target: nat) : nat :=
  if n * n <=? target then n
  else match n with
       | 0 => 0
       | S n' => find_num n' target
       end.

Definition squared (n : nat) : bool :=
  match n with
  | 0 => true
  | S n' => if ((find_num n n) * (find_num n n) =? n) then true
            else false
  end.

Example square_test1 : squared 8 = false.
Proof. reflexivity. Qed.

Example square_test2 : squared 25 = true.
Proof. reflexivity. Qed.


(* 3. Let two sequences of numbers F1(n) and F2(n) be given as follows.
   F1(0) = 0
   F1(n) = F1(n-1) + 2 * n   for n > 0.

   F2(0) = F2(1) = 1
   F2(n+2) = F2(n) + F2(n+1)    for n >= 0.

Define the function Seq such that (Seq n) returns the sequence

[F1(0); F2(0); F1(1); F2(1); ... ; F1(n); F2(n)].
*)

Fixpoint get_F1 (n : nat) : nat :=
  match n with
  | 0 => 0
  | S n' => get_F1 n' + 2 * n
  end.

Fixpoint get_F2 (n : nat) : nat :=
  match n with
  | 0 => 1
  | 1 => 1
  | S n' => get_F2 n' + get_F2 (n' - 1)
  end.

Fixpoint Seq (n: nat) : list nat :=
  match n with
  | 0 => [0; 1]
  | S n' => Seq n' ++ [get_F1 n; get_F2 n]
  end.

Example Seq_test :  Seq 5 = [0; 1; 2; 1; 6; 2; 12; 3; 20; 5; 30; 8].
Proof. reflexivity. Qed.


(* 4. Let oddn be the predicate that tests whether a given number
is odd or not. Show that the multiplication of two odd numbers is odd. *)

Inductive oddn : nat -> Prop :=
 | odd1 : oddn 1
 | odd2 : forall n, oddn n -> oddn (S (S n)).


Theorem odd_helper : forall (n m : nat), oddn n -> oddn m -> oddn ( n + n + m).
Proof.
  intros n m Hn Hm.
  induction Hn.
  - simpl. apply odd2. apply Hm.
  - simpl. assert (n + S (S n) = S (S (n + n))) as H.
    { rewrite PeanoNat.Nat.add_succ_r. rewrite PeanoNat.Nat.add_succ_r. reflexivity. }
   rewrite H. simpl. apply odd2. apply odd2. apply IHHn.
Qed.


Theorem odd_mul : forall n m, oddn n -> oddn m -> oddn (n * m).
Proof.
  intros n m Hn Hm.
  induction Hn as [| n' Hn' IHn'].
  - simpl. rewrite <- plus_n_O. apply Hm.
  - simpl. destruct Hm.
    + simpl. apply odd2. apply IHn'.
    + simpl. rewrite PeanoNat.Nat.add_succ_r. rewrite PeanoNat.Nat.add_succ_r. simpl.
      apply odd2. apply odd2. rewrite add_assoc. apply odd_helper.
      * apply Hm.
      * apply IHn'.
Qed.

(* 5. Write a function (partition):

      partition : list nat -> list (list nat )

   which partitions a list into a list of 3 sublists. The first sublist
   contains all odd numbers divisible by 3 in the original list. 
   The second sublist contains all other odd numbers in the original list. 
   The last sublist contains all the even numbers in the original list. 
   The order of elements in the three sublists should be the same as their 
   order in the original list. 

   Hint: You may use the Coq function (filter).
*)

Fixpoint div3 (n : nat) : bool :=
  match n with
  |O => true
  |S n' => match (leb n' 1) with
           |true => false
           |false => div3 (n'- 2)
           end
  end.

Definition partition (l : list nat) : list (list nat) :=
  match l with
  |[] => [[];[];[]]
  |h :: t => [filter (fun n => andb (odd n) (div3 n)) l; filter (fun n => andb (odd n) (negb (div3 n))) l; filter even l ]
  end.

Example partition_test: 
  partition [1;2;3;9;4;5;6;15;8] = [[3; 9; 15]; [1; 5]; [2; 4; 6; 8]].
Proof. reflexivity. Qed.


(* 6. We call a natural number good if the sum of all 
   its digits is divisible by 5. For example 122 is good 
   but 93 is not. Define a function count such that 
   (count n) returns the number of good numbers smaller than 
   or equal to n. Here we assume that 0 <= n < 10000. 
   Hint: You may find the "let ... in" struct useful. You may 
   directly use the div and modulo functions defined in the 
   standard library of Coq. *)

Fixpoint div5 (n : nat) : bool :=
  match n with
  |O => true
  |S n' => match (leb n' 3) with
           |true => false
           |false => div5 (n'-4)
           end
  end.

Fixpoint sum (k n : nat) : nat :=
  match k with
  | 0 => 0
  | S k' => (sum k' (div n 10)) + (modulo n 10)
  end.

Fixpoint count (n : nat) : nat :=
  match n with
  | O => 1
  | S n' => if div5 (sum 5 n) then 1 + count n' else count n'
  end.

Example count_test1 : count 15 = 3.
Proof. reflexivity. Qed.

Example count_test2 : count 2005 = 401.
Proof. reflexivity. Qed.

(* 7. Prove the following fact about excluded middle. *)

Theorem de_morgan : 
   (forall P, P \/ ~P) -> (forall P Q, ~(~P /\ ~Q) -> P \/Q).
Proof. 
  intros H P Q HPQ.
  unfold not in HPQ.
  assert (P \/ ~P) as HP. { apply H. }
  assert (Q \/ ~Q) as HQ. { apply H. }
  destruct HP.
  - left. apply H0.
  - destruct HQ.
    + right. apply H1.
    + exfalso. apply HPQ. split.
      * apply H0.
      * apply H1.
Qed.


(* 8. Consider the following type:

Inductive btree : Set :=
 | leaf : nat -> btree 
 | node : nat -> btree -> btree -> btree.
 
Define a function to give a preorder traversal of the tree and collect
all the odd numbers in a list. 
*)

Inductive btree : Set :=
 | leaf : nat -> btree 
 | node : nat -> btree -> btree -> btree.

Fixpoint preorder (t: btree) : list nat :=
 match t with 
 | leaf n => if odd n then [n]
             else []
 | node n l r => if odd n then [n] ++ preorder l ++ preorder r
                 else preorder l ++ preorder r
 end.

Example bt_test : preorder (node 5 (node 1 (leaf 0) (node 3 (leaf 2) (leaf 4))) 
                                   (node 9 (node 7 (leaf 6) (leaf 8)) (leaf 10))) 
                   = [5; 1; 3; 9; 7].
Proof. reflexivity. Qed.


(* 9. Write in Coq a function that swaps the maximum and minimum
elements in a list while keeping other elements unchanged. Suppose
all the elements in the input list are distinct and they range from 1 to 100.
*)

Fixpoint max (s : list nat) : nat :=
  match s with
  | [] => 0
  | h :: t => let v := max t in
              if h <? v then v else h
  end.

Fixpoint min (s : list nat) : nat :=
  match s with
  | [] => 200
  | h :: t => let v := min t in
              if v <? h then v else h
  end.

Fixpoint replace (max min : nat) (l : list nat) : list nat :=
  match l with
  | [] => []
  | h::t => if h =? max then min::(replace max min t)
            else if h =? min then max::(replace max min t)
            else h::(replace max min t)
  end.

Definition swap (l : list nat) : list nat :=
  let mmax := max l in
  let mmin := min l in
  let l1 := replace mmax mmin l in
  match l with
  | [] => []
  | h::t => l1
  end.


Example swap_test : swap [3;7;2;5;1;4;6] = [3;1;2;5;7;4;6].
Proof. reflexivity. Qed.


(* 10. The following definitions specify the abstract syntax of
    some arithmetic expressions and an evaluation function. *)

Inductive aexp : Type :=
  | ANum : nat -> aexp
  | APlus : aexp -> aexp -> aexp
  | AMinus : aexp -> aexp -> aexp
  | AMult : aexp -> aexp -> aexp.

Fixpoint aeval (a : aexp) : nat :=
  match a with
  | ANum n => n
  | APlus a1 a2 => (aeval a1) + (aeval a2)
  | AMinus a1 a2 => (aeval a1) - (aeval a2)
  | AMult a1 a2 => (aeval a1) * (aeval a2)
  end.

(* Suppose we define a function that takes an arithmetic expression 
   and slightly simplifies it, changing every occurrence of [e + 0],
   [e - 0] or [e * 1] into [e], and [e * 0] into [0]. *)

Fixpoint optimize (a:aexp) : aexp :=
  match a with
  |ANum n => ANum n
  |APlus e1 (ANum 0) => optimize e1
  |APlus e1 e2 => APlus (optimize e1) (optimize e2)
  |AMinus e1 (ANum 0) => optimize e1 
  |AMinus e1 e2 => AMinus (optimize e1) (optimize e2)
  |AMult e1 (ANum 0) => ANum 0
  |AMult e1 (ANum 1) => optimize e1
  |AMult e1 e2 => AMult (optimize e1) (optimize e2)
  end.

(* Prove the following theorem that states the correctness of the 
optimization with respect to the evaluation of arithmetic expressions. *)

Theorem optimize_mult1_sound: forall a,
  aeval (optimize a) = aeval a.
Proof. 
   intros a. induction a as [n | a1 IHa1 a2 IHa2| a1 IHa1 a2 IHa2| a1 IHa1 a2 IHa2].
 - simpl. reflexivity.
 - destruct a2.
    + destruct n. 
      * simpl. rewrite plus_comm. simpl. rewrite IHa1. reflexivity.
      * simpl. rewrite IHa1. reflexivity.
    + simpl in IHa2. simpl. rewrite IHa2. rewrite IHa1. reflexivity.
    + simpl. simpl in IHa2. rewrite IHa2. rewrite IHa1. reflexivity.
    + simpl. simpl in IHa2. rewrite IHa2. rewrite IHa1. reflexivity.
 - destruct a2.
    + simpl. destruct n.
      * rewrite PeanoNat.Nat.sub_0_r with (n := aeval a1). apply IHa1. 
      * simpl. rewrite IHa1. reflexivity.
    + simpl in IHa2. simpl. rewrite IHa2. rewrite IHa1. reflexivity.
    + simpl. simpl in IHa2. rewrite IHa2. rewrite IHa1. reflexivity.
    + simpl. simpl in IHa2. rewrite IHa2. rewrite IHa1. reflexivity.
 - destruct a2.
    + destruct n eqn:En. 
      * simpl. symmetry. apply mult_0_r.
      * destruct n0. simpl. rewrite <- mult_1_r. apply IHa1. simpl. rewrite IHa1. reflexivity.
    + simpl in IHa2. simpl. rewrite IHa2. rewrite IHa1. reflexivity.
    + simpl. simpl in IHa2. rewrite IHa2. rewrite IHa1. reflexivity.
    + simpl. simpl in IHa2. rewrite IHa2. rewrite IHa1. reflexivity.
Qed.
