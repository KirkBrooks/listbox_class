/*  DataClassPaths class
 Created by: Kirk as Designer, Created: 03/19/23, 10:37:15
 ------------------
 Description: 
 describes all paths from a given dataclass to a specified depth

path
The 'path' is from this dataclass to the referenced value
This is a string that can be used in a query string, for example. 
Each path from the dataclass to a field should be unique. We store
these paths in This._paths where each path is path is hashed.

*/

Class constructor($dataClass : Text; $maxDepth : Integer; $ds : Object)
	//  $ds allows you to pass in a remote datastore as the datastore
	This:C1470._dataclass:=$ds#Null:C1517 ? $ds[$dataClass] : ds:C1482[$dataClass]
	This:C1470._maxDepth:=Count parameters:C259<2 ? 4 : $maxDepth
	This:C1470._paths:=New object:C1471()
	This:C1470._list:=New list:C375
	
	This:C1470._getPaths(This:C1470._dataclass; ""; This:C1470._maxDepth; This:C1470._list)
	
	
	//mark:  --- getters & setters
Function get name : Text
	return String:C10(This:C1470._dataclass.getInfo().name)
	
Function get listRef : Integer
	return This:C1470._list
	
	//mark:  --- public functions
	// these functions return information about a specific field
Function refPath($listRef : Variant) : Text
	return String:C10(This:C1470._paths[This:C1470.refToStr($listRef)].path)
	
Function refName($listRef : Variant) : Text
	return String:C10(This:C1470._paths[This:C1470.refToStr($listRef)].name)
	
Function refKind($listRef : Variant) : Text
	return String:C10(This:C1470._paths[This:C1470.refToStr($listRef)].kind)
	
Function refIndexed($listRef : Variant) : Boolean
	return Bool:C1537(This:C1470._paths[This:C1470.refToStr($listRef)].indexed)
	
Function refFieldType($listRef : Variant) : Integer
	return Num:C11(This:C1470._paths[This:C1470.refToStr($listRef)].fieldType)
	
Function refCalculated($listRef : Variant) : Boolean
	return Bool:C1537(This:C1470._paths[This:C1470.refToStr($listRef)].kind="calculated")
	
Function refData($listRef : Variant) : Object
	return This:C1470._paths[This:C1470.refToStr($listRef)]
	
Function clear
	CLEAR LIST:C377(This:C1470._list; *)
	This:C1470._paths:=New object:C1471()
	
Function refToStr($listRef : Variant) : Text
	If (Value type:C1509($listRef)=Is real:K8:4) | (Value type:C1509($listRef)=Is longint:K8:6)
		return "_"+String:C10($listRef)
	Else 
		return $listRef
	End if 
	
	//mark:  --- private functions
Function _hash_BKDR($str : Text) : Text
/*  This hash function comes from Brian Kernighan and Dennis Ritchie's book 
"The C Programming Language". It is a simple hash function using a strange set 
of possible seeds which all constitute a pattern of 31....31...31 etc, 
it seems to be very similar to the DJB hash function.
https://www.partow.net/programming/hashfunctions/
*/
	var $seed; $i; $hash : Integer
	
	$seed:=131  // 31 131 1313 13131 131313 etc.
	
	For ($i; 1; Length:C16($str))
		$hash:=($hash*$seed)+(Character code:C91($str[[$i]]))
	End for 
	
	return "_"+String:C10($hash & 0x7FFFFFFF)
	
Function _getPaths($dataClass : Object; $pathTo : Text; $maxDepth : Integer; $listRef : Integer)
/* populates This._paths with a hash map of all paths from dataclass to the max depth. 
Putting the path data in a hash map is extremely efficient and fast. 
$listRef is the list these paths will be appended to. The initial call passes This._listRef.
Subsequent calls, therefore, are creating sublists of that parent list. This is how I handle
the recursion across the multiple relations that arise. 
	
This._paths can contain all the data, unsorted, becuase I generate a unique hash for every path.
And every path leads to one and only one field. I initially thought about storing the path data
in a list parameter but found it too limiting beyond very simple data. This._paths let's me store
any amount of data. 
	
Because the hash is a longint it can be used as the listRef. By having a unique listRef in the list
I can immeadiately get the relevant data for a listRef from the hash map with a simple stringify. I do
this in this.refToStr(). I elected to store prepend an underscore to the text references to make
This._paths completely compliant. 
	
When I construct a menu I need a text value to use as the menu parameter anyway. Menu parameter is 
the equivalent of a listRef: a unique value within the context of the menu or list.
	
So with the data stored this way it's easy to represent the database structure as a list or menu. 
*/
	var $ds : cs:C1710.DataStore
	var $thisPath; $hash; $thisField : Text
	var $thisAttribute; $obj : Object
	var $subList : Integer
	var $fields; $relatedEntity; $relatedMany : Collection
	
	$ds:=$dataClass.getDataStore()  //  not required to be the local ds
	//  doing this so I can sort the elements after getting them
	$fields:=New collection:C1472()
	$relatedEntity:=New collection:C1472()
	$relatedMany:=New collection:C1472()
	
	For each ($thisField; $dataClass)
		
		$thisAttribute:=$dataClass[$thisField]
		$thisPath:=$pathTo+$thisAttribute.name
		$thisAttribute.path:=$thisPath
		$hash:=This:C1470._hash_BKDR($thisPath)
		
		Case of 
			: ($thisAttribute.kind="Storage")
				This:C1470._newPath($hash; $thisAttribute)
				$fields.push(New object:C1471("name"; $thisAttribute.name; "hash"; $hash))
				
			: ($thisAttribute.kind="calculated")
				This:C1470._newPath($hash; $thisAttribute)
				$fields.push(New object:C1471("name"; $thisAttribute.name; "hash"; $hash))
				
			: ($thisAttribute.kind="relatedEntity") & ($maxDepth>0)
				$subList:=New list:C375
				This:C1470._getPaths($ds[$thisAttribute.relatedDataClass]; $thisPath+"."; $maxDepth-1; $subList)
				$relatedEntity.push(New object:C1471("name"; $thisAttribute.name; "hash"; $hash; "list"; $subList))
				
			: ($thisAttribute.kind="relatedEntities") & ($maxDepth>0)
				$subList:=New list:C375
				This:C1470._getPaths($ds[$thisAttribute.relatedDataClass]; $thisPath+"."; $maxDepth-1; $subList)
				$relatedMany.push(New object:C1471("name"; $thisAttribute.name; "hash"; $hash; "list"; $subList))
				
		End case 
	End for each 
	
/*  sort by name then add them to the list
using the dataclass name here but the path will be the
relation name. Some databases have crappy relation names,
this is more understandable.
*/
	For each ($obj; $fields.orderBy("name"))
		APPEND TO LIST:C376($listRef; $obj.name; Num:C11($obj.hash))
	End for each 
	
	For each ($obj; $relatedEntity.orderBy("name"))
		APPEND TO LIST:C376($listRef; "Nto1: "+$obj.name; Num:C11($obj.hash); $obj.list; False:C215)
	End for each 
	
	For each ($obj; $relatedMany.orderBy("name"))
		APPEND TO LIST:C376($listRef; "1toN: "+$obj.name; Num:C11($obj.hash); $obj.list; False:C215)
	End for each 
	
Function _newPath($hash : Text; $attr : Object)
	ASSERT:C1129(This:C1470._paths[$hash]=Null:C1517)
	This:C1470._paths[$hash]:=$attr
	