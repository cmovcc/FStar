﻿(*
   Copyright 2008-2014 Nikhil Swamy and Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
#light "off"
// (c) Microsoft Corporation. All rights reserved
module FStar.Syntax.Subst

open FStar
open FStar.Syntax
open FStar.Syntax.Syntax
open FStar.Util

val subst: list<subst_elt> -> term -> term
val subst_comp: list<subst_elt> -> comp -> comp
val compress: term -> term

(* Consider removing these *)
type imap<'env> = 'env -> term -> (term * 'env)
type mapper<'env> = imap<'env> -> imap<'env>
type tm_components = list<universe> * binders * list<term> * list<comp> * list<arg>
val reduce: mapper<'env> -> (term -> list<tm_components> -> 'env -> (term * 'env)) -> imap<'env>
val combine: term -> list<tm_components> -> 'env -> (term * 'env)
