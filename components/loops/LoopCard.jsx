"use client";

import Link from "next/link";
import CheckinButton from "./CheckinButton";
import useLoopStore from "@/lib/store/useLoopStore";

export default function LoopCard({ loop, isCheckedToday = false, showCheckin = true }) {
  const { checkinLoop } = useLoopStore();

  const streakLabel =
    loop.current_streak === 0 ? "No streak"
    : loop.current_streak < 3  ? "Getting started"
    : loop.current_streak < 7  ? "Building momentum"
    : loop.current_streak < 14 ? "On fire"
    : loop.current_streak < 30 ? "Unstoppable"
    : "Legend";

  return (
    <div
      className={`bg-[#111118] border rounded-2xl p-5 flex flex-col gap-4 transition-all hover:border-white/[0.12] ${
        isCheckedToday
          ? "border-violet-500/30 bg-violet-600/[0.04]"
          : "border-white/[0.07]"
      }`}
    >
      {/* Top row — icon, name, checkin */}
      <div className="flex items-start justify-between gap-3">
        <Link href={`/loops/${loop.id}`} className="flex items-center gap-3 flex-1 min-w-0">
          {/* Icon circle */}
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center text-xl shrink-0"
            style={{ background: `${loop.color}22`, border: `1px solid ${loop.color}44` }}
          >
            {loop.icon}
          </div>

          {/* Name + badges */}
          <div className="min-w-0">
            <p className="text-white font-semibold text-sm truncate">{loop.name}</p>
            <div className="flex items-center gap-1.5 mt-1 flex-wrap">
              <span className="text-[11px] text-zinc-500 bg-white/[0.05] px-2 py-0.5 rounded-full">
                {loop.category}
              </span>
              <span className="text-[11px] text-zinc-500 bg-white/[0.05] px-2 py-0.5 rounded-full">
                {loop.frequency}
              </span>
              {loop.target_value && (
                <span className="text-[11px] text-zinc-500 bg-white/[0.05] px-2 py-0.5 rounded-full">
                  {loop.target_value} {loop.target_unit}
                </span>
              )}
            </div>
          </div>
        </Link>

        {/* Checkin button */}
        {showCheckin && (
          <CheckinButton
            loopId={loop.id}
            isChecked={isCheckedToday}
            onCheckin={checkinLoop}
            compact
          />
        )}
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-3 gap-2">
        <div className="text-center bg-white/[0.03] rounded-lg py-2">
          <p className="text-white font-bold text-lg leading-none">
            {loop.current_streak}
            <span className="text-sm text-orange-400 ml-0.5">🔥</span>
          </p>
          <p className="text-zinc-600 text-[10px] mt-1 uppercase tracking-wide">Streak</p>
        </div>
        <div className="text-center bg-white/[0.03] rounded-lg py-2">
          <p className="text-white font-bold text-lg leading-none">{loop.best_streak}</p>
          <p className="text-zinc-600 text-[10px] mt-1 uppercase tracking-wide">Best</p>
        </div>
        <div className="text-center bg-white/[0.03] rounded-lg py-2">
          <p className="text-white font-bold text-lg leading-none">{loop.total_checkins}</p>
          <p className="text-zinc-600 text-[10px] mt-1 uppercase tracking-wide">Total</p>
        </div>
      </div>

      {/* Streak label + done badge */}
      <div className="flex items-center justify-between">
        <span className="text-xs text-zinc-500">{streakLabel}</span>
        {isCheckedToday && (
          <span className="text-[11px] bg-green-500/10 text-green-400 border border-green-500/20 px-2 py-0.5 rounded-full">
            ✓ Done today
          </span>
        )}
      </div>
    </div>
  );
}