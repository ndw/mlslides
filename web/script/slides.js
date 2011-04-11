// -*- Java -*-
//
// $Id: slides.js,v 1.1 2006-08-08 19:09:22 ndw Exp $
//
// Copyright (C) 2002 Norman Walsh
//
// You are free to use, modify and distribute this software without limitation.
// This software is provided "AS IS," without a warranty of any kind.
//
// This script assumes that jQuery has been loaded

var ARR_R = 39;
var ARR_L = 37;
var ARR_U = 38;
var ARR_D = 40;
var KEY_F1 = 112;
var KEY_ESC = 27;
var KEY_h = 104;
var KEY_t = 116;
var KEY_space = 32;
var KEY_p = 112;
var KEY_n = 110;
var KEY_u = 117;
var KEY_d = 100;

function navigate(event) {
    var code = event.keyCode ? event.keyCode : event.which;
    var next = $("link[rel='next']");
    var prev = $("link[rel='prev']");
    var home = $("link[rel='home']");
    var toc = $("link[rel='contents']");

    if ((code == ARR_R || code == KEY_n || code == KEY_space) && next.length > 0) {
        document.location = next.attr('href');
    }

    if ((code == ARR_L || code == KEY_p) && prev.length > 0) {
        document.location = prev.attr('href');
    }

    if (code == KEY_h && home.length > 0) {
        document.location = home.attr('href');
    }

    if (code == KEY_t && toc.length > 0) {
        document.location = toc.attr('href');
    }

    return true;
}

$(document).ready(function(){
    $(document).keypress(navigate);
});
