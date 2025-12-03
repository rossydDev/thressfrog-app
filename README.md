# 🐸 **ThressFrog — Bankroll Management App**  
### *"O salto estratégico para sua banca."*

---

## 🎯 **Visão do Produto**

O **ThressFrog** é um aplicativo mobile desenvolvido em **Flutter** para gestão de banca em **apostas esportivas**, com foco inicial no cenário de **League of Legends (LoL)**.  
A proposta é transformar disciplina financeira em **experiência gamificada**, ajudando o apostador a respeitar seus **Thresholds** e dar *“pulos certeiros”* rumo ao lucro.

---

## 🎨 **Identidade Visual (UI/UX)**

- **Tema:** Dark Mode (foco, imersão e conforto visual)  
- **Cor Primária:** 🍋 **Lemon Green** — `#CCFF00`  
- **Estilo:** Minimalista + Gamer UI (contrastes fortes e fontes modernas)

---

## 🧩 **Core Features — MVP**

### 📊 **Gestão de Banca**
- Definição de banca inicial  
- Cálculo automático da **stake** por porcentagem  
- Modos de gestão: Conservadora / Moderada / Agressiva  
- Registro detalhado de apostas:
  - Partida  
  - Odds  
  - Valor  
  - Resultado

---

### 🛡️ **Sistema Threshold**
- **Stop Win** → Meta atingida? O app sugere encerrar  
- **Stop Loss** → Limite de perda alcançado? Alerta agressivo  
- **Ghost Frog** → Zona segura de lucro protegido  

---

### 🎮 **Gamificação — *The Frog Path***
- **XP por Disciplina** (ganhe por seguir a gestão)  
- **Badges**
  - *Sniper* — alta assertividade  
  - *Tank* — resistiu a um red streak sem quebrar  
- **Níveis:** Girino → Sapo Aprendiz → **Sapo Rei**

---

## 🛠️ **Stack Tecnológica (Planejada)**

| Categoria | Tecnologia |
|----------|------------|
| Linguagem | Dart |
| Framework | Flutter |
| Estado | Riverpod (ou Provider) |
| Banco Local | Hive ou Isar |
| Arquitetura | Clean Architecture / MVVM |

---

## 📁 **Estrutura de Pastas**

```bash
lib/
├── core/        # Tema, constantes, helpers, configs
├── features/    # Módulos (dashboard, history, gamification...)
├── models/      # Modelos de dados
├── services/    # Banco de dados e lógica de acesso
└── main.dart    # Entry point
