

#DECLARE->$result : Integer
$result:=0  // Assume the database request will be granted

Case of 
	: (Test semaphore("suppressTriggers"))
		//  semaphore to set when doing bulk updates or other
		//  operations where we don't want triggers to fire
		
	: (Trigger event=On Saving New Record Event)
		
	: (Trigger event=On Saving Existing Record Event)
		
	: (Trigger event=On Deleting Record Event)
		
End case 
