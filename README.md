[xmlstarlet-home]: <https://xmlstar.sourceforge.net/> "'xmlstarlet' on SourceForge"
[xmlstarlet-files-sf]: <https://sourceforge.net/projects/xmlstar/files> "'xmlstarlet files' on SourceForge"
[xmlstarlet-files-fossies]: <https://fossies.org/linux/www/xmlstarlet-1.6.1.tar.gz> "xmlstarlet-1.6.1.tar.gz on Fossies"
[libxml2-home]: <https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home> "'libxml2 Wiki Home' on gitlab.gnome.org"
[biglines-issue]: <https://gitlab.gnome.org/GNOME/libxml2/-/issues/361> "Issue 'Incorrect line number reported if higher than 65535 in some cases' on gitlab.gnome.org"
[debian-libxml2-dev]: <https://packages.debian.org/bookworm/libxml2-dev> "'libxml2-dev' on packages.debian.org"
[debian-libxslt1-dev]: <https://packages.debian.org/bookworm/libxslt1-dev> "'libxslt1-dev' on packages.debian.org"


# Patch xmlstarlet 1.6.1 to use 'huge' nodes and 'big lines'

This patch adds 2 global options to [`xmlstarlet`][xmlstarlet-home], 
available in the subcommands `elements`, `select`, `edit`, `format`, 
`canonic`, `validate`, and `transform`:

- `--huge`  
   Load XML files with [`libxml2`][libxml2-home]'s `XML_PARSE_HUGE` 
   parser option. Without this option the parser will fail with a 
   <q>xmlSAX2Characters: huge text node: out of memory</q> error when 
   loading a text node larger than 10 MB. (`xmlstarlet`'s `pyx` 
   subcommand uses the SAX API which has no such limitation.) 
   In `libxml2` the `XML_PARSE_HUGE` option is disabled by default to 
   prevent denial-of-service attacks.

- `--big-lines`  
   Load XML files with `libxml2`'s `XML_PARSE_BIG_LINES` parser option. 
   This allows line numbers larger than 65535 to be reported correctly 
   in error messages and (for `select` and `transform`) in output from 
   the `saxon:line-number` extension. 
   There is currently an open [issue][biglines-issue] on this option 
   suggesting it's limited to text nodes, however, it appears to have 
   been resolved by now as line numbers are output as expected for all 
   node types except the root node (`/`) which is fixed at line `-1`.

The patch requires `xmlstarlet` to be rebuilt from source code:

1. Install the packages [`libxml2-dev`][debian-libxml2-dev] 
   (most recent version for the updated `XML_PARSE_BIG_LINES`) and 
   [`libxslt1-dev`][debian-libxslt1-dev] 
   (e.g. `sudo apt-get install libxml2-dev libxslt1-dev`).
2. `cd` to an empty directory, download ([sf.net][xmlstarlet-files-sf] 
   or [fossies.org][xmlstarlet-files-fossies])
   and unpack (e.g. `tar xaf xmlstarlet-1.6.1.tar.gz`)
   the `xmlstarlet` source code.
3. Download `xmlstarlet-huge.diff` and apply the patch by running 
   `patch -u -p1 -d xmlstarlet-1.6.1 < xmlstarlet-huge.diff` 
   to modify source files.
4. Follow the instructions in `xmlstarlet-1.6.1/INSTALL` to build, 
   test, and install `xmlstarlet`.

   On a recent Debian system it was done with the following commands 
   -- resulting in 3 compiler warnings (`maybe-uninitialized`, 
   `incompatible-pointer-types`, `unused-result)` and 2 tests 
   (`bigxml-dtd`, `ed-namespace`) failing as expected. 
   Note that this builds a dynamically linked executable but 
   `./configure --enable-static-libs ...` is there if you can brave 
   the `.a`s.
```lang-shell
$ cd xmlstarlet-1.6.1
$ ./configure CFLAGS="-O3 $(xml2-config --cflags)" LIBS="$(xml2-config --libs)"
…
$ make
…
$ make check
…
$ sudo make install-strip
…
$ sudo mv /usr/local/bin/xml /usr/local/bin/xmlstarlet
```

Global options are listed in the general usage reminder (`xmlstarlet --help`).
