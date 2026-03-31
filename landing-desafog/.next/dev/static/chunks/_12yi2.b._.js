(globalThis["TURBOPACK"] || (globalThis["TURBOPACK"] = [])).push([typeof document === "object" ? document.currentScript : undefined,
"[project]/lib/utils.ts [app-client] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "cn",
    ()=>cn
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$clsx$2f$dist$2f$clsx$2e$mjs__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/clsx/dist/clsx.mjs [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$tailwind$2d$merge$2f$dist$2f$bundle$2d$mjs$2e$mjs__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/tailwind-merge/dist/bundle-mjs.mjs [app-client] (ecmascript)");
;
;
function cn(...inputs) {
    return (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$tailwind$2d$merge$2f$dist$2f$bundle$2d$mjs$2e$mjs__$5b$app$2d$client$5d$__$28$ecmascript$29$__["twMerge"])((0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$clsx$2f$dist$2f$clsx$2e$mjs__$5b$app$2d$client$5d$__$28$ecmascript$29$__["clsx"])(inputs));
}
if (typeof globalThis.$RefreshHelpers$ === 'object' && globalThis.$RefreshHelpers !== null) {
    __turbopack_context__.k.registerExports(__turbopack_context__.m, globalThis.$RefreshHelpers$);
}
}),
"[project]/components/TypewriterHeadline.tsx [app-client] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "default",
    ()=>TypewriterHeadline
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/jsx-dev-runtime.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/index.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$utils$2e$ts__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/lib/utils.ts [app-client] (ecmascript)");
;
var _s = __turbopack_context__.k.signature();
"use client";
;
;
function TypewriterHeadline({ lines, className, charDelayMs = 36, linePauseMs = 320 }) {
    _s();
    const [reduced, setReduced] = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useState"])(false);
    const [lineIdx, setLineIdx] = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useState"])(0);
    const [charCount, setCharCount] = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useState"])(0);
    const [showCursor, setShowCursor] = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useState"])(true);
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useEffect"])({
        "TypewriterHeadline.useEffect": ()=>{
            const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
            const sync = {
                "TypewriterHeadline.useEffect.sync": ()=>setReduced(mq.matches)
            }["TypewriterHeadline.useEffect.sync"];
            sync();
            mq.addEventListener("change", sync);
            return ({
                "TypewriterHeadline.useEffect": ()=>mq.removeEventListener("change", sync)
            })["TypewriterHeadline.useEffect"];
        }
    }["TypewriterHeadline.useEffect"], []);
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useEffect"])({
        "TypewriterHeadline.useEffect": ()=>{
            if (reduced) return;
            const line = lines[lineIdx];
            if (!line) return;
            if (charCount < line.text.length) {
                const id = window.setTimeout({
                    "TypewriterHeadline.useEffect.id": ()=>{
                        setCharCount({
                            "TypewriterHeadline.useEffect.id": (c)=>c + 1
                        }["TypewriterHeadline.useEffect.id"]);
                    }
                }["TypewriterHeadline.useEffect.id"], charDelayMs);
                return ({
                    "TypewriterHeadline.useEffect": ()=>window.clearTimeout(id)
                })["TypewriterHeadline.useEffect"];
            }
            if (lineIdx < lines.length - 1) {
                const id = window.setTimeout({
                    "TypewriterHeadline.useEffect.id": ()=>{
                        setLineIdx({
                            "TypewriterHeadline.useEffect.id": (i)=>i + 1
                        }["TypewriterHeadline.useEffect.id"]);
                        setCharCount(0);
                    }
                }["TypewriterHeadline.useEffect.id"], linePauseMs);
                return ({
                    "TypewriterHeadline.useEffect": ()=>window.clearTimeout(id)
                })["TypewriterHeadline.useEffect"];
            }
            const id = window.setTimeout({
                "TypewriterHeadline.useEffect.id": ()=>setShowCursor(false)
            }["TypewriterHeadline.useEffect.id"], 700);
            return ({
                "TypewriterHeadline.useEffect": ()=>window.clearTimeout(id)
            })["TypewriterHeadline.useEffect"];
        }
    }["TypewriterHeadline.useEffect"], [
        reduced,
        lines,
        lineIdx,
        charCount,
        charDelayMs,
        linePauseMs
    ]);
    if (reduced) {
        return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("h1", {
            className: (0, __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$utils$2e$ts__$5b$app$2d$client$5d$__$28$ecmascript$29$__["cn"])("font-display text-balance", className),
            children: lines.map((line, i)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("span", {
                    className: (0, __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$utils$2e$ts__$5b$app$2d$client$5d$__$28$ecmascript$29$__["cn"])("block", i > 0 && "mt-2 sm:mt-3", line.variant === "gradient" && "bg-gradient-to-r from-ocean via-soft-cyan to-pale-blue bg-clip-text text-transparent", line.variant !== "gradient" && "text-white"),
                    children: line.text
                }, i, false, {
                    fileName: "[project]/components/TypewriterHeadline.tsx",
                    lineNumber: 69,
                    columnNumber: 11
                }, this))
        }, void 0, false, {
            fileName: "[project]/components/TypewriterHeadline.tsx",
            lineNumber: 67,
            columnNumber: 7
        }, this);
    }
    return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("h1", {
        className: (0, __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$utils$2e$ts__$5b$app$2d$client$5d$__$28$ecmascript$29$__["cn"])("font-display text-balance", className),
        children: lines.map((line, i)=>{
            if (i < lineIdx) {
                return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("span", {
                    className: (0, __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$utils$2e$ts__$5b$app$2d$client$5d$__$28$ecmascript$29$__["cn"])("block", i > 0 && "mt-2 sm:mt-3", line.variant === "gradient" && "bg-gradient-to-r from-ocean via-soft-cyan to-pale-blue bg-clip-text text-transparent", line.variant !== "gradient" && "text-white"),
                    children: line.text
                }, i, false, {
                    fileName: "[project]/components/TypewriterHeadline.tsx",
                    lineNumber: 91,
                    columnNumber: 13
                }, this);
            }
            if (i === lineIdx) {
                const slice = line.text.slice(0, charCount);
                return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("span", {
                    className: (0, __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$utils$2e$ts__$5b$app$2d$client$5d$__$28$ecmascript$29$__["cn"])("block min-h-[1.15em]", i > 0 && "mt-2 sm:mt-3", line.variant === "gradient" && "bg-gradient-to-r from-ocean via-soft-cyan to-pale-blue bg-clip-text text-transparent", line.variant !== "gradient" && "text-white"),
                    children: [
                        slice,
                        showCursor && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("span", {
                            className: "ml-0.5 inline-block h-[0.85em] w-[2px] translate-y-[0.08em] rounded-sm bg-soft-cyan motion-safe:animate-pulse motion-reduce:animate-none",
                            "aria-hidden": true
                        }, void 0, false, {
                            fileName: "[project]/components/TypewriterHeadline.tsx",
                            lineNumber: 120,
                            columnNumber: 17
                        }, this)
                    ]
                }, i, true, {
                    fileName: "[project]/components/TypewriterHeadline.tsx",
                    lineNumber: 108,
                    columnNumber: 13
                }, this);
            }
            return null;
        })
    }, void 0, false, {
        fileName: "[project]/components/TypewriterHeadline.tsx",
        lineNumber: 87,
        columnNumber: 5
    }, this);
}
_s(TypewriterHeadline, "0TccC7K8x/sUAXXMklBvUzEeyxM=");
_c = TypewriterHeadline;
var _c;
__turbopack_context__.k.register(_c, "TypewriterHeadline");
if (typeof globalThis.$RefreshHelpers$ === 'object' && globalThis.$RefreshHelpers !== null) {
    __turbopack_context__.k.registerExports(__turbopack_context__.m, globalThis.$RefreshHelpers$);
}
}),
"[project]/components/TypewriterHeadline.tsx [app-client] (ecmascript, next/dynamic entry)", ((__turbopack_context__) => {

__turbopack_context__.n(__turbopack_context__.i("[project]/components/TypewriterHeadline.tsx [app-client] (ecmascript)"));
}),
]);

//# sourceMappingURL=_12yi2.b._.js.map