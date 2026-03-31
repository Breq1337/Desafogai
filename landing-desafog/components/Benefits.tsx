"use client";

import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import StarBorder from "./StarBorder";

const ScrollStack = dynamic(() => import("./ScrollStack").then((m) => m.default), {
  ssr: false,
});
const ScrollStackItem = dynamic(
  () => import("./ScrollStack").then((m) => m.ScrollStackItem),
  { ssr: false }
);

const benefits = [
  {
    title: "Prioridade, não palpite",
    description:
      "O app analisa juros, vencimento e atraso para mostrar qual dívida atacar primeiro. Você age com informação, não com pânico.",
    accent: "bg-ocean/15 text-soft-cyan",
    number: "01",
    featured: true,
  },
  {
    title: "Plano mensal realista",
    description:
      "A partir da sua renda e despesas, o Desafog monta um orçamento que cabe no mês — sem mágica e sem surpresa.",
    accent: "bg-soft-cyan/10 text-pale-blue",
    number: "02",
    featured: false,
  },
  {
    title: "Simulador de cenários",
    description:
      "Quer saber o que acontece se pagar o mínimo do cartão ou antecipar uma parcela? Simule antes de decidir.",
    accent: "bg-ocean/15 text-soft-cyan",
    number: "03",
    featured: false,
  },
  {
    title: "Orientação com IA",
    description:
      "Um assistente que entende seu contexto e responde dúvidas financeiras com linguagem clara — sem aula e sem sermão.",
    accent: "bg-soft-cyan/10 text-pale-blue",
    number: "04",
    featured: false,
  },
];

function BenefitCardBody({
  b,
}: {
  b: (typeof benefits)[number];
}) {
  return (
    <div className="flex items-start gap-5">
      <div
        className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-lg text-sm font-bold ${b.accent}`}
      >
        {b.number}
      </div>
      <div>
        <h3 className="text-lg font-semibold text-white">{b.title}</h3>
        <p className="mt-2 text-sm leading-relaxed text-slate-300">
          {b.description}
        </p>
      </div>
    </div>
  );
}

export default function Benefits() {
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReduceMotion(mq.matches);
    const onChange = () => setReduceMotion(mq.matches);
    mq.addEventListener("change", onChange);
    return () => mq.removeEventListener("change", onChange);
  }, []);

  return (
    <section
      id="como-ajuda"
      className="section-divider scroll-mt-24 px-4 py-16 sm:px-6 lg:px-8 lg:py-20"
    >
      <div className="mx-auto max-w-3xl">
        <p className="text-center text-sm font-semibold uppercase tracking-widest text-soft-cyan">
          Como o Desafog ajuda
        </p>
        <h2 className="mt-3 text-balance text-center text-2xl font-bold tracking-tight text-white sm:text-3xl">
          Saia do caos com um plano claro
        </h2>

        {reduceMotion ? (
          <div className="mt-12 flex flex-col gap-6">
            {benefits.map((b, i) =>
              b.featured ? (
                <StarBorder
                  key={i}
                  as="div"
                  color="#90E0EF"
                  speed="10s"
                  thickness={2}
                  className="w-full rounded-2xl"
                >
                  <BenefitCardBody b={b} />
                </StarBorder>
              ) : (
                <div
                  key={i}
                  className="rounded-2xl border border-slate-700/60 bg-slate-900/80 p-8 backdrop-blur"
                >
                  <BenefitCardBody b={b} />
                </div>
              )
            )}
          </div>
        ) : (
          <div className="mt-14">
            <ScrollStack
              useWindowScroll
              itemDistance={48}
              itemScale={0.035}
              itemStackDistance={20}
              stackPosition="22%"
              scaleEndPosition="12%"
              baseScale={0.9}
              blurAmount={1.2}
            >
              {benefits.map((b, i) =>
                b.featured ? (
                  <ScrollStackItem
                    key={i}
                    itemClassName="!rounded-2xl !border-0 !bg-transparent !p-0 !shadow-none !my-6 min-h-0"
                  >
                    <StarBorder
                      as="div"
                      color="#90E0EF"
                      speed="10s"
                      thickness={2}
                      className="w-full rounded-2xl"
                    >
                      <BenefitCardBody b={b} />
                    </StarBorder>
                  </ScrollStackItem>
                ) : (
                  <ScrollStackItem
                    key={i}
                    itemClassName="border border-slate-700/50 bg-slate-900/90 !rounded-2xl !p-8 !h-auto min-h-[160px] !my-6"
                  >
                    <BenefitCardBody b={b} />
                  </ScrollStackItem>
                )
              )}
            </ScrollStack>
          </div>
        )}
      </div>
    </section>
  );
}
