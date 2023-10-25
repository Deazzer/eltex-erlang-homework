
Задание 1

Erlang/OTP 26 [erts-14.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

Eshell V14.1 (press Ctrl+G to abort, type help(). for help)
    1> rr("person.hrl").
[person]
    2> Persons=[#person{id=1,name="Bob",age=23,gender=male},#person{id=2,name="Kate",age=20,gender=female},#person{id=3,name="Jack",age=34,gender= male},#person{id=4,name="Nata",age=54,gender=female}].
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
        //создаем переменную с рекордом 
    3> [_,SecondPerson,_,_]=Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
        // Здесь происходит паттерн матчинг с переменной , которая как видно из успешного результата либо не связана либо данные в этой переменной таккие же как и второй тапл в созданном ранее рекорде
    4> SecondPerson.
#person{id = 2,name = "Kate",age = 20,gender = female}
    5> SecondName=SecondPerson#person.name.
"Kate"
    6> SecondAge=SecondPerson#person.age.
20
    7> [_,#person{name=SecondName,age=SecondAge}|_Rest]=Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
    8> SecondName.
"Kate"
    9> SecondAge.
20
        // Здесь снова с помощью паттерн матчинга сравниваем ранеее записанные данные, как видно из результата он прошел успешно, так как данные абсолютно одинаковы, если бы мы выбрали другой тапл то произошла бы ошибка
    10> Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
    11> SecondPerson#person{age=21}.
#person{id = 2,name = "Kate",age = 21,gender = female}
    12> Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
    13> SecondPerson.
#person{id = 2,name = "Kate",age = 20,gender = female}
        // после проверки видим что мписок Persons и SeconPerson не изменились 

Задание 2 

    1> Persons = [#{id=>1,name=>"Bob",age=>23,gender=>male},#{id=>2,name=>"Kate",age=>20,gender=>female},#{id=>3,name=>"Jack",age=>34,gender=>male},#{id=>4,name=>"Nata",age=>54,gender=>female}].
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
        // Создаем Мапу с данными
    2> [FirstPerson|_]=Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
        // Присваиваем с помощью паттерн матчинга Переменной FirstPerson данные 1го тапла в мапе
    3> FirstPerson.
#{id => 1,name => "Bob",age => 23,gender => male}
4> [_,_,#{name:=Name,age:=Age},_]=Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
    5> Name.    
"Jack"
    6> Age.
34
        // Присваиваем значения name/age соответствующим переменным с помощью паттернматчинга в мапе
    7> [_First,_Second,#{name:=Name,age:=Age},_Rest]=Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
    8> Name.
"Jack"
    9> Age.
34
        // Здесь мы делаем практически то же самое только изменив немного синтаксис, а так как переменные связаны с теми же данными мы получаем успешный результат
    10> Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
        // список Persons остался не изменным
    11> FirstPerson#{age:=24}.
#{id => 1,name => "Bob",age => 24,gender => male}
        // Здесь мы выводим новый тапл с изммененным значением age
    12> Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
    13> FirstPerson.
#{id => 1,name => "Bob",age => 23,gender => male}
        // как видим переменные остались не изменными
14> FirstPerson#{address:="Mira 31"}.
** exception error: bad key: address
     in function  maps:update/3
        called as maps:update(address,"Mira 31",
                              #{id => 1,name => "Bob",age => 23,gender => male})
        *** argument 3: not a map
     in call from erl_eval:'-expr/6-fun-0-'/2 (erl_eval.erl, line 311)
     in call from lists:foldl/3 (lists.erl, line 1594)
        // здесь мы получили эксепшен в связи с тем что ключа address в мапе нет

3 Задание 

    2> c("converter.erl").
{ok,converter}
    3> converter:to_rub({usd,100}).
Convert usd to rub, amount 100
{ok,7550.0}
    4> converter:to_rub({pesso,12}).
Convert pesso to rub, amount 12
{ok,36}
    5> converter:to_rub({yene,30}).
Unefined type {yene,30}
{error,badargument}
    6> converter:to_rub({euro,-15}).
Convert euro to rub, amount -15
{ok,-1200}
        // строка с йенами выдает ошибку из за того что у нас нет функции которая конвертирует йены в рубли 