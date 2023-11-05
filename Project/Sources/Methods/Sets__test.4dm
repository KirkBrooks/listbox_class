//%attributes = {}

var $test : 4D.Class
var $results : Text
var $setA; $setB; $setC : cs.Set

/*  tests using examples from 
https://en.wikipedia.org/wiki/Set_(mathematics)#Applications
*/

$test:=cs.UnitTest  // constructor
$results:=""

$setA:=cs.Set.new([1; 2; 3])
$results+=$test.new("setA size is 3").expect($setA.size).toEqual(3).displayline+"\n"
$results+=$test.new("setA has 2").expect($setA.has(2)).toEqual(True).displayline+"\n"

$setB:=cs.Set.new([1; 2; 3])
$results+=$test.new("setA isEqual to setB").expect($setA.isEqual($setB)).toEqual(True).displayline+"\n"

$setB:=cs.Set.new([3; 4; 5])
$setC:=$setA.union($setB)
$results+=$test.new("setA UNION setB").expect($setC.isEqual(cs.Set.new([1; 2; 3; 4; 5]))).toEqual(True).displayline+"\n"

$setC:=$setA.intersection($setB)
$results+=$test.new("setA INTERSECT setB").expect($setC.isEqual(cs.Set.new([3]))).toEqual(True).displayline+"\n"

$setC:=$setA.difference($setB)
$results+=$test.new("setA DIFFERENCE setB").expect($setC.isEqual(cs.Set.new([1; 2]))).toEqual(True).displayline+"\n"

$setC:=$setA.symetricDiff($setB)
$results+=$test.new("setA SYMETRIC DIFFERENCE setB").expect($setC.isEqual(cs.Set.new([1; 2; 4; 5]))).toEqual(True).displayline+"\n"

$setC:=$setA.union($setB)
$results+=$test.new("setA SYMETRIC DIFFERENCE setB").expect($setC.isEqual(cs.Set.new([1; 2; 3; 4; 5]))).toEqual(True).displayline+"\n"

$results+=$test.new("the order of values does not matter").expect($setC.isEqual(cs.Set.new([3; 4; 5; 2; 1]))).toEqual(True).displayline+"\n"

ALERT($results)
