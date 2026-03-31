"use client";

import { useState } from "react";

const faqs = [
  {
    q: "Meus dados financeiros ficam seguros?",
    a: "Sim. Seus dados são criptografados em trânsito e em repouso. Não compartilhamos informações com terceiros e você pode excluir sua conta e dados a qualquer momento.",
  },
  {
    q: "O Desafog.ai substitui um assessor financeiro?",
    a: "Não. O app organiza suas contas e orienta com IA, mas não oferece consultoria financeira regulamentada. Para casos complexos, procure um profissional certificado.",
  },
  {
    q: "Em quais plataformas o app funciona?",
    a: "Atualmente o foco é Android. Estamos trabalhando para disponibilizar em outras plataformas em breve.",
  },
  {
    q: "Como funciona a integração com Telegram?",
    a: "Você vincula sua conta do Desafog ao Telegram com um código seguro. Depois, basta mandar uma mensagem para registrar dívidas — tudo sincroniza automaticamente com o app.",
  },
  {
    q: "Preciso informar dados bancários?",
    a: "Não. O Desafog funciona com as informações que você insere manualmente — dívidas, renda e despesas. Não acessamos sua conta bancária.",
  },
];

export default function Faq() {
  const [open, setOpen] = useState<number | null>(null);

  return (
    <section
      id="faq"
      className="section-divider scroll-mt-24 px-4 py-16 sm:px-6 lg:px-8 lg:py-20"
    >
      <div className="mx-auto max-w-2xl">
        <p className="text-center text-sm font-semibold uppercase tracking-widest text-soft-cyan">
          Perguntas frequentes
        </p>
        <h2 className="mt-3 text-center text-2xl font-bold tracking-tight text-white sm:text-3xl">
          Tire suas dúvidas
        </h2>

        <dl className="mt-12 divide-y divide-slate-800">
          {faqs.map((faq, i) => {
            const isOpen = open === i;
            return (
              <div key={i} className="py-5">
                <dt>
                  <button
                    onClick={() => setOpen(isOpen ? null : i)}
                    className="flex w-full items-start justify-between text-left transition-colors hover:text-soft-cyan"
                    aria-expanded={isOpen}
                  >
                    <span className="text-sm font-medium text-white">
                      {faq.q}
                    </span>
                    <span className="ml-4 flex-shrink-0 text-slate-400">
                      <svg
                        width="20"
                        height="20"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        strokeWidth={2}
                        className={`transition-transform duration-200 ${isOpen ? "rotate-45" : ""}`}
                        aria-hidden="true"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M12 4.5v15m7.5-7.5h-15"
                        />
                      </svg>
                    </span>
                  </button>
                </dt>
                <dd
                  className={`grid transition-all duration-200 ${isOpen ? "mt-3 grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}
                >
                  <div className="overflow-hidden">
                    <p className="pr-8 text-sm leading-relaxed text-slate-300">
                      {faq.a}
                    </p>
                  </div>
                </dd>
              </div>
            );
          })}
        </dl>
      </div>
    </section>
  );
}
