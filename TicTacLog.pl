% ==================================================
%           TABULEIRO E CONFIGURACOES INICIAIS
% ==================================================
:- dynamic modo_jogo/1. % Permite que o modo de jogo seja definido em tempo de execucao

tabuleiro([0,0,0,0,0,0,0,0,0]).

posicao(1, 1, 1).
posicao(1, 2, 2).
posicao(1, 3, 3).
posicao(2, 1, 4).
posicao(2, 2, 5).
posicao(2, 3, 6).
posicao(3, 1, 7).
posicao(3, 2, 8).
posicao(3, 3, 9).

simbolo(0, ' ').
simbolo(1, 'X').
simbolo(2, 'O').

nome_jogador(1, 'Jogador 1 (X)').
nome_jogador(2, Nome) :-
    modo_jogo(ia) -> Nome = 'IA (O)' ; Nome = 'Jogador 2 (O)'.

proximo_jogador(1, 2).
proximo_jogador(2, 1).

% ==================================================
%           LOGICA DO JOGO (REGRAS)
% ==================================================
exibir_tabuleiro(Tab) :-
    nth1(1, Tab, P1), nth1(2, Tab, P2), nth1(3, Tab, P3),
    nth1(4, Tab, P4), nth1(5, Tab, P5), nth1(6, Tab, P6),
    nth1(7, Tab, P7), nth1(8, Tab, P8), nth1(9, Tab, P9),
    simbolo(P1, S1), simbolo(P2, S2), simbolo(P3, S3),
    simbolo(P4, S4), simbolo(P5, S5), simbolo(P6, S6),
    simbolo(P7, S7), simbolo(P8, S8), simbolo(P9, S9),
    nl, write('     1   2   3'), nl, write('   +---+---+---+'), nl,
    format(' 1 | ~w | ~w | ~w |~n', [S1, S2, S3]), write('   +---+---+---+'), nl,
    format(' 2 | ~w | ~w | ~w |~n', [S4, S5, S6]), write('   +---+---+---+'), nl,
    format(' 3 | ~w | ~w | ~w |~n', [S7, S8, S9]), write('   +---+---+---+'), nl, nl.

vencedor(Tab, Jog) :- Jog \= 0, (
    (nth1(1, Tab, Jog), nth1(2, Tab, Jog), nth1(3, Tab, Jog));
    (nth1(4, Tab, Jog), nth1(5, Tab, Jog), nth1(6, Tab, Jog));
    (nth1(7, Tab, Jog), nth1(8, Tab, Jog), nth1(9, Tab, Jog));
    (nth1(1, Tab, Jog), nth1(4, Tab, Jog), nth1(7, Tab, Jog));
    (nth1(2, Tab, Jog), nth1(5, Tab, Jog), nth1(8, Tab, Jog));
    (nth1(3, Tab, Jog), nth1(6, Tab, Jog), nth1(9, Tab, Jog));
    (nth1(1, Tab, Jog), nth1(5, Tab, Jog), nth1(9, Tab, Jog));
    (nth1(3, Tab, Jog), nth1(5, Tab, Jog), nth1(7, Tab, Jog))
).

empate(Tab) :- \+ member(0, Tab), \+ vencedor(Tab, 1), \+ vencedor(Tab, 2).

substituir([_|T], 1, Novo, [Novo|T]).
substituir([H|T], Pos, Novo, [H|T2]) :- Pos > 1, Pos1 is Pos - 1, substituir(T, Pos1, Novo, T2).

jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),
    nth1(Pos, Tab, 0),
    substituir(Tab, Pos, Jogador, NovoTab).

% ==================================================
%           INTELIGENCIA ARTIFICIAL (MINIMAX)
% ==================================================
melhor_jogada(Tab, Jogador, L, C) :-
    findall(V-Lin-Col, (
        posicao(Lin, Col, Pos),
        nth1(Pos, Tab, 0),
        substituir(Tab, Pos, Jogador, NTab),
        valor_minimax(NTab, Jogador, 0, false, V)
    ), Jogadas),
    sort(0, @>=, Jogadas, [_-L-C|_]).

valor_minimax(Tab, JogIA, Prof, _, Val) :- vencedor(Tab, JogIA), !, Val is 10 - Prof.
valor_minimax(Tab, JogIA, Prof, _, Val) :- proximo_jogador(JogIA, Op), vencedor(Tab, Op), !, Val is Prof - 10.
valor_minimax(Tab, _, _, _, 0) :- empate(Tab), !.

valor_minimax(Tab, JogIA, Prof, true, Val) :-
    Prof1 is Prof + 1,
    findall(V, (posicao(_,_,P), nth1(P,Tab,0), substituir(Tab,P,JogIA,NT), valor_minimax(NT,JogIA,Prof1,false,V)), Valores),
    max_lista(Valores, Val).

valor_minimax(Tab, JogIA, Prof, false, Val) :-
    Prof1 is Prof + 1,
    proximo_jogador(JogIA, Op),
    findall(V, (posicao(_,_,P), nth1(P,Tab,0), substituir(Tab,P,Op,NT), valor_minimax(NT,JogIA,Prof1,true,V)), Valores),
    min_lista(Valores, Val).

max_lista([H|T], Max) :- max_lista(T, H, Max).
max_lista([], M, M).
max_lista([H|T], Acc, M) :- (H > Acc -> N = H ; N = Acc), max_lista(T, N, M).

min_lista([H|T], Min) :- min_lista(T, H, Min).
min_lista([], M, M).
min_lista([H|T], Acc, M) :- (H < Acc -> N = H ; N = Acc), min_lista(T, N, M).

% ==================================================
%           LOOP PRINCIPAL E PROCESSAMENTO
% ==================================================
iniciar :-
    nl,
    write('=================================================='), nl,
    write('           BEM-VINDO AO JOGO DA VELHA!           '), nl,
    write('=================================================='), nl,
    write('Escolha o modo de jogo:'), nl,
    write('1. Pessoa vs Pessoa'), nl,
    write('2. Pessoa vs IA'), nl,
    write('> '),
    read(Opcao),
    definir_modo(Opcao).

definir_modo(1) :-
    retractall(modo_jogo(_)), assert(modo_jogo(pessoa)),
    write('Modo Pessoa vs Pessoa selecionado!'), nl, iniciar_partida.
definir_modo(2) :-
    retractall(modo_jogo(_)), assert(modo_jogo(ia)),
    write('Modo Pessoa vs IA selecionado!'), nl, iniciar_partida.
definir_modo(_) :-
    write('Opção invalida. Tente novamente.'), nl, iniciar.

iniciar_partida :-
    nl,
    write('  Jogador 1 = X    |    Jogador 2 = O'), nl,
    write('  Linhas e colunas numeradas de 1 a 3'), nl,
    write('=================================================='), nl, nl,
    tabuleiro(Tab),
    rodar(Tab, 1, _).

rodar(Tab, Jogador, NovoTab) :-
    exibir_tabuleiro(Tab),
    nome_jogador(Jogador, NomeJog),
    format('Vez de ~w~n', [NomeJog]),
    (   (Jogador = 2, modo_jogo(ia)) -> % Só entra aqui se for Jogador 2 E modo IA
        write('IA esta pensando...'), nl,
        melhor_jogada(Tab, Jogador, Linha, Coluna),
        format('IA jogou em ~w, ~w~n', [Linha, Coluna]),
        processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab)
    ;
        write('Digite sua jogada no formato:  Linha, Coluna.'), nl,
        write('(ou -1, -1. para sair)'), nl,
        write('> '),
        ler_jogada(Jogada),
        processar_jogada(Jogada, Tab, Jogador, NovoTab)
    ).

ler_jogada(Jogada) :-
    catch(read(Termo), error(syntax_error(_), _), Termo = entrada_invalida),
    ( var(Termo) -> Jogada = entrada_invalida ; Jogada = Termo ).

% --- PREDICADO PROCESSAR_JOGADA ---
processar_jogada((L, C), _Tab, _Jogador, _NovoTab) :-
    L == -1, C == -1,
    !,
    write('=================================================='), nl,
    write('  Jogo finalizado pelo jogador. Ate a proxima!'), nl,
    write('=================================================='), nl, nl.

% 2. Jogada valida (deve ser inteiro e a posicao deve estar livre)
processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    jogar(Linha, Coluna, Tab, Jogador, TabTemp),
    !,
    ( vencedor(TabTemp, Jogador) ->
        nome_jogador(Jogador, NomeVenc),
        exibir_tabuleiro(TabTemp),
        write('=================================================='), nl,
        format('  PARABENS! ~w venceu o jogo!~n', [NomeVenc]),
        write('=================================================='), nl, nl,
        NovoTab = TabTemp
    ; empate(TabTemp) ->
        exibir_tabuleiro(TabTemp),
        write('=================================================='), nl,
        write('  O jogo terminou em EMPATE!'), nl,
        write('=================================================='), nl, nl,
        NovoTab = TabTemp
    ;
        proximo_jogador(Jogador, Proximo),
        rodar(TabTemp, Proximo, NovoTab)
    ).

% 3. Jogada invalida (so inteiros, mas a posicao ocupada ou fora do
% tabuleiro)
processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    !,
    write('--------------------------------------------------'), nl,
    write('  Jogada invalida! Verifique se a posicao existe'), nl,
    write('  ou se a casa ja esta ocupada. Tente novamente.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).

% 4. Entrada invalida generica (qualquer coisa que nao seja o par de
% inteiros (L, C))
processar_jogada(_, Tab, Jogador, NovoTab) :-
    write('--------------------------------------------------'), nl,
    write('  Entrada invalida! Use o formato: Linha, Coluna.'), nl,
    write('  Exemplo: 1, 2.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).
