%% Задание 1

    6> l(recursion).
{module,recursion}
    7> Fac= fun recursion:tail_fac/1.
fun recursion:tail_fac/1
    8> Dup= fun recursion:tail_duplicate/1.
fun recursion:tail_duplicate/1
    9> Fac(10).
3628800
    10> Dup([1,2,3,4,5]).
[1,1,2,2,3,3,4,4,5,5]
        %% здесь мы создаем? так называемые алиасы? как видно выше все прекрасно работает

%% Задание 2

    2> ToRub=fun({usd,Amount}) -> {ok,Amount*75.5};({euro,Amount}) ->{ok,Amount*80};({peso,Amount}) -> {ok,Amount*3};({lari,Amount}) -> {ok,Amount*29};({krone,Amount}) -> {ok,Amount*10};(Error) -> {error,badarg} end.
#Fun<erl_eval.42.105768164>
    3> ToRub({usd,100}).
{ok,7550.0}
    4> ToRub({peso,12}).
{ok,36}
    5> ToRub({yene,30}).
{error,badarg}
    6> ToRub({euro,-15}).
{ok,-1200}   %% на этом моменте я понял что заблы добавить проверку на положительные значения, поэтому я добавил проверку в функцию удвоения ниже

    7> Double = fun(X) when X > 0 -> X*2 end.
#Fun<erl_eval.42.105768164>
    8> Double(10).
20
    9> Double(-10).
** exception error: no function clause matching erl_eval:'-inside-an-interpreted-fun-'(-10) 

%% Задание 3

    3> Pesrons=[#person{id=1,name="Bob",age=23,gender=male},#person{id=2,name="Kate",age=20,gender=female},#person{id=3,name="Jack",age=34,gender=male},#person{id=4,name="Nata",age=54,gender=female}].
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
    4> person:filter(fun(#person{age=Age}) -> Age >=30 end,Pesrons).
[#person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
    5> MalePersons = person:filter(fun(#person{gender=Gender}) -> Gender =:= male end,Pesrons).
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 3,name = "Jack",age = 34,gender = male}]
    6> AnyFemale= person:any(fun(#person{gender=Fgender})-> Fgender =:= female end, Pesrons).
true
    7> OlderTwenty = person:all(fun(#person{age=AgeOTw})-> AgeOTw >= 20 end, Pesrons).
true
    8> OlderThirty = person:all(fun(#person{age=AgeOTh})-> AgeOTh >= 30 end, Pesrons).
false
    9> UpdateJackAge=fun(#person{name="Jack",age=Age}=Person) -> Person#person{age=Age+1};(Person)->Person end.
#Fun<erl_eval.42.105768164>
    10> UpdatedPerson= person:update(UpdateJackAge, Pesrons).
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 35,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
        %% здесь мы создали рекорд затем с помощью молуля person проихводили различную фильтрацию данного рекорда

 %% Задание 4

    1> c("exceptions.erl").
{ok,exceptions}
    2> exceptions:catch_all(fun()->1/0 end).
Action #Fun<erl_eval.43.105768164> failed, reason badarith
error
    3> exceptions:catch_all(fun() -> throw(custom_exceptions) end).
Action #Fun<erl_eval.43.105768164> failed, reason custom_exceptions
throw
    4> exceptions:catch_all(fun() -> exit(killed) end).
Action #Fun<erl_eval.43.105768164> failed, reason killed
exit
    5> exceptions:catch_all(fun() -> erlang:error(runtime_exception) end).
Action #Fun<erl_eval.43.105768164> failed, reason runtime_exception
error

        %% здесь мы выводим различного типа эксепшены