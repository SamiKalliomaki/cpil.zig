# cpil.zig - Competitive Programming Input Library for Zig

Using standard I/O in Zig can be painful because of the need to handle all the error cases. For
competitive programming, the input can be trusted to be in a well-defined format so there is no need
to handle errors.

The goal of this library is to provide fast and easy input handling in Zig.

```zig
var in = cpil.stdin();

var buffer: [256]u8 = undefined;
std.debug.print("{s}", .{ in.nextWord(&buffer) });
std.debug.print("{s}", .{ in.nextLine(&buffer) });
std.debug.print("{}", .{ in.nextInt(i32) });
std.debug.print("{}", .{ in.nextFloat(f32) });
```

## Usage

To add the library as a dependency, first run:

```sh
zig fetch --save https://github.com/SamiKalliomaki/cpil.zig/archive/refs/tags/v0.1.0.tar.gz
```

After this, add the dependency to your `build.zig` file:

```zig
const cpil = b.dependency("cpil.zig", .{
    .optimize = optimize,
});
exe.addModule("cpil", cpil.module("cpil"));
```

## Example

Here's an example how to use the library to solve [Advent of Code 2023, day 2 task](
https://adventofcode.com/2023/day/2).

```zig
const std = @import("std");
const cpil = @import("cpil");

pub fn main() !void {
    var in = cpil.stdin();
    var out = std.io.getStdOut().writer();

    in.is_delimeter[':'] = true;

    var max_colors = std.StringHashMap(u32).init(std.heap.page_allocator);
    try max_colors.put("red", 12);
    try max_colors.put("green", 13);
    try max_colors.put("blue", 14);

    var total: u32 = 0;

    // Each game is its own line.
    // Game 1: 1 blue, 2 red; 4 blue, 5 green; 3 red
    game_loop: while (!in.eof) {
        // Skip "Game" at the start of the line
        in.skipWord();
        const game_id = in.nextInt(u32);

        var line_buf: [1024]u8 = undefined;
        // Read the rest of the line into a buffer
        const line = in.nextLine(&line_buf);
        var samples = std.mem.splitScalar(u8, line, ';');

        while (samples.next()) |sample| {
            var sample_in = cpil.fromBuffer(sample);
            sample_in.is_delimeter[','] = true;

            while (!sample_in.eof) {
                const amount = sample_in.nextInt(u32);
                var word_buf: [32]u8 = undefined;
                const color = sample_in.nextWord(&word_buf);

                if (amount > max_colors.get(color) orelse 0) {
                    continue :game_loop;
                }
            }
        }

        total += game_id;
    }

    try out.print("{}\n", .{total});
}
```
