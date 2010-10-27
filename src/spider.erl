%%%-----------------------------------------------------------------------------
%%% @author Yoshifumi YAMAGUCHI <ymotongpoo AT gmail.com>
%%% @copyright (C) 2010, Yoshifumi YAMAGUCHI
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2010 by Yoshifumi YAMAGUCHI <ymotongpoo AT gmail.com>
%%%-----------------------------------------------------------------------------
-module(spider).
-author('ymotongpoo@gmail.com').

-define(EUNIT, false).

-export([start/2, stop/0]).
-export([init/1]).
-export([dump_webcontent_to_file/2]).
-export([main/2]).
-compile(export_all).

%%------------------------------------------------------------------------------

init({UrlFile, DownloadDir})->
    Flag = file:consult(UrlFile),
    case Flag of
        {ok, UrlPairs} ->
            main(UrlPairs, DownloadDir),
            ok;
        {error, _} ->
            erlang:display("spider:init/1 : No such file"),
            ok
    end.


dump_webcontent_to_file(Filename, Body)->
    case file:open(Filename, [write, binary]) of
        {ok, Fd} ->
            case file:write(Fd, erlang:list_to_binary(Body)) of
                ok ->
                    file:close(Fd);    % fix here
                {error, Reason} ->
                    erlang:display(Filename ++ " : [error] " ++ Reason),
                    timer:sleep(1000),
                    scrape(Filename)
            end;
        {error, Reason} ->
            erlang:display(Filename ++ " : [error] " ++ Reason),
            timer:sleep(1000),
            scrape(Filename)
    end.


scrape(Url)->
    case httpc:request(Url) of
        {ok, {_, _, Body}} ->
            dump_webcontent_to_file(Url, Body);
        {error, Reason} ->
            erlang:display(Url ++ " : [error] " ++ Reason),
            timer:sleep(1000),
            scrape(Url)
    end.


collect_urls(UrlPairs, Tag)->
    Filtered = lists:filter(fun({X,_}) -> X == Tag end, UrlPairs),
    lists:map(fun({_, Y}) -> Y end, Filtered).
    


main(UrlPairs, DownloadDir)->
    start(UrlPairs, DownloadDir),
    stop(),
    ok.


start(UrlPairs, DownloadDir)->
    erlang:display(DownloadDir),
    Urls = collect_urls(UrlPairs, "text"),
    inets:start(),
    lists:foreach(scrape, Urls),
    ok.
                     

stop() ->
    intes:stop(),
    ok.
    


% ============================= test code 
-ifdef(EUNIT).
-include_lib("eunit/include/eunit.hrl").

test_pairs() ->
    [{"foo", "spam"},
     {"foo", "egg"},
     {"foo", "ham"},
     {"bar", "spam"},
     {"bar", "egg"},
     {"bar", "ham"},
     {"buz", "hoge"},
     {"buz", "piyo"}
    ].
             

collect_urls_test_()->
    [?_assert( [] =:= collect_urls(test_pairs(), "qux") ),
     ?_assert( ["hoge", "piyo"] =:= collect_urls(test_pairs(), "buz") )
    ].

-endif.
