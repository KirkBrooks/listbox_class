/*  Set class
 Created by: Kirk as Designer, Created: 11/05/23, 08:44:47
 ------------------
From Tech Note: Nhat Do

The set is an object where each property is a discrete text string
The property value 
*/

Class constructor($param : Collection)
	This._strSet:={}
	This._numSet:={}
	This.size:=0
	
	If ($param=Null)
		return 
	End if 
	
	var $item : Variant
	
	For each ($item; $param)
		This.add($item)
	End for each 
	
	//mark:  --- manage this set
Function has($item : Variant) : Boolean
	If (Value type($item)=Is text)
		return This._strSet[String($item)]=True
	End if 
	
	If (Value type($item)=Is real) || (Value type($item)=Is longint)
		return This._numSet[String($item)]=True
	End if 
	
Function add($item : Variant) : cs.Set
	If (Value type($item)=Is text) && (This._strSet[String($item)]=Null)
		This._strSet[String($item)]:=True
		This.size+=1
		return This
	End if 
	
	If ((Value type($item)=Is longint) || (Value type($item)=Is real)) && (This._numSet[String($item)]=Null)
		This._numSet[String($item)]:=True
		This.size+=1
		return This
	End if 
	
	return This
	
Function delete($item : Variant) : cs.Set
	If (Value type($item)=Is text) && (This._strSet[String($item)]=True)
		OB REMOVE(This._strSet; String($item))
		This.size-=1
		return This
	End if 
	
	If ((Value type($item)=Is longint) || (Value type($item)=Is real)) && (This._numSet[String($item)]=True)
		OB REMOVE(This._numSet; String($item))
		This.size-=1
		return This
	End if 
	
	return This
	
Function clear() : cs.Set
	This._strSet:={}
	This._numSet:={}
	This.size:=0
	
	return This
	
Function collection()->$coll : Collection
	var $item : Text
	$coll:=[]
	
	For each ($item; This._strSet)
		$coll.push($item)
	End for each 
	
	For each ($item; This._numSet)
		$coll.push(Num($item))
	End for each 
	
	return $coll
	
	//mark:  --- set operations
Function isEqual($A : cs.Set)->$isEqual : Boolean
	//  true when every element $A is in This and sizes are equal
	return ($A.size=This.size) && (This.difference($A).size=0)
	
Function union($A : cs.Set)->$union : cs.Set
	var $item : Variant
	$union:=cs.Set.new($A.collection())
	For each ($item; This.collection())
		$union.add($item)
	End for each 
	return 
	
Function intersection($A : cs.Set)->$intersection : cs.Set
	// return a new set that is intersection of $A and this set
	var $item : Variant
	
	$intersection:=cs.Set.new()
	For each ($item; $A.collection())
		If (This.has($item))
			$intersection.add($item)
		End if 
	End for each 
	return 
	
Function difference($A : cs.Set)->$diff : cs.Set
	// $diff are the members of $THIS that ARE NOT in $A
	var $item : Variant
	
	$diff:=cs.Set.new(This.collection())  //  copy This
	For each ($item; $A.collection())
		$diff.delete($item)  // remove any matching elements
	End for each 
	return $diff
	
Function symetricDiff($A : cs.Set)->$diff : cs.Set
/*  the symmetric difference of two sets, 
also known as the disjunctive union and set sum, 
is the set of elements which are in either of the sets, 
but not in their intersection. 
	
For example, the symmetric difference of the sets 
{ 1, 2, 3 } and { 3, 4 } is { 1, 2, 4 }  
*/
	var $item : Variant
	
	$diff:=cs.Set.new($A.collection())
	
	For each ($item; This.collection())
		If ($diff.has($item))
			$diff.delete($item)
		Else 
			$diff.add($item)
		End if 
	End for each 
	
	return $diff
	
Function isSuperSet($A : cs.Set) : Boolean
	// returns true when every item in This is also in $A
	var $item : Variant
	
	For each ($item; $A.collection())
		If (Not(This.has($item)))
			return False
		End if 
	End for each 
	
	return True
	