const Builder = @import("std").build.Builder;

const sqlite_static = true;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    // Test
    var test_cmd = b.addTest("src/main.zig");
    test_cmd.setBuildMode(mode);
    var test_step = b.step("test", "Run the tests");
    test_step.dependOn(&test_cmd.step);

    const exe = b.addExecutable("pkg-test", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    // use the bundled
    //const sqlite = b.addStaticLibrary("sqlite", null);
    //sqlite.addCSourceFile("libs/zig-sqlite/sqlite3.c", &[_][]const u8{"-std=c99"});
    //sqlite.addIncludeDir("libs/zig-sqlite");
    //sqlite.linkLibC();
    //exe.linkLibC();
    //exe.linkLibrary(sqlite);

    // use DLL
    exe.linkLibC();
    exe.linkSystemLibrary("sqlite3");
    exe.addIncludeDir("libs/zig-sqlite");

    exe.addPackage(.{ .name = "sqlite", .path = "libs/zig-sqlite/sqlite.zig" });

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
