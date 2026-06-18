% JOGO DA VELHA EM PROLOG (com IA Minimax)
% Trabalho Pratico - Paradigmas de Programacao (UTFPR - Dois Vizinhos)
% Representacao do tabuleiro: lista de 9 elementos (0=vazio, 1=X, 2=O)

% ==================================================
%           TABULEIRO E CONFIGURACoES INICIAIS
% ==================================================

% modo_jogo/1 (dinâmico): Armazena o modo de jogo selecionado no inicio da execucao.
% A diretiva 'dynamic' e necessaria para que o predicado possa ser modificado 
% Valores possiveis: 'pessoa' (Humano vs Humano) ou 'ia' (Humano vs Computador).
:- dynamic modo_jogo/1.

% Estado inicial: uma lista com 9 zeros representando as 9 casas vazias do jogo.
% A lista representa posicoes 1 a 9, da esquerda para a direita, linha a linha.
tabuleiro([0,0,0,0,0,0,0,0,0]).

% Mapeamento de coordenadas: (Linha, Coluna, Número da Casa)
% Mapeia as coordenadas bidimensionais (Linha, Coluna) para o indice linear da lista.
% Permite que o jogador digite "2, 2" e o sistema entenda que e a casa central (5).
posicao(1, 1, 1).
posicao(1, 2, 2).
posicao(1, 3, 3).
posicao(2, 1, 4).
posicao(2, 2, 5).
posicao(2, 3, 6).
posicao(3, 1, 7).
posicao(3, 2, 8).
posicao(3, 3, 9).

% simbolo: Define a representacao visual de cada estado da casa no tabuleiro.
% 0 -> Casa vazia (espaco em branco)
% 1 -> Jogada do Jogador 1 (representado por 'X')
% 2 -> Jogada do Jogador 2 ou IA (representado por 'O')
simbolo(0, ' ').
simbolo(1, 'X').
simbolo(2, 'O').

% nome_jogador: retorna nome descritivo do jogador para mensagens na tela.
% No modo IA, o jogador 2 aparece como "IA (O)" em vez de "Jogador 2 (O)".
nome_jogador(1, 'Jogador 1 (X)').
nome_jogador(2, Nome) :-
    modo_jogo(ia) -> Nome = 'IA (O)' ; Nome = 'Jogador 2 (O)'.

% Regras de alternância: alterna o turno entre Jogador 1 (X) e Jogador 2 (O/IA).
% Se o atual e o 1, o próximo e o 2.
% Se o atual e o 2, o próximo e o 1.
proximo_jogador(1, 2).
proximo_jogador(2, 1).



% ==================================================
%           LÓGICA DO JOGO (REGRAS)
% ==================================================

% exibir_tabuleiro: Desenha o tabuleiro 3x3 no console.
% Primeiro, extrai os valores de cada posicao da lista (P1 a P9).
% Depois, converte esses valores nos simbolos visuais ('X', 'O' ou ' ') 
% e imprime a grade formatada com as coordenadas laterais e superiores.
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

% vencedor: Verifica se o jogador informado venceu o jogo.
% O predicado testa todas as 8 combinacoes possiveis: 3 horizontais, 3 verticais e 2 diagonais.
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

% empate: Define uma situacao de empate (Velha).
% Ocorre quando nao existem mais casas vazias (0) e nenhum dos jogadores venceu.
empate(Tab) :- \+ member(0, Tab), \+ vencedor(Tab, 1), \+ vencedor(Tab, 2).

% substituir: Predicado utilitario para atualizar uma lista.
% Percorre a lista ate a posicao desejada e substitui o valor antigo pelo novo simbolo.
substituir([_|T], 1, Novo, [Novo|T]).
substituir([H|T], Pos, Novo, [H|T2]) :- Pos > 1, Pos1 is Pos - 1, substituir(T, Pos1, Novo, T2).

% jogar: aplica uma jogada valida e retorna NovoTab com o estado atualizado.
% 1. Converte a Linha/Coluna fornecida no indice linear (1 a 9).
% 2. Confirma se a casa esta disponivel (contem 0).
% 3. Gera um novo tabuleiro com a peca do jogador inserida na posicao.

% Falha se a posicao nao existir ou a casa ja estiver ocupada (jogada invalida).
jogar(Linha, Coluna, Tab, Jogador, NovoTab) :-
    posicao(Linha, Coluna, Pos),            % converte Linha/Coluna em indice
    nth1(Pos, Tab, 0),                      % confirma que a casa esta vazia
    substituir(Tab, Pos, Jogador, NovoTab). % grava a peca do jogador



% ==================================================
%          INTELIGENCIA ARTIFICIAL (MINIMAX)
% ==================================================

% A IA deve analisar o cenario atual e retornar as coordenadas da jogada ideal.
% Ela usa o algoritmo Minimax para escolher a melhor jogada, garantindo que ela nunca perca. Por ser um algoritmo recursivo, ele simula todas as possibilidades futuras

% melhor_jogada(+Tabuleiro, +Jogador, -Linha, -Coluna): Escolhe a melhor jogada (L, C) para a IA usando Minimax.
% Avalia todas as casas vazias, calcula pontuacao de cada uma e escolhe a maior.
melhor_jogada(Tab, Jogador, L, C) :-
    % findall coleta todas as jogadas possiveis no formato Valor-Linha-Coluna.
    % Para cada casa vazia, ele simula a jogada e chama o valor_minimax para avaliar o resultado.
    findall(V-Lin-Col, (
        posicao(Lin, Col, Pos),
        nth1(Pos, Tab, 0),                        % Verifica se a posicao esta vazia
        substituir(Tab, Pos, Jogador, NTab),      % Simula o novo tabuleiro com a jogada
        valor_minimax(NTab, Jogador, 0, false, V) % Avalia o valor dessa jogada (comeca turno do oponente)
    ), Jogadas),
    % sort com a opcao @>= ordena a lista de forma decrescente com base no Valor (V).
    % O primeiro elemento da lista ordenada sera a jogada com o maior valor possivel.
    sort(0, @>=, Jogadas, [_-L-C|_]).  % ordena decrescente e pega a melhor

% valor_minimax(+Tabuleiro, +JogIA, +Profundidade, +Maximizando, -Valor): Calcula pontuacao de uma jogada para a IA (algoritmo Minimax).
% Argumentos: Tab = tabuleiro atual, JogIA = jogador da IA, Prof = profundidade da arvore, maximizando = true (maximiza) ou false (minimiza), Val = pontuacao resultante
% O algoritmo MINMAX assume que a IA quer MAXIMIZAR sua pontuacao e o Humano quer MINIMIZAR a pontuacao da IA.

% CASOS BASE: Condicoes de parada da recursao (fim de jogo simulado).
% Se a IA vence, recebe pontuacao positiva. Subtraimos a profundidade para preferir vitórias rapidas.
valor_minimax(Tab, JogIA, Prof, _, Val) :- vencedor(Tab, JogIA), !, Val is 10 - Prof.
% Se o oponente vence, recebe pontuacao negativa. Somamos a profundidade para preferir derrotas tardias.
valor_minimax(Tab, JogIA, Prof, _, Val) :- proximo_jogador(JogIA, Op), vencedor(Tab, Op), !, Val is Prof - 10.
% Se houver empate, a pontuacao e neutra (0).
valor_minimax(Tab, _, _, _, 0) :- empate(Tab), !.

% CASO RECURSIVO 1: Turno da IA (Maximizador)
% A IA analisa todas as suas jogadas possiveis e escolhe a que da o MAIOR valor.
valor_minimax(Tab, JogIA, Prof, true, Val) :-
    Prof1 is Prof + 1,
    findall(V, (posicao(_,_,P), nth1(P,Tab,0), substituir(Tab,P,JogIA,NT), valor_minimax(NT,JogIA,Prof1,false,V)), Valores),
    max_lista(Valores, Val).

% CASO RECURSIVO 2: Turno do Humano (Minimizador)
% A IA simula a jogada do humano, assumindo que ele escolhera a jogada que mais prejudica a IA (MENOR valor).
valor_minimax(Tab, JogIA, Prof, false, Val) :-
    Prof1 is Prof + 1,
    proximo_jogador(JogIA, Op),
    findall(V, (posicao(_,_,P), nth1(P,Tab,0), substituir(Tab,P,Op,NT), valor_minimax(NT,JogIA,Prof1,true,V)), Valores),
    min_lista(Valores, Val).

% PREDICADOS AUXILIARES DE LISTA
% O findall retorna uma lista de valores. Precisamos extrair o maior ou menor deles para que o MiniMax possa 'propagar' a melhor decisao para os niveis superiores da arvore.

% Encontra o valor maximo em uma lista
max_lista([H|T], Max) :- max_lista(T, H, Max).
max_lista([], M, M).
max_lista([H|T], Acc, M) :- (H > Acc -> N = H ; N = Acc), max_lista(T, N, M).

% Encontra o valor minimo em uma lista
min_lista([H|T], Min) :- min_lista(T, H, Min).
min_lista([], M, M).
min_lista([H|T], Acc, M) :- (H < Acc -> N = H ; N = Acc), min_lista(T, N, M).


% ==================================================
%           LOOP PRINCIPAL E PROCESSAMENTO
% ==================================================

% iniciar: Ponto de entrada do programa.
% Exibe as boas-vindas e o menu para escolha do modo de jogo.
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

% definir_modo: configura modo_jogo/1 e inicia a partida.
% Configura o modo de jogo com base na escolha do usuario.
% Se escolher 1, define o modo como 'pessoa'. Se 2, define como 'ia'.
% Qualquer outra entrada reinicia o menu de escolha: retractall apaga modo anterior, ja o assert grava o novo modo escolhido.
definir_modo(1) :-
    retractall(modo_jogo(_)), assert(modo_jogo(pessoa)),
    write('Modo Pessoa vs Pessoa selecionado!'), nl, iniciar_partida.
definir_modo(2) :-
    retractall(modo_jogo(_)), assert(modo_jogo(ia)),
    write('Modo Pessoa vs IA selecionado!'), nl, iniciar_partida.
definir_modo(_) :-
    write('Escolha invalida. Tente novamente.'), nl, iniciar.

% iniciar_partida: Prepara o ambiente da partida e inicia o primeiro turno com o Jogador 1 (X).
iniciar_partida :-
    nl,
    write('  Jogador 1 = X    |    Jogador 2 = O'), nl,
    write('  Linhas e colunas numeradas de 1 a 3'), nl,
    write('=================================================='), nl, nl,
    tabuleiro(Tab),
    rodar(Tab, 1, _).

% rodar: Gerencia o ciclo de turnos.
% Se for a vez da IA (Jogador 2 no modo IA), ela calcula a jogada automaticamente.
% Caso contrario, solicita a entrada manual do jogador humano.
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

% ler_jogada: Le entrada do teclado com tratamento de erro de sintaxe.
% catch: evita que o programa trave caso o usuario digite caracteres especiais invalidos.
% Se read falhar ou retornar variavel nao instanciada, marca como entrada_invalida.
ler_jogada(Jogada) :-
    catch(read(Termo), error(syntax_error(_), _), Termo = entrada_invalida),
    ( var(Termo) -> Jogada = entrada_invalida ; Jogada = Termo ).


% --- PROCESSAMENTO E VALIDAcaO DAS JOGADAS ---

% processar_jogada: Trata a jogada em quatro situacoes distintas:
%   1) Caso de saida: Saida voluntaria (-1, -1)
%   2) Caso de jogada valida: Jogada valida, vitoria, empate ou proximo turno
%   3) Caso de jogada invalida: Jogada invalida, posicao ocupada ou fora do tabuleiro
%   4) Caso de entrada invalida generica: Qualquer entrada que nao siga o padrao (Linha, Coluna)

% Caso de saida: O jogador digitou exatamente -1, -1 para encerrar o programa.
processar_jogada((L, C), _Tab, _Jogador, _NovoTab) :-
    L == -1, C == -1,
    !,
    write('=================================================='), nl,
    write('  Jogo finalizado pelo jogador. Ate a proxima!'), nl,
    write('=================================================='), nl, nl.

% Caso de jogada valida: Verifica se a posicao existe e esta livre, entao checa vitoria ou empate.
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

% Caso de jogada invalida: Coordenadas numericas validas, mas fora do limite ou casa ja ocupada.
processar_jogada((Linha, Coluna), Tab, Jogador, NovoTab) :-
    integer(Linha), integer(Coluna),
    !,
    write('--------------------------------------------------'), nl,
    write('  Jogada invalida! Verifique se a posicao existe'), nl,
    write('  ou se a casa ja esta ocupada. Tente novamente.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).


% Caso de entrada invalida generica: Qualquer entrada que nao siga o padrao (Linha, Coluna).
processar_jogada(_, Tab, Jogador, NovoTab) :-
    write('--------------------------------------------------'), nl,
    write('  Entrada invalida! Use o formato: Linha, Coluna.'), nl,
    write('  Exemplo: 1, 2.'), nl,
    write('--------------------------------------------------'), nl,
    rodar(Tab, Jogador, NovoTab).
