%% Задание 1

1> [X || X <- [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], X rem 3 == 0].
    [3,6,9]
2> [Z || Z <- lists:seq(1, 10), Z rem 3 == 0].
    [3,6,9]
3> [Y * Y || Y <- [1, "hello", 100, boo, "boo", 9], integer(Y)].
    [1,10000,81]

    %% как видно генераторы списков могут участвовать в сортировке

%% Задание 2

4> <<X:4, Y:2>> = <<42:6>>.
    <<42:6>>
5> X.
    10
6> Y.
    2
    %% здесь у нас получился паттерн матчинг и мы получили 10 в 4 битах, 2 в двухбитах
7> <<C:4, D:4>> = <<1998:6>>.
    ** exception error: no match of right hand side value <<14:6>>
8> <<C:4, D:2>> = <<1998:8>>.
    ** exception error: no match of right hand side value <<"Î">>

    %%  в 7й м 8й строке у нас не произошел паттерн матчинг, в 7й у нас с лева ожидается 8 бит, а с права 6 бит; в 8й с лева ожидается 6, а с рава у нас 8 

%% Задание 3

1> c("protocol.erl").
    {ok,protocol}
2> DataWrongFormat = <<4:4,6:4,0:8,0:3>>.
    <<70,0,0:3>>
3> DataWrongVer = <<6:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello">>.
    <<102,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
    101,108,108,111>>
4> Data1 = <<4:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello">>.
    <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
    101,108,108,111>>
5> Data2 = <<4:4, 6:4, 0:8, 232:16, 0:16, 0:4, 0:16, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "helloworld">>.
    <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,
    134,86,198,198,...>>
6> protocol:ipv4(DataWrongFormat).
    ** exception throw: badarg
     in function  protocol:ipv4/1 (protocol.erl, line 46)
7> protocol:ipv4(DataWrongVer).
    ** exception throw: badarg
     in function  protocol:ipv4/1 (protocol.erl, line 46)
8> protocol:ipv4(Data1).
    Received data <<"hello">>
    {ipv4,4,6,0,232,0,0,0,0,0,0,0,0,<<0,0,0,0>>,<<"hello">>}
9> protocol:ipv4(Data2).
    ** exception throw: badarg
     in function  protocol:ipv4/1 (protocol.erl, line 46)
10> Pid1 = spawn(protocol, ipv4, [Data1]).
    Received data <<"hello">>
    <0.111.0>
11> Pid1.
    <0.111.0>
12> self().
    <0.109.0>
13> Pid1 = spawn(protocol, ipv4, [DataWrongVer]).
    =ERROR REPORT==== 3-Nov-2023::18:41:59.274000 ===
    Error in process <0.114.0> with exit value:
    {{nocatch,badarg},[{protocol,ipv4,1,[{file,"protocol.erl"},{line,46}]}]}

    ** exception error: no match of right hand side value <0.114.0>
14> self().
    <0.115.0>

        %% да изменился, так как процесс запустился и завершился с ошибкой поэтому и пид процесса сменился

%% Задание 4

15> ListenerPid = spawn(protocol, ipv4_listener, []).
    ** exception error: no match of right hand side value <0.126.0>
16> ListenerPid.
    <0.119.0>
17> Msg = {ipv4, self(), Data1}.
    {ipv4,<0.127.0>,
      <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
        101,...>>}
18> erlang:send(ListenerPid, Msg).
    {ipv4,<0.127.0>,
      <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
        101,...>>}
19> ListenerPid ! {ipv4, self(),  Data1}.
    {ipv4,<0.127.0>,
      <<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,
        101,...>>}
20> flush().
    ok

    %% судя по полученому результату от флэш сообщения были получены