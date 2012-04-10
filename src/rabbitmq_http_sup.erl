%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-module(rabbitmq_http_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

-include("rabbitmq_http.hrl").

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, _Arg = []).

init([]) ->
    WorkerChildren = [{rabbitmq_http_worker,
                       {rabbitmq_http_worker, start_link, []},
                       permanent,
                       10000,
                       worker,
                       [rabbitmq_http_worker]}],
    SubChildren = [get_sub_spec(X) || X <- lists:seq(1, ?MQ_NUM_SUBSCRIBERS)],
    Children = lists:append(WorkerChildren, SubChildren),

    {ok, {{one_for_one, 1, 10}, Children}}.

get_sub_spec(X) ->
    ChildId = "rabbitmq_http_subscriber_" ++ integer_to_list(X),
    ChildTerm = list_to_atom(ChildId),

    SubSpec = {ChildTerm,
               {rabbitmq_http_subscriber, start_link, [ChildTerm]},
               permanent,
               10000,
               worker,
               [rabbitmq_http_subscriber]},
    SubSpec.
