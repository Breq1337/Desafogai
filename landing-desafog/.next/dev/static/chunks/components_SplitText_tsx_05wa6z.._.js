(globalThis["TURBOPACK"] || (globalThis["TURBOPACK"] = [])).push([typeof document === "object" ? document.currentScript : undefined,
"[project]/components/SplitText.tsx [app-client] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "default",
    ()=>__TURBOPACK__default__export__
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/jsx-dev-runtime.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/index.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__$3c$locals$3e$__ = __turbopack_context__.i("[project]/node_modules/gsap/index.js [app-client] (ecmascript) <locals>");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$ScrollTrigger$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/gsap/ScrollTrigger.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$SplitText$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/gsap/SplitText.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f40$gsap$2f$react$2f$src$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/@gsap/react/src/index.js [app-client] (ecmascript)");
;
var _s = __turbopack_context__.k.signature();
"use client";
;
;
;
;
;
__TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__$3c$locals$3e$__["gsap"].registerPlugin(__TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$ScrollTrigger$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["ScrollTrigger"], __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$SplitText$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["SplitText"], __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f40$gsap$2f$react$2f$src$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useGSAP"]);
const SplitText = ({ text, className = '', delay = 50, duration = 1.25, ease = 'power3.out', splitType = 'chars', from = {
    opacity: 0,
    y: 40
}, to = {
    opacity: 1,
    y: 0
}, threshold = 0.1, rootMargin = '-100px', tag = 'p', textAlign = 'center', onLetterAnimationComplete })=>{
    _s();
    const ref = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useRef"])(null);
    const animationCompletedRef = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useRef"])(false);
    const onCompleteRef = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useRef"])(onLetterAnimationComplete);
    const [fontsLoaded, setFontsLoaded] = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useState"])(false);
    // Keep callback ref updated
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useEffect"])({
        "SplitText.useEffect": ()=>{
            onCompleteRef.current = onLetterAnimationComplete;
        }
    }["SplitText.useEffect"], [
        onLetterAnimationComplete
    ]);
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useEffect"])({
        "SplitText.useEffect": ()=>{
            if (document.fonts.status === 'loaded') {
                setFontsLoaded(true);
            } else {
                document.fonts.ready.then({
                    "SplitText.useEffect": ()=>{
                        setFontsLoaded(true);
                    }
                }["SplitText.useEffect"]);
            }
        }
    }["SplitText.useEffect"], []);
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f40$gsap$2f$react$2f$src$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useGSAP"])({
        "SplitText.useGSAP": ()=>{
            if (!ref.current || !text || !fontsLoaded) return;
            // Prevent re-animation if already completed
            if (animationCompletedRef.current) return;
            const el = ref.current;
            if (el._rbsplitInstance) {
                try {
                    el._rbsplitInstance.revert();
                } catch (_) {}
                el._rbsplitInstance = undefined;
            }
            const startPct = (1 - threshold) * 100;
            const marginMatch = /^(-?\d+(?:\.\d+)?)(px|em|rem|%)?$/.exec(rootMargin);
            const marginValue = marginMatch ? parseFloat(marginMatch[1]) : 0;
            const marginUnit = marginMatch ? marginMatch[2] || 'px' : 'px';
            const sign = marginValue === 0 ? '' : marginValue < 0 ? `-=${Math.abs(marginValue)}${marginUnit}` : `+=${marginValue}${marginUnit}`;
            const start = `top ${startPct}%${sign}`;
            let targets = [];
            const assignTargets = {
                "SplitText.useGSAP.assignTargets": (self)=>{
                    if (splitType.includes('chars') && self.chars?.length) targets = self.chars;
                    if (!targets.length && splitType.includes('words') && self.words.length) targets = self.words;
                    if (!targets.length && splitType.includes('lines') && self.lines.length) targets = self.lines;
                    if (!targets.length) targets = self.chars || self.words || self.lines;
                }
            }["SplitText.useGSAP.assignTargets"];
            const splitInstance = new __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$SplitText$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["SplitText"](el, {
                type: splitType,
                smartWrap: true,
                autoSplit: splitType === 'lines',
                linesClass: 'split-line',
                wordsClass: 'split-word',
                charsClass: 'split-char',
                reduceWhiteSpace: false,
                onSplit: {
                    "SplitText.useGSAP": (self)=>{
                        assignTargets(self);
                        return __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__$3c$locals$3e$__["gsap"].fromTo(targets, {
                            ...from
                        }, {
                            ...to,
                            duration,
                            ease,
                            stagger: delay / 1000,
                            scrollTrigger: {
                                trigger: el,
                                start,
                                once: true,
                                fastScrollEnd: true,
                                anticipatePin: 0.4
                            },
                            onComplete: {
                                "SplitText.useGSAP": ()=>{
                                    animationCompletedRef.current = true;
                                    onCompleteRef.current?.();
                                }
                            }["SplitText.useGSAP"],
                            willChange: 'transform, opacity',
                            force3D: true
                        });
                    }
                }["SplitText.useGSAP"]
            });
            el._rbsplitInstance = splitInstance;
            return ({
                "SplitText.useGSAP": ()=>{
                    __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$gsap$2f$ScrollTrigger$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["ScrollTrigger"].getAll().forEach({
                        "SplitText.useGSAP": (st)=>{
                            if (st.trigger === el) st.kill();
                        }
                    }["SplitText.useGSAP"]);
                    try {
                        splitInstance.revert();
                    } catch (_) {}
                    el._rbsplitInstance = undefined;
                }
            })["SplitText.useGSAP"];
        }
    }["SplitText.useGSAP"], {
        dependencies: [
            text,
            delay,
            duration,
            ease,
            splitType,
            JSON.stringify(from),
            JSON.stringify(to),
            threshold,
            rootMargin,
            fontsLoaded
        ],
        scope: ref
    });
    const renderTag = ()=>{
        const style = {
            textAlign,
            wordWrap: 'break-word',
            willChange: 'transform, opacity'
        };
        const classes = `split-parent overflow-hidden inline-block whitespace-normal ${className}`;
        const Tag = tag || 'p';
        return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])(Tag, {
            ref: ref,
            style: style,
            className: classes,
            children: text
        }, void 0, false, {
            fileName: "[project]/components/SplitText.tsx",
            lineNumber: 170,
            columnNumber: 7
        }, ("TURBOPACK compile-time value", void 0));
    };
    return renderTag();
};
_s(SplitText, "XXL+Iel4Rlt+jGQZgGx9d9IjeH0=", false, function() {
    return [
        __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f40$gsap$2f$react$2f$src$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useGSAP"]
    ];
});
_c = SplitText;
const __TURBOPACK__default__export__ = SplitText;
var _c;
__turbopack_context__.k.register(_c, "SplitText");
if (typeof globalThis.$RefreshHelpers$ === 'object' && globalThis.$RefreshHelpers !== null) {
    __turbopack_context__.k.registerExports(__turbopack_context__.m, globalThis.$RefreshHelpers$);
}
}),
"[project]/components/SplitText.tsx [app-client] (ecmascript, next/dynamic entry)", ((__turbopack_context__) => {

__turbopack_context__.n(__turbopack_context__.i("[project]/components/SplitText.tsx [app-client] (ecmascript)"));
}),
]);

//# sourceMappingURL=components_SplitText_tsx_05wa6z.._.js.map