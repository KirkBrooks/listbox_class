//%attributes = {}
/*
Classes for managing the data source for a listbox

listbox.setSource(<source>)

listbox class will handle the interface between the source and 
the consumer. The idea is to make the distinction between the 
two as transparent as possible while optimizing the attributes
of both. 

We especially want to take advantage of establishing a context
between the ds and entity selections. 

*/