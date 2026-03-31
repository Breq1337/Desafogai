import type { Metadata } from "next";
import "./globals.css";
import SiteBackground from "@/components/SiteBackground";

export const metadata: Metadata = {
  title: "Desafog.ai — Organize suas dívidas, limpe sua visão financeira",
  description:
    "Controle financeiro com priorização inteligente, plano mensal, simulador de cenários e assistente com IA. Saia do caos das contas com clareza e um plano real.",
  metadataBase: new URL("https://desafog.ai"),
  openGraph: {
    title: "Desafog.ai — Organize suas dívidas, limpe sua visão financeira",
    description:
      "Priorize dívidas, crie um plano mensal e simule cenários com apoio de IA.",
    type: "website",
    locale: "pt_BR",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@500;600;700;800&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="relative min-h-dvh bg-[#021024] antialiased">
        <SiteBackground />
        <div className="relative z-10">{children}</div>
      </body>
    </html>
  );
}
