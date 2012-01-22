/*
class: ObjectArray
wraps the *IObjectArray* interface and exposes methods that enable clients to access items in a collection of objects that support IUnknown.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ObjectArray)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd378311)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7 / Windows Server 2008 R2 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - CCFramework
*/
class ObjectArray extends Unknown
{
	/*
	Field: IID
	This is IID_IObjectArray. It is required to create an instance.
	*/
	static IID := "{92CA9DCD-5622-4bba-A805-5E9F541BD8C9}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: GetCount
	Provides a count of the objects in the collection.

	Returns:
		UINT count - the object count
	*/
	GetCount()
	{
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "UInt*", count))
		return count
	}

	/*
	Method: GetAt
	Provides a pointer to a specified object's interface. The object and interface are specified by index and interface ID.

	Parameters:
		UINT index - The index of the object
		IID type - Reference to the desired interface ID. This can either be a IID string or a pointer.

	Returns:
		UPTR obj - the interface pointer
	*/
	GetAt(index, type)
	{
		free_mem := false
		if !CCFramework.isInteger(type)
		{
			type := CCFramework.String2GUID(type)
			free_mem := true
		}
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "UInt", index, "ptr", type, "ptr*", out))
		if free_mem
			CCFramework.FreeMemory(type)
		return out
	}
}