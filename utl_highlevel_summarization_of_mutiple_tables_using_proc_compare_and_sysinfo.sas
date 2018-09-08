Highlevel summarization of mutiple tables using proc compare and sysinfo;

see
https://tinyurl.com/ydezyjaw
https://communities.sas.com/t5/SAS-Enterprise-Guide/comapre-two-identical-data-sets-with-many-variables-and/m-p/493310
https://communities.sas.com/t5/Base-SAS-Programming/Proc-compare/m-p/392218


INPUT ( Two sets 3 corresponding tables)
========================================

 SYSINFO DECODE

 if sysinfo =0                  then do; /* 0 */ msg = 'All Compared Variables Equal'; output; end;
 if sysinfo='...............1'b then do; /* 1 */ msg = 'Data set labels differ'; output; end;
 if sysinfo='..............1.'b then do; /* 2 */ msg = 'Data set types differ'; output; end;
 if sysinfo='.............1..'b then do; /* 3 */ msg = 'Variable has different informat'; output; end;
 if sysinfo='............1...'b then do; /* 4 */ msg = 'Variable has different format'; output; end;
 if sysinfo='...........1....'b then do; /* 5 */ msg = 'Variable has different length'; output; end;
 if sysinfo='..........1.....'b then do; /* 6 */ msg = 'Variable has different label'; output; end;
 if sysinfo='.........1......'b then do; /* 7 */ msg = 'Base data set has observation not in comparison'; output; end;
 if sysinfo='........1.......'b then do; /* 8 */ msg = 'Comparison data set has observation not in base'; output; end;
 if sysinfo='.......1........'b then do; /* 9 */ msg = 'Base data set has BY group not in comparison '; output; end;
 if sysinfo='......1.........'b then do; /* 10*/ msg = 'Comparison data set has BY group not in base '; output; end;
 if sysinfo='.....1..........'b then do; /* 11*/ msg = 'Base data set has variable not in comparison '; output; end;
 if sysinfo='....1...........'b then do; /* 12*/ msg = 'Comparison data set has variable not in base '; output; end;
 if sysinfo='...1............'b then do; /* 13*/ msg = 'A value comparison was unequal '; output; end;
 if sysinfo='..1.............'b then do; /* 14*/ msg = 'Conflicting variable types '; output; end;
 if sysinfo='.1..............'b then do; /* 15*/ msg = 'BY variables do not match '; output; end;
 if sysinfo='1...............'b then do; /* 16*/ msg = 'Fatal error: comparison not done '; output; end;


Tables  (compare corresponding tables)
---------------------------------------

   d:/prod

      classm.sas7bdat
      class.sas7bdat
      classfit.sas7bdat

   d:/qc

      classm.sas7bdat
      class.sas7bdat
      classfit.sas7bdat


WANT (EXCEL SHEET with Highlevel Summary)
==========================================

 d:/xls/utl_highlevel_summarization_of_mutiple_tables_using_proc_compare_and sysinfo.xlsx

    +-------------------------------------------------------------------------------------------------------+
    |          A             |    B       |     C      |                         D                          |
    +-------------------------------------------------------------------------------------------------------+
 1  | PROD                   | COMPARE    | SYSINFO    |   MESSAGE (can have mutiple messages per table)    |
    +------------------------+------------+------------+----------------------------------------------------+
 2  | prod.CLASS             | qc.CLASS   |     0      |  All Compared Variables Equal                      |
    +------------------------+------------+------------+----------------------------------------------------+
 3  | prod.CLASSFIT          | qc.CLASSFIT|     0      |  All Compared Variables Equal                      |
    +------------------------+------------+------------+----------------------------------------------------+
 4  | prod.CLASSM            | qc.CLASSM  |   4160     |  Base data set has observation not in comparison   | ** two issues
    +------------------------+------------+------------+----------------------------------------------------+
 4  | prod.CLASSM            | qc.CLASSM  |   4160     |  A value comparison was unequal                    |
    +------------------------+------------+------------+----------------------------------------------------+


PROCESS
=======

libname xel "d:/xls/&pgm..xlsx";

%symdel mems /nowarn;

data xel.want(drop=rc mem);

    retain prod compare sysinfo msg;

    * get meta data;
    if _n_=0 then do;
        %let rc=%sysfunc(dosubl('
             proc sql;
                select quote(memname) into :mems separated by ","
                from dictionary.tables where upcase(libname)="PROD";
             ;quit;
        '));
     end;

     length msg $96;

     do mem=&mems;

           call symputx("mem",mem);
           put '*** '  mem=  '  ****';
           rc=dosubl('
               proc compare base=prod.&mem compare=qc.&mem;
               run;quit;
               %let CompareSysinfo=&sysinfo;
          ');

          prod=cats('prod',mem);
          compare=cats('qc',mem);

          sysinfo=input(symget('CompareSysinfo'),12.);

          if sysinfo =0                  then do; /* 0 */ msg = 'All Compared Variables Equal'; output; end;
          if sysinfo='...............1'b then do; /* 1 */ msg = 'Data set labels differ'; output; end;
          if sysinfo='..............1.'b then do; /* 2 */ msg = 'Data set types differ'; output; end;
          if sysinfo='.............1..'b then do; /* 3 */ msg = 'Variable has different informat'; output; end;
          if sysinfo='............1...'b then do; /* 4 */ msg = 'Variable has different format'; output; end;
          if sysinfo='...........1....'b then do; /* 5 */ msg = 'Variable has different length'; output; end;
          if sysinfo='..........1.....'b then do; /* 6 */ msg = 'Variable has different label'; output; end;
          if sysinfo='.........1......'b then do; /* 7 */ msg = 'Base data set has observation not in comparison'; output; end;
          if sysinfo='........1.......'b then do; /* 8 */ msg = 'Comparison data set has observation not in base'; output; end;
          if sysinfo='.......1........'b then do; /* 9 */ msg = 'Base data set has BY group not in comparison '; output; end;
          if sysinfo='......1.........'b then do; /* 10*/ msg = 'Comparison data set has BY group not in base '; output; end;
          if sysinfo='.....1..........'b then do; /* 11*/ msg = 'Base data set has variable not in comparison '; output; end;
          if sysinfo='....1...........'b then do; /* 12*/ msg = 'Comparison data set has variable not in base '; output; end;
          if sysinfo='...1............'b then do; /* 13*/ msg = 'A value comparison was unequal '; output; end;
          if sysinfo='..1.............'b then do; /* 14*/ msg = 'Conflicting variable types '; output; end;
          if sysinfo='.1..............'b then do; /* 15*/ msg = 'BY variables do not match '; output; end;
          if sysinfo='1...............'b then do; /* 16*/ msg = 'Fatal error: comparison not done '; output; end;

     end;

run;quit;

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data _null_;
  rc=dcreate('prod','d:');
  rc=dcreate('qc', 'd:');
run;quit;

*                    _
 _ __  _ __ ___   __| |
| '_ \| '__/ _ \ / _` |
| |_) | | | (_) | (_| |
| .__/|_|  \___/ \__,_|
|_|
;

libname prod "d:/prod";
data prod.classm;
  set sashelp.class;
   if name=:'J' then do; age=99; weight=999;end;
   if mod(_n_,5)=0 then delete;
run;quit;

proc copy in=sashelp out=prod;
 select class classfit;
run;quit;

*
  __ _  ___
 / _` |/ __|
| (_| | (__
 \__, |\___|
    |_|
;

libname qc "d:/qc";
data qc.classm;
  set sashelp.class(where=(sex="M"));
   if name=:'A' then do; age=99; weight=999;end;
run;quit;

proc copy in=sashelp out=qc;
 select class classfit;
run;quit;


