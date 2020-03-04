
### How to compile MQL programs without using MetaEditor?
For maximum backward compatibility the framework comes with the compiler distributed with MetaTrader 4 build 225. The reliability of the generated EX4 files outweights the minor restrictions that compiler has, compared to current compiler versions. The compiler may be replaced by any other version of builds <= 509 without changes to the code base.

The compiler can be integrated in any modern development environment (e.g. by registering custom CLI tools). It may also be called manually using the provided script `bin/mqlc`:

```bash
$ mqlc -?
MetaQuotes Language 4 compiler version 4.00 build 224 (14 May 2009)
Copyright notice

Usage:
  mqlc [options...] FILENAME

Arguments:
  FILENAME  The MQL file to compile.

Options:
   -q       Quite mode.
```
- - -

### How to fix the compiler error "cannot open <include-filename>"?
To make the compiler find the framework's include files a symbolic link pointing to `mql4/experts/include` must be created in `bin/experts`. There is no reliable way for the script to create the symlink in the different Windows versions, therefore the user has to do it manually. A comfortable way to manage Windows symlinks and junctions is the free [Link Shell Extension](http://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html) by Hermann Schinagl.
