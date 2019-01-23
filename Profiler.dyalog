 {r}←Profiler rarg;fnam;msg;ai

⍝ r←Profile'in fooFN'  ⍝ to start
⍝ r←Profiler 'Doing something' r   ⍝ msg (ai from last call)

 ai←⎕AI[3]
msg←,⊆rarg
 
 ⍝ ideally this should be a filename that is unique for the request we're dealing with.
 ⍝ - Can't use ⎕TID for filename as it may vary.
 ⍝ - Can't use cookie 'coz we don't always know it.
 ⍝ - Possibly should create something unique and put it into the Request (and into Response) - but how could this fn (called from various stacks) always find _Request or _Response?
 ⍝ Perhaps we need ⍺? No good ideas atm.
 
 :If ~⎕NEXISTS #.Boot.AppRoot,'Logs/' ⋄ →0 ⋄ :EndIf
 fnam←#.Boot.AppRoot,'Logs/Perf.csv'
 msg←{6::'' ⋄ ⍎⍵}'1⊃msg'
 ⍝ Columns are:
 ⍝ TS,AI[3],Stack,msg,Mem Used,Mem HighWaterMark,# of threads,Msg
 msg←(⍕⎕TS),',',(⍕⎕AI[3]),',',(2⊃⎕NSI),'.',(2⊃⎕SI),'[',(⍕2⊃⎕LC),'] - &',(⍕⎕tid),',',msg,',',∊(⍕¨⌊.001×2000⌶1 14),¨',',(⍕⍴⎕tid),','
 :trap 0
 :If 1=≡rarg
     (⊂msg,'0',⎕UCS 13)⎕NPUT fnam 2
 :Else
     (⊂msg,(⍕ai-2⊃rarg),⎕UCS 13)⎕NPUT fnam 2
 :EndIf
 :endtrap
 r←⎕AI[3]
