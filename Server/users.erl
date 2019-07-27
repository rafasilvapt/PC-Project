-module(users).
-export([startUsers/0,createAccount/2,removeAccount/1,loginAccount/2,registePoints/2,getScore/1]).
startUsers() ->
    register(users, spawn(fun() -> loop(#{}) end))
.
%Map = {Username => {Passw,[Pontos]}, sonia => {"abc",[10,0,0]}} array contem os 3 melhores jogos
loop(Map) ->
    receive
        {create,Username,Passw,From} ->
            case maps:is_key(Username,Map) of
                true -> From ! {users,user_exists}, loop(Map);
                false -> Map1 = maps:put(Username,{Passw,[0,0,0]},Map), From ! {users,ok}, loop(Map1)
            end;
        {remove,Username,From} ->
            case maps:is_key(Username,Map) of
                true -> Map1 = maps:remove(Username,Map), From ! {users,ok}, loop(Map1);
                false -> From ! {users,account_invalid}, loop(Map)
            end;
        {login,Username,Passw,From} ->
            case maps:is_key(Username,Map) of
                true ->
                    {Pass,_} = maps:get(Username,Map),
                    case Pass == Passw of
                        true -> From ! {users,ok}, loop(Map);
                        false -> From ! {users,invalid_passw}, loop(Map)
                    end;
                false -> From ! {users,invalid_account},loop(Map)
            end;
        {getScore,Username,From} ->
            {_,Score} = maps:get(Username,Map),
            From ! {users,Score}, loop(Map);
        {registe,Username,Points,From} ->
            case maps:is_key(Username,Map) of
                true ->
                    Points1 = [Points],
                    {Passw,Lista} = maps:get(Username,Map),
                    NewLista = lists:sublist(lists:reverse(lists:sort(lists:append(Lista,Points1))),3),
                    Map1 = maps:update(Username,{Passw,NewLista},Map),
                    From ! {users,ok},
                    loop(Map1);
                false -> From ! {users,invalid_account}, loop(Map)
            end
    end.
%Interface Functions
createAccount(Username, Passw) ->
    users ! {create,Username,Passw,self()},
    receive
        {users,M} -> M
    end.
removeAccount(Username) ->
    users ! {remove,Username,self()},
    receive
        {users,M} -> M
    end.
loginAccount(Username,Passw) ->
    users ! {login,Username,Passw,self()},
    receive
        {users, M} -> M
    end.
registePoints(Username,Points) ->
    users ! {registe,Username,Points,self()},
    receive
        {users,M} -> M
    end.
getScore(Username)->
    users ! {getScore, Username,self()},
    receive
        {users,M} -> M
    end.
