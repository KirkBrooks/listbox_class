/*  listForm - form method
 Created by: Kirk as Designer, Created: 12/09/23, 15:03:44
 ------------------

*/
var $ui_msg; $objectName; $itemText : Text
var $isSelected : Boolean
var $listRef; $itemRef; $sublist; $i; $j : Integer

If (Form=Null)
	return 
End if 

$objectName:=String(FORM Event.objectName)
$listRef:=Form.h_list.ref

If (Form event code=On Load)
	Form.h_list:={ref: New list; currentItem: {ref: 0; pos: 0; text: ""; isSelected: False}}
	
	For ($j; 1; 4)
		$sublist:=New list
		
		For ($i; 1; 6)
			$itemRef:=($j*100)+$i
			APPEND TO LIST($sublist; "  Sublist "+String($i)+":"+String($j); $itemRef)
			SET LIST ITEM PARAMETER($sublist; *; "selected"; False)
			SET LIST ITEM PROPERTIES($sublist; $itemRef; False; Plain; 0; 0x00CECECE)
		End for 
		
		APPEND TO LIST(Form.h_list.ref; "List #"+String($j); $j*100; $sublist; False)
		
	End for 
	
End if 

If (Form event code=On Unload)
	CLEAR LIST($listRef)
End if 

If ($objectName="h_list")
	Case of 
		: (Form event code=On Clicked)
			GET LIST ITEM($listRef; *; $itemRef; $itemText)
			$itemText:=Substring($itemText; 2)
			
			If ($itemRef%100>0)
				Form.h_list.currentItem.ref:=$itemRef
				Form.h_list.currentItem.text:=$itemText
				Form.h_list.currentItem.pos:=List item position($listRef; $itemRef)
				GET LIST ITEM PARAMETER($listRef; $itemRef; "isSelected"; $isSelected)
				
				$isSelected:=Not($isSelected)  // toggle the selected state
				Form.h_list.currentItem.isSelected:=$isSelected
				SET LIST ITEM PARAMETER($listRef; $itemRef; "isSelected"; $isSelected)
				
				If ($isSelected)
					SET LIST ITEM($listRef; $itemRef; Char(10003)+$itemText; $itemRef)
					SET LIST ITEM PROPERTIES($listRef; $itemRef; False; Plain; 0; 0x00228B22)
				Else 
					SET LIST ITEM($listRef; $itemRef; " "+$itemText; $itemRef)
					SET LIST ITEM PROPERTIES($listRef; $itemRef; False; Plain; 0; 0x00CECECE)
				End if 
			End if 
	End case 
End if 
