"use client";

import Image from "next/image";
import { useState } from "react";

const links = [
  { label: "Funcionalidades", href: "#funcionalidades" },
  { label: "FAQ", href: "#faq" },
];

export default function Navbar() {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <header className="fixed inset-x-0 top-0 z-50 border-b border-slate-800/60 bg-[#021024]/70 backdrop-blur-lg">
      <nav
        className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3 sm:px-6 lg:px-8"
        aria-label="Navegação principal"
      >
        <a
          href="#top"
          className="font-display flex items-center gap-2.5 text-[1.0625rem] font-bold tracking-tight text-white sm:text-lg"
        >
          <Image
            src="/logo_sembackground.png"
            alt="Desafog.ai"
            width={40}
            height={40}
            className="h-9 w-9 shrink-0 object-contain sm:h-10 sm:w-10"
            priority
          />
          <span>
            Desafog<span className="text-ocean">.ai</span>
          </span>
        </a>

        <div className="hidden items-center gap-8 sm:flex">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="text-[0.9375rem] font-medium text-slate-300 transition hover:text-white"
            >
              {l.label}
            </a>
          ))}
          <a
            href="#funcionalidades"
            className="font-display rounded-lg bg-ocean px-4 py-2.5 text-[0.9375rem] font-semibold text-white transition hover:bg-dark-blue focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ocean"
          >
            Conhecer o app
          </a>
        </div>

        <button
          className="inline-flex items-center justify-center rounded-md p-2 text-slate-400 sm:hidden"
          onClick={() => setMenuOpen(!menuOpen)}
          aria-expanded={menuOpen}
          aria-label="Abrir menu"
        >
          {menuOpen ? (
            <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2} aria-hidden="true">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          ) : (
            <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2} aria-hidden="true">
              <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
            </svg>
          )}
        </button>
      </nav>

      {menuOpen && (
        <div className="border-t border-slate-800 bg-[#021024]/95 px-4 pb-4 sm:hidden">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              onClick={() => setMenuOpen(false)}
              className="block py-3 text-[0.9375rem] font-medium text-slate-300 transition hover:text-white"
            >
              {l.label}
            </a>
          ))}
          <a
            href="#funcionalidades"
            onClick={() => setMenuOpen(false)}
            className="font-display mt-2 block rounded-lg bg-ocean px-4 py-2.5 text-center text-[0.9375rem] font-semibold text-white"
          >
            Conhecer o app
          </a>
        </div>
      )}
    </header>
  );
}
