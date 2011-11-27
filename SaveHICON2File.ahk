﻿/*
group: about
This is an example that uses a bunch of classes from the framework. It contains a function that allows you to save a HICON handle to a *.ico file.
*/
#include Unknown\Unknown.ahk
#include Picture\Picture.ahk
#include SequentialStream\SequentialStream.ahk
#include Stream\Stream.ahk
#include Helper Classes\IDI.ahk
#include Helper Classes\PICTYPE.ahk
#include Helper Classes\STREAM_SEEK.ahk

hIcon := DllCall("LoadIcon", "uint", 0, "Uint", IDI.HAND) ; load a system icon
result := SaveIconToFile(hIcon, A_Desktop "\test.ico", true) ; save the icon to a file
MsgBox % "finished: " . (result ? "succeeded" : "failed") ; report to user
return

/*
Function: SaveIconToFile
saves a HICON to a *.ico file

Parameters:
	HICON hIcon - the HICON handle to save
	STR file - the path to save the file to
	[opt] BOOL bAutoDelete - defines whether the HICON should be automatically relesyed once the icon is saved

Returns:
	BOOL success - true on success, false otherwise.

Remarks:
	This function is a conversion from the C++ code posted <here at http://www.autohotkey.com/forum/viewtopic.php?t=72481>.
*/
SaveIconToFile(hIcon, file, bAutoDelete := false)
{
	/*
	initialize the PICTDESC structure:
		PICTDESC pd = {sizeof(pd), PICTYPE_ICON};
		pd.icon.hicon = hico;
	*/
	VarSetCapacity(pd, 8+A_PtrSize, 0)
	NumPut(8+A_PtrSize, pd, 0, "UInt") ; set cbSize
	NumPut(PICTYPE.ICON, pd, 4, "UInt") ; the image is an icon
	NumPut(hIcon, pd, 8, "UPtr") ; set the icon
	
	/*
	initialize variables:
		CComPtr<IPicture> pPict = NULL;
		CComPtr<IStream>  pStrm = NULL;
		LONG cbSize = 0;
   */
	pPict := 0
	pStrm := 0
	cbSize := 0
	
	/*
	create a stream, a picture and save the picture to the stream:
		res = SUCCEEDED( ::CreateStreamOnHGlobal(NULL, TRUE, &pStrm) );
		res = SUCCEEDED( ::OleCreatePictureIndirect(&pd, IID_IPicture, bAutoDelete, (void**)&pPict) );
		res = SUCCEEDED( pPict->SaveAsFile( pStrm, TRUE, &cbSize ) );
	*/
	pStrm := Stream.FromHGlobal(0)
	DllCall("OleAut32.dll\OleCreatePictureIndirect", "UPtr", &pd, "UPtr", Unknown._Guid(i, Picture.IID), "UInt", bAutoDelete, "ptr*", pPict)
	pPict := new Picture(pPict)
	cbSize := pPict.SaveAsFile(pStrm, true)

	/*
	rewind stream to the beginning
		LARGE_INTEGER li = {0};
		pStrm->Seek(li, STREAM_SEEK_SET, NULL);
	*/
	pStrm.Seek(0, STREAM_SEEK_SET)

	/*
	write to file:
		HANDLE hFile = ::CreateFile(szFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
	*/
	hFile := FileOpen(file, "w")
	
	/*
	if file creation succeeded:
		if( INVALID_HANDLE_VALUE != hFile )
	*/
	if (hFile)
	{
		/*
		initialize variables:
			DWORD dwWritten = 0, dwRead = 0, dwDone = 0;
		*/
		dwWritten := 0, dwRead := 0, dwDone := 0
		
		/*
		create buffer:
			BYTE  buf[4096];
		*/
		VarSetCapacity(buf, 4096, 0)
		
		/*
			while( dwDone < cbSize )
		*/
		while (dwDone < cbSize)
		{
			/*
			read bytes from stream to buffer:
				if( SUCCEEDED(pStrm->Read(buf, sizeof(buf), &dwRead)) )
			*/
			if (pStrm.Read(&buf, 4096, dwRead))
			{
				/*
				write buffer to file:
					::WriteFile(hFile, buf, dwRead, &dwWritten, NULL);
				*/
				dwWritten := hFile.RawWrite(&buf, dwRead)
				
				/*
					if( dwWritten != dwRead ) // if something failed with writing: stop
						break;
					dwDone += dwRead;
				*/
				if (dwWritten != dwRead)
					break
				dwDone += dwRead
			}
			else
				break
		}
		/*
		save file:
			::CloseHandle(hFile);
		*/
		hFile.Close()
		return dwDone == cbSize
	}
}