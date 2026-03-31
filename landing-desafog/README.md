# Desafog.ai — Landing Page

Landing page do **Desafog.ai**, app de controle financeiro com priorização inteligente de dívidas, plano mensal, simulador de cenários e assistente com IA.

## Stack

- **Next.js 16** (App Router)
- **Tailwind CSS 4**
- **TypeScript**
- **ogl** — WebGL usado pelo fundo **Dark Veil** ([React Bits](https://www.reactbits.dev/backgrounds/dark-veil), [DavidHDev/react-bits](https://github.com/DavidHDev/react-bits), licença MIT do repositório)
- **shadcn/ui** — configurado em [`components.json`](components.json) com registro **@react-bits** (`https://reactbits.dev/r/{name}.json`) e utilitário [`lib/utils.ts`](lib/utils.ts) (`cn`)

## shadcn / React Bits

Execute os comandos **nesta pasta** (`landing-desafog`), onde está o `components.json` completo:

```bash
cd landing-desafog
npx shadcn@latest add button
npx shadcn@latest add @react-bits/nome-do-componente
```

O MCP **shadcn** na raiz do repositório continua vendo o registro em [`../components.json`](../components.json) (apenas `registries`); o projeto Next usa o arquivo dentro de `landing-desafog`.

## Rodar localmente

```bash
# Instalar dependências
npm install

# Iniciar servidor de desenvolvimento
npm run dev
```

O site estará disponível em [http://localhost:3000](http://localhost:3000).

## Build de produção

```bash
npm run build
npm start
```

## Estrutura

```
landing-desafog/
├── app/
│   ├── globals.css      # Tokens visuais e utilitários
│   ├── layout.tsx        # Layout raiz (meta, fontes, idioma)
│   └── page.tsx          # Composição da landing page
├── components.json       # shadcn + registro @react-bits
├── lib/
│   └── utils.ts          # cn() (clsx + tailwind-merge)
├── components/
│   ├── Navbar.tsx        # Navegação fixa com menu mobile
│   ├── Hero.tsx          # Headline + CTA principal
│   ├── Problem.tsx       # Seção "O problema"
│   ├── Benefits.tsx      # Como o Desafog ajuda (4 cards)
│   ├── Features.tsx      # Grid de funcionalidades
│   ├── Telegram.tsx      # Integração Telegram + App
│   ├── SocialProof.tsx   # Depoimentos (beta)
│   ├── CtaFinal.tsx      # CTA de fechamento
│   ├── Faq.tsx           # Perguntas frequentes
│   └── Footer.tsx        # Rodapé com links
├── next.config.ts
├── postcss.config.mjs
├── tailwind (via CSS)
└── tsconfig.json
```
