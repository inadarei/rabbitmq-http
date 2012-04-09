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

-include_lib("amqp_client/include/amqp_client.hrl").

-record(state, {channel}).

-define(MQ_EXCHANGE, <<"rabbitmq_http.topic">>).
-define(MQ_TYPE, <<"topic">>).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, Channel} = setup_rabbitmq(),
    {ok, #state{channel = Channel}}.

terminate(_, #state{channel = Channel}) ->
    amqp_channel:call(Channel, #'channel.close'{}),
    ok.

handle_request(_, Req) ->
    gen_server:call({global, ?MODULE}, {request, Req}),
    ok.

code_change(_, State, _) ->
    {ok, State}.

handle_call({request, Req}, _, State = #state{channel = Channel}) ->
    io:format("handle_request ~p ~p ~n", [Req:get(raw_path), Channel]),
    Req:respond({200, [{"Content-Type", "text/plain"}], "Request Received"}),
    {reply, ok, State};

handle_call(_, _, State) ->
    {reply, ok, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_info(_, State) ->
    {noreply, State}.

setup_rabbitmq() ->
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
