%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc This module adds, removes items from the list, and also checks whether this
%% item is in the list, searches for it, takes it, and also keeps track of the number 
%% of operations taking place in the process created either with a monitor or with a 
%%----------------------------------------------------------------------------------------------
-module(keylist).

%% API
-export([start_monitor/1, start_link/1, add/3, is_member/1, take/1, find/1, delete/1, loop/1]).

-record(state, {
    
    list = [] :: [{atom(), integer(), string()}] | [],
    counter = 0 :: non_neg_integer()
}).
%% @doc Start proccess with monitor
-spec(start_monitor(atom()) -> {ok, pid(), reference()}).
start_monitor(Name) ->
    Pid = spawn(keylist, loop, [#state{}]),
        register(Name, Pid),
            MonitorRef = spawn_monitor(process, Pid),
		        self() ! {ok, Pid, MonitorRef}.
%% @doc Start linked process
-spec(start_link(atom()) -> {ok, pid()}).
start_link(Name) ->
	Pid = spawn_link(keylist, loop, [#state{}]), 
            register(Name, Pid),    
                self() ! {ok, Pid}.
%% @doc Add element to the list
-spec(add(atom(), integer(), string()) -> ok).
add(Key, Value, Comment) ->
    ?MODULE ! {self(), add, Key, Value, Comment},
    ok.
%% @doc Checks whether this element is a member of the list
-spec(is_member(atom()) -> ok).
is_member(Key) ->
    ?MODULE ! {self(), is_member, Key},
    ok.
%% @doc Delete element from the list
-spec(delete(atom()) -> ok).
delete(Key) ->
    ?MODULE ! {self(), delete, Key},
    ok.
%% @doc Find element of the list
-spec(find(atom()) -> ok).
find(Key) ->
    ?MODULE ! {self(), find, Key},
    ok.
%% @doc Take element from the list
-spec(take(atom()) -> ok).
take(Key) ->
    ?MODULE ! {self(), take, Key},
    ok.

loop(#state{list = List, counter = Counter} = State) ->
    receive
        %% считывание сообщений и выполнение требуемых операций
        {From, add, Key, Value, Comment} ->
            NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
                From ! {ok, NewState#state.counter},    
                        loop(NewState);

        {From, is_member, Key} ->
            Result = lists:keymember(Key, List, 1),
                From ! Result,
                    loop(State);

        {From, take, Key} ->
            {Value, Comment, Rest} = lists:keytake(Key, 1, List),
                NewState = State#state{list = Rest, counter = Counter + 1},
                    From ! {ok, {Value, Comment}, NewState#state.counter},
                        loop(NewState);

        {From, find, Key} ->
            Result = lists:keyfind(Key, List, 1),
                From ! Result,
                    loop(State);

        {From, delete, Key} ->
            NewList = lists:keydelete(Key, 1, State#state.list),
                NewState = State#state{list = NewList, counter = Counter + 1},
                    From ! {ok, NewState#state.counter},
                        loop(NewState);
        {'EXIT', FailedPid, Reason} ->
            error_logger:error_msg("Process ~p exited with reason ~p~n", [FailedPid, Reason])
    end.

