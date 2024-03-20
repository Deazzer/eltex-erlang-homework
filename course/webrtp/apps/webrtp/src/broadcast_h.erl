%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc
%% Модуль реализует обзвон абонентов, находящихся в базе данных через GET,
%% используя API модулей webrtp_mnesia и webrtp_nksip и выводит его результаты
%% @end
%%----------------------------------------------------------------------------------------------
-module(broadcast_h).
-author("VarlanKuanyshev").
-behavior(cowboy_handler).
%%----------------------------------------------------------------------------------------------
-export([init/2]).

init(Request, State) ->

  Met = cowboy_req:method(Request),
    handle_req(Met, Request),
      {ok, Request, State}.

handle_req(<<"GET">>, Req) ->

  AbList = webrtp_mnesia:get_all_abonents(),
    ResCallList = [{Number, call(Number)} || {_, Number, _} <- AbList],
      RespBody = io_lib:format("Call Results: ~p", [ResCallList]),
        cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, lists:flatten(RespBody), Req).

call(AbNumber) ->

  case webrtp_nksip:register(AbNumber) of
    {ok, registred} ->
      webrtp_nksip:call_abonent(AbNumber);

    _ ->
      {error, not_registred}
  end.


