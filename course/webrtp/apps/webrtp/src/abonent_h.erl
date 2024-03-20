%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc
%% Модуль реализует обработку запросов с методами: POST, DELETE, GET которые в свою очередь 
%% реализуют добавление, удаление, возвращение абонента относительно базы данных.
%% @end
%%----------------------------------------------------------------------------------------------
-module(abonent_h).
-author("VarlanKuanyshev").
-behavior(cowboy_handler).
%%----------------------------------------------------------------------------------------------
-export([init/2]).

init(Request, State) ->

  Met = cowboy_req:method(Request),
  handle_req(Met, Request),

  {ok, Request, State}.

handle_req(<<"POST">>, Req) ->

  case cowboy_req:has_body(Req) of

    true ->
      {ok, ReqBody, Req2} = cowboy_req:read_body(Req),
        JsonData = jsone:decode(ReqBody),
          Num = maps:get(<<"num">>, JsonData),
            Name = maps:get(<<"name">>, JsonData),
      
      case webrtp_mnesia:get_abonent(Num) of

        not_found ->
          webrtp_mnesia:insert_abonent(Num, Name),
          cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent successfully added!", Req2);

        _ ->
          cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent is already!", Req)
      end;

    false ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - No Body Request!", Req)
  end;

handle_req(<<"GET">>, Req) ->
  
  NumBin = cowboy_req:binding(number, Req),
    Number = binary_to_integer(NumBin),
      Abonent = webrtp_mnesia:get_abonent(Number),

  case Abonent of

    {Num, Name} ->
      AbData = #{<<"num">> => Num, <<"name">> => Name},
      EnResp = jsone:encode(AbData),
      cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, EnResp, Req);

    not_found ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent not found!", Req)
  end;

handle_req(<<"DELETE">>, Req) ->

  NumBin = cowboy_req:binding(number, Req),
    Number = binary_to_integer(NumBin),
      Result = webrtp_mnesia:delete_abonent(Number),

  case Result of

    ok ->
      cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent deleted successfully!", Req);

    {error, not_found} ->
      cowboy_req:reply(404, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent not found!", Req)
  end.

