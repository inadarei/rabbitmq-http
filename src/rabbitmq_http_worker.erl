%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-module(rabbitmq_http_worker).

-behaviour(gen_server).

-export([dispatch_request/2]).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("rabbitmq_http.hrl").

-record(state, {channel}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, Channel} = rabbitmq_http_util:start_rabbitmq_channel(),
    {ok, #state{channel = Channel}}.

terminate(_, #state{channel = Channel}) ->
    amqp_connection:close(Channel),
    ok;

terminate(_, _) ->
    ok.

dispatch_request(_, Req) ->
    gen_server:call({global, ?MODULE}, {request, Req}),
    ok.

code_change(_, State, _) ->
    {ok, State}.

handle_call({request, Req}, _, State = #state{channel = Channel}) ->
    Method = Req:get(method),
    Path = Req:get(raw_path),
    Body = Req:recv_body(),

    Response = handle_request(Method, Path, Body, Channel),
    Req:respond(Response),

    {reply, ok, State};

handle_call(_, _, State) ->
    {reply, ok, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_info(_, State) ->
    {noreply, State}.

handle_request('GET', "/http/api/test", _, Channel) ->
    publish_message(<<"test">>, "test", Channel);

handle_request('POST', "/http/api/publish", _, _) ->
    {404, [{"Content-Type", "text/plain"}], <<"Unknown Topic">>};

handle_request('POST', _, <<>>, _) ->
    {404, [{"Content-Type", "text/plain"}], <<"Unknown Body">>};

handle_request('POST', "/http/api/publish/" ++ Topic, Body, Channel) ->
    Response = publish_message(Body, Topic, Channel),
    Response;

handle_request(_, _, _, _) ->
    {404, [{"Content-Type", "text/plain"}], <<"Unknown Request">>}.

publish_message(undefined, _, _) ->
    {404, [{"Content-Type", "text/plain"}], <<"Message Not Defined">>};

publish_message(_, undefined, _) ->
    {404, [{"Content-Type", "text/plain"}], <<"Topic Not Defined">>};

publish_message(Body, Topic, Channel) ->
    BasicPublish = #'basic.publish'{exchange = ?MQ_EXCHANGE,
                                    routing_key = list_to_binary(Topic),
                                    mandatory = true,
                                    immediate = false},

    Properties = #'P_basic'{delivery_mode = 2},
    Content = #amqp_msg{props = Properties, payload = Body},

    amqp_channel:call(Channel, BasicPublish, Content),

    {200, [{"Content-Type", "text/plain"}], <<"OK">>}.
