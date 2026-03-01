# lcms2 zig

[Little CMS](https://github.com/mm2/Little-CMS), packaged for the Zig build system.

## Using

First, update your `build.zig.zon`:

```
zig fetch --save git+https://github.com/allyourcodebase/lcms2.git
```

Then in your `build.zig`:

```zig
const lcms2 = b.dependency("lcms2", .{ .target = target, .optimize = optimize });
exe.linkLibrary(lcms2.artifact("lcms2"));
```
