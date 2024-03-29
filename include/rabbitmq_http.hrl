%%
%% @doc RabbitMQ HTTP
%% @author Alex Haro <alex@life360.com>
%%
%% See LICENSE for license information.
%% Copyright (c) 2012 Life360
%%

-ifndef(RABBITMQ_HTTP_HRL).
-define(RABBITMQ_HTTP_HRL, true).

-include_lib("amqp_client/include/amqp_client.hrl").

-record(msgroute, {url, timeout = infinity}).

-define(MQ_NUM_SUBSCRIBERS, 10).
-define(MQ_EXCHANGE, <<"rabbitmq_http.topic">>).
-define(MQ_ROUTE_KEY, <<"#">>).
-define(MQ_TYPE, <<"topic">>).
-define(MQ_ROUTE_TABLE,
        dict:from_list([
                        {"example", #msgroute{url = "http://www.example.com/api/example", timeout = 1000}}
                       ])).

-endif.
