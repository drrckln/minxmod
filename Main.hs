module Main where

import Types
import ToDot

nop = Arith $ \s -> [s]
pushI i = Arith $ \s -> [IntValue i:s]
pushB b = Arith $ \s -> [BoolValue b:s]
unopI op = Arith $ \(IntValue a:s) -> [IntValue (op a):s]
unopB op = Arith $ \(BoolValue a:s) -> [BoolValue (op a):s]
cmp op = Arith $ \(IntValue b:IntValue a:s) -> [BoolValue (op a b):s]

-- while(true) v++
incrementer v = compile [
  Label "loop",
  Get v,
  unopI (+1), 
  Set v, 
  Jmp "loop"
  ]

-- while(true) {lock(mon) {if(v1 <= v2) v1++}}
syncIncrementer v1 v2 mon = compile [
    Label "loop",
    Enter mon,
    Get v1,
    Get v2,
    cmp (<=),
    JmpCond "ok",
    Jmp "leave",
    Label "ok",
    Get v1,
    unopI (+1),
    Set v1,
    Label "leave",
    Leave mon,
    Jmp "loop"
  ]

main1 = initState [("a", IntValue 1), ("b", IntValue 1)] [] (compile [
  Spawn "a" (incrementer "a"),
  Spawn "b" (incrementer "b")
  ])

main2 = initState [("a", IntValue 1), ("b", IntValue 1)] ["m"] (compile [
  Spawn "a" (syncIncrementer "a" "b" "m")
 ,Spawn "b" (syncIncrementer "b" "a" "m")
  ])

