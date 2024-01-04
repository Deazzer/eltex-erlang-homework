%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc This module adds, removes items from the list, and also checks whether this
%% item is in the list, searches for it, takes it, and also keeps track of the number 
%% of operations taking place in the process created either with a monitor or with a 
%%----------------------------------------------------------------------------------------------
-module(keylist).
-behanior(gen_server).

%% API
-export([start_monitor/1, start_link/1, add/3, is_member/1, take/1, find/1, delete/1]).

%% CallBack
-export([init/1, handle_call/3, handle_info/2, terminate/2]).
-record(state, {
    
    list = [] :: [{atom(), integer(), string()}] | [],
    counter = 0 :: non_neg_integer()
}).
%% @doc Start proccess with monitor
-spec(start_monitor(atom()) -> {ok, pid(), reference()}).
start_monitor(Name) ->
    gen_server:start_monitor({local, Name}, ?MODULE, [], []).
%% @doc Start linked process
-spec(start_link(atom()) -> {ok, pid()}).
start_link(Name) ->
	gen_server:start_link({local, Name}, ?MODULE, [], []).
%% @doc Add element to the list
-spec(add(atom(), integer(), string()) -> ok).
add(Key, Value, Comment) ->
    gen_server:call(?MODULE,{self(), add, Key, Value, Comment}),
    ok.
%% @doc Checks whether this element is a member of the list
-spec(is_member(atom()) -> ok).
is_member(Key) ->
    gen_server:call(?MODULE, {self(), is_member, Key}),
    ok.
%% @doc Delete element from the list
-spec(delete(atom()) -> ok).
delete(Key) ->
    gen_server:call(?MODULE, {self(), delete, Key}),
    ok.
%% @doc Find element of the list
-spec(find(atom()) -> ok).
find(Key) ->
    gen_server:call(?MODULE, {self(), find, Key}),
    ok.
%% @doc Take element from the list
-spec(take(atom()) -> ok).
take(Key) ->
    gen_server:call(?MODULE, {self(), take, Key}),
    ok.
init([]) ->
    process_flag(trap_exit, true),
    {ok, #state{list = [], counter = 0}}.

handle_call({Pid, add, Key, Value, Comment} = MSG, _From, #state{list = List, counter = Counter} = State)->
    io:format("Received msg ~p", [MSG]),
    NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
     Pid ! {ok, NewState#state.counter},
{reply, {}, NewState};

handle_call({Pid, is_member, Key} = MSG, _From, #state{list = List} = State) ->
    io:format("Received msg ~p", [MSG]),
    Result = lists:keymember(Key, List, 1),
        Pid ! Result,
{reply, State};

handle_call({Pid, delete, Key} = MSG, _From, #state{list = List, counter = Counter} = State)->
    io:format("Received msg ~p", [MSG]),
    NewList = lists:keydelete(Key, 1, List),
                NewState = State#state{list = NewList, counter = Counter + 1},
                    Pid ! {ok, NewState#state.counter},
{reply, NewState};

handle_call({Pid, find, Key} = MSG, _From, #state{list = List} = State)->
    io:format("Received msg ~p", [MSG]),
    Result = lists:keyfind(Key, List, 1),
                Pid ! Result,
{reply, State};

handle_call({Pid, take, Key} = MSG, _From, #state{list = List, counter = Counter} = State)->
    io:format("Received msg ~p", [MSG]),
    {Value, Comment, Rest} = lists:keytake(Key, 1, List),
                NewState = State#state{list = Rest, counter = Counter + 1},
                    Pid ! {ok, {Value, Comment}, NewState#state.counter},
{reply, NewState}.

handle_info({'EXIT', FailedPid, Reason}, State) ->
    error_logger:error_msg("Process ~p exited with reason ~p~n", [FailedPid, Reason]),
{noreply, State};

handle_info({'DOWN', Ref, process, Pid, Reason}, State) -> 
    io:format("Process is down with msg ~p ~p ~p state ~p", [Ref, Pid, Reason, State]),
{noreply, State};
handle_info(MSG, State) ->
    io:format("Received MSG ~p state ~p", [MSG, State]),
{noreply, State}.

 terminate(Reason, State) ->
    io:format("Terminating reason ~p in state ~p", [Reason, State]),
ok.
