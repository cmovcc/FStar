open Prims
let (_z3hash_checked : Prims.bool FStar_ST.ref) = FStar_Util.mk_ref false 
let (_z3hash_expected : Prims.string) = "1f29cebd4df6" 
let (_z3url : Prims.string) =
  "https://github.com/FStarLang/binaries/tree/master/z3-tested" 
let (parse_z3_version_lines :
  Prims.string -> Prims.string FStar_Pervasives_Native.option) =
  fun out  ->
    match FStar_Util.splitlines out with
    | x::uu____24 ->
        let trimmed = FStar_Util.trim_string x  in
        let parts = FStar_Util.split trimmed " "  in
        let rec aux uu___120_40 =
          match uu___120_40 with
          | hash::[] ->
              let n1 =
                Prims.min (FStar_String.strlen _z3hash_expected)
                  (FStar_String.strlen hash)
                 in
              let hash_prefix =
                FStar_String.substring hash (Prims.parse_int "0") n1  in
              if hash_prefix = _z3hash_expected
              then
                ((let uu____51 = FStar_Options.debug_any ()  in
                  if uu____51
                  then
                    let msg =
                      FStar_Util.format1
                        "Successfully found expected Z3 commit hash %s\n"
                        hash
                       in
                    FStar_Util.print_string msg
                  else ());
                 FStar_Pervasives_Native.None)
              else
                (let msg =
                   FStar_Util.format2
                     "Expected Z3 commit hash \"%s\", got \"%s\""
                     _z3hash_expected trimmed
                    in
                 FStar_Pervasives_Native.Some msg)
          | uu____56::q -> aux q
          | uu____60 ->
              FStar_Pervasives_Native.Some "No Z3 commit hash found"
           in
        aux parts
    | uu____63 -> FStar_Pervasives_Native.Some "No Z3 version string found"
  
let (z3hash_warning_message :
  unit ->
    (FStar_Errors.raw_error,Prims.string) FStar_Pervasives_Native.tuple2
      FStar_Pervasives_Native.option)
  =
  fun uu____76  ->
    let run_proc_result =
      try
        let uu____87 =
          let uu____88 = FStar_Options.z3_exe ()  in
          FStar_Util.run_process "z3_version" uu____88 ["-version"]
            FStar_Pervasives_Native.None
           in
        FStar_Pervasives_Native.Some uu____87
      with | uu____94 -> FStar_Pervasives_Native.None  in
    match run_proc_result with
    | FStar_Pervasives_Native.None  ->
        FStar_Pervasives_Native.Some
          (FStar_Errors.Error_Z3InvocationError, "Could not run Z3")
    | FStar_Pervasives_Native.Some out ->
        let uu____106 = parse_z3_version_lines out  in
        (match uu____106 with
         | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
         | FStar_Pervasives_Native.Some msg ->
             FStar_Pervasives_Native.Some
               (FStar_Errors.Warning_Z3InvocationWarning, msg))
  
let (check_z3hash : unit -> unit) =
  fun uu____128  ->
    let uu____129 =
      let uu____130 = FStar_ST.op_Bang _z3hash_checked  in
      Prims.op_Negation uu____130  in
    if uu____129
    then
      (FStar_ST.op_Colon_Equals _z3hash_checked true;
       (let uu____170 = z3hash_warning_message ()  in
        match uu____170 with
        | FStar_Pervasives_Native.None  -> ()
        | FStar_Pervasives_Native.Some (e,msg) ->
            let msg1 =
              FStar_Util.format4 "%s\n%s\n%s\n%s\n" msg
                "Please download the version of Z3 corresponding to your platform from:"
                _z3url "and add the bin/ subdirectory into your PATH"
               in
            FStar_Errors.log_issue FStar_Range.dummyRange (e, msg1)))
    else ()
  
let (ini_params : unit -> Prims.string Prims.list) =
  fun uu____195  ->
    check_z3hash ();
    (let uu____197 =
       let uu____200 =
         let uu____203 =
           let uu____206 =
             let uu____209 =
               let uu____212 =
                 let uu____215 =
                   let uu____218 =
                     let uu____219 =
                       let uu____220 = FStar_Options.z3_seed ()  in
                       FStar_Util.string_of_int uu____220  in
                     FStar_Util.format1 "smt.random_seed=%s" uu____219  in
                   [uu____218]  in
                 "smt.case_split=3" :: uu____215  in
               "smt.relevancy=2" :: uu____212  in
             "model=true" :: uu____209  in
           "auto_config=false" :: uu____206  in
         "-in" :: uu____203  in
       "-smt2" :: uu____200  in
     let uu____221 = FStar_Options.z3_cliopt ()  in
     FStar_List.append uu____197 uu____221)
  
type label = Prims.string
type unsat_core = Prims.string Prims.list FStar_Pervasives_Native.option
type z3status =
  | UNSAT of unsat_core 
  | SAT of
  (FStar_SMTEncoding_Term.error_labels,Prims.string
                                         FStar_Pervasives_Native.option)
  FStar_Pervasives_Native.tuple2 
  | UNKNOWN of
  (FStar_SMTEncoding_Term.error_labels,Prims.string
                                         FStar_Pervasives_Native.option)
  FStar_Pervasives_Native.tuple2 
  | TIMEOUT of
  (FStar_SMTEncoding_Term.error_labels,Prims.string
                                         FStar_Pervasives_Native.option)
  FStar_Pervasives_Native.tuple2 
  | KILLED 
let (uu___is_UNSAT : z3status -> Prims.bool) =
  fun projectee  ->
    match projectee with | UNSAT _0 -> true | uu____272 -> false
  
let (__proj__UNSAT__item___0 : z3status -> unsat_core) =
  fun projectee  -> match projectee with | UNSAT _0 -> _0 
let (uu___is_SAT : z3status -> Prims.bool) =
  fun projectee  ->
    match projectee with | SAT _0 -> true | uu____292 -> false
  
let (__proj__SAT__item___0 :
  z3status ->
    (FStar_SMTEncoding_Term.error_labels,Prims.string
                                           FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2)
  = fun projectee  -> match projectee with | SAT _0 -> _0 
let (uu___is_UNKNOWN : z3status -> Prims.bool) =
  fun projectee  ->
    match projectee with | UNKNOWN _0 -> true | uu____330 -> false
  
let (__proj__UNKNOWN__item___0 :
  z3status ->
    (FStar_SMTEncoding_Term.error_labels,Prims.string
                                           FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2)
  = fun projectee  -> match projectee with | UNKNOWN _0 -> _0 
let (uu___is_TIMEOUT : z3status -> Prims.bool) =
  fun projectee  ->
    match projectee with | TIMEOUT _0 -> true | uu____368 -> false
  
let (__proj__TIMEOUT__item___0 :
  z3status ->
    (FStar_SMTEncoding_Term.error_labels,Prims.string
                                           FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2)
  = fun projectee  -> match projectee with | TIMEOUT _0 -> _0 
let (uu___is_KILLED : z3status -> Prims.bool) =
  fun projectee  ->
    match projectee with | KILLED  -> true | uu____399 -> false
  
type z3statistics = Prims.string FStar_Util.smap
let (status_tag : z3status -> Prims.string) =
  fun uu___121_406  ->
    match uu___121_406 with
    | SAT uu____407 -> "sat"
    | UNSAT uu____414 -> "unsat"
    | UNKNOWN uu____415 -> "unknown"
    | TIMEOUT uu____422 -> "timeout"
    | KILLED  -> "killed"
  
let (status_string_and_errors :
  z3status ->
    (Prims.string,FStar_SMTEncoding_Term.error_labels)
      FStar_Pervasives_Native.tuple2)
  =
  fun s  ->
    match s with
    | KILLED  -> ((status_tag s), [])
    | UNSAT uu____442 -> ((status_tag s), [])
    | SAT (errs,msg) ->
        let uu____449 =
          FStar_Util.format2 "%s%s" (status_tag s)
            (match msg with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some msg1 ->
                 Prims.strcat " because " msg1)
           in
        (uu____449, errs)
    | UNKNOWN (errs,msg) ->
        let uu____457 =
          FStar_Util.format2 "%s%s" (status_tag s)
            (match msg with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some msg1 ->
                 Prims.strcat " because " msg1)
           in
        (uu____457, errs)
    | TIMEOUT (errs,msg) ->
        let uu____465 =
          FStar_Util.format2 "%s%s" (status_tag s)
            (match msg with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some msg1 ->
                 Prims.strcat " because " msg1)
           in
        (uu____465, errs)
  
let (tid : unit -> Prims.string) =
  fun uu____471  ->
    let uu____472 = FStar_Util.current_tid ()  in
    FStar_All.pipe_right uu____472 FStar_Util.string_of_int
  
let (new_z3proc : Prims.string -> FStar_Util.proc) =
  fun id1  ->
    let uu____478 = FStar_Options.z3_exe ()  in
    let uu____479 = ini_params ()  in
    FStar_Util.start_process id1 uu____478 uu____479 (fun s  -> s = "Done!")
  
type bgproc =
  {
  ask: Prims.string -> Prims.string ;
  refresh: unit -> unit ;
  restart: unit -> unit }
let (__proj__Mkbgproc__item__ask : bgproc -> Prims.string -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { ask = __fname__ask; refresh = __fname__refresh;
        restart = __fname__restart;_} -> __fname__ask
  
let (__proj__Mkbgproc__item__refresh : bgproc -> unit -> unit) =
  fun projectee  ->
    match projectee with
    | { ask = __fname__ask; refresh = __fname__refresh;
        restart = __fname__restart;_} -> __fname__refresh
  
let (__proj__Mkbgproc__item__restart : bgproc -> unit -> unit) =
  fun projectee  ->
    match projectee with
    | { ask = __fname__ask; refresh = __fname__refresh;
        restart = __fname__restart;_} -> __fname__restart
  
type query_log =
  {
  get_module_name: unit -> Prims.string ;
  set_module_name: Prims.string -> unit ;
  write_to_log: Prims.string -> unit ;
  close_log: unit -> unit ;
  log_file_name: unit -> Prims.string }
let (__proj__Mkquery_log__item__get_module_name :
  query_log -> unit -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__get_module_name
  
let (__proj__Mkquery_log__item__set_module_name :
  query_log -> Prims.string -> unit) =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__set_module_name
  
let (__proj__Mkquery_log__item__write_to_log :
  query_log -> Prims.string -> unit) =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__write_to_log
  
let (__proj__Mkquery_log__item__close_log : query_log -> unit -> unit) =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__close_log
  
let (__proj__Mkquery_log__item__log_file_name :
  query_log -> unit -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__log_file_name
  
let (query_logging : query_log) =
  let query_number = FStar_Util.mk_ref (Prims.parse_int "0")  in
  let log_file_opt = FStar_Util.mk_ref FStar_Pervasives_Native.None  in
  let used_file_names = FStar_Util.mk_ref []  in
  let current_module_name = FStar_Util.mk_ref FStar_Pervasives_Native.None
     in
  let current_file_name = FStar_Util.mk_ref FStar_Pervasives_Native.None  in
  let set_module_name n1 =
    FStar_ST.op_Colon_Equals current_module_name
      (FStar_Pervasives_Native.Some n1)
     in
  let get_module_name uu____895 =
    let uu____896 = FStar_ST.op_Bang current_module_name  in
    match uu____896 with
    | FStar_Pervasives_Native.None  -> failwith "Module name not set"
    | FStar_Pervasives_Native.Some n1 -> n1  in
  let new_log_file uu____950 =
    let uu____951 = FStar_ST.op_Bang current_module_name  in
    match uu____951 with
    | FStar_Pervasives_Native.None  -> failwith "current module not set"
    | FStar_Pervasives_Native.Some n1 ->
        let file_name =
          let uu____1001 =
            let uu____1008 = FStar_ST.op_Bang used_file_names  in
            FStar_List.tryFind
              (fun uu____1075  ->
                 match uu____1075 with | (m,uu____1081) -> n1 = m) uu____1008
             in
          match uu____1001 with
          | FStar_Pervasives_Native.None  ->
              ((let uu____1087 =
                  let uu____1094 = FStar_ST.op_Bang used_file_names  in
                  (n1, (Prims.parse_int "0")) :: uu____1094  in
                FStar_ST.op_Colon_Equals used_file_names uu____1087);
               n1)
          | FStar_Pervasives_Native.Some (uu____1211,k) ->
              ((let uu____1218 =
                  let uu____1225 = FStar_ST.op_Bang used_file_names  in
                  (n1, (k + (Prims.parse_int "1"))) :: uu____1225  in
                FStar_ST.op_Colon_Equals used_file_names uu____1218);
               (let uu____1342 =
                  FStar_Util.string_of_int (k + (Prims.parse_int "1"))  in
                FStar_Util.format2 "%s-%s" n1 uu____1342))
           in
        let file_name1 = FStar_Util.format1 "queries-%s.smt2" file_name  in
        (FStar_ST.op_Colon_Equals current_file_name
           (FStar_Pervasives_Native.Some file_name1);
         (let fh = FStar_Util.open_file_for_writing file_name1  in
          FStar_ST.op_Colon_Equals log_file_opt
            (FStar_Pervasives_Native.Some fh);
          fh))
     in
  let get_log_file uu____1442 =
    let uu____1443 = FStar_ST.op_Bang log_file_opt  in
    match uu____1443 with
    | FStar_Pervasives_Native.None  -> new_log_file ()
    | FStar_Pervasives_Native.Some fh -> fh  in
  let append_to_log str =
    let uu____1498 = get_log_file ()  in
    FStar_Util.append_to_file uu____1498 str  in
  let write_to_new_log str =
    let dir_name =
      let uu____1506 = FStar_ST.op_Bang current_file_name  in
      match uu____1506 with
      | FStar_Pervasives_Native.None  ->
          let dir_name =
            let uu____1555 = FStar_ST.op_Bang current_module_name  in
            match uu____1555 with
            | FStar_Pervasives_Native.None  ->
                failwith "current module not set"
            | FStar_Pervasives_Native.Some n1 ->
                FStar_Util.format1 "queries-%s" n1
             in
          (FStar_Util.mkdir true dir_name;
           FStar_ST.op_Colon_Equals current_file_name
             (FStar_Pervasives_Native.Some dir_name);
           dir_name)
      | FStar_Pervasives_Native.Some n1 -> n1  in
    let qnum = FStar_ST.op_Bang query_number  in
    (let uu____1695 =
       let uu____1696 = FStar_ST.op_Bang query_number  in
       uu____1696 + (Prims.parse_int "1")  in
     FStar_ST.op_Colon_Equals query_number uu____1695);
    (let file_name =
       let uu____1780 = FStar_Util.string_of_int qnum  in
       FStar_Util.format1 "query-%s.smt2" uu____1780  in
     let file_name1 = FStar_Util.concat_dir_filename dir_name file_name  in
     FStar_Util.write_file file_name1 str)
     in
  let write_to_log str =
    let uu____1788 =
      let uu____1789 = FStar_Options.n_cores ()  in
      uu____1789 > (Prims.parse_int "1")  in
    if uu____1788 then write_to_new_log str else append_to_log str  in
  let close_log uu____1796 =
    let uu____1797 = FStar_ST.op_Bang log_file_opt  in
    match uu____1797 with
    | FStar_Pervasives_Native.None  -> ()
    | FStar_Pervasives_Native.Some fh ->
        (FStar_Util.close_file fh;
         FStar_ST.op_Colon_Equals log_file_opt FStar_Pervasives_Native.None)
     in
  let log_file_name uu____1897 =
    let uu____1898 = FStar_ST.op_Bang current_file_name  in
    match uu____1898 with
    | FStar_Pervasives_Native.None  -> failwith "no log file"
    | FStar_Pervasives_Native.Some n1 -> n1  in
  { get_module_name; set_module_name; write_to_log; close_log; log_file_name
  } 
let (bg_z3_proc : bgproc FStar_ST.ref) =
  let the_z3proc = FStar_Util.mk_ref FStar_Pervasives_Native.None  in
  let new_proc =
    let ctr = FStar_Util.mk_ref (~- (Prims.parse_int "1"))  in
    fun uu____1975  ->
      let uu____1976 =
        let uu____1977 =
          FStar_Util.incr ctr;
          (let uu____2012 = FStar_ST.op_Bang ctr  in
           FStar_All.pipe_right uu____2012 FStar_Util.string_of_int)
           in
        FStar_Util.format1 "bg-%s" uu____1977  in
      new_z3proc uu____1976
     in
  let z3proc uu____2059 =
    (let uu____2061 =
       let uu____2062 = FStar_ST.op_Bang the_z3proc  in
       uu____2062 = FStar_Pervasives_Native.None  in
     if uu____2061
     then
       let uu____2112 =
         let uu____2115 = new_proc ()  in
         FStar_Pervasives_Native.Some uu____2115  in
       FStar_ST.op_Colon_Equals the_z3proc uu____2112
     else ());
    (let uu____2162 = FStar_ST.op_Bang the_z3proc  in
     FStar_Util.must uu____2162)
     in
  let x = []  in
  let ask input =
    let kill_handler uu____2224 = "\nkilled\n"  in
    let uu____2225 = z3proc ()  in
    FStar_Util.ask_process uu____2225 input kill_handler  in
  let refresh uu____2231 =
    (let uu____2233 = z3proc ()  in FStar_Util.kill_process uu____2233);
    (let uu____2235 =
       let uu____2238 = new_proc ()  in
       FStar_Pervasives_Native.Some uu____2238  in
     FStar_ST.op_Colon_Equals the_z3proc uu____2235);
    query_logging.close_log ()  in
  let restart uu____2289 =
    query_logging.close_log ();
    FStar_ST.op_Colon_Equals the_z3proc FStar_Pervasives_Native.None;
    (let uu____2337 =
       let uu____2340 = new_proc ()  in
       FStar_Pervasives_Native.Some uu____2340  in
     FStar_ST.op_Colon_Equals the_z3proc uu____2337)
     in
  FStar_Util.mk_ref
    {
      ask = (FStar_Util.with_monitor x ask);
      refresh = (FStar_Util.with_monitor x refresh);
      restart = (FStar_Util.with_monitor x restart)
    }
  
let (set_bg_z3_proc : bgproc -> unit) =
  fun bgp  -> FStar_ST.op_Colon_Equals bg_z3_proc bgp 
let (at_log_file : unit -> Prims.string) =
  fun uu____2420  ->
    let uu____2421 = FStar_Options.log_queries ()  in
    if uu____2421
    then
      let uu____2422 = query_logging.log_file_name ()  in
      Prims.strcat "@" uu____2422
    else ""
  
type smt_output_section = Prims.string Prims.list
type smt_output =
  {
  smt_result: smt_output_section ;
  smt_reason_unknown: smt_output_section FStar_Pervasives_Native.option ;
  smt_unsat_core: smt_output_section FStar_Pervasives_Native.option ;
  smt_statistics: smt_output_section FStar_Pervasives_Native.option ;
  smt_labels: smt_output_section FStar_Pervasives_Native.option }
let (__proj__Mksmt_output__item__smt_result :
  smt_output -> smt_output_section) =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_result
  
let (__proj__Mksmt_output__item__smt_reason_unknown :
  smt_output -> smt_output_section FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_reason_unknown
  
let (__proj__Mksmt_output__item__smt_unsat_core :
  smt_output -> smt_output_section FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_unsat_core
  
let (__proj__Mksmt_output__item__smt_statistics :
  smt_output -> smt_output_section FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_statistics
  
let (__proj__Mksmt_output__item__smt_labels :
  smt_output -> smt_output_section FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_labels
  
let (smt_output_sections :
  FStar_Range.range -> Prims.string Prims.list -> smt_output) =
  fun r  ->
    fun lines  ->
      let rec until tag lines1 =
        match lines1 with
        | [] -> FStar_Pervasives_Native.None
        | l::lines2 ->
            if tag = l
            then FStar_Pervasives_Native.Some ([], lines2)
            else
              (let uu____2649 = until tag lines2  in
               FStar_Util.map_opt uu____2649
                 (fun uu____2679  ->
                    match uu____2679 with
                    | (until_tag,rest) -> ((l :: until_tag), rest)))
         in
      let start_tag tag = Prims.strcat "<" (Prims.strcat tag ">")  in
      let end_tag tag = Prims.strcat "</" (Prims.strcat tag ">")  in
      let find_section tag lines1 =
        let uu____2757 = until (start_tag tag) lines1  in
        match uu____2757 with
        | FStar_Pervasives_Native.None  ->
            (FStar_Pervasives_Native.None, lines1)
        | FStar_Pervasives_Native.Some (prefix1,suffix) ->
            let uu____2812 = until (end_tag tag) suffix  in
            (match uu____2812 with
             | FStar_Pervasives_Native.None  ->
                 failwith
                   (Prims.strcat "Parse error: "
                      (Prims.strcat (end_tag tag) " not found"))
             | FStar_Pervasives_Native.Some (section,suffix1) ->
                 ((FStar_Pervasives_Native.Some section),
                   (FStar_List.append prefix1 suffix1)))
         in
      let uu____2877 = find_section "result" lines  in
      match uu____2877 with
      | (result_opt,lines1) ->
          let result = FStar_Util.must result_opt  in
          let uu____2907 = find_section "reason-unknown" lines1  in
          (match uu____2907 with
           | (reason_unknown,lines2) ->
               let uu____2932 = find_section "unsat-core" lines2  in
               (match uu____2932 with
                | (unsat_core,lines3) ->
                    let uu____2957 = find_section "statistics" lines3  in
                    (match uu____2957 with
                     | (statistics,lines4) ->
                         let uu____2982 = find_section "labels" lines4  in
                         (match uu____2982 with
                          | (labels,lines5) ->
                              let remaining =
                                let uu____3010 = until "Done!" lines5  in
                                match uu____3010 with
                                | FStar_Pervasives_Native.None  -> lines5
                                | FStar_Pervasives_Native.Some
                                    (prefix1,suffix) ->
                                    FStar_List.append prefix1 suffix
                                 in
                              ((match remaining with
                                | [] -> ()
                                | uu____3050 ->
                                    let uu____3053 =
                                      let uu____3058 =
                                        FStar_Util.format1
                                          "Unexpected output from Z3: %s\n"
                                          (FStar_String.concat "\n" remaining)
                                         in
                                      (FStar_Errors.Warning_UnexpectedZ3Output,
                                        uu____3058)
                                       in
                                    FStar_Errors.log_issue r uu____3053);
                               (let uu____3059 = FStar_Util.must result_opt
                                   in
                                {
                                  smt_result = uu____3059;
                                  smt_reason_unknown = reason_unknown;
                                  smt_unsat_core = unsat_core;
                                  smt_statistics = statistics;
                                  smt_labels = labels
                                }))))))
  
let (doZ3Exe :
  FStar_Range.range ->
    Prims.bool ->
      Prims.string ->
        FStar_SMTEncoding_Term.error_labels ->
          (z3status,z3statistics) FStar_Pervasives_Native.tuple2)
  =
  fun r  ->
    fun fresh  ->
      fun input  ->
        fun label_messages  ->
          let parse z3out =
            let lines =
              FStar_All.pipe_right (FStar_String.split [10] z3out)
                (FStar_List.map FStar_Util.trim_string)
               in
            let smt_output = smt_output_sections r lines  in
            let unsat_core =
              match smt_output.smt_unsat_core with
              | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
              | FStar_Pervasives_Native.Some s ->
                  let s1 = FStar_Util.trim_string (FStar_String.concat " " s)
                     in
                  let s2 =
                    FStar_Util.substring s1 (Prims.parse_int "1")
                      ((FStar_String.length s1) - (Prims.parse_int "2"))
                     in
                  if FStar_Util.starts_with s2 "error"
                  then FStar_Pervasives_Native.None
                  else
                    (let uu____3120 =
                       FStar_All.pipe_right (FStar_Util.split s2 " ")
                         (FStar_Util.sort_with FStar_String.compare)
                        in
                     FStar_Pervasives_Native.Some uu____3120)
               in
            let labels =
              match smt_output.smt_labels with
              | FStar_Pervasives_Native.None  -> []
              | FStar_Pervasives_Native.Some lines1 ->
                  let rec lblnegs lines2 =
                    match lines2 with
                    | lname::"false"::rest when
                        FStar_Util.starts_with lname "label_" ->
                        let uu____3149 = lblnegs rest  in lname :: uu____3149
                    | lname::uu____3153::rest when
                        FStar_Util.starts_with lname "label_" -> lblnegs rest
                    | uu____3157 -> []  in
                  let lblnegs1 = lblnegs lines1  in
                  FStar_All.pipe_right lblnegs1
                    (FStar_List.collect
                       (fun l  ->
                          let uu____3178 =
                            FStar_All.pipe_right label_messages
                              (FStar_List.tryFind
                                 (fun uu____3229  ->
                                    match uu____3229 with
                                    | (m,uu____3241,uu____3242) ->
                                        (FStar_Pervasives_Native.fst m) = l))
                             in
                          match uu____3178 with
                          | FStar_Pervasives_Native.None  -> []
                          | FStar_Pervasives_Native.Some (lbl,msg,r1) ->
                              [(lbl, msg, r1)]))
               in
            let statistics =
              let statistics = FStar_Util.smap_create (Prims.parse_int "0")
                 in
              match smt_output.smt_statistics with
              | FStar_Pervasives_Native.None  -> statistics
              | FStar_Pervasives_Native.Some lines1 ->
                  let parse_line line =
                    let pline =
                      FStar_Util.split (FStar_Util.trim_string line) ":"  in
                    match pline with
                    | "("::entry::[] ->
                        let tokens = FStar_Util.split entry " "  in
                        let key = FStar_List.hd tokens  in
                        let ltok =
                          FStar_List.nth tokens
                            ((FStar_List.length tokens) -
                               (Prims.parse_int "1"))
                           in
                        let value =
                          if FStar_Util.ends_with ltok ")"
                          then
                            FStar_Util.substring ltok (Prims.parse_int "0")
                              ((FStar_String.length ltok) -
                                 (Prims.parse_int "1"))
                          else ltok  in
                        FStar_Util.smap_add statistics key value
                    | ""::entry::[] ->
                        let tokens = FStar_Util.split entry " "  in
                        let key = FStar_List.hd tokens  in
                        let ltok =
                          FStar_List.nth tokens
                            ((FStar_List.length tokens) -
                               (Prims.parse_int "1"))
                           in
                        let value =
                          if FStar_Util.ends_with ltok ")"
                          then
                            FStar_Util.substring ltok (Prims.parse_int "0")
                              ((FStar_String.length ltok) -
                                 (Prims.parse_int "1"))
                          else ltok  in
                        FStar_Util.smap_add statistics key value
                    | uu____3356 -> ()  in
                  (FStar_List.iter parse_line lines1; statistics)
               in
            let reason_unknown =
              FStar_Util.map_opt smt_output.smt_reason_unknown
                (fun x  ->
                   let ru = FStar_String.concat " " x  in
                   if FStar_Util.starts_with ru "(:reason-unknown \""
                   then
                     let reason =
                       FStar_Util.substring_from ru
                         (FStar_String.length "(:reason-unknown \"")
                        in
                     let res =
                       FStar_String.substring reason (Prims.parse_int "0")
                         ((FStar_String.length reason) -
                            (Prims.parse_int "2"))
                        in
                     res
                   else ru)
               in
            let status =
              (let uu____3374 = FStar_Options.debug_any ()  in
               if uu____3374
               then
                 let uu____3375 =
                   FStar_Util.format1 "Z3 says: %s\n"
                     (FStar_String.concat "\n" smt_output.smt_result)
                    in
                 FStar_All.pipe_left FStar_Util.print_string uu____3375
               else ());
              (match smt_output.smt_result with
               | "unsat"::[] -> UNSAT unsat_core
               | "sat"::[] -> SAT (labels, reason_unknown)
               | "unknown"::[] -> UNKNOWN (labels, reason_unknown)
               | "timeout"::[] -> TIMEOUT (labels, reason_unknown)
               | "killed"::[] ->
                   ((let uu____3384 =
                       let uu____3389 = FStar_ST.op_Bang bg_z3_proc  in
                       uu____3389.restart  in
                     uu____3384 ());
                    KILLED)
               | uu____3409 ->
                   let uu____3410 =
                     FStar_Util.format1
                       "Unexpected output from Z3: got output result: %s\n"
                       (FStar_String.concat "\n" smt_output.smt_result)
                      in
                   failwith uu____3410)
               in
            (status, statistics)  in
          let stdout1 =
            if fresh
            then
              let uu____3412 = tid ()  in
              let uu____3413 = FStar_Options.z3_exe ()  in
              let uu____3414 = ini_params ()  in
              FStar_Util.run_process uu____3412 uu____3413 uu____3414
                (FStar_Pervasives_Native.Some input)
            else
              (let uu____3418 =
                 let uu____3423 = FStar_ST.op_Bang bg_z3_proc  in
                 uu____3423.ask  in
               uu____3418 input)
             in
          parse (FStar_Util.trim_string stdout1)
  
let (z3_options : Prims.string FStar_ST.ref) =
  FStar_Util.mk_ref
    "(set-option :global-decls false)\n(set-option :smt.mbqi false)\n(set-option :auto_config false)\n(set-option :produce-unsat-cores true)\n"
  
let (set_z3_options : Prims.string -> unit) =
  fun opts  -> FStar_ST.op_Colon_Equals z3_options opts 
type 'a job = {
  job: unit -> 'a ;
  callback: 'a -> unit }
let __proj__Mkjob__item__job : 'a . 'a job -> unit -> 'a =
  fun projectee  ->
    match projectee with
    | { job = __fname__job; callback = __fname__callback;_} -> __fname__job
  
let __proj__Mkjob__item__callback : 'a . 'a job -> 'a -> unit =
  fun projectee  ->
    match projectee with
    | { job = __fname__job; callback = __fname__callback;_} ->
        __fname__callback
  
type z3result =
  {
  z3result_status: z3status ;
  z3result_time: Prims.int ;
  z3result_statistics: z3statistics ;
  z3result_query_hash: Prims.string FStar_Pervasives_Native.option }
let (__proj__Mkz3result__item__z3result_status : z3result -> z3status) =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_status
  
let (__proj__Mkz3result__item__z3result_time : z3result -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_time
  
let (__proj__Mkz3result__item__z3result_statistics :
  z3result -> z3statistics) =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_statistics
  
let (__proj__Mkz3result__item__z3result_query_hash :
  z3result -> Prims.string FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_query_hash
  
type z3job = z3result job
let (job_queue : z3job Prims.list FStar_ST.ref) = FStar_Util.mk_ref [] 
let (pending_jobs : Prims.int FStar_ST.ref) =
  FStar_Util.mk_ref (Prims.parse_int "0") 
let (z3_job :
  FStar_Range.range ->
    Prims.bool ->
      FStar_SMTEncoding_Term.error_labels ->
        Prims.string ->
          Prims.string FStar_Pervasives_Native.option -> unit -> z3result)
  =
  fun r  ->
    fun fresh  ->
      fun label_messages  ->
        fun input  ->
          fun qhash  ->
            fun uu____3689  ->
              let start = FStar_Util.now ()  in
              let uu____3693 =
                try doZ3Exe r fresh input label_messages
                with
                | e when
                    let uu____3717 = FStar_Options.trace_error ()  in
                    Prims.op_Negation uu____3717 ->
                    ((let uu____3719 =
                        let uu____3724 = FStar_ST.op_Bang bg_z3_proc  in
                        uu____3724.refresh  in
                      uu____3719 ());
                     FStar_Exn.raise e)
                 in
              match uu____3693 with
              | (status,statistics) ->
                  let uu____3750 =
                    let uu____3755 = FStar_Util.now ()  in
                    FStar_Util.time_diff start uu____3755  in
                  (match uu____3750 with
                   | (uu____3756,elapsed_time) ->
                       {
                         z3result_status = status;
                         z3result_time = elapsed_time;
                         z3result_statistics = statistics;
                         z3result_query_hash = qhash
                       })
  
let (running : Prims.bool FStar_ST.ref) = FStar_Util.mk_ref false 
let rec (dequeue' : unit -> unit) =
  fun uu____3783  ->
    let j =
      let uu____3785 = FStar_ST.op_Bang job_queue  in
      match uu____3785 with
      | [] -> failwith "Impossible"
      | hd1::tl1 -> (FStar_ST.op_Colon_Equals job_queue tl1; hd1)  in
    FStar_Util.incr pending_jobs;
    FStar_Util.monitor_exit job_queue;
    run_job j;
    FStar_Util.with_monitor job_queue
      (fun uu____3852  -> FStar_Util.decr pending_jobs) ();
    dequeue ()

and (dequeue : unit -> unit) =
  fun uu____3854  ->
    let uu____3855 = FStar_ST.op_Bang running  in
    if uu____3855
    then
      let rec aux uu____3880 =
        FStar_Util.monitor_enter job_queue;
        (let uu____3886 = FStar_ST.op_Bang job_queue  in
         match uu____3886 with
         | [] ->
             (FStar_Util.monitor_exit job_queue;
              FStar_Util.sleep (Prims.parse_int "50");
              aux ())
         | uu____3918 -> dequeue' ())
         in
      aux ()
    else ()

and (run_job : z3job -> unit) =
  fun j  ->
    let uu____3922 = j.job ()  in FStar_All.pipe_left j.callback uu____3922

let (init : unit -> unit) =
  fun uu____3927  ->
    FStar_ST.op_Colon_Equals running true;
    (let n_cores1 = FStar_Options.n_cores ()  in
     if n_cores1 > (Prims.parse_int "1")
     then
       let rec aux n1 =
         if n1 = (Prims.parse_int "0")
         then ()
         else (FStar_Util.spawn dequeue; aux (n1 - (Prims.parse_int "1")))
          in
       aux n_cores1
     else ())
  
let (enqueue : z3job -> unit) =
  fun j  ->
    FStar_Util.with_monitor job_queue
      (fun uu____3969  ->
         (let uu____3971 =
            let uu____3974 = FStar_ST.op_Bang job_queue  in
            FStar_List.append uu____3974 [j]  in
          FStar_ST.op_Colon_Equals job_queue uu____3971);
         FStar_Util.monitor_pulse job_queue) ()
  
let (finish : unit -> unit) =
  fun uu____4031  ->
    let rec aux uu____4037 =
      let uu____4038 =
        FStar_Util.with_monitor job_queue
          (fun uu____4054  ->
             let uu____4055 = FStar_ST.op_Bang pending_jobs  in
             let uu____4075 =
               let uu____4076 = FStar_ST.op_Bang job_queue  in
               FStar_List.length uu____4076  in
             (uu____4055, uu____4075)) ()
         in
      match uu____4038 with
      | (n1,m) ->
          if (n1 + m) = (Prims.parse_int "0")
          then FStar_ST.op_Colon_Equals running false
          else (FStar_Util.sleep (Prims.parse_int "500"); aux ())
       in
    aux ()
  
type scope_t = FStar_SMTEncoding_Term.decl Prims.list Prims.list
let (fresh_scope : scope_t FStar_ST.ref) = FStar_Util.mk_ref [[]] 
let (mk_fresh_scope : unit -> scope_t) =
  fun uu____4158  -> FStar_ST.op_Bang fresh_scope 
let (bg_scope : FStar_SMTEncoding_Term.decl Prims.list FStar_ST.ref) =
  FStar_Util.mk_ref [] 
let (push : Prims.string -> unit) =
  fun msg  ->
    FStar_Util.atomically
      (fun uu____4203  ->
         (let uu____4205 =
            let uu____4206 = FStar_ST.op_Bang fresh_scope  in
            [FStar_SMTEncoding_Term.Caption msg; FStar_SMTEncoding_Term.Push]
              :: uu____4206
             in
          FStar_ST.op_Colon_Equals fresh_scope uu____4205);
         (let uu____4251 =
            let uu____4254 = FStar_ST.op_Bang bg_scope  in
            FStar_List.append uu____4254
              [FStar_SMTEncoding_Term.Push;
              FStar_SMTEncoding_Term.Caption msg]
             in
          FStar_ST.op_Colon_Equals bg_scope uu____4251))
  
let (pop : Prims.string -> unit) =
  fun msg  ->
    FStar_Util.atomically
      (fun uu____4311  ->
         (let uu____4313 =
            let uu____4314 = FStar_ST.op_Bang fresh_scope  in
            FStar_List.tl uu____4314  in
          FStar_ST.op_Colon_Equals fresh_scope uu____4313);
         (let uu____4359 =
            let uu____4362 = FStar_ST.op_Bang bg_scope  in
            FStar_List.append uu____4362
              [FStar_SMTEncoding_Term.Caption msg;
              FStar_SMTEncoding_Term.Pop]
             in
          FStar_ST.op_Colon_Equals bg_scope uu____4359))
  
let (snapshot :
  Prims.string -> (Prims.int,unit) FStar_Pervasives_Native.tuple2) =
  fun msg  -> FStar_Common.snapshot push fresh_scope msg 
let (rollback :
  Prims.string -> Prims.int FStar_Pervasives_Native.option -> unit) =
  fun msg  ->
    fun depth  ->
      FStar_Common.rollback (fun uu____4439  -> pop msg) fresh_scope depth
  
let (giveZ3 : FStar_SMTEncoding_Term.decl Prims.list -> unit) =
  fun decls  ->
    FStar_All.pipe_right decls
      (FStar_List.iter
         (fun uu___122_4453  ->
            match uu___122_4453 with
            | FStar_SMTEncoding_Term.Push  -> failwith "Unexpected push/pop"
            | FStar_SMTEncoding_Term.Pop  -> failwith "Unexpected push/pop"
            | uu____4454 -> ()));
    (let uu____4456 = FStar_ST.op_Bang fresh_scope  in
     match uu____4456 with
     | hd1::tl1 ->
         FStar_ST.op_Colon_Equals fresh_scope ((FStar_List.append hd1 decls)
           :: tl1)
     | uu____4507 -> failwith "Impossible");
    (let uu____4508 =
       let uu____4511 = FStar_ST.op_Bang bg_scope  in
       FStar_List.append uu____4511 decls  in
     FStar_ST.op_Colon_Equals bg_scope uu____4508)
  
let (refresh : unit -> unit) =
  fun uu____4564  ->
    (let uu____4566 =
       let uu____4567 = FStar_Options.n_cores ()  in
       uu____4567 < (Prims.parse_int "2")  in
     if uu____4566
     then
       let uu____4568 =
         let uu____4573 = FStar_ST.op_Bang bg_z3_proc  in uu____4573.refresh
          in
       uu____4568 ()
     else ());
    (let uu____4594 =
       let uu____4597 =
         let uu____4602 = FStar_ST.op_Bang fresh_scope  in
         FStar_List.rev uu____4602  in
       FStar_List.flatten uu____4597  in
     FStar_ST.op_Colon_Equals bg_scope uu____4594)
  
let (mk_input :
  FStar_SMTEncoding_Term.decl Prims.list ->
    (Prims.string,Prims.string FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2)
  =
  fun theory  ->
    let options = FStar_ST.op_Bang z3_options  in
    let uu____4686 =
      let uu____4693 =
        (FStar_Options.record_hints ()) ||
          ((FStar_Options.use_hints ()) && (FStar_Options.use_hint_hashes ()))
         in
      if uu____4693
      then
        let uu____4700 =
          let uu____4711 =
            FStar_All.pipe_right theory
              (FStar_Util.prefix_until
                 (fun uu___123_4739  ->
                    match uu___123_4739 with
                    | FStar_SMTEncoding_Term.CheckSat  -> true
                    | uu____4740 -> false))
             in
          FStar_All.pipe_right uu____4711 FStar_Option.get  in
        match uu____4700 with
        | (prefix1,check_sat,suffix) ->
            let pp =
              FStar_List.map (FStar_SMTEncoding_Term.declToSmt options)  in
            let pp_no_cap =
              FStar_List.map
                (FStar_SMTEncoding_Term.declToSmt_no_caps options)
               in
            let suffix1 = check_sat :: suffix  in
            let ps_lines = pp prefix1  in
            let ss_lines = pp suffix1  in
            let ps = FStar_String.concat "\n" ps_lines  in
            let ss = FStar_String.concat "\n" ss_lines  in
            let uncaption uu___124_4824 =
              match uu___124_4824 with
              | FStar_SMTEncoding_Term.Caption uu____4825 ->
                  FStar_SMTEncoding_Term.Caption ""
              | FStar_SMTEncoding_Term.Assume a ->
                  FStar_SMTEncoding_Term.Assume
                    (let uu___129_4829 = a  in
                     {
                       FStar_SMTEncoding_Term.assumption_term =
                         (uu___129_4829.FStar_SMTEncoding_Term.assumption_term);
                       FStar_SMTEncoding_Term.assumption_caption =
                         FStar_Pervasives_Native.None;
                       FStar_SMTEncoding_Term.assumption_name =
                         (uu___129_4829.FStar_SMTEncoding_Term.assumption_name);
                       FStar_SMTEncoding_Term.assumption_fact_ids =
                         (uu___129_4829.FStar_SMTEncoding_Term.assumption_fact_ids)
                     })
              | FStar_SMTEncoding_Term.DeclFun (n1,a,s,uu____4833) ->
                  FStar_SMTEncoding_Term.DeclFun
                    (n1, a, s, FStar_Pervasives_Native.None)
              | FStar_SMTEncoding_Term.DefineFun (n1,a,s,b,uu____4844) ->
                  FStar_SMTEncoding_Term.DefineFun
                    (n1, a, s, b, FStar_Pervasives_Native.None)
              | d -> d  in
            let hs =
              let uu____4853 =
                let uu____4856 =
                  let uu____4859 =
                    FStar_All.pipe_right prefix1 (FStar_List.map uncaption)
                     in
                  FStar_All.pipe_right uu____4859 pp_no_cap  in
                FStar_All.pipe_right uu____4856
                  (FStar_List.filter (fun s  -> s <> ""))
                 in
              FStar_All.pipe_right uu____4853 (FStar_String.concat "\n")  in
            let uu____4878 =
              let uu____4881 = FStar_Util.digest_of_string hs  in
              FStar_Pervasives_Native.Some uu____4881  in
            ((Prims.strcat ps (Prims.strcat "\n" ss)), uu____4878)
      else
        (let uu____4885 =
           let uu____4886 =
             FStar_List.map (FStar_SMTEncoding_Term.declToSmt options) theory
              in
           FStar_All.pipe_right uu____4886 (FStar_String.concat "\n")  in
         (uu____4885, FStar_Pervasives_Native.None))
       in
    match uu____4686 with
    | (r,hash) ->
        ((let uu____4906 = FStar_Options.log_queries ()  in
          if uu____4906 then query_logging.write_to_log r else ());
         (r, hash))
  
type cb = z3result -> unit
let (cache_hit :
  Prims.string FStar_Pervasives_Native.option ->
    Prims.string FStar_Pervasives_Native.option -> cb -> Prims.bool)
  =
  fun cache  ->
    fun qhash  ->
      fun cb  ->
        let uu____4940 =
          (FStar_Options.use_hints ()) && (FStar_Options.use_hint_hashes ())
           in
        if uu____4940
        then
          match qhash with
          | FStar_Pervasives_Native.Some x when qhash = cache ->
              let stats = FStar_Util.smap_create (Prims.parse_int "0")  in
              (FStar_Util.smap_add stats "fstar_cache_hit" "1";
               (let result =
                  {
                    z3result_status = (UNSAT FStar_Pervasives_Native.None);
                    z3result_time = (Prims.parse_int "0");
                    z3result_statistics = stats;
                    z3result_query_hash = qhash
                  }  in
                cb result; true))
          | uu____4951 -> false
        else false
  
let (ask_1_core :
  FStar_Range.range ->
    (FStar_SMTEncoding_Term.decls_t ->
       (FStar_SMTEncoding_Term.decls_t,Prims.bool)
         FStar_Pervasives_Native.tuple2)
      ->
      Prims.string FStar_Pervasives_Native.option ->
        FStar_SMTEncoding_Term.error_labels ->
          FStar_SMTEncoding_Term.decls_t -> cb -> unit)
  =
  fun r  ->
    fun filter_theory  ->
      fun cache  ->
        fun label_messages  ->
          fun qry  ->
            fun cb  ->
              let theory =
                let uu____5009 = FStar_ST.op_Bang bg_scope  in
                FStar_List.append uu____5009
                  (FStar_List.append [FStar_SMTEncoding_Term.Push]
                     (FStar_List.append qry [FStar_SMTEncoding_Term.Pop]))
                 in
              let uu____5035 = filter_theory theory  in
              match uu____5035 with
              | (theory1,used_unsat_core) ->
                  let uu____5042 = mk_input theory1  in
                  (match uu____5042 with
                   | (input,qhash) ->
                       (FStar_ST.op_Colon_Equals bg_scope [];
                        (let uu____5079 =
                           let uu____5080 = cache_hit cache qhash cb  in
                           Prims.op_Negation uu____5080  in
                         if uu____5079
                         then
                           run_job
                             {
                               job =
                                 (z3_job r false label_messages input qhash);
                               callback = cb
                             }
                         else ())))
  
let (ask_n_cores :
  FStar_Range.range ->
    (FStar_SMTEncoding_Term.decls_t ->
       (FStar_SMTEncoding_Term.decls_t,Prims.bool)
         FStar_Pervasives_Native.tuple2)
      ->
      Prims.string FStar_Pervasives_Native.option ->
        FStar_SMTEncoding_Term.error_labels ->
          FStar_SMTEncoding_Term.decls_t ->
            scope_t FStar_Pervasives_Native.option -> cb -> unit)
  =
  fun r  ->
    fun filter_theory  ->
      fun cache  ->
        fun label_messages  ->
          fun qry  ->
            fun scope  ->
              fun cb  ->
                let theory =
                  let uu____5149 =
                    match scope with
                    | FStar_Pervasives_Native.Some s -> FStar_List.rev s
                    | FStar_Pervasives_Native.None  ->
                        (FStar_ST.op_Colon_Equals bg_scope [];
                         (let uu____5185 = FStar_ST.op_Bang fresh_scope  in
                          FStar_List.rev uu____5185))
                     in
                  FStar_List.flatten uu____5149  in
                let theory1 =
                  FStar_List.append theory
                    (FStar_List.append [FStar_SMTEncoding_Term.Push]
                       (FStar_List.append qry [FStar_SMTEncoding_Term.Pop]))
                   in
                let uu____5214 = filter_theory theory1  in
                match uu____5214 with
                | (theory2,used_unsat_core) ->
                    let uu____5221 = mk_input theory2  in
                    (match uu____5221 with
                     | (input,qhash) ->
                         let uu____5234 =
                           let uu____5235 = cache_hit cache qhash cb  in
                           Prims.op_Negation uu____5235  in
                         if uu____5234
                         then
                           enqueue
                             {
                               job =
                                 (z3_job r true label_messages input qhash);
                               callback = cb
                             }
                         else ())
  
let (ask :
  FStar_Range.range ->
    (FStar_SMTEncoding_Term.decls_t ->
       (FStar_SMTEncoding_Term.decls_t,Prims.bool)
         FStar_Pervasives_Native.tuple2)
      ->
      Prims.string FStar_Pervasives_Native.option ->
        FStar_SMTEncoding_Term.error_labels ->
          FStar_SMTEncoding_Term.decl Prims.list ->
            scope_t FStar_Pervasives_Native.option -> cb -> unit)
  =
  fun r  ->
    fun filter1  ->
      fun cache  ->
        fun label_messages  ->
          fun qry  ->
            fun scope  ->
              fun cb  ->
                let uu____5303 =
                  let uu____5304 = FStar_Options.n_cores ()  in
                  uu____5304 = (Prims.parse_int "1")  in
                if uu____5303
                then ask_1_core r filter1 cache label_messages qry cb
                else ask_n_cores r filter1 cache label_messages qry scope cb
  