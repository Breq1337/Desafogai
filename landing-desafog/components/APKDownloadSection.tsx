"use client";

export default function APKDownloadSection() {
  return (
    <section className="px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div className="mx-auto max-w-3xl">
        <div className="rounded-2xl border border-ocean/30 bg-slate-900/50 p-8">
          <div className="flex items-start gap-4">
            <span className="text-4xl">📱</span>
            <div className="flex-1">
              <h3 className="text-xl font-bold text-white">Download Direto (APK)</h3>
              <p className="mt-2 text-slate-300">
                Para Android, você pode baixar o APK direto e instalar sem a Play Store.
              </p>

              <div className="mt-6 space-y-3">
                <a
                  href="https://desafogai-web.vercel.app/desafogai-v1.1.0.apk"
                  download="Desafog.ai-v1.1.0.apk"
                  className="flex items-center justify-between rounded-lg bg-ocean/20 px-4 py-3 transition-all hover:bg-ocean/30"
                >
                  <div>
                    <p className="font-semibold text-white">📥 Desafog.ai v1.1.0</p>
                    <p className="text-xs text-slate-400">58 MB • APK Release Assinado • Design Melhorado</p>
                  </div>
                  <svg className="h-5 w-5 text-ocean" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                </a>

                <div className="rounded-lg bg-slate-800/50 p-4 text-sm text-slate-300">
                  <p className="font-semibold text-white">Como instalar:</p>
                  <ol className="mt-2 space-y-1 list-decimal list-inside">
                    <li>Baixe o arquivo acima</li>
                    <li>Vá para Configurações → Segurança → Ativar "Instalar de fontes desconhecidas"</li>
                    <li>Abra o arquivo baixado</li>
                    <li>Toque em "Instalar"</li>
                  </ol>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
