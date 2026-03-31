const testimonials = [
  {
    quote:
      "Pela primeira vez eu sei exatamente o que pagar primeiro e quanto sobra no mês. É uma paz que eu não tinha.",
    name: "Carla M.",
    detail: "Usuária desde o beta",
  },
  {
    quote:
      "Eu usava planilha e nunca lembrava de atualizar. Pelo Telegram registro em segundos e tá tudo lá no app.",
    name: "Rafael S.",
    detail: "Usuário desde o beta",
  },
];

export default function SocialProof() {
  return (
    <section className="section-divider scroll-mt-24 px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div className="mx-auto max-w-3xl text-center">
        <p className="text-sm font-semibold uppercase tracking-widest text-soft-cyan">
          Depoimentos
        </p>
        <h2 className="mt-3 text-2xl font-bold tracking-tight text-white sm:text-3xl">
          O que dizem de nós
        </h2>

        <div className="mt-12 grid gap-6 sm:grid-cols-2">
          {testimonials.map((t, i) => (
            <blockquote
              key={i}
              className="rounded-2xl border border-slate-800 bg-slate-900/40 p-6 text-left backdrop-blur transition-all duration-300 hover:border-slate-700"
            >
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                className="mb-3 text-ocean/30"
                aria-hidden="true"
              >
                <path
                  d="M4.583 17.321C3.553 16.227 3 15 3 13.011c0-3.5 2.457-6.637 6.03-8.188l.893 1.378c-3.335 1.804-3.987 4.145-4.247 5.621.537-.278 1.24-.375 1.929-.311 1.804.167 3.226 1.648 3.226 3.489a3.5 3.5 0 01-3.5 3.5c-1.073 0-2.099-.49-2.748-1.179zm10 0C13.553 16.227 13 15 13 13.011c0-3.5 2.457-6.637 6.03-8.188l.893 1.378c-3.335 1.804-3.987 4.145-4.247 5.621.537-.278 1.24-.375 1.929-.311 1.804.167 3.226 1.648 3.226 3.489a3.5 3.5 0 01-3.5 3.5c-1.073 0-2.099-.49-2.748-1.179z"
                  fill="currentColor"
                />
              </svg>
              <p className="text-sm leading-relaxed text-slate-300">
                {t.quote}
              </p>
              <footer className="mt-5 flex items-center gap-3">
                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-ocean/10 text-xs font-bold text-ocean">
                  {t.name[0]}
                </div>
                <div>
                  <p className="text-sm font-medium text-white">{t.name}</p>
                  <p className="text-xs text-slate-400">{t.detail}</p>
                </div>
              </footer>
            </blockquote>
          ))}
        </div>

        <p className="mt-8 text-xs text-slate-700">
          Depoimentos de testadores durante fase beta. Resultados individuais
          podem variar.
        </p>
      </div>
    </section>
  );
}
