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

-export([start/2, stop/0]).
-export([init/1]).
-export([status_check/1]).
-export([url_scanner/1]).
-export([main/2]).
-compile(export_all).

%%------------------------------------------------------------------------------

init({UrlFile, DownloadDir})->
    Flag = file:open(UrlFile, [read]),
    case Flag of
        {ok, Fd} ->
            Urls = url_scanner(Fd),
            lists:foreach(fun(X) -> erlang:display(X) end, Urls),
            main(Urls, DownloadDir),
            ok;
        {error, Reason} ->
            erlang:display(Reason),
            ok
    end.


url_scanner(Fd)->
    url_scanner(Fd, []).
url_scanner(Fd, Accu)->
    case file:read_line(Fd) of
        {ok, Line} -> 
            url_scanner(Fd, [Line | Accu]);
        eof ->
            Accu;
        {error, Reason} ->
            erlang:display(Reason)
    end.


scrape(Url)->
    case httpc:request(Url) of
        {ok, {_, _, Body}} ->
            case file:open(Url, [write]) of
                {ok, Fd} ->
                    case file:write(Fd, erlang:list_to_binary(Body)) of
                        ok ->
                            file:sync(Fd),     % fix here
                            file:close(Fd);    % fix here
                        {error, Reason} ->
                            erlang:display(Url ++ " : [error] " ++ Reason),
                            timer:sleep(1000),
                            scrape(Url)
                    end;
                {error, Reason} ->
                    erlang:display(Url ++ " : [error] " ++ Reason),
                    timer:sleep(1000),
                    scrape(Url)
            end;
        {error, Reason} ->
            erlang:display(Url ++ " : [error] " ++ Reason),
            timer:sleep(1000),
            scrape(Url)
    end.


main(Urls, DownloadDir)->
    start(Urls, DownloadDir),
    stop(),
    ok.


start(Urls, DownloadDir)->
    erlang:display(DownloadDir),
    inets:start(),
    Stats = lists:map(fun(Url) -> spawn(?MODULE, scrape, [Url]) end, Urls),
    status_check(Stats),
    ok.
                     

stop() ->
    intes:stop(),
    ok.
    

status_check(Stats)->
    case lists:all(fun(X) -> X == ok end, Stats) of
        true ->
            ok;
        false ->
            timer:sleep(1000),
            status_check(Stats)
    end.
    


% ============================= test code 
-ifdef(DEBUG).
-include_lib("eunit/include/eunit.hrl").

erlspider_test()->
    ok=erlspider:start(),
    ok=erlspider:stop().

-endif.
