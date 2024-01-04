> c("keylist_mgr.erl").
{ok,keylist_mgr}
2> c("keylist.erl").
{ok,keylist}
3> rr("keylist.erl").
[state]
        %% компилируем модули
4> keylist_mgr:start().
ok
        %% запускаем родительский процесс

5> keylist_mgr:start_child(#{name => somename, restart => permanent}).
Received msg
{<0.85.0>,start_child,#{name => somename,restart => permanent}}
It's a new map
 Name: somename
 Param: permanent
Received MSG {added_new_child,<0.103.0>,somename} state {state,[],0}ok
        %% запускаем постоянный дочерний процесс

6> keylist_mgr:start_child(#{name => somename1, restart => temporary}).
Received msg
{<0.85.0>,start_child,#{name => somename1,restart => temporary}}
It's a new map
 Name: somename1
 Param: temporary
Received MSG {added_new_child,<0.105.0>,somename1} state {state,[],0}Received MSG {added_new_child,<0.105.0>,somename1} state {state,[],0}ok
        %% запускаем временный дочерний процесс

7> whereis(somename).
<0.103.0>
8> whereis(somename1).
<0.105.0>
        %% проверяем пиды дочерних процессов

9> exit(<0.103.0>, kill).

somename
true
=ERROR REPORT==== 4-Jan-2024::14:38:29.405000 ===
Process <0.103.0> exited with reason killed

Received MSG {restarted_child,<0.103.0>,somename} state {state,[],0}Received MSG {restarted_child,<0.103.0>,somename} state {state,[],0}
        %% завершаем постоянный дочерний процесс

10> whereis(somename).
<0.109.0>
        %% исходя из полученного пида после завершения постоянного процесса, он перезапустился под новым пидом

11> exit(<0.105.0>, kill).

somename1
true
Received MSG {deleted_child,<0.105.0>,somename1} state {state,[],0}=ERROR REPORT==== 4-Jan-2024::14:39:40.607000 ===
Process <0.105.0> exited with reason killed
        %% завершаем временный дочерний процесс
12> whereis(somename1).
undefined
        %% временный процесс не был запущен заново, так как не является постоянным