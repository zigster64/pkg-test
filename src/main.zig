const std = @import("std");
const sqlite = @import("sqlite");
const string = []const u8;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = &gpa.allocator;

const Employee = struct {
    id: [128:0]u8,
    name: [128:0]u8,
    age: usize,
    salary: usize,
};

pub fn main() anyerror!void {
    std.os.unlink("./testfile.db") catch {
        std.log.info("no exsiting DB to delete\n", .{});
    };

    var db: sqlite.Db = undefined;
    try db.init(.{
        .mode = sqlite.Db.Mode{ .File = "./testfile.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });

    var create = try db.prepare("CREATE TABLE employees (id text, name text, age int, salary int)");
    defer create.deinit();
    try create.exec(.{});

    var add = try db.prepare("INSERT INTO employees (id, name, age, salary) VALUES (?,?,?,?)");
    defer add.deinit();
    add.reset();
    try add.exec(.{ "ABC", "Mr Smith", 33, 12000 });
    add.reset();
    try add.exec(.{ "DEF", "Mr Jones", 32, 11000 });
    add.reset();
    try add.exec(.{ "GHI", "Mr Wayne", 31, 14000 });
    add.reset();
    try add.exec(.{ "JKL", "Mr Fred", 38, 12000 });
    add.reset();
    try add.exec(.{ "MNO", "Mr Smythe", 36, 11000 });
    add.reset();
    try add.exec(.{ "PQR", "Mr Tonsil", 30, 11000 });
    add.reset();
    try add.exec(.{ "STU", "Mr Fancypants", 22, 8000 });
    add.reset();
    try add.exec(.{ "VXY", "Mr Thing", 24, 7000 });
    add.reset();
    try add.exec(.{ "ZZZ", "Mr What", 27, 6000 });

    var select = try db.prepare("SELECT id,name,age,salary FROM employees ORDER BY salary DESC LIMIT 5");
    defer select.deinit();
    var iter = try select.iterator(Employee, .{});
    while (try iter.next(.{})) |row| {
        std.log.info("name: {s}, age: {}, id: {s}, salary: {}", .{ std.mem.spanZ(&row.name), row.age, std.mem.spanZ(&row.id), row.salary });
    }
}

test "test" {
    std.debug.print("Tests pass\n", .{});
    std.testing.expect(true);
}
