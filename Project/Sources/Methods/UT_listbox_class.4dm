//%attributes = {}
/* Purpose: 
 ------------------
UT_listbox_class ()
 Created by: Kirk as Designer, Created: 07/12/23, 19:03:58
*/
//  unit testing stuff
var $test; $formula; $obj; $entity : Object
var $collection : Collection
var $i; $length : Integer
var $results : Text

$test:=cs.UnitTest  //  constructor object for unit test
$results:="Listbox Class unit test:\n\n"

//mark:  --- begin test

var $class : cs.listbox
$class:=cs.listbox.new("test_LB")

$results+=$test.new("$class is not null").expect($class).notToBeNull().displayline+"\n"
$results+=$test.new("$class.isFormObject is false").expect($class.isFormObject).toEqual(False).displayline+"\n"
$results+=$test.new("$class.isREad is false").expect($class.isReady).toEqual(False).displayline+"\n"
$results+=$test.new("Empty listbox should have zero length").expect($class.dataLength).toEqual(0).displayline+"\n"
$results+=$test.new("$class.isSelected is False").expect($class.isSelected).toEqual(False).displayline+"\n"
$results+=$test.new("index should be -1").expect($class.index).toEqual(-1).displayline+"\n"
$results+=$test.new("get_item() should be null").expect($class.get_item()).toBeNull().displayline+"\n"
$results+=$test.new("isEntitySelection should be false").expect($class.isEntitySelection).toEqual(False).displayline+"\n"
$results+=$test.new("isCollection should be false").expect($class.isCollection).toEqual(False).displayline+"\n"
$results+=$test.new("Empty class description is 'The listbox is empty'").expect($class.get_shortDesc()).toEqual("The listbox is empty").displayline+"\n"

$results+="\nMath Functions on empty listbox\n"
$results+=$test.new("Sum should be 0").expect($class.sum("x")).toEqual(0).displayline+"\n"
$results+=$test.new("Min should be 0").expect($class.min("x")).toEqual(0).displayline+"\n"
$results+=$test.new("Max should be 0").expect($class.max("x")).toEqual(0).displayline+"\n"
$results+=$test.new("Average should be 0").expect($class.average("x")).toEqual(0).displayline+"\n"

$results+="\n"+$test.new("No errors").expect($class.error).toEqual("").displayline+"\n"

//mark:  --- entity selection data

$class:=cs.listbox.new("test_LB").setSource(Address_getRecords())

$results+="\nEntity Selection data\n"
$results+=$test.new("isReady should be True").expect($class.isReady).toEqual(True).displayline+"\n"
$results+=$test.new("dataLength should be 5000").expect($class.dataLength).toEqual(5000).displayline+"\n"
$results+=$test.new("isSelected should be False").expect($class.isSelected).toEqual(False).displayline+"\n"
$results+=$test.new("index should be -1").expect($class.index).toEqual(-1).displayline+"\n"
$results+=$test.new("get_item() should be null").expect($class.get_item()).toBeNull().displayline+"\n"
$results+=$test.new("isEntitySelection should be True").expect($class.isEntitySelection).toEqual(True).displayline+"\n"
$results+=$test.new("isCollection should be false").expect($class.isCollection).toEqual(False).displayline+"\n"
$results+=$test.new("Description is '0 selected out of 5000'").expect($class.get_shortDesc()).toEqual("0 selected out of 5000").displayline+"\n"

$results+="\n  Math Functions \n"
$results+=$test.new("Sum(latitude) should be 189697.433635").expect($class.sum("latitude")).toEqual(189697.433635).displayline+"\n"
$results+=$test.new("Min(latitude) should be 15.179922").expect($class.min("latitude")).toEqual(15.179922).displayline+"\n"
$results+=$test.new("Max(latitude) should be 66.825").expect($class.max("latitude")).toEqual(66.825).displayline+"\n"
$results+=$test.new("Average(latitude) should be 37.939486727").expect($class.average("latitude")).toEqual(37.939486727).displayline+"\n"

$results+="\n  Functions \n"
$obj:=$class.data[22]
$results+=$test.new("Index of object at data[22]").expect($class.indexOf($obj)).toEqual(22).displayline+"\n"
$results+=$test.new("Row number of object at data[22] should be 23").expect($class.findRow($obj)).toEqual(23).displayline+"\n"
$results+=$test.new("Last index of city='Burns' is 20").expect($class.lastIndexOf("city"; "Burns")).toEqual(20).displayline+"\n"
$results+=$test.new("Length of 'distinct(\"state\") is 50").expect($class.distinct("state").length).toEqual(52).displayline+"\n"
$results+=$test.new("Length of 'extract(\"zip\") is 5000").expect($class.extract("city").length).toEqual(5000).displayline+"\n"

START TRANSACTION()
$entity:=ds.ADDRESS.new()
$entity.save()
$results+=$test.new("Attempting to insert to entity selection fails").expect($class.insert(0; $entity)).notToContain(New object("success"; True)).displayline+"\n"
CANCEL TRANSACTION


//mark:  --- collection data
$collection:=New collection()
$length:=20
For ($i; 1; $length)
	$collection.push(New object("i"; $i; "text"; "This is row number "+String($i); "number"; 100*$i))
End for 

$class:=cs.listbox.new("test_LB")
$class.setSource($collection)

$results+=$test.new("Class description is '0 selected out of 20'").expect($class.get_shortDesc()).toEqual("0 selected out of 20").displayline+"\n"
$results+="\nCollection data\n"
$results+=$test.new("isReady should be True").expect($class.isReady).toEqual(True).displayline+"\n"
$results+=$test.new("dataLength should be "+String($length)).expect($class.dataLength).toEqual($length).displayline+"\n"
$results+=$test.new("isSelected should be False").expect($class.isSelected).toEqual(False).displayline+"\n"
$results+=$test.new("index should be -1").expect($class.index).toEqual(-1).displayline+"\n"
$results+=$test.new("get_item() should be null").expect($class.get_item()).toBeNull().displayline+"\n"
$results+=$test.new("isEntitySelection should be false").expect($class.isEntitySelection).toEqual(False).displayline+"\n"
$results+=$test.new("isCollection should be true").expect($class.isCollection).toEqual(True).displayline+"\n"

$results+="\n  Math Functions \n"
$results+=$test.new("Sum(i) should be 210").expect($class.sum("i")).toEqual(210).displayline+"\n"
$results+=$test.new("Min(i) should be 1").expect($class.min("i")).toEqual(1).displayline+"\n"
$results+=$test.new("Max(i) should be 20").expect($class.max("i")).toEqual(20).displayline+"\n"
$results+=$test.new("Average(i) should be 10.5").expect($class.average("i")).toEqual(10.5).displayline+"\n"

$results+="\n  Functions \n"

$obj:=$class.data[10]  //  number = 1000
$results+=$test.new("Index of object at data[10]").expect($class.indexOf($obj)).toEqual(10).displayline+"\n"
$results+=$test.new("Row number of object at data[10] should be 11").expect($class.findRow($obj)).toEqual(11).displayline+"\n"
$results+=$test.new("Last index of i=7 is 6").expect($class.lastIndexOf("i"; 7)).toEqual(6).displayline+"\n"
$results+=$test.new("Length of 'distinct(\"text\") is 20").expect($class.distinct("text").length).toEqual(20).displayline+"\n"
$results+=$test.new("Length of 'extract(\"number\") is 20").expect($class.extract("number").length).toEqual(20).displayline+"\n"

$obj:=New object("i"; 33; "text"; "This is row number "+String(33); "number"; 100*33)
$results+=$test.new("Insert new object").expect($class.insert(0; $obj)).toContain(New object("success"; True)).displayline+"\n"



//mark:  --- show results
ALERT($results)
