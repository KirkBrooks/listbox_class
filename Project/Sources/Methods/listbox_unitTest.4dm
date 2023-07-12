//%attributes = {}
/* Purpose: series of unit test for  listbox class
 ------------------
listbox_unitTest ()
 Created by: Kirk as Designer,  
 Modified by: Kirk (07/11/2023 19:01:54) 
*/
var $class : cs.listbox
var $collection; $resultCol : Collection
var $length; $i; $index; $row : Integer
var $entity : cs.ADDRESSEntity
var $result : Object

$class:=cs.listbox.new("test_LB")

//mark:-  empty listbox
ASSERT($class.dataLength=0; "Empty listbox should have zero length")
ASSERT(Not($class.isSelected); "Empty listbox has no selection")
ASSERT($class.index=-1; "Empty listbox has -1 index")
ASSERT($class.get_item()=Null; "Empty listbox has no item")
ASSERT($class.get_shortDesc()="The listbox is empty."; "Empty listbox should say so")

$class.deselect()
$class.findRow()

ASSERT($class.sum()=0; "Math functions should be zero when there is no data")
ASSERT($class.extract().length=0; "Extract should return empty collection when there is no data")
ASSERT($class.distinct().length=0; "Distinct should return empty collection when there is no data")

//mark:  --- setting data
$class.setSource(Address_getRecords)

ASSERT($class.isEntitySelection; "This should show as an entity selection. ")
ASSERT(Not($class.isCollection); "This should show as an entity selection. ")
ASSERT($class.dataLength=Records in table([ADDRESS]); "The entity selection does not seem correct.")

// mock up selecting an item at index 9
$class.position:=10
$class.currentItem:=$class.data[9]
$class.selectedItems:=$class.data.query("ID = :1"; $class.currentItem.ID)

ASSERT($class.isSelected; "The class should indicate it is selected.")
ASSERT($class.currentItem.street="2864 Petunia Way"; "The street value appears incorrect.")
ASSERT($class.get_item().street="2864 Petunia Way"; "The 'get_item()' function should return the currentItem.")
ASSERT($class.get_shortDesc()="1 selected out of 5000"; "There is one item selected.")

$result:=$class.insert(7; New object("number"; 7; "date"; Timestamp; "text"; "This is different"; "bool"; Random%2=0))
ASSERT($result.success=False; "Shouldn't be able to insert into an entity selection.")

$entity:=$class.data[23]
$index:=$class.indexOf($entity)
ASSERT($index=23; "Should find the index of the entity.")

ASSERT($class.lastIndexOf("City"; "Buffalo")=-1; "The property name in the table is 'city'.")
$index:=$class.lastIndexOf("city"; "Buffalo")
$entity:=$class.data[$index]
ASSERT($entity.city="Buffalo")

$row:=$class.findRow($entity)  //  what row is this entity on?
ASSERT($row=($index+1); "The row should be the index + 1.")

/*  put a subset of records into data
This is the whole point of having 'source' and 'data'

*/
$class.data:=$class.source.slice(0; 100)
ASSERT($class.sum("latitude")>0; "The sum function should return a value.")
ASSERT($class.min("latitude")>0; "The min function should return a value.")
ASSERT($class.max("latitude")>0; "The max function should return a value.")
ASSERT($class.extract("city").length=100; "The extracted city array is not correct.")
ASSERT(($class.distinct("city").length>0) & ($class.distinct("city").length<=100); "The distinct city array is not correct.")


//mark:  --- now test the collection functions

$collection:=New collection()
$length:=20
For ($i; 1; $length)
	$collection.push(New object("i"; $i; "number"; Random; "date"; Timestamp; "text"; "This is a text string"; "bool"; Random%2=0))
End for 

$class.setSource($collection.copy())
ASSERT(Not($class.isEntitySelection); "This is a collection. ")
ASSERT($class.isCollection; "This is a collection. ")

ASSERT($class.findRow("i"; 14)=14; "The row number should match 'i'.")
ASSERT($class.dataLength=$length; "Listbox length is incorrect")
ASSERT(Not($class.isSelected); "There is no selection")
ASSERT($class.index=-1; "There is no selection so -1 index")
ASSERT($class.get_item()=Null; "There is no selection so no item to get")
ASSERT($class.get_shortDesc()="0 selected@"; "There are no items selected")
ASSERT($class.dataLength=$class.source.length; "The data and source should be the same length")

//  insert an item and use it for some test later
$result:=$class.insert(7; New object("number"; 7; "date"; Timestamp; "text"; "This is different"; "bool"; Random%2=0))
ASSERT($result.success; "Should be able to insert. ")

$length+=1
ASSERT($class.data[7].number=7; "The insert operation failed")

ASSERT($class.sum("number")=$class.data.sum("number"); "The sum function failed")
ASSERT($class.extract("bool").length=$length; "Extract collection is not correct")
ASSERT($class.distinct("text").length=2; "Distinct failed")
ASSERT($class.lastIndexOf("text"; "This is different")=7; "LastIndexOf should return the inserted object, 7")

// --------------------------------------------------------
ALERT("All tests complete!\n\n If no asserts appeared all tests passed.")