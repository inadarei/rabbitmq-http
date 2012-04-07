%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-module(rabbitmq_http).

-behaviour(application).

-export([start/2, stop/1]).

start(normal, []) ->
    rabbitmq_http_sup:start_link().

stop(_State) ->
    ok.
