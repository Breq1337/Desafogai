(globalThis["TURBOPACK"] || (globalThis["TURBOPACK"] = [])).push([typeof document === "object" ? document.currentScript : undefined,
"[project]/components/SiteBackground.tsx [app-client] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "default",
    ()=>SiteBackground
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/jsx-dev-runtime.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/index.js [app-client] (ecmascript)");
;
var _s = __turbopack_context__.k.signature();
"use client";
;
const LIQUID_BASE = [
    0.1,
    0.1,
    0.1
];
function SiteBackground() {
    _s();
    const [reduceMotion, setReduceMotion] = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useState"])(false);
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useEffect"])({
        "SiteBackground.useEffect": ()=>{
            const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
            setReduceMotion(mq.matches);
            const onChange = {
                "SiteBackground.useEffect.onChange": ()=>setReduceMotion(mq.matches)
            }["SiteBackground.useEffect.onChange"];
            mq.addEventListener("change", onChange);
            return ({
                "SiteBackground.useEffect": ()=>mq.removeEventListener("change", onChange)
            })["SiteBackground.useEffect"];
        }
    }["SiteBackground.useEffect"], []);
    if (reduceMotion) {
        return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
            className: "pointer-events-none fixed inset-0 z-0 bg-[#021024]",
            "aria-hidden": true
        }, void 0, false, {
            fileName: "[project]/components/SiteBackground.tsx",
            lineNumber: 21,
            columnNumber: 7
        }, this);
    }
    return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
        className: "pointer-events-none fixed inset-0 z-0 overflow-hidden bg-[#021024]",
        "aria-hidden": true,
        children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
            className: "absolute inset-0 min-h-[100dvh] w-full",
            children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])(Prism, {
                animationType: "rotate",
                timeScale: 0.5,
                height: 3.5,
                baseWidth: 5.5,
                scale: 3.6,
                hueShift: 0,
                colorFrequency: 1,
                noise: 0,
                glow: 0.72,
                bloom: 0.85,
                transparent: false,
                suspendWhenOffscreen: true
            }, void 0, false, {
                fileName: "[project]/components/SiteBackground.tsx",
                lineNumber: 34,
                columnNumber: 9
            }, this)
        }, void 0, false, {
            fileName: "[project]/components/SiteBackground.tsx",
            lineNumber: 33,
            columnNumber: 7
        }, this)
    }, void 0, false, {
        fileName: "[project]/components/SiteBackground.tsx",
        lineNumber: 29,
        columnNumber: 5
    }, this);
}
_s(SiteBackground, "JG4l94zpvv67Bfd7Dxv3GKZ2ZaI=");
_c = SiteBackground;
var _c;
__turbopack_context__.k.register(_c, "SiteBackground");
if (typeof globalThis.$RefreshHelpers$ === 'object' && globalThis.$RefreshHelpers !== null) {
    __turbopack_context__.k.registerExports(__turbopack_context__.m, globalThis.$RefreshHelpers$);
}
}),
]);

//# sourceMappingURL=components_SiteBackground_tsx_0axy~zz._.js.map