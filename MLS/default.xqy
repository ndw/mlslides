xquery version "1.0-ml";

declare namespace dbp="http://docbook.org/ns/docbook/params";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $xslt := "/style/html/slides.xsl"
let $xml  :=
  <para xmlns="http://docbook.org/ns/docbook">Some paragraph that cites a <citetitle>title</citetitle>.</para>

let $doc := document { $xml }
let $map := map:map()
return
  (xdmp:set-response-content-type("text/html"),
   xdmp:xslt-invoke($xslt, $doc, $map))
