 {r}←{cat}Profiler rarg;fnam;msg;ai;ts
 r←0 ⋄ prf←⎕AI[3]
 msg←(⍕prf),',',({326=⎕DR ⍵:1⊃⍵ ⋄ ⍵}rarg),','
 msg,←,(2⊃⎕NSI),'.',(2⊃⎕SI),'[',(⍕2⊃⎕LC),'],',(⍕⎕TID),',',(⍕≢⎕tnums),',',{0::'0' ⋄ ⍵:⍕cat ⋄ '0'}2=⎕NC'cat'
 :Trap 0   ⍝ shouldn't be neccessary, but Jenkins had an issue during its test of the latest version...
     (⊂msg,⎕UCS 13)⎕NPUT #.Boot.ms.PerfLogFile 2
 :Else
     ⎕←'⎕DR msg=',⍕⎕DR msg
     ⎕←'logfile=',#.Boot.ms.PerfLogFile
     ⎕←⎕DM
     ⎕←⎕DMX
 :EndTrap
 ⍝⎕←'profiling=',⎕AI[3]-prf
 →0


⍝→r←0
⍝ r←Profile'in fooFN'  ⍝ to start
⍝ r←Profiler 'Doing something' r   ⍝ msg (ai from last call)
⍝ [cat] determines the category of the fn - there's no functionality linked to it, no specific datatype expected and you can use it in any way you like
⍝       to inject even info or to categorize calls like "init", "proc", post" etc. If present, it will be added as last element



 r←ai←⎕AI[3] ⋄ ts←⎕TS
 msg←,⊆rarg

 ⍝ ideally this should be a filename that is unique for the request we're dealing with.
 ⍝ - Can't use ⎕TID for filename as it may vary.
 ⍝ - Can't use cookie 'coz we don't always know it.
 ⍝ - Possibly should create something unique and put it into the Request (and into Response) - but how could this fn (called from various stacks) always find _Request or _Response?
 ⍝ Perhaps we need ⍺? No good ideas atm.

 :If 0=#.Boot.⎕NC'ms'
     →0
 :ElseIf 0=#.Boot.ms.⎕NC'PerfLogFile'
     :If ⎕NEXISTS #.Boot.AppRoot,'Logs/' ⋄ i←1 ⋄
         :While ⎕NEXISTS #.Boot.AppRoot,'Logs/Perf',(⍕i),'.csv' ⋄ i+←1 ⋄ :EndWhile
         ⎕←'*** Profiling into ',#.Boot.ms.PerfLogFile←#.Boot.AppRoot,'Logs/Perf',(⍕i),'.csv'
     :EndIf
 :EndIf
 msg←{6::'' ⋄ ⍎⍵}'1⊃msg'
 ⍝ Columns are:
 ⍝ TS,AI[3],Stack,⎕TID,msg,Mem Used,Mem HighWaterMark,#Compactions,# of threads,∆ ⎕AI[3]
 ⍝msg←(⍕ts),',',(⍕ai),',',(2⊃⎕NSI),'.',(2⊃⎕SI),'[',(⍕2⊃⎕LC),'],',(⍕⎕TID),',',msg,',',(∊(⍕¨⌊0.001 0.001 1×2000⌶1 14 2),¨','),(⍕⍴⎕TNUMS),','
 msg←(⍕ts),',',msg,','
 :If 1=≡rarg
     msg,←'0'
 :Else
     msg,←⍕ai-2⊃rarg
 :EndIf
 msg,←',',{0::'0' ⋄ '"',(⍕⍎'cat'),'"'}0
 :Trap 0
     (⊂msg,⎕UCS 13)⎕NPUT #.Boot.ms.PerfLogFile 2
 :Else
     ⎕←⎕DM
     ⎕←⎕DMX
     ∘∘∘
 :EndTrap
 r←⎕AI[3]
