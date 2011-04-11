xquery version "1.0-ml";

module namespace endpoints="http://marklogic.com/appservices/endpoints";

declare namespace rest="http://marklogic.com/appservices/rest";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $endpoints:ENDPOINTS as element(rest:options)
  := <options xmlns="http://marklogic.com/appservices/rest">
       <request uri="^/slides/(.+?)/(\d+)$" endpoint="/slides.xqy">
         <uri-param name="slides">/$1/slides.xml</uri-param>
         <uri-param name="num" as="decimal">$2</uri-param>
         <param name="toc" as="boolean" default="false"/>
         <http method="GET"/>
       </request>
       <request uri="^/slides/(.+?)/toc$" endpoint="/slides.xqy">
         <uri-param name="slides">/$1/slides.xml</uri-param>
         <uri-param name="toc" as="boolean">true</uri-param>
         <http method="GET"/>
       </request>
       <request uri="^/slides/(.+?)/$" endpoint="/slides.xqy">
         <uri-param name="slides">/$1/slides.xml</uri-param>
         <http method="GET"/>
       </request>
       <request uri="^/slides/([^/]+)/(.+)$" endpoint="/serve.xqy">
         <uri-param name="uri">/$1/$2</uri-param>
         <http method="GET"/>
       </request>
       <request uri="^/post(/.+)$" endpoint="/post.xqy">
         <uri-param name="uri">$1</uri-param>
         <http method="POST"/>
       </request>
       <request uri="^(/.*\.xqy.*)$" endpoint="$1"/>
       <request uri="^(/.+)$" endpoint="/serve.xqy">
         <uri-param name="uri">$1</uri-param>
       </request>
     </options>;


declare function endpoints:options()
as element(rest:options)
{
  $ENDPOINTS
};

declare function endpoints:request(
  $module as xs:string)
as element(rest:request)?
{
  ($ENDPOINTS/rest:request[@endpoint = $module])[1]
};
