"use client";

import { useEffect, useState } from "react";
import LiquidChrome from "./LiquidChrome";

import "./SiteBackground.css";

/**
 * Base do shader alinhada à paleta do site:
 * slate-950 #021024, dark-blue #023E8A, ocean #0077B6 (ponderado e atenuado — o shader divide por |sin|).
 */
const LIQUID_BASE: [number, number, number] = (() => {
  const slate = { r: 2 / 255, g: 16 / 255, b: 36 / 255 };
  const dark = { r: 2 / 255, g: 62 / 255, b: 138 / 255 };
  const ocean = { r: 0 / 255, g: 119 / 255, b: 182 / 255 };
  const wS = 0.5;
  const wD = 0.32;
  const wO = 0.18;
  const tone = 0.45;
  return [
    tone * (wS * slate.r + wD * dark.r + wO * ocean.r),
    tone * (wS * slate.g + wD * dark.g + wO * ocean.g),
    tone * (wS * slate.b + wD * dark.b + wO * ocean.b),
  ] as [number, number, number];
})();

export default function SiteBackground() {
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReduceMotion(mq.matches);
    const onChange = () => setReduceMotion(mq.matches);
    mq.addEventListener("change", onChange);
    return () => mq.removeEventListener("change", onChange);
  }, []);

  if (reduceMotion) {
    return (
      <div
        className="pointer-events-none fixed inset-0 z-0 bg-[#021024]"
        aria-hidden
      />
    );
  }

  return (
    <div
      className="pointer-events-none fixed inset-0 z-0 overflow-hidden bg-[#021024]"
      aria-hidden
    >
      <div className="site-background-fx">
        <div className="site-background-fx__chrome">
          <LiquidChrome
            baseColor={LIQUID_BASE}
            speed={0.42}
            amplitude={0.36}
            frequencyX={2.35}
            frequencyY={1.65}
            interactive={false}
            className="absolute inset-0 min-h-full w-full"
          />
        </div>
        <div className="site-background-fx__veil" aria-hidden />
      </div>
    </div>
  );
}
