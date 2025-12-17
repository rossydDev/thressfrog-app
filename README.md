# 🐸 ThressFrog - O Grimório Tático de Apostas (V1.0)

## 🎯 Visão do Produto
O **ThressFrog** é mais que uma planilha de gestão: é um **Analista Tático de Bolso** desenvolvido em Flutter para apostadores de League of Legends (LoL).

Diferente de apps genéricos, o ThressFrog combina **Disciplina Financeira** com **Inteligência de Dados (Data-Driven)**. Ele cruza dados oficiais da API (PandaScore) com o seu histórico pessoal para revelar padrões ocultos — o "Modo Grimório".

> *"Não aposte no escuro. Consulte o Sapo."*

---

## 🎨 Identidade Visual (UI/UX)
* **Tema:** Dark Mode Imersivo (`#121212`) para longas sessões de análise.
* **Paleta:** * 🍋 **Neon Green (#D4FF00):** Lucro, Ações Positivas e XP.
    * 🔮 **Mystic Purple (#D946EF):** Dados do Grimório, Profecias e Times Oficiais.
* **Estilo:** Minimalista + Gamer UI. Cards com efeitos de "Glassmorphism", ícones de RPG e feedbacks visuais táteis.
* **Navegação:** Bottom Navigation unificada (`MainPage`) separando claramente a **Gestão (Home)** da **Análise (Grimório)**.

---

## 🧩 Core Features (Funcionalidades)

### 📊 1. Smart Bankroll (Gestão Inteligente)
* **Perfis de Investidor:** Escolha sua skin de risco na nova **Página de Perfil**:
    * 🐢 **Tartaruga:** Conservador (Stake 1%).
    * 🐸 **Sapo:** Moderado (Stake 2.5%).
    * 🐊 **Jacaré:** Agressivo (Stake 5%).
* **Gestão de Capital:** Ferramenta dedicada para **Aportes** e **Saques** que ajusta a banca sem distorcer os gráficos de lucro/prejuízo das apostas.
* **Stake Dinâmica:** O app sugere o valor da entrada baseado na sua banca atual e perfil selecionado.

### 🔮 2. O Grimório Tático (Oracle Lens)
* **Motor de Profecias (`ProphecyEngine`):** Algoritmo que analisa seus jogos passados e gera "Buffs" ou "Maldições" (Ex: *"Maldição do Rio: Você perde 70% dos jogos com < 2 Dragões"*).
* **Busca Global & Dossiê de Times:** * Pesquise qualquer time oficial (T1, Pain, G2) via API.
    * **Dossiê Pessoal:** Veja o elenco atual (com fotos) comparado com a **sua** taxa de vitória apostando neles.
* **Livro Trancado (Gamificação):** As profecias só são reveladas após o usuário registrar um número mínimo de partidas no modo tático.
* **Filtros de Biblioteca:**terne entre visão global ou foque nas estatísticas de um time específico que você "Rastreou".

### 🛡️ 3. Sistema de Proteção
* **Stop Win/Loss Visual:** Barras de progresso na Home.
* **👻 Protocolo Fantasma (Ghost Mode):** Configurável no Perfil. Se ativado, ele protege seus ganhos do dia travando novas entradas arriscadas após atingir uma % da meta diária.

---

## 🛠️ Stack Tecnológica

| Categoria | Tecnologia | Detalhes |
| :--- | :--- | :--- |
| **Linguagem** | Dart | Null Safety |
| **Framework** | Flutter | Mobile (Android/iOS) |
| **Estado** | Provider | `ChangeNotifier` + `ListenableBuilder` (Singleton Controllers) |
| **Database** | Hive | NoSQL, Local-First, Adaptadores de Tipo customizados |
| **API** | Dio | Consumo da API PandaScore (LoL Esports) |
| **Segurança** | flutter_dotenv | Gerenciamento de chaves de API (.env) |
| **Gráficos** | FL Chart | Visualização da curva de evolução da banca |
| **Codegen** | Build Runner | Geração de TypeAdapters para o Hive |

---

## 📁 Estrutura do Projeto (Feature-First)

A arquitetura foi refatorada na V1.0 para suportar a complexidade do Grimório:

```bash
lib/
├── core/
│   ├── services/      # PandaScoreService (API)
│   ├── logic/         # ProphecyEngine (Lógica de Insights)
│   ├── state/         # BankrollController (Regras de Negócio & Hive)
│   └── theme/         # AppTheme
├── features/
│   ├── main/          # MainPage (Gerenciador de Navegação/Abas)
│   ├── home/          # Dashboard Financeiro & Gráficos
│   ├── create_bet/    # Flow de Aposta (Simples vs Grimório)
│   ├── oracle/        # O Grimório (Busca, Dossiê de Times, Insights)
│   └── profile/       # Edição de Perfil, Risco e Ghost Mode
├── models/            # Domínio (Bet, UserProfile, LoLTeam, Insight)
└── main.dart          # Inicialização
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