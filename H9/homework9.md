20> c("keylist_mgr.erl").

    {ok,keylist_mgr}

21> c("keylist.erl").

    {ok,keylist}

22> rr("keylist.erl").

    [state]

23> keylist_mgr:start().

    {ok,<0.148.0>,#Ref<0.2359818913.3496476679.199861>}

        %%произведение запуска родительского процесса 

24> keylist_mgr:start_child(#{name => keylist, restart => permanent}).

    Yes, it's a map
    ok
    It's a new map

        %%запуск дочернего процесса в модуле keylist через модуль keylist_mgr

25> exit(whereis(keylist), kill).

    keylist
    true
    =ERROR REPORT==== 18-Dec-2023::18:50:43.302000 ===
    Process <0.151.0> exited with reason killed

        %% принудительно завершаем процесс, с типом данных permonent, по условию этот тип данных при завершении должен перезапустится, проверим это ниже =>

26> whereis(keylist).

    <0.152.0>

        %% как мы видим процесс перезапустился, тут я совершил ошибку, надо было заранее проверить с каким пидом запустился процесс изначально чтобы сравнить %% пид перезапущенного процесса с исходным 

4> keylist_mgr:start().

    {ok,<0.100.0>,#Ref<0.2664622285.2810183681.185378>}

5> keylist_mgr:start_child(#{name => keylist, restart => temporary}).

    Yes, it's a map
    ok
    It's a new map

7> exit(whereis(keylist), kill).

    keylist
    true
    =ERROR REPORT==== 20-Dec-2023::12:25:43.877000 ===
    Process <0.103.0> exited with reason killed

        %% произвели те же операции с temporary, что и с permonent 

8> whereis(keylist).

    undefined

        %% как видим процесс не перезапустился что удовлетворяет заданному условию в тз