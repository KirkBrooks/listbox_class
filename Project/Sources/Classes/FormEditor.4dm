/*  FormEditor class
 Created by: Kirk as Designer, Created: 11/28/23, 15:40:54
 ------------------
Provides some functtions and tools for working with
a form editor

*/

Class constructor($form : Object; $file : 4D.File)
	This.form:=$form
	This.file:=$file
	
	//mark:  --- getters
Function get name : Text
	return This.form.name
	
	//mark:  --- functions
Function getPage($number : Integer) : Object
	If ($number>This.form.pages.length) || ($number<0)
		return Null
	End if 
	
	return This.form.pages[$number]
	
Function getObject($name : Text) : Object
	var $page : Object
	
	For each ($page; This.form.pages)
		If ($page=Null)
			continue
		End if 
		
		If ($page.objects[$name]#Null)
			return $page.objects[$name]
		End if 
	End for each 
	
Function isDupeName($name : Text)->$isDupe : Boolean
	// new object names must be unique for the entire form
	return This.getObject($name)#Null
	
Function getObjectCoords($name : Text)->$coords : Collection
	//  [0; 0; 0; 0; 0; 0]  // l; t; r; b; w; h
	var $obj : Object
	$obj:=This.getObject($name)
	
	If ($obj=Null)
		return []
	End if 
	
	$coords:=[0; 0; 0; 0; 0; 0]  // l; t; r; b; w; h
	
	//  objects always have a left & top
	$coords[0]:=$obj.left
	$coords[1]:=$obj.top
	// usually 4D has height and width
	If ($obj.width#Null)
		$coords[4]:=$obj.width
		$coords[2]:=$obj.width-$obj.left  // calc right
	Else 
		$coords[2]:=$obj.left
		$coords[4]:=$obj.left-$obj.width
	End if 
	
	If ($obj.height#Null)
		$coords[5]:=$obj.height
		$coords[3]:=$obj.height-$obj.top
	Else 
		$coords[3]:=$obj.bottom
		$coords[5]:=$obj.bottom-$obj.height
	End if 
	
Function addObjectToPage($name : Text; $object : Object; $page : Integer)
	var $objects : Object
	$objects:=This.getPage($page)
	$objects.objects[$name]:=$object
	
Function getMethodFile($name : Text)->$file : 4D.File
	// if name is blank or 'form' returns the form method
	// object method otherwise
	If ($name="form") || ($name="")
		$file:=This.file.parent.file("method.4dm")
	End if 
	
	
	
	//mark:  --- new objects
Function newListbox() : Object
	//  returns a minimal listbox object
	return {type: "listbox"; \
		left: 100; \
		top: 100; \
		width: 200; \
		height: 300; \
		events: []; \
		listboxType: "collection"; \
		columns: [\
		{name: "Column1"; \
		header: {text: "Header1"; name: "Header2"}; \
		footer: {name: "Footer2"}}]}
	