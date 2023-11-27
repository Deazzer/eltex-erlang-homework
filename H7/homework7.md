1> c("keylist.erl").

    {ok,keylist}

2> self().

    <0.85.0>

3> {ok, PidMonitored, MonitorRef} = keylist:start_monitor(monitored).

    {ok,<0.93.0>,#Ref<0.229189621.1013186564.158713>}

4> {ok, PidLinked} = keylist:start_link(linked).

    {ok,<0.95.0>}

5> self().

    <0.85.0>

6> PidLinked ! {self(), add, key, 3, "some_msg"}.

    {<0.85.0>,add,key,3,"some_msg"}

7> flush().

    Shell got {ok,1}
        ok

8> PidLinked ! {self(), take, key}.

    {<0.85.0>,take,key}

9> flush().

    Shell got {ok,{value,{key,3,"some_msg"}},2}
        ok
10> PidLinked ! {self(), find, key}.

=ERROR REPORT==== 8-Nov-2023::18:53:12.793000 ===
Error in process <0.95.0> with exit value:
{badarg,[{lists,keyfind,
                [key,[],1],
                [{error_info,#{module => erl_stdlib_errors}}]},
         {keylist,loop,1,[{file,"keylist.erl"},{line,42}]}]}

** exception exit: badarg
     in function  lists:keyfind/3
        called as lists:keyfind(key,[],1)
        *** argument 2: not an integer
        *** argument 3: not a list
     in call from keylist:loop/1 (keylist.erl, line 42)

%% Здесь процесс свалился из за того что я ищу ключ которого нет, а такую возможность в модуле я не прописал

12> process_info(PidLinked).

undefined

14> process_info(PidMonitored).

[{current_function,{keylist,loop,1}},
 {initial_call,{keylist,loop,1}},
 {status,waiting},
 {message_queue_len,0},
 {links,[]},
 {dictionary,[]},
 {trap_exit,false},
 {error_handler,error_handler},
 {priority,normal},
 {group_leader,<0.70.0>},
 {total_heap_size,233},
 {heap_size,233},
 {stack_size,5},
 {reductions,7},
 {garbage_collection,[{max_heap_size,#{error_logger => true,include_shared_binaries => false,
                                       kill => true,size => 0}},
                      {min_bin_vheap_size,46422},
                      {min_heap_size,233},
                      {fullsweep_after,65535},
                      {minor_gcs,0}]},
 {suspending,[]}]

%% Здесь я на всякий случай проверил информацию о состоянии процессов

16> {ok, PidLinked1} = keylist:start_link(linked).

    {ok,<0.111.0>}

17> PidLinked1 ! {self(), add, key, 3, "some_msg"}.

    {<0.109.0>,add,key,3,"some_msg"}

18> PidLinked ! {self(), find, key}.

    {<0.109.0>,find,key}

19> flush().

    Shell got {ok,1}

        ok

20> exit(PidMonitored, normal).

    true

21> flush().
    
    ok

22> exit(PidLinked, normal).
    
    true

23> flush().

    ok

24> process_flag(trap_exit, true).
    
    false
    
25> {ok, PidLinked2} = keylist:start_link(linked).

    {ok,<0.124.0>}

27> exit(PidLinked2, normal).

    true

28> flush().

    ok

29> self().
    
    <0.122.0>

30> {ok, PidLinked3} = keylist:start_link(linked).
    
    {ok,<0.132.0>}

32> exit(PidLinked3, normal).
    
    true

33> flush().

    ok

34> self().

    <0.130.0>

35> process_flag(trap_exit, false).
    
    false

36> self().

    <0.130.0>

37> {ok, PidLinked4} = keylist:start_link(linked).

    {ok,<0.142.0>}

38> exit(PidLinked4, normal).
    
    true

40> flush().
    
    ok

41> self().
    
    <0.140.0>

    %% как видно процессы завершились корзина с сообщениями пуста, но с трап экзитами что то не выходит

    %%ПОПРАВКИ

1> c("keylist.erl").
    
    {ok,keylist}

2> {ok, PidMonitored, MonitorRef} = keylist:start_monitor(monitored).
    
    {ok,<0.92.0>,#Ref<0.808809936.132120582.131281>}

3> flush().

    Shell got {ok,<0.92.0>,#Ref<0.808809936.132120582.131281>}
    ok

4> {ok,PidLinked} = keylist:start_link(linked).
    
    {ok,<0.95.0>}

5> PidLinked ! (self(), add, key1, 1, "first_msg").
    
    * 1:20: syntax error before: ','

5> PidLinked ! {self(), add, key1, 1, "first_msg"}.

    {<0.85.0>,add,key1,1,"first_msg"}

6> PidLinked ! {self(), add, key2, 2, "second_msg"}.

    {<0.85.0>,add,key2,2,"second_msg"}

7> PidLinked ! {self(), add, key3, 3, "third_msg"}.

    {<0.85.0>,add,key3,3,"third_msg"}

8> flush().

    Shell got {ok,<0.95.0>}
    Shell got {ok,1}
    Shell got {ok,2}
    Shell got {ok,3}
    ok

9> PidLinked ! {self(), take, key3}.
    
    {<0.85.0>,take,key3}

10> PidLinked ! {self(), take, key2}.

    {<0.85.0>,take,key2}

11> PidLinked ! {self(), take, key1}.

    {<0.85.0>,take,key1}

12> flush().

    Shell got {ok,{value,{key3,3,"third_msg"}},4}
    Shell got {ok,{value,{key2,2,"second_msg"}},5}
    Shell got {ok,{value,{key1,1,"first_msg"}},6}
    ok

13> exit(PidMonitored, killed).

    true

14> flush().

    Shell got {'DOWN',#Ref<0.808809936.132120582.131281>,process,<0.92.0>,killed}
    ok

15> exit(PidLinked, killed).
    
    ** exception exit: killed

16> exit(PidLinked, kill).
    
    true

17> flush().

    ok

18> exit(PidLinked, killed).

    true

19> flush().
    
    ok