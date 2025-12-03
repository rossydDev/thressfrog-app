🐸 ThressFrog - Bankroll Management

"O salto estratégico para sua banca."

1. Visão do Produto

O ThressFrog é um aplicativo mobile desenvolvido em Flutter para gestão de banca em apostas esportivas, com foco no cenário de League of Legends (LoL). O objetivo é transformar a disciplina financeira em uma experiência gamificada, ajudando o apostador a respeitar seus limites ("Thresholds") e dar "pulos certeiros" em direção ao lucro.

2. Identidade Visual (UI/UX)

Tema: Dark Mode (Foco e Conforto Visual).

Cor Primária: Lemon Green (#CCFF00 ou similar) - Representa o "Green", o lucro e a energia.

Estilo: Minimalista, com fontes modernas e elementos de "Gamer UI".

3. Core Features (MVP - Mínimo Produto Viável)

📊 Gestão de Banca

Definição de Banca Inicial.

Definição de Stake (valor da aposta) baseada em porcentagem (Gestão Conservadora vs. Agressiva).

Registro de Entradas (Partida, Odds, Valor, Resultado).

🛡️ Sistema Threshold (Limites)

Stop Win: Meta do dia alcançada? O app sugere parar.

Stop Loss: Limite de perda atingido? O app bloqueia ou alerta agressivamente.

Ghost Frog: O "limite seguro" onde o lucro é protegido.

🎮 Gamificação (The Frog Path)

XP por Disciplina: Ganhe pontos não apenas por lucrar, mas por seguir a gestão.

Badges: "Sniper" (alta assertividade), "Tank" (segurou um red streak sem quebrar).

Níveis: Girino -> Sapo Aprendiz -> Sapo Rei.

4. Stack Tecnológica (Planejada)

Linguagem: Dart

Framework: Flutter (Multiplataforma)

Gerenciamento de Estado: Riverpod (Moderno, seguro e testável) ou Provider.

Armazenamento Local: Hive ou Isar (NoSQL, extremamente rápido para mobile).

Arquitetura: Clean Architecture ou MVVM (Model-View-ViewModel).

5. Estrutura de Pastas (Sugestão Inicial)

lib/
  ├── core/          # Configurações globais, temas, constantes
  ├── features/      # Módulos do app (ex: dashboard, history, gamification)
  ├── models/        # Modelos de dados
  ├── services/      # Lógica de banco de dados
  └── main.dart


Desenvolvido com foco em aprendizado e engenharia de software sólida.
