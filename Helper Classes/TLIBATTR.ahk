/*
class: TLIBATTR
a structure class that contains information about a type library. Information from this structure is used to identify the type library and to provide national language support for member names.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TLIBATTR)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221376%28v=VS.85%29.aspx)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - (unknown)
	Base classes - StructBase
	Helper classes - SYSKIND, LIBFLAGS
*/
class TLIBATTR
{
	/*
	Field: guid
	The globally unique identifier.
	*/
	guid := ""

	/*
	Field: lcid
	The locale identifier.
	*/
	lcid := 0

	/*
	Field: syskind
	The target hardware platform. You may use the fields of the SYSKIND class for convenience. The initial value is the same as the current OS.
	*/
	syskind := A_PtrSize == 4 ? 1 : 2

	/*
	Field: wMajorVerNum
	The major version number.
	*/
	wMajorVerNum := 0

	/*
	Field: wMinorVerNum
	The minor version number.
	*/
	wMinorVerNum := 0

	/*
	Field: wLibFlags
	The library flags. You may use the fields of the LIBFLAGS class for convenience.
	*/
	wLibFlags := 0

	/*
	Method: ToStructPtr
	converts the instance to a script-usable struct and returns its memory adress.

	Parameters:
		[opt] UPTR ptr - the fixed memory address to copy the struct to.

	Returns:
		UPTR ptr - a pointer to the struct in memory
	*/
	ToStructPtr(ptr := 0)
	{
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		DllCall("Ole32.dll\CLSIDFromString", "str", this.guid, "ptr", ptr)
		NumPut(this.lcid,			1*ptr,	16,	"UInt")
		NumPut(this.syskind,		1*ptr,	20,	"UInt")
		NumPut(this.wMajorVerNum,	1*ptr,	24,	"UShort")
		NumPut(this.wMinorVerNum,	1*ptr,	26,	"UShort")
		NumPut(this.wLibFlags,		1*ptr,	28,	"UShort")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		UPTR ptr - a pointer to a TLIBATTR struct in memory

	Returns:
		TLIBATTR instance - the new TLIBATTR instance
	*/
	FromStructPtr(ptr)
	{
		local instance := new TLIBATTR()

		DllCall("Ole32.dll\StringFromCLSID", "ptr", ptr, "ptr*", guid)
		instance.guid			:= StrGet(guid, "UTF-16")
		instance.lcid			:= NumGet(1*ptr,	16,	"UInt")
		instance.syskind		:= NumGet(1*ptr,	20,	"UInt")
		instance.wMajorVerNum	:= NumGet(1*ptr,	24,	"UShort")
		instance.wMinorVerNum	:= NumGet(1*ptr,	26,	"UShort")
		instance.wLibFlags		:= NumGet(1*ptr,	28,	"UShort")

		return instance
	}

	/*
	Method: GetRequiredSize
	calculates the size a memory instance of this class requires.

	Parameters:
		[opt] OBJECT data - an optional data object that may cotain data for the calculation.

	Returns:
		UINT bytes - the number of bytes required

	Remarks:
		- This may be called as if it was a static method.
		- The data object is ignored by this class.
	*/
	GetRequiredSize(data := "")
	{
		return 30
	}
}