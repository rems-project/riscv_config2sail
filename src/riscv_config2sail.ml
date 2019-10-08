(**************************************************************************)
(*     Sail                                                               *)
(*                                                                        *)
(*  Copyright (c) 2019                                                    *)
(*    Robert Norton-Wright                                                *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*                                                                        *)
(*  This software was developed by the University of Cambridge Computer   *)
(*  Laboratory as part of the Rigorous Engineering of Mainstream Systems  *)
(*  (REMS) project, funded by EPSRC grant EP/K008528/1.                   *)
(*                                                                        *)
(*  Redistribution and use in source and binary forms, with or without    *)
(*  modification, are permitted provided that the following conditions    *)
(*  are met:                                                              *)
(*  1. Redistributions of source code must retain the above copyright     *)
(*     notice, this list of conditions and the following disclaimer.      *)
(*  2. Redistributions in binary form must reproduce the above copyright  *)
(*     notice, this list of conditions and the following disclaimer in    *)
(*     the documentation and/or other materials provided with the         *)
(*     distribution.                                                      *)
(*                                                                        *)
(*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''    *)
(*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     *)
(*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A       *)
(*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR   *)
(*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,          *)
(*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      *)
(*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF      *)
(*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND   *)
(*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,    *)
(*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT    *)
(*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF    *)
(*  SUCH DAMAGE.                                                          *)
(**************************************************************************)

open Rresult
   
let opt_file_out : string option ref = ref None
let opt_file_arguments = ref ([]:string list)
let options = Arg.align ([
  ( "-o",
    Arg.String (fun f -> opt_file_out := Some f),
    "<file> select output filename");
] )

let usage_msg =
    ("riscv_config2sail " (*^ "pre beta"*) ^ "\n"
     ^ "usage:       riscv_config2sail <file1.sail> .. <fileN.sail>\n"
    )

let _ =
  Arg.parse options
    (fun s ->
      opt_file_arguments := (!opt_file_arguments) @ [s])
    usage_msg

let rec flatten_yaml : string -> int -> Yaml.value -> (string * string) list = fun prefix i yaml -> match yaml with
  | `Null      -> []
  | `Bool b    -> [(prefix, if b then "true" else "false")]
  | `Float f   -> [(prefix, string_of_int (int_of_float f))]
  | `String s  -> [(prefix, "\"" ^ s ^ "\"")]
  | `A (v::vs) -> flatten_yaml (prefix ^ "_" ^ (string_of_int i)) 0 v @ (flatten_yaml prefix (i+1) (`A vs))
  | `A ([])    -> []
  | `O ((s,v)::vs) -> flatten_yaml (prefix ^ "_" ^ s) i v @ (flatten_yaml prefix i (`O vs))
  | `O ([])    -> []


let main () = begin
    let yaml_result = match !opt_file_arguments with
      | f::_ -> Yaml_unix.of_file Fpath.(v f) (* TODO handle more than one file argument *)
      | []   -> raise (Invalid_argument "Please give a yaml file.") in
    let flattened_yaml = match yaml_result with
      | Ok v -> flatten_yaml "yaml" 0 v
      | Error _ -> raise (Failure "Failed to parse ocaml.") in
    print_endline (String.concat "\n" (List.map (fun (i, v) -> i ^ " = " ^ v) flattened_yaml))
  end

let _ = main ()
