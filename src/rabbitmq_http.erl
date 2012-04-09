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
    rabbit_mochiweb:register_context_handler(rabbitmq_http, "http/api",
                                             fun rabbitmq_http_worker:handle_request/2,
                                             "RabbitMQ HTTP API"),

    rabbitmq_http_sup:start_link().

stop(_State) ->
    rabbit_mochiweb:unregister_context(rabbitmq_http),
    ok.
