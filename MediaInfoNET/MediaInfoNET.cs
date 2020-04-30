
using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.InteropServices;

public class MediaInfo : IDisposable
{
    public static string DllPath { get; set; }

    IntPtr Handle;
    static bool Loaded;

    public MediaInfo(string path)
    {
        if (!Loaded && File.Exists(DllPath))
        {
            if (IntPtr.Zero == LoadLibrary(DllPath))
                throw new Win32Exception(Marshal.GetLastWin32Error());

            Loaded = true;
        }

        if ((Handle = MediaInfo_New()) == IntPtr.Zero)
            throw new Exception("Error MediaInfo_New");

        if (MediaInfo_Open(Handle, path) == 0)
            throw new Exception("Error MediaInfo_Open");
    }

    public int GetCount(MediaInfoStreamKind streamKind) => MediaInfo_Count_Get(Handle, streamKind, -1);

    public string GetInfo(MediaInfoStreamKind streamKind, int stream, string parameter)
    {
        return Marshal.PtrToStringUni(MediaInfo_Get(Handle, streamKind, stream,
            parameter, MediaInfoKind.Text, MediaInfoKind.Name));
    }

    public string GetSummary(bool complete, bool rawView)
    {
        MediaInfo_Option(Handle, "Language", rawView ? "raw" : "");
        MediaInfo_Option(Handle, "Complete", complete ? "1" : "0");
        return Marshal.PtrToStringUni(MediaInfo_Inform(Handle, 0)) ?? "";
    }

    bool Disposed;

    public void Dispose()
    {
        if (!Disposed)
        {
            if (Handle != IntPtr.Zero)
            {
                MediaInfo_Close(Handle);
                MediaInfo_Delete(Handle);
            }

            Disposed = true;
        }
    }

    ~MediaInfo()
    {
        Dispose();
    }

    [DllImport("kernel32.dll")]
    public static extern IntPtr LoadLibrary(string path);

    [DllImport("MediaInfo.dll")]
    public static extern IntPtr MediaInfo_New();

    [DllImport("MediaInfo.dll", CharSet = CharSet.Unicode)]
    public static extern int MediaInfo_Open(IntPtr handle, string path);

    [DllImport("MediaInfo.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr MediaInfo_Option(IntPtr handle, string option, string value);

    [DllImport("MediaInfo.dll")]
    public static extern IntPtr MediaInfo_Inform(IntPtr handle, int reserved);

    [DllImport("MediaInfo.dll")]
    public static extern int MediaInfo_Close(IntPtr handle);

    [DllImport("MediaInfo.dll")]
    public static extern void MediaInfo_Delete(IntPtr handle);

    [DllImport("MediaInfo.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr MediaInfo_Get(IntPtr handle, MediaInfoStreamKind streamKind,
        int stream, string parameter, MediaInfoKind infoKind, MediaInfoKind searchKind);

    [DllImport("MediaInfo.dll", CharSet = CharSet.Unicode)]
    public static extern int MediaInfo_Count_Get(IntPtr handle, MediaInfoStreamKind streamKind, int stream);
}

public enum MediaInfoStreamKind
{
    General,
    Video,
    Audio,
    Text,
    Other,
    Image,
    Menu,
    Max,
}

public enum MediaInfoKind
{
    Name,
    Text,
    Measure,
    Options,
    NameText,
    MeasureText,
    Info,
    HowTo
}
