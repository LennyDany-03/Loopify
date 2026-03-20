"use client";

import Link from "next/link";
import SlideToComplete from "./SlideToComplete";
import useLoopStore from "@/lib/store/useLoopStore";

export default function LoopCard({ loop, isCheckedToday = false, showCheckin = true }) {
  const { checkinLoop } = useLoopStore();

  const streakLabel =
    loop.current_streak === 0 ? "No streak"
    : loop.current_streak < 3  ? "Getting started"
    : loop.current_streak < 7  ? "Building momentum"
    : loop.current_streak < 14 ? "On fire 🔥"
    : loop.current_streak < 30 ? "Unstoppable ⚡"
    : "Legend 👑";

  // Streak progress ring (max 30 day visual)
  const streakPct = Math.min(loop.current_streak / 30, 1);
  const circumference = 2 * Math.PI * 16;
  const dashOffset = circumference * (1 - streakPct);

  return (
    <div
      className={`
        animate-fade-up glass-card rounded-2xl p-5 flex flex-col gap-4
        transition-all duration-300 hover:translate-y-[-2px]
        hover:shadow-lg hover:shadow-violet-500/5
        ${isCheckedToday
          ? "border-violet-500/30 bg-violet-600/[0.04]"
          : "hover:border-white/[0.12]"
        }
      `}
    >
      {/* ── Top row — icon, name, streak ring ──────────────── */}
      <div className="flex items-start justify-between gap-3">
        <Link href={`/loops/${loop.id}`} className="flex items-center gap-3 flex-1 min-w-0">
          {/* Icon circle */}
          <div
            className="w-11 h-11 rounded-xl flex items-center justify-center text-xl shrink-0 transition-transform duration-200 hover:scale-105"
            style={{
              background: `linear-gradient(135deg, ${loop.color}22, ${loop.color}11)`,
              border: `1px solid ${loop.color}44`,
            }}
          >
            {loop.icon}
          </div>

          {/* Name + badges */}
          <div className="min-w-0">
            <p className="text-white font-semibold text-sm truncate">{loop.name}</p>
            <div className="flex items-center gap-1.5 mt-1 flex-wrap">
              <span className="text-[10px] text-zinc-500 bg-white/[0.05] px-2 py-0.5 rounded-full">
                {loop.category}
              </span>
              <span className="text-[10px] text-zinc-500 bg-white/[0.05] px-2 py-0.5 rounded-full">
                {loop.frequency}
              </span>
            </div>
          </div>
        </Link>

        {/* Streak mini ring */}
        <div className="relative w-10 h-10 shrink-0" title={`${loop.current_streak} day streak`}>
          <svg viewBox="0 0 36 36" className="w-full h-full -rotate-90">
            <circle
              cx="18" cy="18" r="16"
              fill="none"
              stroke="rgba(255,255,255,0.04)"
              strokeWidth="2.5"
            />
            <circle
              cx="18" cy="18" r="16"
              fill="none"
              stroke={loop.color || "#7c6cfc"}
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={dashOffset}
              className="transition-all duration-700"
              style={{ opacity: 0.8 }}
            />
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-white text-[10px] font-bold">{loop.current_streak}</span>
          </div>
        </div>
      </div>

      {/* ── Stats row ─────────────────────────────────────── */}
      <div className="grid grid-cols-3 gap-2">
        <div className="text-center bg-white/[0.03] rounded-xl py-2 transition-colors hover:bg-white/[0.05]">
          <p className="text-white font-bold text-sm leading-none">
            {loop.current_streak}
            <span className="text-orange-400 ml-0.5 text-xs">🔥</span>
          </p>
          <p className="text-zinc-600 text-[9px] mt-1 uppercase tracking-wider">Streak</p>
        </div>
        <div className="text-center bg-white/[0.03] rounded-xl py-2 transition-colors hover:bg-white/[0.05]">
          <p className="text-white font-bold text-sm leading-none">{loop.best_streak}</p>
          <p className="text-zinc-600 text-[9px] mt-1 uppercase tracking-wider">Best</p>
        </div>
        <div className="text-center bg-white/[0.03] rounded-xl py-2 transition-colors hover:bg-white/[0.05]">
          <p className="text-white font-bold text-sm leading-none">{loop.total_checkins}</p>
          <p className="text-zinc-600 text-[9px] mt-1 uppercase tracking-wider">Total</p>
        </div>
      </div>

      {/* ── Footer label ──────────────────────────────────── */}
      <div className="flex items-center justify-between">
        <span className="text-[11px] text-zinc-500">{streakLabel}</span>
        {isCheckedToday && (
          <span className="text-[10px] bg-green-500/10 text-green-400 border border-green-500/20 px-2 py-0.5 rounded-full">
            ✓ Done today
          </span>
        )}
      </div>

      {/* ── Slide-to-complete at bottom for easy mobile access ── */}
      {showCheckin && (
        <SlideToComplete
          loopId={loop.id}
          isChecked={isCheckedToday}
          onCheckin={checkinLoop}
          compact
          color={loop.color}
        />
      )}
    </div>
  );
}