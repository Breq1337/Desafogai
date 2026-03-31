"use client";

import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";

export type TypewriterLine = {
  text: string;
  /** Segunda linha com gradiente da marca */
  variant?: "plain" | "gradient";
};

type TypewriterHeadlineProps = {
  lines: TypewriterLine[];
  className?: string;
  /** ms entre cada caractere */
  charDelayMs?: number;
  /** ms entre o fim de uma linha e o início da próxima */
  linePauseMs?: number;
};

export default function TypewriterHeadline({
  lines,
  className,
  charDelayMs = 36,
  linePauseMs = 320,
}: TypewriterHeadlineProps) {
  const [reduced, setReduced] = useState(false);
  const [lineIdx, setLineIdx] = useState(0);
  const [charCount, setCharCount] = useState(0);
  const [showCursor, setShowCursor] = useState(true);

  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    const sync = () => setReduced(mq.matches);
    sync();
    mq.addEventListener("change", sync);
    return () => mq.removeEventListener("change", sync);
  }, []);

  useEffect(() => {
    if (reduced) return;

    const line = lines[lineIdx];
    if (!line) return;

    if (charCount < line.text.length) {
      const id = window.setTimeout(() => {
        setCharCount((c) => c + 1);
      }, charDelayMs);
      return () => window.clearTimeout(id);
    }

    if (lineIdx < lines.length - 1) {
      const id = window.setTimeout(() => {
        setLineIdx((i) => i + 1);
        setCharCount(0);
      }, linePauseMs);
      return () => window.clearTimeout(id);
    }

    const id = window.setTimeout(() => setShowCursor(false), 700);
    return () => window.clearTimeout(id);
  }, [reduced, lines, lineIdx, charCount, charDelayMs, linePauseMs]);

  if (reduced) {
    return (
      <h1 className={cn("font-display text-balance", className)}>
        {lines.map((line, i) => (
          <span
            key={i}
            className={cn(
              "block",
              i > 0 && "mt-2 sm:mt-3",
              line.variant === "gradient" &&
                "bg-gradient-to-r from-ocean via-soft-cyan to-pale-blue bg-clip-text text-transparent",
              line.variant !== "gradient" && "text-white",
            )}
          >
            {line.text}
          </span>
        ))}
      </h1>
    );
  }

  return (
    <h1 className={cn("font-display text-balance", className)}>
      {lines.map((line, i) => {
        if (i < lineIdx) {
          return (
            <span
              key={i}
              className={cn(
                "block",
                i > 0 && "mt-2 sm:mt-3",
                line.variant === "gradient" &&
                  "bg-gradient-to-r from-ocean via-soft-cyan to-pale-blue bg-clip-text text-transparent",
                line.variant !== "gradient" && "text-white",
              )}
            >
              {line.text}
            </span>
          );
        }
        if (i === lineIdx) {
          const slice = line.text.slice(0, charCount);
          return (
            <span
              key={i}
              className={cn(
                "block min-h-[1.15em]",
                i > 0 && "mt-2 sm:mt-3",
                line.variant === "gradient" &&
                  "bg-gradient-to-r from-ocean via-soft-cyan to-pale-blue bg-clip-text text-transparent",
                line.variant !== "gradient" && "text-white",
              )}
            >
              {slice}
              {showCursor && (
                <span
                  className="ml-0.5 inline-block h-[0.85em] w-[2px] translate-y-[0.08em] rounded-sm bg-soft-cyan motion-safe:animate-pulse motion-reduce:animate-none"
                  aria-hidden
                />
              )}
            </span>
          );
        }
        return null;
      })}
    </h1>
  );
}
