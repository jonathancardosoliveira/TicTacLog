% JOGO DA VELHA EM PROLOG (com IA Minimax)
% Trabalho Pratico - Paradigmas de Programacao (UTFPR - Dois Vizinhos)
% Representacao do tabuleiro: lista de 9 elementos (0=vazio, 1=X, 2=O)

%           TABULEIRO E CONFIGURACOES INICIAIS

% modo_jogo/1 (dinamico): guarda o modo escolhido pelo usuario em tempo de execucao.
% Valores: pessoa (dois jogadores humanos) ou ia (humano vs computador).
:- dynamic modo_jogo/1.

% tabuleiro/1: estado inicial exigido pelo enunciado, 9 casas vazias (valor 0).
% A lista representa posicoes 1 a 9, da esquerda para a direita, linha a linha.
tabuleiro([0,0,0,0,0,0,0,0,0]).

% posicao/3: mapeia coordenadas (Linha, Coluna) para o indice Pos na lista.
% Exemplo: posicao(1, 1, 1) = linha 1, coluna 1 corresponde a posicao 1.
% Usado em jogar/5 e na IA para converter coordenadas em indice.
posicao(1, 1, 1).
posicao(1, 2, 2).
posicao(1, 3, 3).
posicao(2, 1, 4).
posicao(2, 2, 5).
posicao(2, 3, 6).
posicao(3, 1, 7).
posicao(3, 2, 8).
posicao(3, 3, 9).

% simbolo/2: converte codigo numerico da casa no caractere exibido na tela.
% 0 = vazio, 1 = X (Jogador 1), 2 = O (Jogador 2 ou IA).
simbolo(0, ' ').
simbolo(1, 'X').
simbolo(2, 'O').



% nome_jogador/2: retorna nome descritivo do jogador para mensagens na tela.
% No modo ia, o jogador 2 aparece como "IA (O)" em vez de "Jogador 2 (O)".
nome_jogador(1, 'Jogador 1 (X)').
nome_jogador(2, Nome) :-
    modo_jogo(ia) -> Nome = 'IA (O)' ; Nome = 'Jogador 2 (O)'.



% proximo_jogador/2: alterna o turno entre Jogador 1 (X) e Jogador 2 (O/IA).
proximo_jogador(1, 2).
proximo_jogador(2, 1).



%           LOGICA DO JOGO (REGRAS)

% exibir_tabuleiro/1: imprime o tabuleiro 3x3 com bordas e numeros de referencia.
% Le cada posicao da lista, converte para simbolo (X, O ou vazio) e formata a grade.
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

% vencedor/2: verifica se o jogador Jog (1 ou 2) venceu com tres pecas em linha.
% Testa 8 combinacoes: 3 horizontais, 3 verticais e 2 diagonais.
% Jog \= 0 evita considerar casas vazias como vitoria.
vencedor(Tab, Jog) :- Jog \= 0, (
    (nth1(1, Tab, Jog), nth1(2, Tab, Jog), nth1(3, Tab, Jog));  % linha 1
    (nth1(4, Tab, Jog), nth1(5, Tab, Jog), nth1(6, Tab, Jog));  % linha 2
    (nth1(7, Tab, Jog), nth1(8, Tab, Jog), nth1(9, Tab, Jog));  % linha 3
    (nth1(1, Tab, Jog), nth1(4, Tab, Jog), nth1(7, Tab, Jog));  % coluna 1
    (nth1(2, Tab, Jog), nth1(5, Tab, Jog), nth1(8, Tab, Jog));  % coluna 2
    (nth1(3, Tab, Jog), nth1(6, Tab, Jog), nth1(9, Tab, Jog));  % coluna 3
    (nth1(1, Tab, Jog), nth1(5, Tab, Jog), nth1(9, Tab, Jog));  % diagonal \
    (nth1(3, Tab, Jog), nth1(5, Tab, Jog), nth1(7, Tab, Jog))   % diagonal /
).

% empate/1: verdadeiro quando o tabuleiro esta cheio e ninguem venceu.
empate(Tab) :- \+ member(0, Tab), \+ vencedor(Tab, 1), \+ vencedor(Tab, 2).

% substituir/4: substitui o elemento na Pos-esima posicao da lista pelo valor Novo.
% Caso base (Pos=1): troca a cabeca. Recursivo: mantem cabeca e avanca na cauda.
substituir([_|T], 1, Novo, [Novo|T]).
substituir([H|T], Pos, Novo, [H|T2]) :- Pos > 1, Pos1 is Pos - 1, substituir(T, Pos1, Novo, T2).

% jogar/5: aplica uma jogada valida e retorna NovoTab com o estado atualizado.
% Falha se a posicao nao existir ou a casa ja estiver ocupada (jogada invalida).
jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),           % converte Linha/Coluna em indice
    nth1(Pos, Tab, 0),                     % confirma que a casa esta vazia
    substituir(Tab, Pos, Jogador, NovoTab). % grava a peca do jogador




%           INTELIGENCIA ARTIFICIAL (MINIMAX)

% melhor_jogada/4: escolhe a melhor jogada (L, C) para a IA usando Minimax.
% Avalia todas as casas vazias, calcula pontuacao de cada uma e escolhe a maior.
melhor_jogada(Tab, Jogador, L, C) :-
    findall(V-Lin-Col, (
        posicao(Lin, Col, Pos),
        nth1(Pos, Tab, 0),
        substituir(Tab, Pos, Jogador, NTab),
        valor_minimax(NTab, Jogador, 0, false, V)
    ), Jogadas),
    sort(0, @>=, Jogadas, [_-L-C|_]).  % ordena decrescente e pega a melhor

% valor_minimax/5: calcula pontuacao de um estado para a IA (algoritmo Minimax).
% Tab = tabuleiro atual, JogIA = jogador da IA, Prof = profundidade da arvore,
% terceiro arg. = true (maximiza) ou false (minimiza), Val = pontuacao resultante.
% +10-Prof se IA vence, Prof-10 se oponente vence, 0 se empate.

valor_minimax(Tab, JogIA, Prof, _, Val) :- vencedor(Tab, JogIA), !, Val is 10 - Prof.
valor_minimax(Tab, JogIA, Prof, _, Val) :- proximo_jogador(JogIA, Op), vencedor(Tab, Op), !, Val is Prof - 10.
valor_minimax(Tab, _, _, _, 0) :- empate(Tab), !.

% No da IA (maximizador): simula jogadas da IA e retorna o maior valor possivel
valor_minimax(Tab, JogIA, Prof, true, Val) :-
    Prof1 is Prof + 1,
    findall(V, (posicao(_,_,P), nth1(P,Tab,0), substituir(Tab,P,JogIA,NT), valor_minimax(NT,JogIA,Prof1,false,V)), Valores),
    max_lista(Valores, Val).

% No do oponente (minimizador): simula jogadas do adversario e retorna o menor valor
valor_minimax(Tab, JogIA, Prof, false, Val) :-
    Prof1 is Prof + 1,
    proximo_jogador(JogIA, Op),
    findall(V, (posicao(_,_,P), nth1(P,Tab,0), substituir(Tab,P,Op,NT), valor_minimax(NT,JogIA,Prof1,true,V)), Valores),
    min_lista(Valores, Val).

% max_lista/2: retorna o maior valor de uma lista (auxiliar do Minimax).
max_lista([H|T], Max) :- max_lista(T, H, Max).
max_lista([], M, M).
max_lista([H|T], Acc, M) :- (H > Acc -> N = H ; N = Acc), max_lista(T, N, M).

% min_lista/2: retorna o menor valor de uma lista (auxiliar do Minimax).
min_lista([H|T], Min) :- min_lista(T, H, Min).
min_lista([], M, M).
min_lista([H|T], Acc, M) :- (H < Acc -> N = H ; N = Acc), min_lista(T, N, M).



%           LOOP PRINCIPAL E PROCESSAMENTO

% iniciar/0: ponto de entrada, exibe menu e le opcao de modo de jogo.
iniciar :-
    nl,
    write('=================================================='), nl,
    write('           BEM-VINDO AO JOGO DA VELHA!           '), nl,
    write('=================================================='), nl,
    write('Escolha o modo de jogo:'), nl,
    write('1. Pessoa vs Pessoa'), nl,
    write('2. Pessoa vs IA (impossivel ganhar T.T)'), nl,
    write('> '),
    read(Opcao),
    definir_modo(Opcao).

% definir_modo/1: configura modo_jogo/1 e inicia a partida.
% retractall/1 apaga modo anterior; assert/1 grava o novo modo escolhido.
definir_modo(1) :-
    retractall(modo_jogo(_)), assert(modo_jogo(pessoa)),
    write('Modo Pessoa vs Pessoa selecionado!'), nl, iniciar_partida.
definir_modo(2) :-
    retractall(modo_jogo(_)), assert(modo_jogo(ia)),
    write('Modo Pessoa vs IA selecionado!'), nl, iniciar_partida.
definir_modo(_) :-
    write('Escolha invalida. Tente novamente.'), nl, iniciar.

% iniciar_partida/0: carrega tabuleiro vazio e comeca com Jogador 1 (X).
iniciar_partida :-
    nl,
    write('  Jogador 1 = X    |    Jogador 2 = O'), nl,
    write('  Linhas e colunas numeradas de 1 a 3'), nl,
    write('=================================================='), nl, nl,
    tabuleiro(Tab),
    rodar(Tab, 1, _).

% rodar/3: loop principal, exibe tabuleiro e obtem a proxima jogada.
% No modo ia, quando e vez do Jogador 2, a IA joga automaticamente.
rodar(Tab, Jogador, NovoTab) :-
    exibir_tabuleiro(Tab),
    nome_jogador(Jogador, NomeJog),
    format('Vez de ~w~n', [NomeJog]),
    (   (Jogador = 2, modo_jogo(ia)) ->
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

% ler_jogada/1: le entrada do teclado com tratamento de erro de sintaxe.
% catch/3 evita crash se o usuario digitar algo invalido (ex: texto sem virgula).
% Se read/1 falhar ou retornar variavel nao instanciada, marca como entrada_invalida.
ler_jogada(Jogada) :-
    catch(read(Termo), error(syntax_error(_), _), Termo = entrada_invalida),
    ( var(Termo) -> Jogada = entrada_invalida ; Jogada = Termo ).

% processar_jogada/4: trata a jogada em quatro situacoes (ordem das clausulas importa):
%   1) Saida voluntaria (-1, -1)
%   2) Jogada valida, vitoria, empate ou proximo turno
%   3) Jogada invalida, posicao ocupada ou fora do tabuleiro
%   4) Entrada com formato incorreto

% Caso 1: jogador digita -1, -1. para encerrar o jogo
processar_jogada((L, C), _Tab, _Jogador, _NovoTab) :-
    L == -1, C == -1,
    !,
    write('=================================================='), nl,
    write('  Jogo finalizado pelo jogador. Ate a proxima!'), nl,
    write('=================================================='), nl, nl.

% Caso 2: jogada valida, atualiza tabuleiro e verifica fim de jogo
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

% Caso 3: coordenadas inteiras validas, mas jogada impossivel
processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    !,
    write('--------------------------------------------------'), nl,
    write('  Jogada invalida! Verifique se a posicao existe'), nl,
    write('  ou se a casa ja esta ocupada. Tente novamente.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).

% Caso 4: entrada com formato invalido (nao e par de inteiros)
processar_jogada(_, Tab, Jogador, NovoTab) :-
    write('--------------------------------------------------'), nl,
    write('  Entrada invalida! Use o formato: Linha, Coluna.'), nl,
    write('  Exemplo: 1, 2.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).
