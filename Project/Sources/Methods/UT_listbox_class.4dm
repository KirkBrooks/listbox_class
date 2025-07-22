//%attributes = {}
/* Purpose:
 ------------------
UT_listbox_class ()
 Created by: Kirk as Designer, Created: 07/12/23, 19:03:58
*/
//  unit testing stuff
var $test; $formula; $entity; $result : Object
var $collection : Collection
var $i; $length : Integer
var $results : Text

//mark:  --- begin test

var $class : cs.listbox
$class:=cs.listbox.new("test_LB")
ASSERT($class#Null)
// check defaults

ASSERT($class.isCollection=False)
ASSERT($class.isEntitySelection=False)
ASSERT($class.isFormObject=False)
ASSERT($class.isReady=False)
ASSERT($class.isSelected=False)
ASSERT($class.index=-1)
ASSERT($class.shortDesc="The listbox is empty.")

ASSERT($class.position=0)
ASSERT($class.selectedItems=Null)
ASSERT($class.currentItem=Null)


$collection:=[]
$length:=20
For ($i; 1; $length)
	$collection.push({i: $i; text: "This is row number "+String($i); number: 100*$i})
End for 

$class:=cs.listbox.new("test_LB"; $collection)
ASSERT($class#Null)
// check defaults

ASSERT($class.isCollection=True)
ASSERT($class.isEntitySelection=False)
ASSERT($class.isFormObject=False)
ASSERT($class.isReady=True)
ASSERT($class.isSelected=False)
ASSERT($class.index=-1)
ASSERT($class.shortDesc="0 selected out of 20")

ASSERT($class.position=0)
ASSERT($class.selectedItems=Null)
ASSERT($class.currentItem=Null)

ASSERT($class.sum("i")=210)
ASSERT($class.min("i")=1)
ASSERT($class.max("i")=20)
ASSERT($class.average("i")=10.5)


$obj:=$class.data[10]  //  number = 1000
ASSERT($class.indexOf($obj)=10)
ASSERT($class.findRow($obj)=11)
ASSERT($class.lastIndexOf("i"; 7)=6)
ASSERT($class.distinct("text").length=20)
ASSERT($class.extract("number").length=20)



$class.selectRow(3)  // select a row by number
ASSERT($class.isCollection=True)
ASSERT($class.isEntitySelection=False)
ASSERT($class.isFormObject=False)
ASSERT($class.isReady=True)
ASSERT($class.isSelected=True)
ASSERT($class.index=2)
ASSERT($class.shortDesc="1 selected out of 20")

ASSERT($class.position=3)
ASSERT($class.selectedItems#Null)
ASSERT($class.currentItem#Null)

$class.selectRow($collection[2])  // select row object is on
ASSERT($class.isCollection=True)
ASSERT($class.isEntitySelection=False)
ASSERT($class.isFormObject=False)
ASSERT($class.isReady=True)
ASSERT($class.isSelected=True)
ASSERT($class.index=2)
ASSERT($class.shortDesc="1 selected out of 20")
ASSERT($class.currentItem=$class.get_item())

ASSERT($class.position=3)
ASSERT($class.selectedItems#Null)
ASSERT($class.currentItem#Null)

$class.selectRow(30)  // no such row
ASSERT($class.isCollection=True)
ASSERT($class.isEntitySelection=False)
ASSERT($class.isFormObject=False)
ASSERT($class.isReady=True)
ASSERT($class.isSelected=False)
ASSERT($class.index=-1)
ASSERT($class.shortDesc="0 selected out of 20")

ASSERT($class.position=0)
ASSERT($class.selectedItems=Null)
ASSERT($class.currentItem=Null)

// insert an item into the collection
var $obj : Object:={i: 21; text: "This is row number 21"; number: 999}
$result:=$class.insert(5; $obj)  // inserting does not select it
ASSERT($result.success)
ASSERT($class.data[5]=$obj)

//mark:  --- entity selection data

$class:=cs.listbox.new("test_LB")
$class.setSource(Address_getRecords)

ASSERT($class#Null)
ASSERT($class.isCollection=False)
ASSERT($class.isEntitySelection=True)
ASSERT($class.dataClass.getInfo().name=ds.ADDRESS.getInfo().name)
ASSERT($class.isFormObject=False)
ASSERT($class.isReady=True)
ASSERT($class.isSelected=False)
ASSERT($class.index=-1)
ASSERT($class.shortDesc="0 selected out of 5000")

//  math functions
ASSERT($class.sum("latitude")=189697.433635)
ASSERT($class.min("latitude")=15.179922)
ASSERT($class.max("latitude")=66.825)
ASSERT($class.average("latitude")=37.939486727)

ASSERT($class.indexOf($class.data[22])=22)
ASSERT($class.findRow($class.data[22])=23)
ASSERT($class.lastIndexOf("city"; "Burns")=20)
ASSERT($class.distinct("state").length=52)
ASSERT($class.extract("city").length=5000)

START TRANSACTION()
$entity:=ds.ADDRESS.new()
$entity.save()

$result:=$class.insert(0; $entity)
ASSERT($result.success=False)
CANCEL TRANSACTION

ALERT("Unit test complete")