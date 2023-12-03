const std = @import("std");
const cpil = @import("cpil.zig");
const expect = std.testing.expect;

test "read some values" {
    const test_input = "Foo bar\nLorem ip sum\nDolor 1337 sit 3.14";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    input.skipLine();
    try expect(std.mem.eql(u8, input.nextLine(&buffer), "Lorem ip sum"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "Dolor"));
    try expect(input.nextInt(i32) == 1337);
    input.skipWord();
    try expect(input.nextFloat(f32) == 3.14);
}

test "readLine removes carriage return" {
    const test_input = "Lorem ip sum\r\nDolor sit amet\r\n";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    try expect(std.mem.eql(u8, input.nextLine(&buffer), "Lorem ip sum"));
    try expect(std.mem.eql(u8, input.nextLine(&buffer), "Dolor sit amet"));
}

test "nextWord sets eof" {
    const test_input = "Lorem\nip sum";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    try expect(!input.eof);
    _ = input.nextWord(&buffer);
    try expect(!input.eof);
    _ = input.nextWord(&buffer);
    try expect(!input.eof);
    _ = input.nextWord(&buffer);
    try expect(input.eof);
}

test "nextWord consumes new line after carriage return" {
    const test_input = "Lorem\r\nip sum";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    _ = input.nextWord(&buffer);
    try expect(std.mem.eql(u8, input.nextLine(&buffer), "ip sum"));
}

test "skipWord consumes new line after carriage return" {
    const test_input = "Lorem\r\nip sum";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    input.skipWord();
    try expect(std.mem.eql(u8, input.nextLine(&buffer), "ip sum"));
}

test "nextLine sets eof" {
    const test_input = "Lorem\nip sum";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    try expect(!input.eof);
    _ = input.nextLine(&buffer);
    try expect(!input.eof);
    _ = input.nextLine(&buffer);
    try expect(input.eof);
}

test "custom delimeter" {
    const test_input = "Lorem,ip sum";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    input.is_delimeter[','] = true;

    try expect(std.mem.eql(u8, input.nextWord(&buffer), "Lorem"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "ip"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "sum"));
}

test "extra whitespace" {
    const test_input = "Lorem ip  sum   dolor \r\n\tsit";
    var input = cpil.fromBuffer(test_input);
    var buffer: [4096]u8 = undefined;

    try expect(std.mem.eql(u8, input.nextWord(&buffer), "Lorem"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "ip"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "sum"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "dolor"));
    try expect(std.mem.eql(u8, input.nextWord(&buffer), "sit"));
}

test "initialize stdin" {
    _ = cpil.stdin();
}
