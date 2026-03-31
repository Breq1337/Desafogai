const pains = [
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5} aria-hidden="true">
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
      </svg>
    ),
    title: "Contas espalhadas",
    text: "Boletos no e-mail, faturas no app do banco, anotações no bloco de notas. Nada num lugar só.",
  },
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5} aria-hidden="true">
        <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
      </svg>
    ),
    title: "Prazos perdidos",
    text: "Vencimentos chegam sem aviso e você não sabe qual pagar primeiro — ou se vai dar.",
  },
  {
    icon: (
      <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5} aria-hidden="true">
        <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5" />
      </svg>
    ),
    title: "Sem plano real",
    text: "Falta um lugar que junte tudo num plano só, com prioridade clara pra agir de verdade.",
  },
];

export default function Problem() {
  return (
    <section className="section-divider scroll-mt-24 px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div className="mx-auto max-w-5xl">
        <h2 className="text-balance text-center text-2xl font-bold tracking-tight text-white sm:text-3xl">
          Se o mês começa e as contas já venceram...
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-center leading-relaxed text-slate-300">
          Você não está sozinho. Sem um plano financeiro unificado, cada boleto
          vira motivo de ansiedade.
        </p>

        <div className="mt-12 grid gap-6 sm:grid-cols-3">
          {pains.map((pain, i) => (
            <div
              key={i}
              className="group rounded-2xl border border-slate-800 bg-slate-900/50 p-6 backdrop-blur-sm transition-all duration-300 hover:border-warning/25 hover:bg-slate-900/70"
            >
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-warning/10 text-warning transition-colors group-hover:bg-warning/15">
                {pain.icon}
              </div>
              <h3 className="mb-2 text-sm font-semibold text-white">
                {pain.title}
              </h3>
              <p className="text-sm leading-relaxed text-slate-300">
                {pain.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
