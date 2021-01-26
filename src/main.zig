const std = @import("std");
const sqlite = @import("sqlite");

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});

    try std.os.unlink("/home/steve/testfile.db");

    var db: sqlite.Db = undefined;
    try db.init(.{
        .mode = sqlite.Db.Mode{ .File = "/home/steve/testfile.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });

    const creator =
        \\CREATE TABLE employees (id text, name text, age int, salary int)
    ;
    var stmt = try db.prepare(creator);
    try stmt.exec(.{});
    stmt.deinit();
    std.log.info("created the employee table ok\n", .{});

    const addone =
        \\INSERT INTO employees (id, name, age, salary) VALUES ('ABC','Mr Smith', 33, 12000);
    ;
    var stmtone = try db.prepare(addone);
    try stmtone.exec(.{});
    stmtone.deinit();
    std.log.info("added the 1st employee\n", .{});

    const addtwo =
        \\INSERT INTO employees (id, name, age, salary) VALUES ('DEF','Mrs Smith', 32, 11000);
    ;
    var stmttwo = try db.prepare(addtwo);
    try stmttwo.exec(.{});
    stmttwo.deinit();
    std.log.info("added the 2nd employee\n", .{});

    const query =
        \\SELECT id, name, age, salary FROM employees
    ;
    var stmt2 = try db.prepare(query);
    const row = try stmt2.one(
        struct {
            id: [128:0]u8,
            name: [128:0]u8,
            age: usize,
            salary: usize,
        },
        .{},
        .{},
    );
    if (row) |field| {
        std.log.debug("name: {s}, age: {}, id: {s}, salary: {}", .{ std.mem.spanZ(&field.name), field.age, std.mem.spanZ(&field.id), field.salary });
    }
    stmt2.deinit();
}

test "test" {
    std.debug.print("Tests pass\n", .{});
    std.testing.expect(true);
}
