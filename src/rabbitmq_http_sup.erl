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

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, _Arg = []).

init([]) ->
    {ok, {{one_for_one, 10, 10},
          [{rabbitmq_http_worker,
            {rabbitmq_http_worker, start_link, []},
            permanent,
            10000,
            worker,
            [rabbitmq_http_worker]},
           {rabbitmq_http_subscriber,
            {rabbitmq_http_subscriber, start_link, []},
            permanent,
            10000,
            worker,
            [rabbitmq_http_subscriber]}
          ]}}.
