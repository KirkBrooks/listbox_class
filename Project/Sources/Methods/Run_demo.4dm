//%attributes = {}
/* Purpose: open the listbox class demo form

Be sure to also take a look at
    listbox_unitTest
 ------------------
Run_demo ()
 Created by: Kirk as Designer, Created: 07/12/23, 12:23:12
*/
var $window : Integer
var $formData : Object

$window:=Open form window("demo_form"; Plain form window)

/*  You can instantiate and populate the listbox class
before opening the form. For example, you could pass an entity selection
of Addresses into this method and instantiate the class right here.
*/
$formData:=New object()

DIALOG("demo_form"; $formData)
CLOSE WINDOW($window)

ALERT("Before you go-\n\nNotice that because the listbox class doesn't need a form object you still have the data and lots of functionality available. \n\nCheck out $formData.")
TRACE

