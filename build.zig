const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(std.builtin.LinkMode, "linkage", "Library linkage type") orelse .static;

    const upstream = b.dependency("upstream", .{});
    const src = upstream.path("");

    const os = target.result.os.tag;
    const arch = target.result.cpu.arch;

    const mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true });
    mod.addIncludePath(src.path(b, "include"));
    mod.addCSourceFiles(.{ .root = src, .files = sources, .flags = &((if (os != .windows) .{
        "-fvisibility=hidden",
        "-DHAVE_FUNC_ATTRIBUTE_VISIBILITY=1",
        "-DHAVE_GMTIME_R=1",
    } else .{ "", "", "" }) ++
        .{ "-DHasTHREADS=1", "-DHAVE_TIMESPEC_GET=1" } ++
        .{if (arch.endian() == .big) "-DWORDS_BIGENDIAN=1" else ""} ++
        .{if (arch != .x86_64 and arch != .x86) "-DCMS_DONT_USE_SSE2=1" else ""}) });

    const lib = b.addLibrary(.{ .name = "lcms2", .root_module = mod, .linkage = linkage });
    inline for (.{ "lcms2.h", "lcms2_plugin.h" }) |h| lib.installHeader(src.path(b, "include/" ++ h), h);
    b.installArtifact(lib);
}

const sources: []const []const u8 = &.{
    "src/cmsalpha.c", "src/cmscam02.c", "src/cmscgats.c",  "src/cmscnvrt.c",
    "src/cmserr.c",   "src/cmsgamma.c", "src/cmsgmt.c",    "src/cmshalf.c",
    "src/cmsintrp.c", "src/cmsio0.c",   "src/cmsio1.c",    "src/cmslut.c",
    "src/cmsmd5.c",   "src/cmsmtrx.c",  "src/cmsnamed.c",  "src/cmsopt.c",
    "src/cmspack.c",  "src/cmspcs.c",   "src/cmsplugin.c", "src/cmsps2.c",
    "src/cmssamp.c",  "src/cmssm.c",    "src/cmstypes.c",  "src/cmsvirt.c",
    "src/cmswtpnt.c", "src/cmsxform.c",
};
