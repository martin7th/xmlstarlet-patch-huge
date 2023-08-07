#!/bin/sh

## Try xmlstarlet --big-lines option with saxon:line-number()

cat <<'HERE' |
<?xml version="1.0"?>
<!-- edited -->
<doc>
  <one att="1">text</one>
  <two val="st">str<r:i xmlns:r="urn:nsr:local">i</r:i>ng</two>
  <three xmlns="urn:g3r:local" />
  <?rrr "'><&?>
  <four att="4" val="v" flag="true" />
  <![CDATA[ &<>'" (in CDATA) ]]>
  <!-- eodoc -->
</doc>
<?post sed -e 's/xC9/0311/' -- file ?>
HERE

# at line 3 insert a lot of blank lines
awk 'NR==3{for(i=0;i<1234567;i++)print"";}1' |
xmlstarlet --big-lines select --text -t \
  --var ofs -o "$(printf '\t')" -b \
  --var ors -n -b \
  -v 'concat("line-num",$ofs,"node-type",$ofs,"name",$ofs,"normalized-text-value",$ors)' \
  -m '/ | //node() | //@* | //namespace::* | document("")//xsl:otherwise' \
    --var typ \
      --if 'self::*' -o 'element' \
      --elif 'self::text()' -o '#text' \
      --elif 'self::comment()' -o '#comment' \
      --elif 'self::processing-instruction()' -o '#pi' \
      --elif 'count(.|/)=1' -o '#root' \
      --elif 'count(.|../@*)=count(../@*)' -o 'attribute' \
      --elif 'count(.|../namespace::*)=count(../namespace::*)' -o 'namespace' \
      --else -o '#aliens-at-work' \
      -b \
    -b \
    --var lno -v 'saxon:line-number()' -b \
    --var txt -v 'substring(normalize-space(),1,40)' -b \
    -v 'concat($lno,$ofs,$typ,$ofs,name(),$ofs,$txt,$ors)' \
  -b | 
expand -t 10,22,37
