ffi.cdef [[
    bool CreateDirectoryA(
        const char* lpPathName,
        void* lpSecurityAttributes
    );
    bool WriteFile(
        void*       hFile,
        char*      lpBuffer,
        unsigned long        nNumberOfBytesToWrite,
        unsigned long*      lpNumberOfBytesWritten,
        void* lpOverlapped
    );
    void* CloseHandle(void *hFile);
    void* CreateFileA(
        const char*                lpFileName,
        unsigned long                 dwDesiredAccess,
        unsigned long                 dwShareMode,
        unsigned long lpSecurityAttributes,
        unsigned long                 dwCreationDisposition,
        unsigned long                 dwFlagsAndAttributes,
        void*                hTemplateFile
    );
    bool ReadFile(
        void*       hFile,
        char*       lpBuffer,
        unsigned long        nNumberOfBytesToRead,
        unsigned long*      lpNumberOfBytesRead,
        int lpOverlapped
    );

    typedef struct _OVERLAPPED {
        unsigned long* Internal;
        unsigned long* InternalHigh;
        union {
             struct {
                  unsigned long Offset;
                  unsigned long OffsetHigh;
             } DUMMYSTRUCTNAME;
             void* Pointer;
        } DUMMYUNIONNAME;
        void*    hEvent;
    } OVERLAPPED, *LPOVERLAPPED;

    typedef struct _class{
        void** this;
    } aclass;
]]

-- font downloading
-- get font bytes
local result = Http.Get("https://github.com/11x1/Lua/blob/main/smallest_pixel-7.txt?raw=true")
-- create font directory
ffi.C.CreateDirectoryA("nl\\fonts", nil)
-- only change path ig ("nl\\fonts\\pixelnew.ttf")
local pfile = ffi.cast("void*", ffi.C.CreateFileA("nl\\fonts\\pixelnew.ttf", 0xC0000000, 0x3, 0, 0x4, 0x80, nil))
-- overlapping check
local overlapped = ffi.new("OVERLAPPED")
overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.Offset = 0xFFFFFFFF
overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.OffsetHigh = 0xFFFFFFFF
-- writefile only if it isnt overlapped
ffi.C.WriteFile(pfile, ffi.cast("char*", result), string.len(result), nil, ffi.cast("void*", overlapped))
-- close file
ffi.C.CloseHandle(pfile)

local font = Render.InitFont("nl\\fonts\\pixelnew.ttf", 12)
