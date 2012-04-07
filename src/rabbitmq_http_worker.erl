%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-module(rabbitmq_http_worker).

-behaviour(gen_server).

-export([handle_request/2]).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, ok}.

terminate(_, _) ->
    ok.

handle_request(_, Req) ->
    io:format("handle_request ~p ~n", [Req:get(raw_path)]),
    Req:respond({200, [{"Content-Type", "text/plain"}], "Request Received"}),
    ok.

code_change(_, State, _) ->
    {ok, State}.

handle_call(_, _, State) ->
    {noreply, State}.

handle_cast({request, _Req}, State) ->
    {noreply, State};

handle_cast(_, State) ->
    {noreply, State}.

handle_info(_, State) ->
    {noreply, State}.
