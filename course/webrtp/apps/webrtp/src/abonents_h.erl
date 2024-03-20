%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc
%% Модуль реализует обработку запроса с методом GET, для вывода информации про всех абонентов
%% при помощи API webrtp_mnesia
%% @end
%%----------------------------------------------------------------------------------------------
-module(abonents_h).
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

  case AbList of

    not_found ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - There are no abonents!", Req);

    _ ->
      AbData = lists:map(fun({_TableName, Num, Name}) -> #{<<"num">> => Num, <<"name">> => Name} end, AbList),
        EnResp = jsone:encode(AbData),
          cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, EnResp, Req)
  end.