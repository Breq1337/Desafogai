import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Problem from "@/components/Problem";
import Benefits from "@/components/Benefits";
import Features from "@/components/Features";
import Telegram from "@/components/Telegram";
import SocialProof from "@/components/SocialProof";
import APKDownloadSection from "@/components/APKDownloadSection";
import DownloadGuide from "@/components/DownloadGuide";
import Faq from "@/components/Faq";
import CtaFinal from "@/components/CtaFinal";
import Footer from "@/components/Footer";
import ScrollToTop from "@/components/ScrollToTop";

export default function Home() {
  return (
    <>
      <Navbar />
      <ScrollToTop />
      <main>
        <Hero />
        <Problem />
        <Benefits />
        <Features />
        <Telegram />
        <SocialProof />
        <CtaFinal />
        <APKDownloadSection />
        <DownloadGuide />
        <Faq />
      </main>
      <Footer />
    </>
  );
}
