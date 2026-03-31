"use client";

import { useCallback, useEffect, useState } from "react";

export default function ScrollToTop() {
  const [visible, setVisible] = useState(false);

  const onScroll = useCallback(() => {
    setVisible(window.scrollY > 480);
  }, []);

  useEffect(() => {
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, [onScroll]);

  const goTop = () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  if (!visible) return null;

  return (
    <button
      type="button"
      onClick={goTop}
      className="fixed bottom-6 right-5 z-[60] flex h-12 w-12 items-center justify-center rounded-full border border-ocean/40 bg-[#061630]/95 text-soft-cyan shadow-lg shadow-ocean/20 backdrop-blur-md transition hover:border-soft-cyan/50 hover:bg-dark-blue hover:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ocean sm:bottom-8 sm:right-8"
      aria-label="Voltar ao topo"
    >
      <svg
        width="22"
        height="22"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={2.2}
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden
      >
        <path d="M12 19V5M5 12l7-7 7 7" />
      </svg>
    </button>
  );
}
