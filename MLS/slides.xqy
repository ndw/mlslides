xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "endpoints.xqy";

declare namespace db="http://docbook.org/ns/docbook";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare function local:no-slides(
  $uri as xs:string)
as element()
{
  <html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <title>No slides</title>
  </head>
  <body>
  <h1>No slides</h1>
  <p>There is no slides document named {$uri}</p>
  </body>
  </html>
};

declare function local:not-slides(
  $uri as xs:string)
as element()
{
  <html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <title>Not slides</title>
  </head>
  <body>
  <h1>Not slides</h1>
  <p>The {$uri} document does not contain slides.</p>
  </body>
  </html>
};

let $params := rest:process-request(endpoint:request("/slides.xqy"))
let $slides := map:get($params, "slides")
let $num    := map:get($params, "num")
let $toc    := map:get($params, "toc")
let $doc    := doc($slides)
return
  if (empty($doc))
  then
    local:no-slides($slides)
  else
    if (not($doc/db:slides))
    then
      local:not-slides($slides)
    else
      let $params := map:map()
      let $_      := map:put($params, "deck", $slides)
      let $_      := map:put($params, "toc", $toc)
      let $_      := if (empty($num)) then () else map:put($params, "slideno", $num)
      return
        xdmp:xslt-invoke("/style/html/mlslides.xsl", $doc, $params)
