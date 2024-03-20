%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc
%% Модуль реализует операции для работы с DETS- и ETS-таблицами.
%% @end
%%----------------------------------------------------------------------------------------------
-module(webrtp_mnesia).
-author("VarlanKuanyshev").
%%----------------------------------------------------------------------------------------------
-include_lib("kernel/include/logger.hrl").

%% API
-export([start/0, stop/0]).
-export([insert_abonent/2, delete_abonent/1]).
-export([get_abonent/1, get_all_abonents/0]).

-record(abonent, {
  num  :: non_neg_integer(),
  name :: string()
}).

%% API

%% @doc start
-spec start() -> {ok, ok} | {error, term()}.
start() ->
  mnesia:start(),
  init_schema(),
  create_abonent_table().

%% @doc stop
-spec stop() -> ok.
stop() ->
  mnesia:stop(),
  ok.

%% @doc Add abonent
-spec insert_abonent(Num :: non_neg_integer(), Name ::string()) ->
                    {atomic, ok} | {error, term()}.

insert_abonent(Num, Name) ->
  AbonentRec = #abonent{num = Num, name = Name},
  Transaction =
    fun() ->
      case mnesia:read(abonent, Num) of
        [] ->
          mnesia:write(AbonentRec),
          ?LOG_NOTICE("Abonent ~p added in the table!", [Num]);
        [_] ->
          ?LOG_WARNING("Abonent ~p is already in the table.", [Num]),
          {error, already_exists}
      end
    end,
  {atomic, Res} = mnesia:transaction(Transaction),
  Res.

%% @doc Delete abonent
-spec delete_abonent(Num :: non_neg_integer()) ->
                    {atomic, ok} | {error, term()}.

delete_abonent(Num) ->
  Transaction =
    fun() ->
      case mnesia:read(abonent, Num) of
        [_] ->
          mnesia:delete({abonent, Num}),
          ?LOG_NOTICE("Abonent ~p has been successfully deleted!", [Num]);
        [] ->
          ?LOG_WARNING("Abonent ~p is not in the table!", [Num]),
          {error, not_found}
      end
    end,

  {atomic, Res} = mnesia:transaction(Transaction),
  Res.

%% @doc Get abonent-info 
-spec get_abonent(Num :: non_neg_integer()) ->
                 {atomic, {non_neg_integer(), string()} | not_found}.

get_abonent(Num) ->
  Transaction = fun() ->
    case mnesia:read({abonent, Num}) of
      [{abonent, Num, Name}] ->
        {Num, Name};
      [] ->
        not_found
    end
          end,
  {atomic, Res} = mnesia:transaction(Transaction),
  Res.

%% @doc Get abonent-list
-spec get_all_abonents() ->
        {atomic, [{non_neg_integer(), string()}] | not_found}.

get_all_abonents() ->
  {atomic, Result} =
    mnesia:transaction(
      fun() ->
        mnesia:select(abonent, [{'_', [], ['$_']}])
      end
    ),
  case Result of
    [] ->
      ?LOG_WARNING("No abonents found in table!"),
      not_found;
    _ ->
      Result
  end.

%% Callback.
init_schema() ->
  case mnesia:create_schema([node()]) of
    {ok, _} ->
      ok;
    {error, {already_exists, _}} ->
      ok;
    {error, Reason} ->
      {error, Reason}
  end.

create_abonent_table() ->
  %% Default: set / ram_copies
  case mnesia:create_table(abonent, [{attributes, record_info(fields, abonent)}]) of
    {atomic, ok} ->
      ?LOG_NOTICE("Table was created successfully!"),
      ok;
    {aborted, {error, already_exists}} ->
      ?LOG_WARNING("Table has already been created."),
      ok;
    {aborted, Reason} ->
      {error, Reason}
  end.