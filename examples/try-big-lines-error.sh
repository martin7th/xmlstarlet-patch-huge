#!/bin/sh

## Try xmlstarlet --big-lines option with error reporting

cat <<'HERE' |
<?xml version="1.0"?>
<doc/>
this text will trigger an error
HERE

# at line 2 insert a lot of blank lines
awk 'NR==2{for(i=0;i<1234567;i++)print"";}1' |
xmlstarlet --big-lines validate --well-formed --err /dev/stdin 2>&1
