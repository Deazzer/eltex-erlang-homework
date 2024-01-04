%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc This module creates a process that is designed to create and control its child processes
%%----------------------------------------------------------------------------------------------
-module(keylist_mgr).
-behanior(gen_server).
%% API
-export([start/0, stop/0]).
-export([start_child/1, stop_child/1]).
-export([get_names/0]).
%% Collbacks
-export([init/1, handle_call/3, handle_info/2, terminate/2]).

-record(state, {
    children = [] :: [{atom(), pid()}] | [],
    permanent = [] :: [pid()] | []
}).
%% @doc Start process with monitor
-spec(start() -> ok).
start() ->
    gen_server:start_monitor({local, ?MODULE}, ?MODULE, [], []),
    ok.
%% @doc Start child process with link in module "keylist"
-spec(start_child(Params::map()) -> ok).
start_child(Params) when is_map(Params) ->
    gen_server:call(?MODULE, {self(), start_child, Params}),
    ok.
%% @doc Stop child process with link in module "keylist
-spec(stop_child(atom()) -> ok).
stop_child(Name) ->
    gen_server:call(?MODULE, {self(), stop_child, Name}),
    ok.
%% @doc Stop main process
-spec(stop() -> ok).
stop() ->
    gen_server:call(?MODULE, {self(), stop}),
    ok.
%% @doc Get process names
-spec(get_names() -> ok).
get_names() ->
   gen_server:call(?MODULE, {self(), get_names}),
    ok.

init([]) ->
    process_flag(trap_exit, true),
    {ok, #state{children = [], permanent = []}}.

handle_call({Pid, start_child, Params} = MSG, _From, #state{children = Children, permanent = Permanent} = State) ->
    io:format("Received msg ~n~p~n", [MSG]),
            Name = maps:get(name, Params),
            Param = maps:get(restart, Params),
            case proplists:lookup(Name, Children) of
                none ->
                    io:format("It's a new map ~n Name: ~p~n Param: ~p~n", [Name, Param]),
                    {ok, PidKey} = keylist:start_link(Name),
                    NewChildren = [{Name, PidKey} | Children],
                    NewPermanent = case Param of   
                        permanent ->
                            [PidKey | Permanent];
                        temporary ->
                            Permanent;
                        _ ->
                            Permanent
                    end,
                    Pid ! {ok, PidKey},
                    NewState = State#state{children = NewChildren, permanent = NewPermanent},
                    lists:foreach(fun({_, ChildrenPid}) -> ChildrenPid ! {added_new_child, PidKey, Name} end, NewChildren);
                {Name, true} ->
                    io:format("It's map already exists ~n~p", [Name]),
                    Pid ! {error, already_started},
                    NewState = State
            end,
{reply, {}, NewState};

handle_call({Pid, stop_child, Name} = MSG, _From, #state{children = Children} = State) ->
    io:format("Received msg ~n~p~n", [MSG]),
    case proplists:lookup(Name, Children) of
        none ->
            Pid ! {error, not_found},
            NewState = State;
        
        _ ->
            keylist:stop(Name),
                NewChildren = State#state{children = proplists:delete(Name, Children)},
                    Pid ! {ok, NewChildren},
                        NewState = State#state{children = NewChildren}
    end,
{reply, NewState};

handle_call({Pid, get_names},_From, #state{children = Children, permanent = Permanent} = State) ->
    Pid ! proplists:get_keys(Children),
    Pid ! proplists:get_keys(Permanent),
{reply, State};

handle_call({Pid, stop},_From, #state{} = State) ->
    Pid ! stopped,
    exit(kill),
{reply, State}.

handle_info({'EXIT', FailedPid, Reason}, #state{children = Children, permanent = Permanent} = State) ->
    case lists:keyfind(FailedPid, 2, Children) of
        {Name,_} ->
        io:format("~n~p~n", [Name]),
        case lists:member(FailedPid, Permanent) of
            true ->
                error_logger:error_msg("Process ~p exited with reason ~p~n", [FailedPid, Reason]),
                proplists:delete(FailedPid, Children),
                proplists:delete(FailedPid, Permanent),
                {ok, PidKey} = keylist:start_link(Name),
                NewChildren = [{Name, PidKey} | Children],
                NewPermanent =[{PidKey} | Permanent],
                lists:foreach(fun({_, ChildrenPid}) -> ChildrenPid ! {restarted_child, FailedPid, Name} end, NewChildren),
                {noreply, State#state{children = NewChildren, permanent = NewPermanent}};
            false ->
                error_logger:error_msg("Process ~p exited with reason ~p~n", [FailedPid, Reason]),
                NewChildren = proplists:delete(FailedPid, Children),
                lists:foreach(fun({_, ChildrenPid}) -> ChildrenPid ! {deleted_child, FailedPid, Name} end, NewChildren),
                {noreply, State#state{children = NewChildren}}
        end;
        false -> 
            {noreply, State}
    end;

handle_info({'DOWN', Ref, process, Pid, Reason}, State) -> 
    io:format("Process is down with msg ~p ~p ~p state ~p", [Ref, Pid, Reason, State]),
{noreply, State};

handle_info(MSG, State) ->
    io:format("Sended MSG ~p state ~p", [MSG, State]),
{noreply, State}.

 terminate(Reason, State) ->
    io:format("Terminating reason ~p in state ~p", [Reason, State]),
ok.