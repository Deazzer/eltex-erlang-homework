%%%-------------------------------------------------------------------
%% @doc webrtp public API
%% @end
%%%-------------------------------------------------------------------
-module(webrtp_app).
-behaviour(application).

-include_lib("kernel/include/logger.hrl").

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  %% Start Mnesia
  webrtp_mnesia:start(),
  %% Start cowboy
  Dispatch = cowboy_router:compile([
    {'_', [
            
            {"/abonent/[:number]", abonent_h, []},
            {"/abonents", abonents_h, []},
            {"/call/abonent/[:number]", call_abonent_h, []},
            {"/call/broadcast", broadcast_h, []}
        ]}
    ]),
    Port = 8080,
    {ok, _} =
      cowboy:start_clear(http, [{port, Port}],
                        #{env => #{dispatch => Dispatch}}
                        ),
  ?LOG_NOTICE("webrtp start!"),

   webrtp_sup:start_link().

stop(_State) ->
    ok.
