//%attributes = {}
/* Purpose: series of unit test for  listbox class
 ------------------
listbox_unitTest ()
 Created by: Kirk as Designer, Created: 05/03/23, 18:25:06
*/

var $class : cs.listbox
var $collection; $resultCol : Collection

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
$collection:=New collection()
$length:=20
For ($i; 1; $length)
	$collection.push(New object("number"; Random; "date"; Timestamp; "text"; "This is a text string"; "bool"; Random%2=0))
	DELAY PROCESS(Current process; 32)  //  allow timestamp to advance - reduc
End for 

$class.setSource($collection.copy())

ASSERT($class.dataLength=$length; "Listbox length is incorrect")
ASSERT(Not($class.isSelected); "There is no selection")
ASSERT($class.index=-1; "There is no selection so -1 index")
ASSERT($class.get_item()=Null; "There is no selection so no item to get")
ASSERT($class.get_shortDesc()="0 selected@"; "There are no items selected")
ASSERT($class.dataLength=$class.source.length; "The data and source should be the same length")

//  insert an item and use it for some test later
$class.insert(7; New object("number"; 7; "date"; Timestamp; "text"; "This is different"; "bool"; Random%2=0))
$length+=1
ASSERT($class.data[7].number=7; "The insert operation failed")

ASSERT($class.sum("number")=$class.data.sum("number"); "The sum function failed")
ASSERT($class.extract("bool").length=$length; "Extract collection is not correct")
ASSERT($class.distinct("text").length=2; "Distinct failed")
ASSERT($class.lastIndexOf("text"; "This is different")=7; "LastIndexOf should return the inserted object, 7")

// --------------------------------------------------------
ALERT("All tests complete!\n\n If no asserts appeared all tests passed.")