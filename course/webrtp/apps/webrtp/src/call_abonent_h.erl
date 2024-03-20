%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc
%% Модуль реализует звонок конкретному абоненту по номеру через запрос GET,
%% используя API из модулей webrtp_mnesia и webrtp_nksip
%% @end
%%----------------------------------------------------------------------------------------------
-module(call_abonent_h).
-author("VarlanKuanyshev").
-behavior(cowboy_handler).
%%----------------------------------------------------------------------------------------------
-export([init/2]).

init(Request, State) ->

  Met = cowboy_req:method(Request),
    handle_req(Met, Request),
      {ok, Request, State}.

handle_req(<<"GET">>, Req) ->

  NumBin = cowboy_req:binding(number, Req),
    Number = binary_to_integer(NumBin),
      Abonent = webrtp_mnesia:get_abonent(Number),
  
case Abonent of

    {Num, _Name} ->
      RespCall = call(Num),

      case RespCall of

        {ok, called} ->
          cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent was successfully called!", Req);

        busy ->
          cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent busy!", Req);

        not_respond ->
          cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent not respond!", Req);

        not_registred ->
          cowboy_req:reply(404, #{<<"content-type">> => <<"text/plain">>}, "Abonent not registred!", Req);

        dialog_not_started ->
          cowboy_req:reply(480, #{<<"content-type">> => <<"text/plain">>}, "Dialog not started!", Req)
      end;

    not_found ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent for call not found!", Req)
  end.

call(AbonentNumber) ->

  case webrtp_nksip:register(AbonentNumber) of

    {ok, registred} ->
      webrtp_nksip:call_abonent(AbonentNumber);
    
    _ ->
      {error, not_registred}
  end.


