const std = @import("std");
const testing = std.testing;

const panic = std.debug.panic;

pub fn InputReader(comptime ReaderType: type) type {
    const buffer_size = 4096;

    return struct {
        const FillBufferError = error{EndOfStream};
        const Self = @This();

        buffer: [buffer_size]u8 = undefined,
        start: usize = 0,
        end: usize = 0,
        reader: ReaderType,

        eof: bool = false,
        is_delimeter: [256]bool = blk: {
            var d = [_]bool{false} ** 256;
            d[' '] = true;
            d['\t'] = true;
            d['\r'] = true;
            d['\n'] = true;
            break :blk d;
        },

        fn fillBuffer(self: *Self) FillBufferError!void {
            if (self.start == self.end) {
                if (self.eof) return error.EndOfStream;

                self.start = 0;
                self.end = self.reader.read(&self.buffer) catch |e| {
                    if (e == error.EndOfStream) {
                        self.end = 0;
                        self.eof = true;
                        return error.EndOfStream;
                    } else {
                        panic("{any}: Failed to read", .{e});
                    }
                };

                // Some readers give 0 bytes on the final read.
                if (self.start == self.end) {
                    self.eof = true;
                    return error.EndOfStream;
                }
            }
        }

        fn readByte(self: *Self) FillBufferError!u8 {
            try self.fillBuffer();
            self.start += 1;
            return self.buffer[self.start - 1];
        }

        fn consumeDelimeters(self: *Self) FillBufferError!void {
            try self.fillBuffer();

            while (self.is_delimeter[self.buffer[self.start]]) {
                self.start += 1;
                try self.fillBuffer();
            }
        }

        pub fn nextInt(self: *Self, comptime t: type) t {
            var buffer: [128]u8 = undefined;
            const word = self.nextWord(&buffer);
            const int = std.fmt.parseInt(t, word, 10) catch |e| panic("{any}: Failed to parse int: {s}", .{ e, word });
            return int;
        }

        pub fn nextFloat(self: *Self, comptime t: type) t {
            var buffer: [128]u8 = undefined;
            const word = self.nextWord(&buffer);
            const float = std.fmt.parseFloat(t, word) catch |e| panic("{any}: Failed to parse float: {s}", .{ e, word });
            return float;
        }

        pub fn nextWord(self: *Self, buffer: []u8) []u8 {
            if (buffer.len == 0) @panic("Empty buffer is not allowed");

            self.consumeDelimeters() catch @panic("End of stream - no next word available");

            var len: usize = 0;
            while (self.readByte()) |c| {
                if (self.is_delimeter[c]) {
                    break;
                }

                if (len >= buffer.len) {
                    @panic("Word does not fit in the buffer");
                }

                buffer[len] = c;
                len += 1;
            } else |_| {}
            self.consumeDelimeters() catch {};

            return buffer[0..len];
        }

        pub fn skipWord(self: *Self) void {
            self.consumeDelimeters() catch {};

            while (self.readByte()) |c| {
                if (self.is_delimeter[c]) {
                    break;
                }
            } else |_| {}
            self.consumeDelimeters() catch {};
        }

        pub fn nextLine(self: *Self, buffer: []u8) []u8 {
            self.consumeDelimeters() catch @panic("End of stream - no next line available");

            var len: usize = 0;
            while (self.readByte()) |c| {
                if (c == '\n') {
                    break;
                }

                if (len >= buffer.len) {
                    @panic("Line does not fit in the buffer");
                }

                buffer[len] = c;
                len += 1;
            } else |_| {}
            self.consumeDelimeters() catch {};

            if (len > 0 and buffer[len - 1] == '\r') {
                len -= 1;
            }
            return buffer[0..len];
        }

        pub fn skipLine(self: *Self) void {
            self.consumeDelimeters() catch {};

            while (self.readByte()) |c| {
                if (c == '\n') {
                    break;
                }
            } else |_| {}
            self.consumeDelimeters() catch {};
        }
    };
}

pub fn fromReader(reader: anytype) InputReader(@TypeOf(reader)) {
    return .{ .reader = reader };
}

pub fn fromBuffer(buffer: []const u8) InputReader(@TypeOf(std.io.fixedBufferStream(buffer))) {
    return .{ .reader = std.io.fixedBufferStream(buffer) };
}

pub fn stdin() @TypeOf(fromReader(std.io.getStdIn().reader())) {
    return fromReader(std.io.getStdIn().reader());
}
