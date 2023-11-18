-module(keylist_mgr).

-export([loop/1, start/0, stop/0]).

-record(state, {
    children = []
}).

start() ->
    {Pid, MonitorRef} = spawn_monitor(keylist_mgr, loop, [#state{}]),
    register(?MODULE, Pid),
    self() ! {ok, Pid, MonitorRef}.

stop() ->
    ?MODULE ! stop.

    loop(#state{children = Children} = State) ->
        process_flag(trap_exit, true),
        receive
            {From, start_child, Name} ->
                case proplists:lookup(Name, Children) of
                    none ->
                        {ok, Pid} = keylist:start_link(Name),
                        NewChildren = [{Name, Pid} | Children],
                        From ! {ok, Pid},
                        loop(State#state{children = NewChildren});
                    _ ->
                        From ! {error, already_started},
                        loop(State)
                end;
    
            {From, stop_child, Name} ->
                case proplists:lookup(Name, Children) of
                    none ->
                        From ! {error, not_found},
                        loop(State);
                
                    _ ->
                        keylist:stop(Name),
                        NewChildren = State#state{children = proplists:delete(Name, Children)},
                        From ! {ok, NewChildren},
                        loop(State#state{children = NewChildren})
                end;                       
                
                {From, stop} ->
                    From ! stopped,
                    exit(normal);
    
                {From, get_names} ->
                    From ! proplists:get_keys(State#state.children),
                    loop(State);
            
                {'EXIT', Pid, Reason} ->
                    error_logger:error_msg("Process ~p exited with reason ~p~n", [Pid, Reason]),
                    NewState = State#state{children = proplists:delete(Pid, Children)},
                    loop(NewState)
            end.
