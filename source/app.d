import std.stdio, std.getopt, std.file, std.algorithm, std.string, std.array, std.range, std.conv;

struct Data {
    byte x;
    byte y;
    byte vx;
    byte vy;
    byte clr;
}

enum Command {dump, process};

void dumpHints(string file) {
    if (!file.exists) {
        stderr.writefln("File %s doesn't exist", file);
    }

    File(file).byLine.map!(_ => _.split("###")).filter!(_ => _.length == 2).map!(_ => _[1].to!string).joiner("\n").writeln();
}

void process(string file) {
    import imageformats;

    if (!file.exists) {
        stderr.writefln("File %s doesn't exist", file);
    }

    auto image = file.read_image(ColFmt.RGB);

    auto f(Data[] data, ubyte[] abc) {
        byte a = cast(byte)abc[0];
        byte b = cast(byte)abc[1];
        byte c = cast(byte)abc[2];

        byte vx = cast(byte)(data[$ - 1].vx ^ a);
        byte vy = cast(byte)(data[$ - 1].vy ^ b);
        byte clr = cast(byte)(data[$ - 1].clr ^ c);
        byte x = cast(byte)(vx + data[$ - 1].x);
        byte y = cast(byte)(vy + data[$ - 1].y);

        return data ~ Data(x, y, vx, vy, clr);
    }

    image.pixels.chunks(3).until([0, 0, 0], No.openRight)
        .fold!(f)([Data(70, 79, 18, 26, 0)]).each!(a => writeln(a));
}

void main(string[] args) {
    string file = "";
    Command command;
    GetoptResult help;

    scope(exit) {
        writeln("Press <Enter>");
        readln;
    }

    try {
        help = args.getopt(
            config.required,
            "file|f", "Input file", &file,
            config.required,
            "command|c", "dump|process. dump - dump hints", &command);

        if (help.helpWanted) {
            defaultGetoptPrinter("Options:", help.options);

            return;
        }

        switch (command) {
            case Command.dump:
                file.dumpHints();

                break;

            case Command.process: 
                file.process();

                break;

            default: break;
        }
    } catch (GetOptException e) {
        stderr.writeln(e.msg);
    }
}
