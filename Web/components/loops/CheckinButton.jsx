"use client";

import { useState } from "react";

export default function CheckinButton({
  loopId,
  isChecked,
  onCheckin,
  compact = false,
}) {
  const [loading, setLoading] = useState(false);
  const [justChecked, setJustChecked] = useState(false);

  async function handleClick(e) {
    e.preventDefault(); // prevent Link navigation if inside a card
    e.stopPropagation();
    if (isChecked || loading) return;
    setLoading(true);
    await onCheckin(loopId);
    setJustChecked(true);
    setLoading(false);
    // Reset animation after 1.5s
    setTimeout(() => setJustChecked(false), 1500);
  }

  const done = isChecked || justChecked;

  if (compact) {
    return (
      <button
        onClick={handleClick}
        disabled={done || loading}
        title={done ? "Done today!" : "Mark as done"}
        className={`w-9 h-9 rounded-xl border flex items-center justify-center text-base shrink-0 transition-all ${
          done
            ? "bg-green-500/10 border-green-500/30 text-green-400 cursor-default"
            : loading
            ? "bg-white/[0.04] border-white/[0.08] text-zinc-600 cursor-wait"
            : "bg-white/[0.04] border-white/[0.08] text-zinc-400 hover:border-violet-500 hover:text-violet-300 hover:bg-violet-500/10 active:scale-95"
        }`}
      >
        {loading ? "⏳" : done ? "✓" : "○"}
      </button>
    );
  }

  // Full size button (used on loop detail page)
  return (
    <button
      onClick={handleClick}
      disabled={done || loading}
      className={`flex items-center gap-2 px-4 py-2 rounded-xl border text-sm font-medium transition-all ${
        done
          ? "bg-green-500/10 border-green-500/30 text-green-400 cursor-default"
          : loading
          ? "bg-white/[0.04] border-white/[0.08] text-zinc-500 cursor-wait"
          : "bg-violet-600/20 border-violet-500/30 text-violet-300 hover:bg-violet-600/30 active:scale-95"
      }`}
    >
      {loading ? (
        <span>Logging...</span>
      ) : done ? (
        <><span>✓</span><span>Done today</span></>
      ) : (
        <><span>○</span><span>Log today</span></>
      )}
    </button>
  );
}