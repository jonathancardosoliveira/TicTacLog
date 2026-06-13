% JOGO DA VELHA EM PROLOG
% Trabalho Pratico - Paradigmas de Programacao (UTFPR - Dois Vizinhos)
% Representacao do tabuleiro: lista de 9 elementos (0=vazio, 1=X, 2=O)


% ESTADO INICIAL DO TABULEIRO
% Fato exigido pelo enunciado: tabuleiro com 9 casas vazias (valor 0).
% A lista representa as posicoes 1 a 9 da esquerda para a direita, linha a linha.

tabuleiro([0,0,0,0,0,0,0,0,0]).

% MAPEAMENTO LINHA/COLUNA -> POSICAO NA LISTA
% Relaciona coordenadas (Linha, Coluna) ao indice Pos na lista do tabuleiro.
% Exemplo: posicao(1, 1, 1) significa linha 1, coluna 1 = posicao 1.
% Obrigatorio usar este fato em ao menos um predicado (usado em jogar/5).

posicao(1, 1, 1).
posicao(1, 2, 2).
posicao(1, 3, 3).
posicao(2, 1, 4).
posicao(2, 2, 5).
posicao(2, 3, 6).
posicao(3, 1, 7).
posicao(3, 2, 8).
posicao(3, 3, 9).

% SIMBOLOS VISUAIS
% Converte o codigo numerico de cada casa no caractere exibido na tela.
% 0 = espaco vazio, 1 = X (Jogador 1), 2 = O (Jogador 2).

simbolo(0, ' ').
simbolo(1, 'X').
simbolo(2, 'O').

% exibir_tabuleiro(Tab)
% Exibe o tabuleiro formatado em grade 3x3 com numeros de linha e coluna.
% Le cada posicao da lista, converte para simbolo.

exibir_tabuleiro(Tab) :-

    % Obtem o valor de cada uma das 9 casas da lista
    nth1(1, Tab, P1), nth1(2, Tab, P2), nth1(3, Tab, P3),
    nth1(4, Tab, P4), nth1(5, Tab, P5), nth1(6, Tab, P6),
    nth1(7, Tab, P7), nth1(8, Tab, P8), nth1(9, Tab, P9),

    % Converte cada valor numerico no simbolo correspondente (X, O ou vazio)
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


% vencedor(Tab, Jog)
% Verifica se o jogador Jog (1 ou 2) venceu com tres pecas iguais em linha.
% Ha 8 clausulas: 3 horizontais, 3 verticais e 2 diagonais.
% Jog \= 0 evita falso positivo com casas vazias.

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

% empate(Tab)
% Verdadeiro quando nao ha casas vazias e nenhum jogador venceu.

empate(Tab) :-
    \+ member(0, Tab),       % tabuleiro cheio (sem zeros)
    \+ vencedor(Tab, 1),     % jogador 1 nao venceu
    \+ vencedor(Tab, 2).     % jogador 2 nao venceu


% jogar(Linha, Coluna, Tab, Jogador, NovoTab)
% Realiza uma jogada valida: converte coordenadas em posicao, verifica se a
% casa esta vazia (0) e gera NovoTab com a peca do Jogador na posicao escolhida.
% Falha se a posicao nao existir ou ja estiver ocupada (jogada invalida).

jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),      % obtem indice na lista a partir de Linha/Coluna
    nth1(Pos, Tab, 0),                % confirma que a casa esta vazia
    substituir(Tab, Pos, Jogador, NovoTab).  % cria novo tabuleiro com a jogada


% substituir/4 (predicado auxiliar)
% Substitui o elemento na Pos-esima posicao da lista pelo valor Novo.
% Caso base: Pos = 1, troca a cabeca da lista.
% Caso recursivo: mantem a cabeca e avanca na cauda decrementando Pos.

substituir([_|T], 1, Novo, [Novo|T]).
substituir([H|T], Pos, Novo, [H|T2]) :-
    Pos > 1,
    Pos1 is Pos - 1,
    substituir(T, Pos1, Novo, T2).


% proximo_jogador/2 (predicado auxiliar)
% Alterna o turno entre Jogador 1 (X) e Jogador 2 (O).

proximo_jogador(1, 2).
proximo_jogador(2, 1).

% nome_jogador/2 (predicado auxiliar)
% Retorna o nome descritivo do jogador para exibicao nas mensagens.

nome_jogador(1, 'Jogador 1 (X)').
nome_jogador(2, 'Jogador 2 (O)').


% rodar(Tab, Jogador, NovoTab)
% Loop principal do jogo: exibe tabuleiro, pede jogada, le entrada do teclado
% e delega o processamento a processar_jogada/4.
% NovoTab recebe o estado final apos vitoria, empate ou encerramento.

rodar(Tab, Jogador, NovoTab) :-
    exibir_tabuleiro(Tab),
    nome_jogador(Jogador, NomeJog),
    format('Vez de ~w~n', [NomeJog]),
    write('Digite sua jogada no formato:  Linha, Coluna.'), nl,
    write('(ou -1, -1. para sair)'), nl,
    write('> '),
    read(Jogada),                              % le tupla (Linha, Coluna) do teclado
    processar_jogada(Jogada, Tab, Jogador, NovoTab).


% processar_jogada/4
% Trata a entrada do jogador em tres situacoes distintas (ordem importa):
%   1) Saida do jogo (-1, -1)
%   2) Jogada valida ou invalida com coordenadas inteiras
%   3) Entrada com formato incorreto


% Caso 1: jogador digita -1, -1. para encerrar o jogo voluntariamente
processar_jogada(((-1), (-1)), _Tab, _Jogador, _NovoTab) :-
    !,  % corte: impede backtracking para outras clausulas
    write('=================================================='), nl,
    write('  Jogo finalizado pelo jogador. Ate a proxima!'), nl,
    write('=================================================='), nl, nl.

% Caso 2a: jogada valida — atualiza tabuleiro e verifica fim de jogo ou proximo turno
processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    jogar(Linha, Coluna, Tab, Jogador, TabTemp),
    !,
    ( vencedor(TabTemp, Jogador) ->
        % Algum jogador formou tres em linha: anuncia vitoria e termina
        nome_jogador(Jogador, NomeVenc),
        write('=================================================='), nl,
        format('  PARABENS! ~w venceu o jogo!~n', [NomeVenc]),
        write('=================================================='), nl, nl,
        NovoTab = TabTemp
    ; empate(TabTemp) ->
        % Tabuleiro cheio sem vencedor: anuncia empate e termina
        write('=================================================='), nl,
        write('  O jogo terminou em EMPATE!'), nl,
        write('=================================================='), nl, nl,
        NovoTab = TabTemp
    ;
        % Jogo continua: passa a vez ao adversario e chama rodar recursivamente
        proximo_jogador(Jogador, Proximo),
        rodar(TabTemp, Proximo, NovoTab)
    ).

% Caso 2b: coordenadas inteiras, mas jogada invalida (posicao inexistente ou ocupada)
processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    !,
    write('--------------------------------------------------'), nl,
    write('  Jogada invalida! Verifique se a posicao existe'), nl,
    write('  ou se a casa ja esta ocupada. Tente novamente.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).  % repete o turno do mesmo jogador

% Caso 3: entrada com formato invalido (nao e tupla de inteiros)
processar_jogada(_, Tab, Jogador, NovoTab) :-
    write('--------------------------------------------------'), nl,
    write('  Entrada invalida! Use o formato: Linha, Coluna.'), nl,
    write('  Exemplo: 2, 3.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).


% iniciar
% Ponto de entrada do programa. Exibe boas-vindas, carrega tabuleiro inicial
% e inicia o loop do jogo com o Jogador 1 (X).
% Para executar: consulte o arquivo e digite "iniciar." no console.

iniciar :-
    nl,
    write('=================================================='), nl,
    write('           BEM-VINDO AO JOGO DA VELHA!           '), nl,
    write('=================================================='), nl,
    write('  Jogador 1 = X    |    Jogador 2 = O'), nl,
    write('  Linhas e colunas numeradas de 1 a 3'), nl,
    write('=================================================='), nl, nl,
    tabuleiro(Tab),    % obtem estado inicial (9 casas vazias)
    rodar(Tab, 1, _).  % comeca com jogador 1; _ ignora tabuleiro final
