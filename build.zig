const std = @import("std");
const LinkMode = std.builtin.LinkMode;

const manifest = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const os = target.result.os.tag;
    const arch = target.result.cpu.arch;

    const options = .{
        .linkage = b.option(LinkMode, "linkage", "Library linkage type") orelse
            .static,
    };

    const upstream = b.dependency("lcms2_c", .{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    mod.addIncludePath(upstream.path("include"));

    mod.addCMacro("HasTHREADS", "1");
    mod.addCMacro("HAVE_TIMESPEC_GET", "1");
    if (os != .windows) {
        mod.addCMacro("HAVE_FUNC_ATTRIBUTE_VISIBILITY", "1");
        mod.addCMacro("HAVE_GMTIME_R", "1");
    }
    if (arch.endian() == .big) mod.addCMacro("WORDS_BIGENDIAN", "1");
    if (arch != .x86_64 and arch != .x86) mod.addCMacro("CMS_DONT_USE_SSE2", "1");

    mod.addCSourceFiles(.{
        .root = upstream.path(""),
        .files = src,
        .flags = if (os != .windows) &.{"-fvisibility=hidden"} else &.{},
    });

    const lib = b.addLibrary(.{
        .name = "lcms2",
        .root_module = mod,
        .linkage = options.linkage,
        .version = try .parse(manifest.version),
    });
    inline for (.{ "lcms2.h", "lcms2_plugin.h" }) |h| lib.installHeader(upstream.path("include/" ++ h), h);
    b.installArtifact(lib);
}

const src: []const []const u8 = &.{
    "src/cmsalpha.c", "src/cmscam02.c", "src/cmscgats.c",  "src/cmscnvrt.c",
    "src/cmserr.c",   "src/cmsgamma.c", "src/cmsgmt.c",    "src/cmshalf.c",
    "src/cmsintrp.c", "src/cmsio0.c",   "src/cmsio1.c",    "src/cmslut.c",
    "src/cmsmd5.c",   "src/cmsmtrx.c",  "src/cmsnamed.c",  "src/cmsopt.c",
    "src/cmspack.c",  "src/cmspcs.c",   "src/cmsplugin.c", "src/cmsps2.c",
    "src/cmssamp.c",  "src/cmssm.c",    "src/cmstypes.c",  "src/cmsvirt.c",
    "src/cmswtpnt.c", "src/cmsxform.c",
};
