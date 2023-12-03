# cpil.zig - Competitive Programming Input Library for Zig

Using standard I/O in Zig can be painful because of the need to handle all the error cases. For
competitive programming, the input can be trusted to be in a well-defined format so there is no need
to handle errors.

The goal of this library is to provide fast and easy input handling in Zig.

```zig
const in = cpil.stdin();

var buffer: [256]u8 = undefined;
std.debug.print("{s}", .{ in.nextWord(&buffer) });
std.debug.print("{s}", .{ in.nextLine(&buffer) });
std.debug.print("{}", .{ in.nextInt(i32) });
std.debug.print("{}", .{ in.nextFloat(f32) });
```
