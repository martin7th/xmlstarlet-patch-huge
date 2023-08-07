#!/bin/sh

## Try xmlstarlet --huge option (using pipes and /dev/fd/N)

tryit() {

  echo '<r/>' |
  # add 250MB of ASCII characters (no --huge option)
  xmlstarlet edit -O \
    --var a 'str:padding(100000,"abcd")' \
    --var b 'concat($a,$a,$a,$a,$a,$a,$a,$a,$a,$a)' \
    --var c 'concat($b,$b,$b,$b,$b,$b,$b,$b,$b,$b)' \
    -s 'r' -t elem -n tag -u '$prev' \
    -x 'concat($c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c,$c)' |

  # make it bigger
  xmlstarlet --huge edit -O \
    --var t 'r/tag' \
    -i '$t' -t elem -n tag0 -u '$prev' -x 'concat($t,$t)' \
    -a '$t' -t elem -n tag2 -u '$prev' -x 'concat($t,$t,$t,$t,$t)' |

  # pass through c14n and fo subcommands
  xmlstarlet --huge canonic |
  xmlstarlet --huge format -o |

  # display document structure
  { tee /dev/fd/3 |
    xmlstarlet --huge elements >> /dev/fd/4
  } 3>&1 |

  # display byte sizes (line length)
  xmlstarlet --huge select --text -t \
    -m '*/*' \
      -o 'string-length ' \
      -v 'str:align(name(),str:padding(6))' \
      --var nstr='format-number(string-length(),"#,###")' \
      -v 'str:align($nstr,str:padding(14),"right")' \
      -n \
  >> /dev/fd/4
} 4>&1

echo 'This may take a while ...' > /dev/stderr
tryit
echo 'Done.' > /dev/stderr
