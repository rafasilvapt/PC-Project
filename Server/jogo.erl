-module(jogo).
-export([acao/3,geraJogador/1, gerarBolas/2, inicio/2, jogo/1,string2Atom/1]).


% Estado = { J1, J2, Bolas}
%		   { {Pid1, Px1, Py1 , Tam1}, {Pid2,Px2, Py2, Tam2}, ListaBolas} 

inicio(Pid1, Pid2) ->
	{{Px1, Py1}, Tam1, TamMax1} = {{10,350},20,20},
	{{Px2, Py2}, Tam2,TamMax2} = {{690,350},20,20},

	ListaBolas = gerarBolas(10,[]),
	{ {Pid1, {Px1, Py1}, Tam1,TamMax1}, {Pid2,{Px2, Py2}, Tam2,TamMax2}, ListaBolas }.

	

acao(From, Movimento, Estado) -> %devolve estado
	{ {Pid1, {Px1, Py1}, Tam1,TamMax1}, {Pid2,{Px2, Py2}, Tam2, TamMax2}, ListaBolas } = Estado,

	Min = min(Tam1,Tam2),
	case From of
		Pid1 -> 
			{AuxPx1, AuxPy1} = moveJogador({Px1, Py1}, Movimento,Tam1), %movimentar jogador		
			{{{AuxPx1,AuxPy1},Tam, TamMax1_1}, NovaLista} = capturaBolas(Min,{{AuxPx1, AuxPy1}, Tam1, TamMax1}, ListaBolas), %aplicar a todas as bolas
			
			{{{ReturnPx1, ReturnPy1},ReturnTam1,TamMax1_2} , {{ReturnPx2, ReturnPy2},ReturnTam2,TamMax2_2}} = jogCapturaJog({{AuxPx1,AuxPy1},Tam, TamMax1_1} , {{Px2, Py2},Tam2, TamMax2}); %verificar se come o outro jogador
			
		Pid2 -> 
			{AuxPx2, AuxPy2} = moveJogador({Px2, Py2}, Movimento,Tam2),
			{{{AuxPx2,AuxPy2},Tam, TamMax2_1}, NovaLista} = capturaBolas(Min,{{AuxPx2, AuxPy2}, Tam2, TamMax2}, ListaBolas), %aplicar a todas as bolas
			{{{ReturnPx1,ReturnPy1},ReturnTam1, TamMax1_2} , {{ReturnPx2, ReturnPy2},ReturnTam2, TamMax2_2}} = jogCapturaJog({{Px1,Py1},Tam1, TamMax1} , {{AuxPx2, AuxPy2},Tam, TamMax2_1}) %nao interessa a ordem
	
	end,

	case ReturnTam1 > TamMax1_2 of
		true -> 
			NovoTamMax1 = ReturnTam1;
		false -> 
			NovoTamMax1 = TamMax1_2
	end,

	case ReturnTam2 > TamMax2_2 of
		true -> 
			NovoTamMax2 = ReturnTam2;
		false -> 
			NovoTamMax2 = TamMax2_2
	end,

	Min3 = min(NovoTamMax1,NovoTamMax2),
	case verifBolaMin(Min3,NovaLista) of 
		true ->
			{ {Pid1, {ReturnPx1, ReturnPy1},ReturnTam1,NovoTamMax1}, {Pid2, {ReturnPx2, ReturnPy2}, ReturnTam2, NovoTamMax2}, NovaLista};
		false ->
			NovaBola = {{rand:uniform(700), rand:uniform(700)},rand:uniform(Min3), rand:uniform(1)},
			NovaNovaLista = [NovaBola] ++ NovaLista,
			{ {Pid1, {ReturnPx1, ReturnPy1},ReturnTam1,NovoTamMax1}, {Pid2, {ReturnPx2, ReturnPy2}, ReturnTam2, NovoTamMax2}, NovaNovaLista}
	end.

moveJogador({Px1,Py1},Movimento,Tam) -> %retorna a nova posição do jogador

    case Movimento of
    	direita ->
    		{ somaCoord(Px1,(40/Tam)), Py1};
    	esquerda ->
    		{ somaCoord(Px1,-((40/Tam))), Py1};
    	frente ->
    	    { Px1 , somaCoord(Py1,-((40/Tam)))};
    	tras ->
    	    { Px1 , somaCoord(Py1,(40/Tam))};
		esqfrente ->
    	    { somaCoord(Px1,-((40/Tam))), somaCoord(Py1,-((40/Tam)))};
		esqtras ->
			{ somaCoord(Px1,-((40/Tam))) , somaCoord(Py1,(40/Tam))};
		dirtras ->
			{ somaCoord(Px1,(40/Tam)) , somaCoord(Py1,(40/Tam))};
		dirfrente -> 
			{ somaCoord(Px1,(40/Tam)) , somaCoord(Py1,-((40/Tam)))};
    	_ ->
    	    io:format("Erro: Acao nao reconhecida ~n"),
			{Px1,Py1}
              
  	end.

capturaBolas(_,J1,[]) ->
	{J1,[]};

capturaBolas(Min,J1,[Head|Bolas])->
	{{Px1,Py1},Tam1, TamMax} = J1, 
	{{_, _},Tam2, Tipo} = Head,

	X = jogCapturaBola(J1,Head),
	
	case X of 
		true -> 
			case Tipo of %tipo == 1 (COMIDA) , tipo == 2 (VENENO)
				1 -> 
					J1a = {{Px1,Py1},Tam1+Tam2, TamMax},
					Min2 = Min,
					B = geraRandBola(Min2),
					NovoBolas = [B];
				2 -> 
					TamJ = Tam1-Tam2,
					J1a =  {{Px1,Py1},TamJ, TamMax} , 
					Min2 = min(Min, TamJ),
					B = geraRandBola(Min2),
					NovoBolas = [B]
			end;
		false -> 
			Min2 = Min,
			J1a = {{Px1,Py1},Tam1, TamMax},
			NovoBolas = [Head]
			

	end,

	{J1b, NovaLista} = capturaBolas(Min2,J1a,Bolas),
	{J1b, NovoBolas ++ NovaLista}
.
	


jogCapturaBola({{Px1,Py1},Tam1, _} , {{Px2, Py2},Tam2, _}) -> %recebe ({Px1,Py1,Tam1} , {Px2, Py2,Tam2, Tipo})
	
	Dist = calculaDist( {Px1,Py1} , {Px2,Py2} ),
	Tam1_2 = Tam1/2,
	Tam2_2 = Tam2/2,
    case Tam1_2 >= Dist+Tam2_2 of %o Jog captura a BOLA
		true -> true;
		false -> false
	end.


jogCapturaJog({{Px1,Py1},Tam1, TamMax1} , {{Px2, Py2},Tam2, TamMax2}) -> %retorna tuplo {{{Px1,Py1},Tam1} , {{Px2, Py2},Tam2}}
    Dist = calculaDist({Px1,Py1},{Px2,Py2}),
	Tam1_2 = Tam1/2,
	Tam2_2 = Tam2/2,
    case Tam1_2 >= Tam2_2 of %Jog1 >= Jog2
        true ->
        	case Tam1_2 >= Dist+Tam2_2 of %o 1 captura o 2
				true -> 
					{{{Px1,Py1},Tam1+0.25*Tam2, TamMax1} , geraJogador(TamMax2)};
				false -> 
					{{{Px1,Py1},Tam1, TamMax1} , {{Px2, Py2},Tam2, TamMax2}}
			end;
              
        false ->  %Jog1 < Jog2
        	case Tam2_2 >= Dist+Tam1_2 of %o 2 captura o 1
				true -> 
					J1 = geraJogador(TamMax1),
					{J1, {{Px2,Py2},Tam2+0.25*Tam1, TamMax1}};
				false -> 
					{{{Px1,Py1},Tam1, TamMax1} , {{Px2, Py2},Tam2, TamMax2}}
			end
    end.

calculaDist({Px1,Py1} , {Px2,Py2} ) -> % retorn um float
    X = math:sqrt( math:pow((Px2-Px1),2) + math:pow((Py2-Py1),2) ),
	X.


somaCoord(P,A) -> %recebe a componente da coordenada e qual o aumento, e devolve a componente da coordenada
  case P+A >= 700 of
	  true -> 700;
	  false -> 
		  case P+A =< 0 of 
				  true -> 0;
				  false -> P+A
			   end
	end.

geraRandBola(Tam) -> %recebe o Tam mais pequeno, retorn {Px,Py,Tam}
	TamBola = trunc(Tam),

	Bola = {{rand:uniform(700), rand:uniform(700)},rand:uniform(TamBola), rand:uniform(2)},
	Bola.

verifBolaMin(_, []) -> false;
verifBolaMin ( Valor, [{{_,_},Tam,Tipo} | ListTail ] ) ->
    case ( Tam < Valor ) of
        true    ->  case Tipo of 
						1 -> true;
						2 -> verifBolaMin(Valor, ListTail)
					end;
        false   ->  verifBolaMin(Valor, ListTail)
    end
.

geraJogador(TamMax) -> %devolve {Px,Py, Tam, TamMac}
	{{rand:uniform(700), rand:uniform(700)}, 20, TamMax}.

gerarBolas(0,Lista) -> Lista;
gerarBolas(N,Lista) -> 
	Bola = geraRandBola(20),
	NovaLista = Lista ++ [Bola],
	gerarBolas(N-1,NovaLista).

jogo(Estado)->
    {{Pid1,_,_,Points1},{Pid2,_,_,Points2},_} = Estado,
    Pid1 ! {line,estado2String(Estado)++"\n"},
    Pid2 ! {line,estado2String(Estado)++"\n"},
    receive
        {line,From, Data} ->
            [H|_] = string:split(Data," "),
            case string2Atom(H) of
                esquerda -> NewEstado = acao(From,esquerda,Estado), jogo(NewEstado);
                direita -> NewEstado = acao(From,direita,Estado), jogo(NewEstado);
                frente -> NewEstado = acao(From,frente,Estado), jogo(NewEstado);
                tras -> NewEstado = acao(From,tras,Estado), jogo(NewEstado);
				esqfrente -> NewEstado = acao(From,esqfrente,Estado), jogo(NewEstado);
				esqtras -> NewEstado = acao(From,esqtras,Estado), jogo(NewEstado);
				dirtras -> NewEstado = acao(From,dirtras,Estado), jogo(NewEstado);
				dirfrente -> NewEstado = acao(From,dirfrente,Estado), jogo(NewEstado);
				null -> jogo(Estado)
            end;
        terminar ->
			Pid1 ! {line,"endGame\n"},
			Pid1 ! {prepara, servidor},
			Pid2 ! {line,"endGame\n"},
            Pid2 ! {prepara, servidor},
            case Points1>Points2 of
                true -> servidor ! {endedGame,self(),Pid1,Points1,Pid2,Points2};
                false ->
					case Points1<Points2 of
						true ->  servidor ! {endedGame,self(),Pid2,Points2,Pid1,Points1};
						false ->  servidor ! {endedGame,self(),Pid2,Points2,Pid1,Points1}
					end
            end
    end.

estado2String(Estado)->
    {P1,P2,Bolas} = Estado,
    {Pid,{X,Y},Massa,MaiorMassa} = P1,
    {Pid2,{X2,Y2},Massa2,MaiorMassa2} = P2,
    lists:flatten(io_lib:format("~p ~p ~p ~p ~p ~p ~p ~p ~p ~p ",[Pid,X,Y,Massa,MaiorMassa,Pid2,X2,Y2,Massa2,MaiorMassa2]))++bolas2String(Bolas).

bolas2String([]) -> "";
bolas2String([H|T]) ->
    {{X,Y},Massa,Tipo} = H,
    lists:flatten(io_lib:format("~p ~p ~p ~p ",[X,Y,Massa,Tipo]))++bolas2String(T).

string2Atom(String) ->
    case string:equal(String,"create") of
        true -> create;
        false ->
            case string:equal(String,"login") of
                true -> login;
                false ->
                    case string:equal(String,"close") of
                        true -> close;
                        false ->
                            case string:equal(String,"play") of
                                true -> play;
                                false ->
                                    case string:equal(String,"logout") of
                                        true -> logout;
                                        false ->
											case string:equal(String,"getScore") of
												true -> getScore;
												false ->
													case string:equal(String,"esquerda") of
														true -> esquerda;
														false ->
															case string:equal(String,"direita") of
																true -> direita;
																false ->
																	case string:equal(String,"frente") of
																		true -> frente;
																		false ->
																			case string:equal(String,"tras") of
																				true -> tras;
																				false ->
																					case string:equal(String,"esqfrente") of
																						true -> esqfrente;
																						false ->
																							case string:equal(String,"esqtras") of
																								true -> esqtras;
																								false ->
																									case string:equal(String,"dirtras") of
																										true -> dirtras;
																										false -> 
																											case string:equal(String,"dirfrente") of
																												true -> dirfrente;
																												false -> null
																											end
																									end
																							end
																					end
																			end
																	end
															end
													end
											end
                                    end
                            end
                    end
            end
    end.
