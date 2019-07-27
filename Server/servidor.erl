-module(servidor).
-export([start/0]).
-import(users,[startUsers/0,createAccount/2,removeAccount/1,loginAccount/2,registePoints/2,getScore/1]).
-import(jogo,[jogo/1,inicio/2,string2Atom/1]).
start() ->
    startUsers(),
    register(servidor,spawn(fun() -> servidor([],[],[]) end)),
    register(pidsnames,spawn(fun() -> pidsAndNames(#{}) end)),
    server(12345).

server(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
    acceptor(LSock, servidor).

acceptor(LSock, Room) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> acceptor(LSock, Room) end),
    user(Sock, Room).

user(Sock, Room) ->
    receive
        {prepara, NovoRoom} ->
            user(Sock,NovoRoom);
        {line, Data} ->
            gen_tcp:send(Sock, Data),
            user(Sock, Room);
        {tcp, _, Data} ->
            Room ! {line, self(), Data},
            user(Sock, Room);
        {tcp_closed, _} ->
            Room ! {leave, self()};
        {tcp_error, _, _} ->
            Room ! {leave, self()}
    end.

servidor(Jogos,UsersWaiting,UsersON) ->
    io:fwrite("Users online: ~w~n",[length(UsersON)+length(UsersWaiting)]),
    receive
        {leave,From} -> servidor(Jogos,UsersWaiting--[From],UsersON--[From]);
        {line, From, Data} ->
            [Accao | Info] = string:split(Data," ",all),
            Accao2 = string2Atom(Accao),
            case Accao2 of
                create ->
                    [UserName|Passw] = Info,
                    case createAccount(UserName,Passw) of
                        ok -> From ! {line,"ok\n"}, pidsnames ! {add,From,UserName}, servidor(Jogos,UsersWaiting,[From|UsersON]);
                        user_exists -> From ! {line,"error\n"},servidor(Jogos,UsersWaiting,UsersON)
                    end;
                login ->
                    [UserName|Passw] = Info,
                    case loginAccount(UserName,Passw) of
                        ok -> From ! {line,"ok\n"}, pidsnames ! {add,From,UserName}, servidor(Jogos,UsersWaiting,[From|UsersON]);
                        invalid_account ->  From ! {line,"error\n"}, servidor(Jogos,UsersWaiting,UsersON);
                        invalid_passw ->  From ! {line,"error\n"}, servidor(Jogos,UsersWaiting,UsersON)
                    end;
                logout ->
                    pidsnames ! {remove,From}, From ! {line,"ok\n"}, servidor(Jogos,UsersWaiting--[From],UsersON--[From]);
                close ->
                    UserName = getName(From),
                    case removeAccount(UserName) of
                        ok -> From ! {line,"ok\n"}, pidsnames ! {remove,From}, servidor(Jogos,UsersWaiting--[From],UsersON--[From]);
                        account_invalid -> From ! {line,"error\n"}, servidor(Jogos,UsersWaiting,UsersON)
                    end;
                play ->
                    case length(UsersWaiting)>=1 of
                        true ->
                            [H|T] = UsersWaiting,
                            Estado = inicio(From,H),
                            H ! {line, "startGame 2\n"},
                            io:fwrite("startGame 2\n"),
                            From ! {line, "startGame 1\n"},
                            io:fwrite("startGame 1\n"),
                            Jogo = spawn(fun()-> jogo(Estado) end),
                            spawn(fun()-> timer(Jogo)end),
                            From ! {prepara, Jogo},
                            H ! {prepara, Jogo},

                            servidor([Jogo | Jogos], T, UsersON--[From]);
                        false -> servidor(Jogos,[From|UsersWaiting],UsersON--[From])
                    end;
                getScore ->
                    UserName = getName(From),
                    Score = getScore(UserName),
                    From ! {line ,score2String(Score) ++ "\n"},
                    servidor(Jogos,UsersWaiting,UsersON);
                _ -> servidor(Jogos,UsersWaiting,UsersON)
            end;
        {endedGame,PidJogo,PidWinner,WinnerPoints,PidLoser,LoserPoints} ->
            WinnerName = getName(PidWinner),
            LoserName = getName(PidLoser),
            registePoints(WinnerName,WinnerPoints),
            registePoints(LoserName,LoserPoints),
            servidor(Jogos--[PidJogo],UsersWaiting,[PidWinner]++[PidLoser]++UsersON)
    end
.
getName(Pid) ->
    pidsnames ! {get,self(),Pid},
    receive
        Msg -> Msg
    end.

timer(Pid)->
    receive
        after 120000 -> Pid ! terminar
    end.

pidsAndNames(Map) ->
    receive
        {add,From,Name} -> pidsAndNames(maps:put(From,Name,Map));
        {get,From,Pid} -> From ! maps:get(Pid,Map), pidsAndNames(Map);
        {remove,From} -> pidsAndNames(maps:remove(From,Map))
    end.

score2String([]) -> "";
score2String([H|T]) ->
     lists:flatten(io_lib:format("~p ",[H]))++score2String(T).