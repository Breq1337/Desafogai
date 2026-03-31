"use client";

import Image from "next/image";
import { useState } from "react";

export default function DownloadGuide() {
  const [activeTab, setActiveTab] = useState<"ios" | "android" | "web">("ios");

  const guides = {
    ios: {
      title: "Baixar no iPhone/iPad",
      steps: [
        {
          num: 1,
          title: "Abra o Safari",
          desc: "Use o navegador Safari (Chrome tem limitações em iOS)",
          icon: "🌐",
        },
        {
          num: 2,
          title: "Acesse o app",
          desc: "Digite desafogai-web.vercel.app na barra de endereço",
          icon: "📍",
        },
        {
          num: 3,
          title: "Toque em Compartilhar",
          desc: "Encontre o botão de compartilhar (caixa com seta)",
          icon: "⬆️",
        },
        {
          num: 4,
          title: "Adicionar à Tela Inicial",
          desc: "Role até encontrar 'Adicionar à Tela Inicial' e toque",
          icon: "➕",
        },
        {
          num: 5,
          title: "Confirme o nome",
          desc: "Toque em 'Adicionar' no canto superior direito",
          icon: "✅",
        },
        {
          num: 6,
          title: "App instalado!",
          desc: "O Desafog.ai aparecerá como ícone na sua tela inicial",
          icon: "🎉",
        },
      ],
    },
    android: {
      title: "Baixar no Android",
      steps: [
        {
          num: 1,
          title: "Abra o Chrome",
          desc: "Navegador Chrome (recomendado para PWA)",
          icon: "🌐",
        },
        {
          num: 2,
          title: "Acesse o app",
          desc: "Digite desafogai-web.vercel.app na barra de endereço",
          icon: "📍",
        },
        {
          num: 3,
          title: "Toque o Menu",
          desc: "Toque nos 3 pontinhos (⋮) no canto superior direito",
          icon: "⋮",
        },
        {
          num: 4,
          title: "Instalar app",
          desc: "Procure por 'Instalar app' ou 'Install app'",
          icon: "📥",
        },
        {
          num: 5,
          title: "Confirme a instalação",
          desc: "Toque em 'Instalar' na caixa de diálogo",
          icon: "✅",
        },
        {
          num: 6,
          title: "App instalado!",
          desc: "O Desafog.ai aparecerá como app normal na sua tela inicial",
          icon: "🎉",
        },
      ],
    },
    web: {
      title: "Usar no Navegador",
      steps: [
        {
          num: 1,
          title: "Abra qualquer navegador",
          desc: "Chrome, Safari, Firefox, Edge - qualquer um funciona",
          icon: "🌐",
        },
        {
          num: 2,
          title: "Acesse o app",
          desc: "Digite desafogai-web.vercel.app na barra de endereço",
          icon: "📍",
        },
        {
          num: 3,
          title: "Pronto!",
          desc: "O app carrega e funciona normalmente no navegador",
          icon: "✨",
        },
        {
          num: 4,
          title: "Funciona offline",
          desc: "Após carregar, funciona sem internet (Service Worker)",
          icon: "📴",
        },
        {
          num: 5,
          title: "Salve o bookmark",
          desc: "Salve a página como favorito para acesso rápido",
          icon: "⭐",
        },
      ],
    },
  };

  const currentGuide = guides[activeTab];

  return (
    <section className="px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div className="mx-auto max-w-4xl">
        {/* Header */}
        <div className="text-center">
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
            Como Baixar o Desafog.ai
          </h2>
          <p className="mt-4 text-lg text-slate-300">
            Escolha o seu dispositivo e siga os passos simples
          </p>
        </div>

        {/* Tabs */}
        <div className="mt-8 flex gap-4 border-b border-slate-700 sm:justify-center">
          {(["ios", "android", "web"] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`pb-4 px-4 font-semibold transition-all ${
                activeTab === tab
                  ? "border-b-2 border-ocean text-ocean"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              {tab === "ios" && "🍎 iPhone/iPad"}
              {tab === "android" && "🤖 Android"}
              {tab === "web" && "🌐 Navegador"}
            </button>
          ))}
        </div>

        {/* Steps */}
        <div className="mt-12">
          <h3 className="mb-8 text-2xl font-bold text-white">{currentGuide.title}</h3>

          <div className="space-y-6">
            {currentGuide.steps.map((step, idx) => (
              <div key={step.num} className="flex gap-6">
                {/* Número */}
                <div className="flex flex-shrink-0 items-center justify-center">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-ocean/20 text-2xl">
                    {step.icon}
                  </div>
                </div>

                {/* Conteúdo */}
                <div className="flex-1 pt-1">
                  <p className="text-lg font-semibold text-white">{step.title}</p>
                  <p className="mt-1 text-slate-400">{step.desc}</p>
                </div>

                {/* Divisor */}
                {idx < currentGuide.steps.length - 1 && (
                  <div className="absolute left-6 h-12 w-0.5 bg-ocean/20" />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Features Card */}
        <div className="mt-12 rounded-2xl border border-ocean/30 bg-slate-900/50 p-8">
          <h4 className="text-lg font-semibold text-white">✨ Vantagens da PWA</h4>
          <div className="mt-6 grid gap-4 sm:grid-cols-2">
            <div className="flex gap-3">
              <span className="text-2xl">📴</span>
              <div>
                <p className="font-semibold text-white">Funciona Offline</p>
                <p className="text-sm text-slate-400">Sem internet depois de carregar</p>
              </div>
            </div>
            <div className="flex gap-3">
              <span className="text-2xl">⚡</span>
              <div>
                <p className="font-semibold text-white">Muito Rápido</p>
                <p className="text-sm text-slate-400">Abre em menos de 1 segundo</p>
              </div>
            </div>
            <div className="flex gap-3">
              <span className="text-2xl">🔄</span>
              <div>
                <p className="font-semibold text-white">Sincroniza Real-time</p>
                <p className="text-sm text-slate-400">Dados atualizados instantaneamente</p>
              </div>
            </div>
            <div className="flex gap-3">
              <span className="text-2xl">🔐</span>
              <div>
                <p className="font-semibold text-white">100% Seguro</p>
                <p className="text-sm text-slate-400">HTTPS e criptografia Firestore</p>
              </div>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div className="mt-12 rounded-2xl border border-ocean/30 bg-slate-900/50 p-8 text-center">
          <p className="text-slate-300">Pronto para começar?</p>
          <a
            href="https://desafogai-web.vercel.app"
            target="_blank"
            rel="noopener noreferrer"
            className="mt-4 inline-flex items-center justify-center gap-2 rounded-xl bg-ocean px-8 py-4 text-base font-semibold text-white shadow-lg shadow-ocean/25 transition-all duration-200 hover:bg-dark-blue hover:shadow-ocean/40 hover:-translate-y-0.5"
          >
            <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M13 10V3L4 14h7v7l9-11h-7z"
              />
            </svg>
            Acessar o App Agora
          </a>
        </div>
      </div>
    </section>
  );
}
