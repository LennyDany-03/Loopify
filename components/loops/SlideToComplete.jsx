"use client";

import { useState, useRef, useCallback } from "react";

/**
 * SlideToComplete — gamified slide-to-check-in component.
 *
 * Props:
 *   loopId      – loop ID
 *   isChecked   – already completed today
 *   onCheckin   – async (loopId) => void
 *   compact     – renders inline mini-rail (for LoopCard rows)
 *   color       – accent color (hex), defaults to purple
 */
export default function SlideToComplete({
  loopId,
  isChecked,
  onCheckin,
  compact = false,
  color = "#7c6cfc",
}) {
  const railRef = useRef(null);
  const [progress, setProgress] = useState(0);     // 0–1
  const [dragging, setDragging] = useState(false);
  const [loading, setLoading] = useState(false);
  const [justCompleted, setJustCompleted] = useState(false);

  const done = isChecked || justCompleted;
  const THRESHOLD = 0.85;

  const handlePointerDown = useCallback((e) => {
    if (done || loading) return;
    e.preventDefault();
    e.currentTarget.setPointerCapture(e.pointerId);
    setDragging(true);
    setProgress(0);
  }, [done, loading]);

  const handlePointerMove = useCallback((e) => {
    if (!dragging || done || loading) return;
    const rail = railRef.current;
    if (!rail) return;

    const rect = rail.getBoundingClientRect();
    const thumbSize = compact ? 28 : 40;
    const maxTravel = rect.width - thumbSize;
    const x = e.clientX - rect.left - thumbSize / 2;
    const pct = Math.max(0, Math.min(x / maxTravel, 1));
    setProgress(pct);
  }, [dragging, done, loading, compact]);

  const handlePointerUp = useCallback(async () => {
    if (!dragging) return;
    setDragging(false);

    if (progress >= THRESHOLD) {
      // Trigger checkin
      setProgress(1);
      setLoading(true);
      await onCheckin(loopId);
      setLoading(false);
      setJustCompleted(true);
      // Done state persists — no reset
    } else {
      // Spring back to start
      setProgress(0);
    }
  }, [dragging, progress, onCheckin, loopId]);

  // ── DONE STATE ──────────────────────────────────────────────
  if (done) {
    if (compact) {
      return (
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-green-500/10 border border-green-500/20 shrink-0 animate-scale-in">
          <span className="text-green-400 text-xs">✓</span>
          <span className="text-green-400 text-[11px] font-medium">Done</span>
        </div>
      );
    }
    return (
      <div className="relative w-full h-12 rounded-2xl bg-green-500/10 border border-green-500/20 flex items-center justify-center gap-2 overflow-hidden animate-scale-in">
        <span className="text-green-400 text-base">✓</span>
        <span className="text-green-400 text-sm font-semibold">Completed!</span>
        {/* Confetti dots */}
        {justCompleted && (
          <>
            {[...Array(6)].map((_, i) => (
              <div
                key={i}
                className="absolute w-2 h-2 rounded-full animate-pulse"
                style={{
                  background: ['#7c6cfc', '#5eead4', '#fb923c', '#f472b6', '#4ade80', '#facc15'][i],
                  left: `${15 + i * 14}%`,
                  top: `${20 + (i % 3) * 25}%`,
                  animationDelay: `${i * 100}ms`,
                  animationDuration: '0.8s',
                }}
              />
            ))}
          </>
        )}
      </div>
    );
  }

  // ── COMPACT RAIL ────────────────────────────────────────────
  if (compact) {
    const thumbSize = 32;
    return (
      <div
        ref={railRef}
        className="relative w-full h-9 rounded-full bg-white/[0.04] border border-white/[0.08] cursor-pointer overflow-hidden shrink-0 select-none touch-none"
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
      >
        {/* Progress fill */}
        <div
          className="absolute inset-y-0 left-0 rounded-full transition-[width] duration-75"
          style={{
            width: `${progress * 100}%`,
            background: `linear-gradient(90deg, ${color}33, ${color}88)`,
          }}
        />

        {/* Shimmer text */}
        {!dragging && progress === 0 && (
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <span className="text-[10px] text-zinc-500 font-medium tracking-widest uppercase animate-shimmer"
              style={{
                backgroundImage: `linear-gradient(90deg, #52525b 0%, #a1a1aa 50%, #52525b 100%)`,
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundSize: '200% auto',
              }}
            >
              Slide to complete →
            </span>
          </div>
        )}

        {/* Progress text (while dragging) */}
        {dragging && (
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <span className={`text-[10px] font-bold transition-colors ${
              progress >= THRESHOLD ? 'text-green-400' : 'text-zinc-500'
            }`}>
              {progress >= THRESHOLD ? 'Release!' : `${Math.round(progress * 100)}%`}
            </span>
          </div>
        )}

        {/* Thumb */}
        <div
          className={`absolute top-1/2 -translate-y-1/2 rounded-full flex items-center justify-center text-xs transition-shadow duration-200 ${
            dragging ? 'shadow-lg' : ''
          }`}
          style={{
            width: thumbSize,
            height: thumbSize,
            left: `${Math.max(2, progress * (railRef.current ? railRef.current.offsetWidth - thumbSize - 2 : 0))}px`,
            background: `linear-gradient(135deg, ${color}, ${color}cc)`,
            boxShadow: dragging ? `0 0 16px ${color}66` : `0 0 8px ${color}33`,
            transition: dragging ? 'none' : 'left 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.2s',
          }}
        >
          <span className="text-white text-xs">{progress >= THRESHOLD ? '✓' : '→'}</span>
        </div>
      </div>
    );
  }

  // ── FULL-SIZE RAIL ──────────────────────────────────────────
  const fullThumb = 40;
  return (
    <div
      ref={railRef}
      className="relative w-full h-12 rounded-2xl bg-white/[0.04] border border-white/[0.08] cursor-pointer overflow-hidden select-none touch-none"
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={handlePointerUp}
    >
      {/* Progress fill */}
      <div
        className="absolute inset-y-0 left-0 rounded-2xl transition-[width] duration-75"
        style={{
          width: `${progress * 100}%`,
          background: `linear-gradient(90deg, ${color}22, ${color}66)`,
        }}
      />

      {/* Guide text */}
      {!dragging && progress === 0 && (
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <span
            className="text-xs text-zinc-500 font-medium tracking-widest uppercase animate-shimmer"
            style={{
              backgroundImage: `linear-gradient(90deg, #52525b 0%, #d4d4d8 50%, #52525b 100%)`,
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              backgroundSize: '200% auto',
            }}
          >
            Slide to complete →
          </span>
        </div>
      )}

      {/* Progress text (while dragging) */}
      {dragging && (
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <span className={`text-xs font-bold transition-colors ${
            progress >= THRESHOLD ? 'text-green-400' : 'text-zinc-500'
          }`}>
            {progress >= THRESHOLD ? 'Release to complete!' : `${Math.round(progress * 100)}%`}
          </span>
        </div>
      )}

      {/* Thumb */}
      <div
        className={`absolute top-1/2 -translate-y-1/2 rounded-xl flex items-center justify-center transition-shadow ${
          dragging ? 'scale-105' : ''
        }`}
        style={{
          width: fullThumb,
          height: fullThumb,
          left: `${Math.max(4, progress * (railRef.current ? railRef.current.offsetWidth - fullThumb - 4 : 0))}px`,
          background: `linear-gradient(135deg, ${color}, ${color}bb)`,
          boxShadow: dragging
            ? `0 0 24px ${color}88, 0 0 48px ${color}33`
            : `0 0 12px ${color}44`,
          transition: dragging ? 'none' : 'left 0.35s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.2s, transform 0.2s',
        }}
      >
        <span className="text-white text-sm font-bold">
          {loading ? '⏳' : progress >= THRESHOLD ? '✓' : '→'}
        </span>
      </div>
    </div>
  );
}
