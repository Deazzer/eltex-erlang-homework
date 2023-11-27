-module(keylist).

-export([loop/1, start_monitor/1, start_link/1]).

-record(state, {
    
    list = [], 
    counter = 0
}).

start_monitor(Name) ->
    Pid = spawn(keylist, loop, [#state{}]),
        register(Name, self()),
            MonitorRef = erlang:monitor(process, Pid),
		        self() ! {ok, Pid, MonitorRef}.

start_link(Name) ->
	Pid = spawn(keylist, loop, [#state{}]),
        link(Pid),
            register(Name, Pid),    
                self() ! {ok, Pid}.
loop(#state{list = List, counter = Counter} = State) ->
    receive
        
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
                        loop(NewState)

    end.

