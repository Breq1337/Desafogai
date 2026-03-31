(globalThis["TURBOPACK"] || (globalThis["TURBOPACK"] = [])).push([typeof document === "object" ? document.currentScript : undefined,
"[project]/components/LiquidChrome.tsx [app-client] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "LiquidChrome",
    ()=>LiquidChrome,
    "default",
    ()=>__TURBOPACK__default__export__
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/jsx-dev-runtime.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/index.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$core$2f$Mesh$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/ogl/src/core/Mesh.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$core$2f$Program$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/ogl/src/core/Program.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$core$2f$Renderer$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/ogl/src/core/Renderer.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$extras$2f$Triangle$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/ogl/src/extras/Triangle.js [app-client] (ecmascript)");
;
var _s = __turbopack_context__.k.signature();
"use client";
;
;
;
const LiquidChrome = ({ baseColor = [
    0.1,
    0.1,
    0.1
], speed = 0.2, amplitude = 0.5, frequencyX = 3, frequencyY = 2, interactive = true, ...props })=>{
    _s();
    const containerRef = (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useRef"])(null);
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["useEffect"])({
        "LiquidChrome.useEffect": ()=>{
            const root = containerRef.current;
            if (!root) return;
            const renderer = new __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$core$2f$Renderer$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["Renderer"]({
                antialias: true,
                dpr: Math.min(2, window.devicePixelRatio || 1)
            });
            const gl = renderer.gl;
            gl.clearColor(baseColor[0], baseColor[1], baseColor[2], 1);
            const vertexShader = `
      attribute vec2 position;
      attribute vec2 uv;
      varying vec2 vUv;
      void main() {
        vUv = uv;
        gl_Position = vec4(position, 0.0, 1.0);
      }
    `;
            const fragmentShader = `
      precision highp float;
      uniform float uTime;
      uniform vec3 uResolution;
      uniform vec3 uBaseColor;
      uniform float uAmplitude;
      uniform float uFrequencyX;
      uniform float uFrequencyY;
      uniform vec2 uMouse;
      varying vec2 vUv;

      vec4 renderImage(vec2 uvCoord) {
          vec2 fragCoord = uvCoord * uResolution.xy;
          vec2 uv = (2.0 * fragCoord - uResolution.xy) / min(uResolution.x, uResolution.y);

          for (float i = 1.0; i < 10.0; i++){
              uv.x += uAmplitude / i * cos(i * uFrequencyX * uv.y + uTime + uMouse.x * 3.14159);
              uv.y += uAmplitude / i * cos(i * uFrequencyY * uv.x + uTime + uMouse.y * 3.14159);
          }

          vec2 diff = (uvCoord - uMouse);
          float dist = length(diff);
          float falloff = exp(-dist * 20.0);
          float ripple = sin(10.0 * dist - uTime * 2.0) * 0.03;
          uv += (diff / (dist + 0.0001)) * ripple * falloff;

          vec3 color = uBaseColor / abs(sin(uTime - uv.y - uv.x));
          return vec4(color, 1.0);
      }

      void main() {
          vec4 col = vec4(0.0);
          int samples = 0;
          for (int i = -1; i <= 1; i++){
              for (int j = -1; j <= 1; j++){
                  vec2 offset = vec2(float(i), float(j)) * (1.0 / min(uResolution.x, uResolution.y));
                  col += renderImage(vUv + offset);
                  samples++;
              }
          }
          gl_FragColor = col / float(samples);
      }
    `;
            const geometry = new __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$extras$2f$Triangle$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["Triangle"](gl);
            const program = new __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$core$2f$Program$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["Program"](gl, {
                vertex: vertexShader,
                fragment: fragmentShader,
                uniforms: {
                    uTime: {
                        value: 0
                    },
                    uResolution: {
                        value: new Float32Array([
                            gl.canvas.width,
                            gl.canvas.height,
                            gl.canvas.width / Math.max(gl.canvas.height, 1)
                        ])
                    },
                    uBaseColor: {
                        value: new Float32Array(baseColor)
                    },
                    uAmplitude: {
                        value: amplitude
                    },
                    uFrequencyX: {
                        value: frequencyX
                    },
                    uFrequencyY: {
                        value: frequencyY
                    },
                    uMouse: {
                        value: new Float32Array([
                            0,
                            0
                        ])
                    }
                }
            });
            const mesh = new __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$ogl$2f$src$2f$core$2f$Mesh$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["Mesh"](gl, {
                geometry,
                program
            });
            root.appendChild(gl.canvas);
            function resize() {
                const el = containerRef.current;
                if (!el) return;
                const w = el.offsetWidth;
                const h = el.offsetHeight;
                if (w < 1 || h < 1) return;
                renderer.setSize(w, h);
                const resUniform = program.uniforms.uResolution.value;
                resUniform[0] = gl.canvas.width;
                resUniform[1] = gl.canvas.height;
                resUniform[2] = gl.canvas.width / Math.max(gl.canvas.height, 1);
            }
            window.addEventListener("resize", resize);
            resize();
            function handleMouseMove(event) {
                const el = containerRef.current;
                if (!el) return;
                const rect = el.getBoundingClientRect();
                const x = (event.clientX - rect.left) / rect.width;
                const y = 1 - (event.clientY - rect.top) / rect.height;
                const mouseUniform = program.uniforms.uMouse.value;
                mouseUniform[0] = x;
                mouseUniform[1] = y;
            }
            function handleTouchMove(event) {
                if (event.touches.length > 0) {
                    const el = containerRef.current;
                    if (!el) return;
                    const touch = event.touches[0];
                    const rect = el.getBoundingClientRect();
                    const x = (touch.clientX - rect.left) / rect.width;
                    const y = 1 - (touch.clientY - rect.top) / rect.height;
                    const mouseUniform = program.uniforms.uMouse.value;
                    mouseUniform[0] = x;
                    mouseUniform[1] = y;
                }
            }
            if (interactive) {
                root.addEventListener("mousemove", handleMouseMove);
                root.addEventListener("touchmove", handleTouchMove, {
                    passive: true
                });
            }
            let animationId;
            function update(t) {
                animationId = requestAnimationFrame(update);
                program.uniforms.uTime.value = t * 0.001 * speed;
                renderer.render({
                    scene: mesh
                });
            }
            animationId = requestAnimationFrame(update);
            return ({
                "LiquidChrome.useEffect": ()=>{
                    cancelAnimationFrame(animationId);
                    window.removeEventListener("resize", resize);
                    if (interactive) {
                        root.removeEventListener("mousemove", handleMouseMove);
                        root.removeEventListener("touchmove", handleTouchMove);
                    }
                    if (gl.canvas.parentElement) {
                        gl.canvas.parentElement.removeChild(gl.canvas);
                    }
                    gl.getExtension("WEBGL_lose_context")?.loseContext();
                }
            })["LiquidChrome.useEffect"];
        }
    }["LiquidChrome.useEffect"], [
        baseColor,
        speed,
        amplitude,
        frequencyX,
        frequencyY,
        interactive
    ]);
    return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
        ref: containerRef,
        className: "liquidChrome-container",
        ...props
    }, void 0, false, {
        fileName: "[project]/components/LiquidChrome.tsx",
        lineNumber: 182,
        columnNumber: 10
    }, ("TURBOPACK compile-time value", void 0));
};
_s(LiquidChrome, "8puyVO4ts1RhCfXUmci3vLI3Njw=");
_c = LiquidChrome;
const __TURBOPACK__default__export__ = LiquidChrome;
var _c;
__turbopack_context__.k.register(_c, "LiquidChrome");
if (typeof globalThis.$RefreshHelpers$ === 'object' && globalThis.$RefreshHelpers !== null) {
    __turbopack_context__.k.registerExports(__turbopack_context__.m, globalThis.$RefreshHelpers$);
}
}),
"[project]/components/SiteBackground.tsx [app-client] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "default",
    ()=>SiteBackground
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/jsx-dev-runtime.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$index$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/dist/compiled/react/index.js [app-client] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$components$2f$LiquidChrome$2e$tsx__$5b$app$2d$client$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/components/LiquidChrome.tsx [app-client] (ecmascript)");
;
var _s = __turbopack_context__.k.signature();
"use client";
;
;
;
/**
 * Base do shader alinhada à paleta do site:
 * slate-950 #021024, dark-blue #023E8A, ocean #0077B6 (ponderado e atenuado — o shader divide por |sin|).
 */ const LIQUID_BASE = (()=>{
    const slate = {
        r: 2 / 255,
        g: 16 / 255,
        b: 36 / 255
    };
    const dark = {
        r: 2 / 255,
        g: 62 / 255,
        b: 138 / 255
    };
    const ocean = {
        r: 0 / 255,
        g: 119 / 255,
        b: 182 / 255
    };
    const wS = 0.5;
    const wD = 0.32;
    const wO = 0.18;
    const tone = 0.45;
    return [
        tone * (wS * slate.r + wD * dark.r + wO * ocean.r),
        tone * (wS * slate.g + wD * dark.g + wO * ocean.g),
        tone * (wS * slate.b + wD * dark.b + wO * ocean.b)
    ];
})();
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
            lineNumber: 40,
            columnNumber: 7
        }, this);
    }
    return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
        className: "pointer-events-none fixed inset-0 z-0 overflow-hidden bg-[#021024]",
        "aria-hidden": true,
        children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
            className: "site-background-fx",
            children: [
                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
                    className: "site-background-fx__chrome",
                    children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])(__TURBOPACK__imported__module__$5b$project$5d2f$components$2f$LiquidChrome$2e$tsx__$5b$app$2d$client$5d$__$28$ecmascript$29$__["default"], {
                        baseColor: LIQUID_BASE,
                        speed: 0.42,
                        amplitude: 0.36,
                        frequencyX: 2.35,
                        frequencyY: 1.65,
                        interactive: false,
                        className: "absolute inset-0 min-h-full w-full"
                    }, void 0, false, {
                        fileName: "[project]/components/SiteBackground.tsx",
                        lineNumber: 54,
                        columnNumber: 11
                    }, this)
                }, void 0, false, {
                    fileName: "[project]/components/SiteBackground.tsx",
                    lineNumber: 53,
                    columnNumber: 9
                }, this),
                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$dist$2f$compiled$2f$react$2f$jsx$2d$dev$2d$runtime$2e$js__$5b$app$2d$client$5d$__$28$ecmascript$29$__["jsxDEV"])("div", {
                    className: "site-background-fx__veil",
                    "aria-hidden": true
                }, void 0, false, {
                    fileName: "[project]/components/SiteBackground.tsx",
                    lineNumber: 64,
                    columnNumber: 9
                }, this)
            ]
        }, void 0, true, {
            fileName: "[project]/components/SiteBackground.tsx",
            lineNumber: 52,
            columnNumber: 7
        }, this)
    }, void 0, false, {
        fileName: "[project]/components/SiteBackground.tsx",
        lineNumber: 48,
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

//# sourceMappingURL=components_0y4qzq4._.js.map