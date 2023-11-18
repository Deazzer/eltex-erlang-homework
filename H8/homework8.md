1> c("keylist_mgr.erl").

   {ok,keylist_mgr}

2> rr("keylist.erl").

   [state]

3> {ok, PidKey, MonitorRef} = keylist_mgr:start().

   {ok,<0.95.0>,#Ref<0.3883610770.4188012550.101802>}

4> PidKey ! {self(), start_child, keylist1}.

{<0.85.0>,start_child,keylist1}

Child started {keylist1,<0.98.0>}

5> whereis(keylist1).

<0.98.0>

6> keylist1 ! {self(), add, key1, 1, "something"}.

{<0.85.0>,add,key1,1,"something"}

7> flush().

Shell got {ok,<0.95.0>,#Ref<0.3883610770.4188012550.101802>}
Shell got {ok,<0.98.0>}
Shell got {ok,1}

ok

 self().

<0.85.0>

22> keylist3 ! {self(), add, person, 1, "Georgy"}.

{<0.85.0>,add,person,1,"Georgy"}

23> flush().

Shell got {ok,1}

ok

      %% Здесь мы успешно запустили основной и его дочерние процессы а также отправили им сообщения, которые были успешно приняты
24> exit(<0.125.0>, kill).

=ERROR REPORT==== 15-Nov-2023::19:09:41.139000 ===
Process <0.125.0> exited with reason killed

true

25> flush().

ok

      %% был завершен процесс keylist1
26> self().

<0.85.0>

      %% процесс ешела не изменился
27> whereis(keylist2).

<0.127.0>

28> whereis(keylist3).

<0.129.0>

      %% завершение keylist1 не повлияло на другие дочерние процессы

29> keylist_mgr ! {'EXIT', <0.125.0>, kill}.

=ERROR REPORT==== 15-Nov-2023::19:12:48.339000 ===
Process <0.125.0> exited with reason kill

{'EXIT',<0.125.0>,kill}

      %% как видим наш основной процесс залогировал выход 
31> exit(PidKey, kill).
true

32> flush().

Shell got {'DOWN',#Ref<0.3883610770.4188012550.102088>,process,<0.123.0>,
                  killed}
ok

33> self().

<0.85.0>

      %% процесс не изменился
1> c("keylist_mgr.erl").

{ok,keylist_mgr}

2> rr("keylist.erl").

[state]

      %% здесь мы заново завпустили что бы проверить другой способ завершения процесса
3> {ok, PidKeylist, MonitorRef} = keylist_mgr:start().

{ok,<0.95.0>,#Ref<0.1599228219.2581331971.109942>}

5> PidKeylist ! {self(), start_child, keylist2}.

{<0.85.0>,start_child,keylist2}

6> PidKeylist ! {self(), start_child, keylist3}.

{<0.85.0>,start_child,keylist3}

7> PidKeylist ! {self(), stop}.

{<0.85.0>,stop}

8> flush().

Shell got {ok,<0.95.0>,#Ref<0.1599228219.2581331971.109942>}
Shell got {ok,<0.98.0>}
Shell got {ok,<0.100.0>}
Shell got stopped
Shell got {'DOWN',#Ref<0.1599228219.2581331971.109942>,process,<0.95.0>,
                  normal}
ok

9> whereis(keylist2).

<0.98.0>

10> whereis(keylist3).

<0.100.0>

      %% как видим основной процесс был остановлен, а его дочерние процессы  до сих пор функционируют