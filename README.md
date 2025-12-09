# 🐸 ThressFrog — Bankroll Management App

> **"O salto estratégico para sua banca."**

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-MVP%20Concluído-success?style=for-the-badge)

## 🎯 Visão do Produto
O **ThressFrog** é um aplicativo mobile desenvolvido em Flutter para gestão de banca em apostas esportivas, focado no cenário competitivo de **League of Legends (LoL)**.

Diferente de planilhas complexas, o ThressFrog transforma disciplina financeira em uma experiência **gamificada e Data-Driven**, conectando dados oficiais de partidas com a gestão de risco pessoal do apostador.

## 🎨 Identidade Visual (UI/UX)
* **Tema:** Dark Mode Imersivo (Background `#121212`)
* **Destaque:** 🍋 Neon Green (`#D4FF00`) e 🔮 Mystic Purple (`#D946EF`) para dados analíticos.
* **Estilo:** Minimalista + Gamer UI (Cards com efeitos de brilho/neon e iconografia moderna).

---

## 🧩 Core Features (Funcionalidades)

### 📊 Gestão de Banca & Risco
* **Perfis de Investidor:** Tartaruga 🐢 (Conservador), Sapo 🐸 (Moderado), Jacaré 🐊 (Agressivo).
* **Stake Dinâmica:** Cálculo automático baseado no perfil e banca atual.
* **CRUD de Apostas:** Registro completo com status (Green, Red, Void, Pendente).

### 🛡️ Sistema Threshold (Segurança)
* **Stop Win/Loss Visual:** Barras de progresso que indicam visualmente a hora de parar.
* **👻 Ghost Frog (Trailing Stop):** *Feature exclusiva!* Se o lucro do dia atinge 50% da meta, o Stop Loss sobe automaticamente para o "0x0" (Breakeven), blindando o lucro já obtido.

### 🔮 Lente do Oráculo (Oracle Lens)
* **Integração API (PandaScore):** Busca de jogos oficiais de LoL (CBLOL, LCK, Worlds, etc).
* **Carrossel de Tendências:** Análise global das ligas (Winrate por Side, Duração Média).
* **Filtros Inteligentes:** O usuário escolhe quais ligas quer monitorar.
* **Performance Pessoal:** Estatísticas cruzadas apenas de apostas oficiais validadas.

### 🎮 Gamificação — The Frog Path
* **XP por Disciplina:** Ganhe XP não apenas por lucrar, mas por respeitar a gestão de risco.
* **Sala de Troféus:** Badges desbloqueáveis (Sniper, Sapo Rico, Disciplina, etc) persistentes.
* **Evolução:** Níveis baseados em XP acumulado (Girino → Sapo Rei).

---

## 🛠️ Stack Tecnológica

| Categoria | Tecnologia | Detalhes |
| :--- | :--- | :--- |
| **Linguagem** | Dart | Null Safety |
| **Framework** | Flutter | Mobile (Android/iOS) |
| **Gerência de Estado** | Provider | ChangeNotifier + ListenableBuilder (Singleton Pattern) |
| **Banco de Dados** | Hive | NoSQL, Local-First, Ultra-rápido |
| **Conectividade** | Dio | Consumo da API PandaScore |
| **Gráficos** | FL Chart | Visualização da evolução da banca |
| **Geração de Código** | Build Runner | Adaptadores de TypeHive |

---

## 📁 Estrutura do Projeto

A arquitetura segue o padrão **Feature-First**, facilitando a escalabilidade e manutenção:

```bash
lib/
├── core/
│   ├── services/      # PandaScoreService (API)
│   ├── state/         # BankrollController (Lógica Global e Regras de Negócio)
│   └── theme/         # AppTheme e Paleta de Cores
├── features/
│   ├── home/          # Dashboard, Gráficos e Lista de Apostas
│   ├── create_bet/    # Formulário e Busca de Jogos (API)
│   ├── oracle/        # Lente do Oráculo (Analytics & Charts)
│   └── settings/      # Configuração de Perfil e Filtros
├── models/            # Classes de Domínio (Bet, UserProfile, LoLMatch)
└── main.dart          # Inicialização e Injeção de Dependências

```

## 🚀 Como Rodar o Projeto

1. Clone o repositório:
```bash
  git clone https://github.com/seu-usuario/thressfrog.git
```

2. Instale as dependências:
```bash
  flutter pub get
```

3. Gere os adaptadores do Hive: (Passo obrigatório devido ao uso do build_runner)
```bash
  flutter pub run build_runner build --delete-conflicting-outputs
```

4. Configure a API Key:
  * Vá em lib/core/services/pandascore_service.dart.

  * Insira sua chave gratuita da PandaScore na variável _token.

5. Execute:
```bash
  flutter run
```

Desenvolvido com 💚 e 🐸 por [Lucas](https://github.com/rossydDev/thressfrog-app)
