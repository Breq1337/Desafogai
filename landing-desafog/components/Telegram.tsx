"use client";

import StarBorder from "./StarBorder";

export default function Telegram() {
  return (
    <section className="section-divider scroll-mt-24 px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div className="mx-auto max-w-4xl">
        <StarBorder
          as="div"
          color="#90E0EF"
          speed="8s"
          thickness={2}
          className="w-full rounded-3xl"
        >
          <div className="grid items-center gap-10 p-8 sm:p-12 lg:grid-cols-[1fr_auto] lg:gap-16">
            <div>
              <span className="inline-flex items-center gap-2 rounded-full bg-soft-cyan/10 px-3 py-1 text-xs font-semibold text-soft-cyan">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.479.33-.913.492-1.302.486-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z" />
                </svg>
                Telegram + App
              </span>

              <h2 className="mt-5 text-2xl font-bold tracking-tight text-white sm:text-3xl">
                Registre pelo Telegram,
                <br />
                organize no app.
              </h2>

              <p className="mt-4 leading-relaxed text-slate-300">
                Vincule sua conta ao Telegram com um código seguro e registre
                dívidas direto pelo chat — rápido como mandar uma mensagem. Tudo
                sincroniza automaticamente com o app.
              </p>
              <p className="mt-3 text-sm text-slate-400">
                <span className="mr-1.5 inline-block rounded bg-slate-800 px-2 py-0.5 text-xs font-medium text-soft-cyan">
                  Em breve
                </span>
                Registro de gastos diários pelo Telegram.
              </p>
            </div>

            <div className="hidden w-64 flex-col gap-3 lg:flex" aria-hidden="true">
              <div className="self-end rounded-2xl rounded-br-md bg-ocean/20 px-4 py-2.5 text-sm text-soft-cyan">
                Registrar dívida: Cartão Nubank R$&nbsp;450
              </div>
              <div className="self-start rounded-2xl rounded-bl-md bg-slate-800 px-4 py-2.5 text-sm text-slate-300">
                Dívida registrada! Qual o vencimento?
              </div>
              <div className="self-end rounded-2xl rounded-br-md bg-ocean/20 px-4 py-2.5 text-sm text-soft-cyan">
                15/04
              </div>
              <div className="self-start rounded-2xl rounded-bl-md bg-slate-800 px-4 py-2.5 text-sm text-slate-300">
                Pronto, adicionei ao seu plano mensal.
              </div>
            </div>
          </div>
        </StarBorder>
      </div>
    </section>
  );
}
