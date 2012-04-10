%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-module(rabbitmq_http_subscriber).

-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("rabbitmq_http.hrl").

-record(state, {channel}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, Channel} = rabbitmq_http_util:start_rabbitmq_channel(),
    start_rabbitmq_subscriber(Channel),
    {ok, #state{channel = Channel}}.

terminate(_, #state{channel = Channel}) ->
    amqp_connection:close(Channel),
    ok;

terminate(_, _) ->
    ok.

code_change(_, State, _) ->
    {ok, State}.

handle_call(_, _, State) ->
    {reply, ok, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_info(#'basic.consume_ok'{}, State) ->
    {noreply, State};

handle_info({#'basic.deliver'{} = Info, Msg}, #state{channel = Channel} = State) ->
    #'basic.deliver'{delivery_tag = DTag} = Info,
    io:format("handle_deliver ... ~p ~p ~p ~p ~n", [Info, DTag, Msg, Channel]),
    ack_message(Channel, DTag),
    {noreply, State};

handle_info(Info, State) ->
    io:format("handle_info ... ~p ~p ~n", [Info, State]),
    {noreply, State}.

ack_message(Channel, DeliveryTag) ->
    Method = #'basic.ack'{delivery_tag = DeliveryTag},
    amqp_channel:call(Channel, Method).

start_rabbitmq_subscriber(Channel) ->

    QName = <<"rabbitmq_http_queue">>,
    Method = #'queue.declare'{durable = true, queue = QName},
    #'queue.declare_ok'{queue = Queue} = amqp_channel:call(Channel, Method),

    Result = amqp_channel:subscribe(Channel,
                                    #'basic.consume'{
                                      queue        = Queue,
                                      consumer_tag = "CTag",
                                      no_local     = false,
                                      no_ack       = false,
                                      exclusive    = false
                                     },
                                    self()),

    #'queue.bind_ok'{} = amqp_channel:call(Channel,
                                           #'queue.bind'{
                                             queue       = Queue,
                                             exchange    = ?MQ_EXCHANGE,
                                             routing_key = ?MQ_ROUTE_KEY
                                            }),

    ok.
