%%%-------------------------------------------------------------------
%%% @author Yoshifumi YAMAGUCHI <ymotongpoo AT gmail.com>
%%% @copyright (C) 2010, Yoshifumi YAMAGUCHI
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2010 by Yoshifumi YAMAGUCHI <ymotongpoo AT gmail.com>
%%%-------------------------------------------------------------------
-module(erlspider).
-author('ymotongpoo@gmail.com').

-export([start/0, stop/0]).

start()-> application:start(erlspider).
stop()->  application:stop(erlspider).

% ============================= test code 
-ifdef(DEBUG).
-include_lib("eunit/include/eunit.hrl").

erlspider_test()->
    ok=tc:start(),
    ok=tc:stop().

-endif.
