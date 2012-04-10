%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-module(rabbitmq_http_util).

-include("rabbitmq_http.hrl").

-export([start_rabbitmq_channel/0]).

start_rabbitmq_channel() ->
    {ok, Connection} = amqp_connection:start(#amqp_params_direct{}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    ExchangeDeclare = #'exchange.declare'{exchange = ?MQ_EXCHANGE,
                                          type = ?MQ_TYPE,
                                          passive = false,
                                          durable = false,
                                          auto_delete = false,
                                          internal = false,
                                          nowait = false,
                                          arguments = []},
    #'exchange.declare_ok'{} = amqp_channel:call(Channel, ExchangeDeclare),
    {ok, Channel}.

