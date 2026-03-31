"use client";

import { useState } from "react";
import dynamic from "next/dynamic";
import GradientText from "./GradientText";

const SplitText = dynamic(() => import("./SplitText"), { ssr: false });

export default function CtaFinal() {
  const [showModal, setShowModal] = useState(false);

  return (
    <section className="scroll-mt-24 px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div className="relative mx-auto w-full max-w-2xl overflow-hidden rounded-3xl border border-ocean/30 bg-slate-900/55 p-10 text-center shadow-xl shadow-ocean/10 backdrop-blur-sm sm:p-14">
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-0"
          style={{
            background:
              "radial-gradient(ellipse 70% 60% at 50% 0%, rgba(0,119,182,0.18) 0%, transparent 55%)",
          }}
        />

        <div className="relative">
          <p className="text-xs font-semibold uppercase tracking-widest text-soft-cyan">
            Clareza no dia a dia
          </p>
          <h2 className="mt-3 text-balance text-2xl font-bold tracking-tight text-white sm:text-3xl">
            <SplitText
              text="Pronto para sair do caos financeiro?"
              tag="span"
              splitType="words"
              delay={60}
              duration={0.8}
              className="inline"
              from={{ opacity: 0, y: 20 }}
              to={{ opacity: 1, y: 0 }}
            />
          </h2>
          <p className="mx-auto mt-4 max-w-md text-slate-300">
            Organize suas dívidas, tenha um plano mensal realista e conte com{" "}
            <GradientText
              colors={["#90E0EF", "#CAF0F8", "#90E0EF"]}
              animationSpeed={5}
              className="font-semibold"
            >
              IA
            </GradientText>{" "}
            para te guiar — tudo no mesmo lugar.
          </p>
          <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:justify-center sm:gap-3">
            <a
              href="https://desafogai-web.vercel.app"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center justify-center gap-2 rounded-xl bg-ocean px-8 py-4 text-base font-semibold text-white shadow-lg shadow-ocean/25 transition-all duration-200 hover:bg-dark-blue hover:shadow-ocean/40 hover:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ocean"
            >
              <svg
                width="20"
                height="20"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                />
              </svg>
              Baixar App
            </a>
            <button
              onClick={() => setShowModal(true)}
              className="inline-flex items-center justify-center gap-2 rounded-xl border border-ocean/50 px-8 py-4 text-base font-semibold text-ocean transition-all duration-200 hover:bg-ocean/10 hover:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ocean"
            >
              Conhecer o app
              <svg
                width="20"
                height="20"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M17 8l4 4m0 0l-4 4m4-4H3"
                />
              </svg>
            </button>
          </div>

          {/* Modal de Download */}
          {showModal && (
            <div
              className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
              onClick={() => setShowModal(false)}
            >
              <div
                className="rounded-2xl bg-slate-900 p-8 shadow-2xl"
                onClick={(e) => e.stopPropagation()}
              >
                <div className="flex items-center justify-between">
                  <h3 className="text-xl font-bold text-white">Baixar Desafog.ai</h3>
                  <button
                    onClick={() => setShowModal(false)}
                    className="text-slate-400 hover:text-white"
                  >
                    ✕
                  </button>
                </div>

                <p className="mt-4 text-slate-300">Escolha sua plataforma:</p>

                <div className="mt-6 space-y-3">
                  {/* iOS */}
                  <a
                    href="https://desafogai-web.vercel.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 rounded-lg border border-ocean/30 bg-slate-800/50 p-4 transition-all hover:bg-slate-800"
                  >
                    <span className="text-2xl">🍎</span>
                    <div className="flex-1">
                      <p className="font-semibold text-white">iOS (PWA)</p>
                      <p className="text-xs text-slate-400">
                        Safari → Compartilhar → Adicionar à Tela Inicial
                      </p>
                    </div>
                    <svg className="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </a>

                  {/* Android */}
                  <a
                    href="https://desafogai-web.vercel.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 rounded-lg border border-ocean/30 bg-slate-800/50 p-4 transition-all hover:bg-slate-800"
                  >
                    <span className="text-2xl">🤖</span>
                    <div className="flex-1">
                      <p className="font-semibold text-white">Android (PWA)</p>
                      <p className="text-xs text-slate-400">
                        Chrome → Menu → Instalar app
                      </p>
                    </div>
                    <svg className="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </a>

                  {/* Web */}
                  <a
                    href="https://desafogai-web.vercel.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 rounded-lg border border-ocean/30 bg-slate-800/50 p-4 transition-all hover:bg-slate-800"
                  >
                    <span className="text-2xl">🌐</span>
                    <div className="flex-1">
                      <p className="font-semibold text-white">Web (Navegador)</p>
                      <p className="text-xs text-slate-400">
                        Acesse direto no navegador
                      </p>
                    </div>
                    <svg className="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </a>
                </div>

                <p className="mt-6 text-center text-xs text-slate-400">
                  Funciona 100% offline após carregar pela primeira vez
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
