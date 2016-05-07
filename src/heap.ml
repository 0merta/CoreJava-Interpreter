open Core.Std
type t = (Syntax.value * heapEntry) list
and heapEntry = {id: Syntax.id; env: Syntax.typeValue Environment.t}
exception Not_bound

let empty = []
let _nextLocation = ref 0
let nextLocation () = Syntax.LocV !_nextLocation
let extend x v heap = let newHeap = (Syntax.LocV !_nextLocation, v) :: heap in
  _nextLocation := !_nextLocation + 1; newHeap

let rec union lst heap = match lst with
  | [] -> heap
  | (x :: xs) -> x :: union xs heap

let rec update loc field nv heap = match heap with
  | [] -> empty
  | (key, he) :: tl ->
    if key = loc then
      let nEnv = Environment.update field nv he.env in
      (key, {he with env = nEnv}) :: tl
    else (key,he) :: update loc field nv tl

let isIn loc heap =
  try let _ = List.find_exn heap ~f:(fun (x, _)-> x = loc) in true with Not_found -> false

let getFieldEnv_exn loc heap =
  let (_, objVal) = List.find_exn heap ~f:(fun (x, _) -> x = loc) in objVal.env

let getObjectType_exn loc heap =
  let (_, objVal) = List.find_exn heap ~f:(fun (x, _) -> x = loc) in Syntax.ObjectType objVal.id
