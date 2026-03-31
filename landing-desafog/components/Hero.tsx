"use client";

import Image from "next/image";
import dynamic from "next/dynamic";

const TypewriterHeadline = dynamic(() => import("./TypewriterHeadline"), {
  ssr: false,
});

const HERO_LINES = [
  { text: "Suas contas organizadas.", variant: "plain" as const },
  { text: "Seu mês no controle.", variant: "gradient" as const },
];

export default function Hero() {
  return (
    <section
      id="top"
      className="scroll-mt-24 px-4 pt-28 pb-20 sm:px-6 lg:px-8 lg:pt-28 lg:pb-28"
    >
      <div className="relative mx-auto flex w-full max-w-4xl flex-col items-center text-center">
        {/* Bloco principal: hierarquia clara */}
        <header className="flex w-full flex-col items-center gap-8">
          <div className="flex flex-col items-center gap-5">
            <div className="animate-fade-up">
              <Image
                src="/logo_sembackground.png"
                alt="Desafog.ai"
                width={112}
                height={112}
                className="h-24 w-24 object-contain drop-shadow-[0_0_28px_rgba(0,119,182,0.4)] sm:h-[6.5rem] sm:w-[6.5rem]"
                priority
              />
            </div>

            <p className="animate-fade-up inline-flex items-center rounded-full border border-slate-700/80 bg-slate-900/55 px-4 py-2 text-sm font-medium tracking-wide text-soft-cyan sm:text-[0.9375rem]">
              Controle financeiro com IA
            </p>
          </div>

          <TypewriterHeadline
            lines={HERO_LINES}
            charDelayMs={34}
            linePauseMs={340}
            className="text-[2rem] font-extrabold leading-[1.12] tracking-tight text-white sm:text-5xl sm:leading-[1.1] lg:text-[3.25rem] lg:leading-[1.06]"
          />

          <p className="animate-fade-up-delay-2 max-w-2xl text-pretty text-lg leading-[1.75] text-slate-200 sm:text-xl sm:leading-[1.72] lg:text-[1.3125rem] lg:leading-[1.7]">
            O{" "}
            <span className="font-semibold text-white">
              Desafog<span className="text-ocean">.ai</span>
            </span>{" "}
            prioriza suas dívidas, monta um plano mensal realista e te orienta com
            inteligência artificial — sem julgamento, com clareza.
          </p>
        </header>

        <div className="animate-fade-up-delay-3 mt-12 flex w-full max-w-lg flex-col items-stretch gap-3 sm:mx-auto sm:flex-row sm:justify-center">
          <a
            href="#funcionalidades"
            className="font-display inline-flex items-center justify-center gap-2 rounded-xl bg-ocean px-8 py-4 text-[1.0625rem] font-semibold text-white shadow-lg shadow-ocean/25 transition-all duration-200 hover:bg-brand-dark hover:shadow-ocean/40 hover:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ocean"
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
          </a>
          <a
            href="#faq"
            className="font-display inline-flex items-center justify-center gap-1 rounded-xl border border-slate-600/90 bg-slate-900/50 px-8 py-4 text-[1.0625rem] font-medium text-slate-200 transition-all duration-200 hover:border-ocean/45 hover:bg-slate-900/80 hover:text-white hover:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ocean"
          >
            Tire suas dúvidas
          </a>
        </div>
      </div>
    </section>
  );
}
