# Display.ps1
# Turns on exactly the listed monitors, turns the others off, and places them.
# The monitor placed at 0,0 becomes the main (primary) monitor.
# Uses the same Windows API as the Settings > Display page (QueryDisplayConfig / SetDisplayConfig).
# Usage: Display.ps1 ABC1234=0,0 DEF5678=1920,0 GHI9012=1920,-1080
#        Display.ps1 --list   (prints ID<TAB>X<TAB>Y<TAB>Width<TAB>Height<TAB>Name for each active monitor)
#   left side  = Short Monitor ID (as in the monitor's hardware ID)
#   right side = X,Y of the monitor's top-left corner

$src = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

public static class DispCfg {
    [StructLayout(LayoutKind.Sequential)]
    public struct LUID { public uint LowPart; public int HighPart; }

    [StructLayout(LayoutKind.Sequential)]
    public struct PATH_SOURCE_INFO { public LUID adapterId; public uint id; public uint modeInfoIdx; public uint statusFlags; }

    [StructLayout(LayoutKind.Sequential)]
    public struct RATIONAL { public uint Numerator; public uint Denominator; }

    [StructLayout(LayoutKind.Sequential)]
    public struct PATH_TARGET_INFO {
        public LUID adapterId; public uint id; public uint modeInfoIdx;
        public int outputTechnology; public int rotation; public int scaling;
        public RATIONAL refreshRate; public int scanLineOrdering;
        public int targetAvailable; public uint statusFlags;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PATH_INFO { public PATH_SOURCE_INFO sourceInfo; public PATH_TARGET_INFO targetInfo; public uint flags; }

    [StructLayout(LayoutKind.Explicit, Size = 64)]
    public struct MODE_INFO {
        [FieldOffset(0)]  public int infoType;   // 1 = source, 2 = target
        [FieldOffset(4)]  public uint id;
        [FieldOffset(8)]  public LUID adapterId;
        [FieldOffset(16)] public uint width;
        [FieldOffset(20)] public uint height;
        [FieldOffset(24)] public int pixelFormat;
        [FieldOffset(28)] public int posX;
        [FieldOffset(32)] public int posY;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DEVICE_INFO_HEADER { public int type; public uint size; public LUID adapterId; public uint id; }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct TARGET_DEVICE_NAME {
        public DEVICE_INFO_HEADER header;
        public uint flags; public int outputTechnology;
        public ushort edidManufactureId; public ushort edidProductCodeId;
        public uint connectorInstance;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 64)]  public string monitorFriendlyDeviceName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string monitorDevicePath;
    }

    [DllImport("user32.dll")] static extern int GetDisplayConfigBufferSizes(uint flags, out uint numPaths, out uint numModes);
    [DllImport("user32.dll")] static extern int QueryDisplayConfig(uint flags, ref uint numPaths, [Out] PATH_INFO[] paths, ref uint numModes, [Out] MODE_INFO[] modes, IntPtr topologyId);
    [DllImport("user32.dll")] static extern int SetDisplayConfig(uint numPaths, [In] PATH_INFO[] paths, uint numModes, [In] MODE_INFO[] modes, uint flags);
    [DllImport("user32.dll")] static extern int DisplayConfigGetDeviceInfo(ref TARGET_DEVICE_NAME info);

    const uint QDC_ALL_PATHS = 0x1, QDC_ONLY_ACTIVE_PATHS = 0x2;
    const uint SDC_APPLY = 0x80, SDC_USE_SUPPLIED_DISPLAY_CONFIG = 0x20, SDC_SAVE_TO_DATABASE = 0x200, SDC_ALLOW_CHANGES = 0x400;
    const uint PATH_ACTIVE = 0x1, IDX_INVALID = 0xFFFFFFFF;
    const uint APPLY_FLAGS = SDC_APPLY | SDC_USE_SUPPLIED_DISPLAY_CONFIG | SDC_ALLOW_CHANGES | SDC_SAVE_TO_DATABASE;

    static void Query(uint flags, out PATH_INFO[] paths, out MODE_INFO[] modes) {
        uint np, nm;
        int r = GetDisplayConfigBufferSizes(flags, out np, out nm);
        if (r != 0) throw new Exception("GetDisplayConfigBufferSizes failed: " + r);
        paths = new PATH_INFO[np];
        modes = new MODE_INFO[nm];
        r = QueryDisplayConfig(flags, ref np, paths, ref nm, modes, IntPtr.Zero);
        if (r != 0) throw new Exception("QueryDisplayConfig failed: " + r);
        Array.Resize(ref paths, (int)np);
        Array.Resize(ref modes, (int)nm);
    }

    static string[] TargetName(PATH_INFO p) {
        var n = new TARGET_DEVICE_NAME();
        n.header.type = 2; // DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
        n.header.size = (uint)Marshal.SizeOf(typeof(TARGET_DEVICE_NAME));
        n.header.adapterId = p.targetInfo.adapterId;
        n.header.id = p.targetInfo.id;
        if (DisplayConfigGetDeviceInfo(ref n) != 0) return new string[] { "", "" };
        return new string[] { n.monitorDevicePath ?? "", n.monitorFriendlyDeviceName ?? "" };
    }

    // "\\?\DISPLAY#ABC1234#5&..." -> "ABC1234"
    static string IdOf(PATH_INFO p) {
        string[] parts = TargetName(p)[0].ToUpperInvariant().Split('#');
        return parts.Length > 1 ? parts[1] : "";
    }

    static string SrcKey(PATH_INFO p) {
        return p.sourceInfo.adapterId.LowPart + ":" + p.sourceInfo.adapterId.HighPart + ":" + p.sourceInfo.id;
    }

    static string Describe() {
        PATH_INFO[] ap; MODE_INFO[] am;
        Query(QDC_ONLY_ACTIVE_PATHS, out ap, out am);
        var sb = new StringBuilder();
        foreach (var p in ap) {
            string pos = "?";
            if (p.sourceInfo.modeInfoIdx < am.Length) {
                var m = am[p.sourceInfo.modeInfoIdx];
                pos = m.posX + "," + m.posY + (m.posX == 0 && m.posY == 0 ? " (main)" : "");
            }
            double hz = p.targetInfo.refreshRate.Denominator == 0 ? 0 :
                (double)p.targetInfo.refreshRate.Numerator / p.targetInfo.refreshRate.Denominator;
            sb.AppendLine("    " + IdOf(p) + " " + TargetName(p)[1] + " at " + pos + " " + Math.Round(hz) + "Hz");
        }
        return sb.ToString();
    }

    public static string List() {
        PATH_INFO[] ap; MODE_INFO[] am;
        Query(QDC_ONLY_ACTIVE_PATHS, out ap, out am);
        var sb = new StringBuilder();
        foreach (var p in ap)
            if (p.sourceInfo.modeInfoIdx < am.Length)
                sb.AppendLine(IdOf(p) + "\t" + am[p.sourceInfo.modeInfoIdx].posX + "\t" + am[p.sourceInfo.modeInfoIdx].posY
                    + "\t" + am[p.sourceInfo.modeInfoIdx].width + "\t" + am[p.sourceInfo.modeInfoIdx].height + "\t" + TargetName(p)[1]);
        return sb.ToString().TrimEnd();
    }

    public static string Run(string[] specs) {
        var sb = new StringBuilder();
        var want = new Dictionary<string, int[]>();
        var order = new List<string>();
        foreach (string s in specs) {
            string[] kv = s.Split('=');
            string[] xy = kv[1].Split(',');
            string id = kv[0].Trim().ToUpperInvariant();
            want[id] = new int[] { int.Parse(xy[0]), int.Parse(xy[1]) };
            order.Add(id);
        }

        sb.AppendLine("  before:");
        sb.Append(Describe());

        // ---- Step 1: turn on exactly the wanted monitors ----
        PATH_INFO[] ap; MODE_INFO[] am;
        Query(QDC_ONLY_ACTIVE_PATHS, out ap, out am);
        PATH_INFO[] allp; MODE_INFO[] allm;
        Query(QDC_ALL_PATHS, out allp, out allm);

        var chosen = new List<PATH_INFO>();
        var modes = new List<MODE_INFO>();
        var usedSrc = new HashSet<string>();
        var covered = new HashSet<string>();
        bool changed = false;

        foreach (var p0 in ap) {
            string id = IdOf(p0);
            if (!want.ContainsKey(id) || covered.Contains(id)) { changed = true; sb.AppendLine("  turn off " + id); continue; }
            var p = p0;
            if (p.sourceInfo.modeInfoIdx != IDX_INVALID && p.sourceInfo.modeInfoIdx < am.Length) {
                modes.Add(am[p.sourceInfo.modeInfoIdx]); p.sourceInfo.modeInfoIdx = (uint)(modes.Count - 1);
            }
            if (p.targetInfo.modeInfoIdx != IDX_INVALID && p.targetInfo.modeInfoIdx < am.Length) {
                modes.Add(am[p.targetInfo.modeInfoIdx]); p.targetInfo.modeInfoIdx = (uint)(modes.Count - 1);
            }
            chosen.Add(p);
            usedSrc.Add(SrcKey(p0));
            covered.Add(id);
        }

        foreach (string id in order) {
            if (covered.Contains(id)) continue;
            bool found = false;
            foreach (var p0 in allp) {
                if (p0.targetInfo.targetAvailable == 0) continue;
                if (IdOf(p0) != id) continue;
                if (usedSrc.Contains(SrcKey(p0))) continue;
                var p = p0;
                p.flags = PATH_ACTIVE;
                p.sourceInfo.modeInfoIdx = IDX_INVALID;
                p.targetInfo.modeInfoIdx = IDX_INVALID;
                chosen.Add(p);
                usedSrc.Add(SrcKey(p0));
                covered.Add(id);
                found = true; changed = true;
                sb.AppendLine("  turn on " + id);
                break;
            }
            if (!found) sb.AppendLine("  WARNING: " + id + " not found / not connected");
        }

        // When the main (0,0) monitor stays on, place the kept monitors in the same call.
        // Windows rejects a layout with no monitor at 0,0 (error 87), e.g. after turning the main monitor off.
        string anchor0 = null;
        foreach (string id in order) if (want[id][0] == 0 && want[id][1] == 0) { anchor0 = id; break; }
        if (changed && anchor0 != null && covered.Contains(anchor0)) {
            for (int i = 0; i < chosen.Count; i++) {
                var p = chosen[i];
                string id = IdOf(p);
                if (want.ContainsKey(id) && p.sourceInfo.modeInfoIdx != IDX_INVALID && p.sourceInfo.modeInfoIdx < modes.Count) {
                    var m = modes[(int)p.sourceInfo.modeInfoIdx];
                    m.posX = want[id][0]; m.posY = want[id][1];
                    modes[(int)p.sourceInfo.modeInfoIdx] = m;
                }
            }
        }

        if (changed) {
            int r = SetDisplayConfig((uint)chosen.Count, chosen.ToArray(), (uint)modes.Count, modes.ToArray(), APPLY_FLAGS);
            sb.AppendLine("  on/off result: " + r);
            Thread.Sleep(2500);
        }

        // ---- Step 2: positions (the monitor at 0,0 becomes main) ----
        string anchor = null;
        foreach (string id in order) if (want[id][0] == 0 && want[id][1] == 0) { anchor = id; break; }

        for (int attempt = 1; attempt <= 3; attempt++) {
            Query(QDC_ONLY_ACTIVE_PATHS, out ap, out am);
            foreach (var p in ap) {
                string id = IdOf(p);
                if (want.ContainsKey(id) && p.sourceInfo.modeInfoIdx < am.Length) {
                    am[p.sourceInfo.modeInfoIdx].posX = want[id][0];
                    am[p.sourceInfo.modeInfoIdx].posY = want[id][1];
                }
            }
            int r = SetDisplayConfig((uint)ap.Length, ap, (uint)am.Length, am, APPLY_FLAGS);
            sb.AppendLine("  position try " + attempt + " result: " + r);
            Thread.Sleep(1500);

            // verify (relative to the anchor, since Windows keeps the main monitor at 0,0)
            Query(QDC_ONLY_ACTIVE_PATHS, out ap, out am);
            var pos = new Dictionary<string, int[]>();
            foreach (var p in ap)
                if (p.sourceInfo.modeInfoIdx < am.Length)
                    pos[IdOf(p)] = new int[] { am[p.sourceInfo.modeInfoIdx].posX, am[p.sourceInfo.modeInfoIdx].posY };
            bool ok = anchor != null && pos.ContainsKey(anchor) && pos[anchor][0] == 0 && pos[anchor][1] == 0;
            foreach (string id in order)
                if (!pos.ContainsKey(id) || pos[id][0] != want[id][0] || pos[id][1] != want[id][1]) ok = false;
            if (ok) { sb.AppendLine("  OK"); break; }
        }

        sb.AppendLine("  after:");
        sb.Append(Describe());
        return sb.ToString();
    }
}
'@

try {
    Add-Type -TypeDefinition $src -ErrorAction Stop
    if ($args.Count -gt 0 -and $args[0] -eq '--list') { [DispCfg]::List() }
    else { [DispCfg]::Run([string[]]$args) }
} catch {
    "  ERROR: $($_.Exception.Message)"
    exit 1
}
