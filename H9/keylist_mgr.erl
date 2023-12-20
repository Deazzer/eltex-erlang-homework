%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc This module creates a process that is designed to create and control its child processes
%%----------------------------------------------------------------------------------------------
-module(keylist_mgr).
%% API
-export([start/0, stop/0]).
-export([start_child/1, stop_child/1]).
-export([get_names/0]).
%% Collbacks
-export([init/0]).

-record(state, {
    children = [] :: [{atom(), pid()}] | [],
    permanent = [] :: [pid()] | []
}).
%% @doc Start process with monitor
-spec(start() -> {ok, pid(), reference()}).
start() ->
    {Pid, MonitorRef} = spawn_monitor(?MODULE, init, []),
    self() ! {ok, Pid, MonitorRef}.
%% @doc Start child process with link in module "keylist"
-spec(start_child(Params::map()) -> ok).
start_child(Params) ->
    ?MODULE ! {self(), start_child, Params},
    ok.
%% @doc Stop child process with link in module "keylist
-spec(stop_child(atom()) -> ok).
stop_child(Name) ->
    ?MODULE ! {self(), stop_child, Name},
    ok.
%% @doc Stop main process
-spec(stop() -> ok).
stop() ->
    ?MODULE ! {self(), stop},
    ok.
%% @doc Get process names
-spec(get_names() -> ok).
get_names() ->
    ?MODULE ! {self(), get_names},
    ok.

init() ->
    register(?MODULE, self()),
    loop(#state{}).

loop(#state{children = Children, permanent = Permanent} = State) ->
    process_flag(trap_exit, true),
    receive
        {From, start_child, Params} when is_map(Params) ->
            io:format("Yes, it's a map ~n"),
            Name = maps:get(name, Params),
            Param = maps:get(restart, Params),
            case proplists:lookup(Name, Children) of
                none ->
                    io:format("It's a new map ~n~p~p", [Name, Param]),
                    {ok, Pid} = keylist:start_link(Name),
                    NewChildren = [{Name, Pid} | Children],
                    NewPermanent = case Param of   
                        permanent ->
                            [Pid | Permanent];
                        temporary ->
                            Permanent;
                        _ ->
                            From ! {error, type_error}
                    end,
                    From ! {ok, Pid},
                    loop(State#state{children = NewChildren, permanent = NewPermanent});
                {Name, true} ->
                    io:format("It's map already exists ~n~p", [Name]),
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
            exit(kill);
    
        {From, get_names} ->
            From ! proplists:get_keys(State#state.children),
            From ! proplists:get_keys(State#state.permanent),
            loop(State);
            %% регистрация завершения дочернего процесса и перезапуск
        {'EXIT', FailedPid, Reason} ->
            {Name,_} = lists:keyfind(FailedPid, 2, Children),
            io:format("~n~p~n", [Name]),
            case lists:member(FailedPid, Permanent) of
                true ->
                    error_logger:error_msg("Process ~p exited with reason ~p~n", [FailedPid, Reason]),
                    proplists:delete(FailedPid, Children),
                    proplists:delete(FailedPid, Permanent),
                    {ok, Pid} = keylist:start_link(Name),
                    NewChildren = [{Name, Pid} | Children],
                    NewPermanent =[{Pid} | Permanent],
                    loop(State#state{children = NewChildren, permanent = NewPermanent});
                false ->
                    error_logger:error_msg("Process ~p exited with reason ~p~n", [FailedPid, Reason]),
                    NewState = State#state{children = proplists:delete(FailedPid, Children)},
                    loop(NewState)
            end
    end.