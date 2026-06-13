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

exibir_tabuleiro(Tab) :-
    nth1(1, Tab, P1), nth1(2, Tab, P2), nth1(3, Tab, P3),
    nth1(4, Tab, P4), nth1(5, Tab, P5), nth1(6, Tab, P6),
    nth1(7, Tab, P7), nth1(8, Tab, P8), nth1(9, Tab, P9),
    simbolo(P1, S1), simbolo(P2, S2), simbolo(P3, S3),
    simbolo(P4, S4), simbolo(P5, S5), simbolo(P6, S6),
    simbolo(P7, S7), simbolo(P8, S8), simbolo(P9, S9),
    nl,
    write('     1   2   3'), nl,
    write('   +---+---+---+'), nl,
    format(' 1 | ~w | ~w | ~w |~n', [S1, S2, S3]),
    write('   +---+---+---+'), nl,
    format(' 2 | ~w | ~w | ~w |~n', [S4, S5, S6]),
    write('   +---+---+---+'), nl,
    format(' 3 | ~w | ~w | ~w |~n', [S7, S8, S9]),
    write('   +---+---+---+'), nl, nl.

vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(1, Tab, Jog), nth1(2, Tab, Jog), nth1(3, Tab, Jog).
vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(4, Tab, Jog), nth1(5, Tab, Jog), nth1(6, Tab, Jog).
vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(7, Tab, Jog), nth1(8, Tab, Jog), nth1(9, Tab, Jog).

vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(1, Tab, Jog), nth1(4, Tab, Jog), nth1(7, Tab, Jog).
vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(2, Tab, Jog), nth1(5, Tab, Jog), nth1(8, Tab, Jog).
vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(3, Tab, Jog), nth1(6, Tab, Jog), nth1(9, Tab, Jog).

vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(1, Tab, Jog), nth1(5, Tab, Jog), nth1(9, Tab, Jog).
vencedor(Tab, Jog) :-
    Jog \= 0,
    nth1(3, Tab, Jog), nth1(5, Tab, Jog), nth1(7, Tab, Jog).

empate(Tab) :-
    \+ member(0, Tab),
    \+ vencedor(Tab, 1),
    \+ vencedor(Tab, 2).

jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),
    nth1(Pos, Tab, 0),
    substituir(Tab, Pos, Jogador, NovoTab).

substituir([_|T], 1, Novo, [Novo|T]).
substituir([H|T], Pos, Novo, [H|T2]) :-
    Pos > 1,
    Pos1 is Pos - 1,
    substituir(T, Pos1, Novo, T2).

proximo_jogador(1, 2).
proximo_jogador(2, 1).

nome_jogador(1, 'Jogador 1 (X)').
nome_jogador(2, 'Jogador 2 (O)').

rodar(Tab, Jogador, NovoTab) :-
    exibir_tabuleiro(Tab),
    nome_jogador(Jogador, NomeJog),
    format('Vez de ~w~n', [NomeJog]),
    write('Digite sua jogada no formato:  Linha, Coluna.'), nl,
    write('(ou -1, -1. para sair)'), nl,
    write('> '),
    read(Jogada),
    processar_jogada(Jogada, Tab, Jogador, NovoTab).

processar_jogada(((-1), (-1)), _Tab, _Jogador, _NovoTab) :-
    !,
    write('=================================================='), nl,
    write('  Jogo finalizado pelo jogador. Ate a proxima!'), nl,
    write('=================================================='), nl, nl.

processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    jogar(Linha, Coluna, Tab, Jogador, TabTemp),
    !,
    exibir_tabuleiro(TabTemp),
    ( vencedor(TabTemp, Jogador) ->
        nome_jogador(Jogador, NomeVenc),
        write('=================================================='), nl,
        format('  PARABENS! ~w venceu o jogo!~n', [NomeVenc]),
        write('=================================================='), nl, nl,
        NovoTab = TabTemp
    ; empate(TabTemp) ->
        write('=================================================='), nl,
        write('  O jogo terminou em EMPATE!'), nl,
        write('=================================================='), nl, nl,
        NovoTab = TabTemp
    ;
        proximo_jogador(Jogador, Proximo),
        rodar(TabTemp, Proximo, NovoTab)
    ).

processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    !,
    write('--------------------------------------------------'), nl,
    write('  Jogada invalida! Verifique se a posicao existe'), nl,
    write('  ou se a casa ja esta ocupada. Tente novamente.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).

processar_jogada(_, Tab, Jogador, NovoTab) :-
    write('--------------------------------------------------'), nl,
    write('  Entrada invalida! Use o formato: Linha, Coluna.'), nl,
    write('  Exemplo: 2, 3.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).

iniciar :-
    nl,
    write('=================================================='), nl,
    write('           BEM-VINDO AO JOGO DA VELHA!           '), nl,
    write('=================================================='), nl,
    write('  Jogador 1 = X    |    Jogador 2 = O'), nl,
    write('  Linhas e colunas numeradas de 1 a 3'), nl,
    write('=================================================='), nl, nl,
    tabuleiro(Tab),
    rodar(Tab, 1, _).