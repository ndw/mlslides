xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $options as element(rest:options)
  := <rest:options>
       <rest:http method="GET">
         <rest:param name="uri" type="string"/>
       </rest:http>
     </rest:options>;

declare function local:find-doc(
  $uri as xs:string)
as xs:string
{
  (:let $trace := xdmp:log(concat("find-doc: ", $uri)):)
  let $path := tokenize($uri, "/")
  let $file := $path[count($path)]
  let $next := ($path[position() < count($path)-2], $path[position() = count($path)-1], $file)
  return
    if (count($path) <= 2)
    then
      $uri
    else
      if (doc($uri))
      then
        $uri
      else
        local:find-doc(string-join($next, "/"))
};

let $params := rest:process-request(endpoint:request("/serve.xqy"))
let $uri    := local:find-doc(map:get($params, "uri"))
let $doc    := doc($uri)
return
  $doc
