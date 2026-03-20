"use client";

import { useEffect } from "react";
import useLoopStore from "@/lib/store/useLoopStore";
import useAuthStore from "@/lib/store/useAuthStore";
import LoopList from "@/components/loops/LoopList";
import StatCard from "@/components/analytics/StatCard";
import Spinner from "@/components/ui/Spinner";

export default function DashboardPage() {
  const { user } = useAuthStore();
  const {
    loops,
    summary,
    todayCheckins,
    fetchLoops,
    fetchSummary,
    fetchTodayCheckins,
    isLoading,
  } = useLoopStore();

  useEffect(() => {
    fetchLoops();
    fetchSummary();
    fetchTodayCheckins();
  }, []);

  const hour = new Date().getHours();
  const greeting =
    hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";

  const doneCount = Object.keys(todayCheckins).length;
  const totalCount = loops.length;
  const progressPct = totalCount > 0 ? Math.round((doneCount / totalCount) * 100) : 0;

  if (isLoading && !loops.length) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto space-y-8">

      {/* ── Greeting & Daily Progress ─────────────────────── */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 animate-fade-up">
        <div>
          <h1 className="text-white text-2xl sm:text-3xl font-bold tracking-tight">
            {greeting}, {user?.full_name?.split(" ")[0] ?? "there"}{" "}
            <span className="inline-block animate-float">👋</span>
          </h1>
          <p className="text-zinc-500 text-sm mt-1.5">
            {new Date().toLocaleDateString("en-IN", {
              weekday: "long", day: "numeric", month: "long",
            })}
          </p>
        </div>

        {/* Daily progress ring */}
        {totalCount > 0 && (
          <div className="flex items-center gap-3 glass-card rounded-2xl px-4 py-3">
            <div className="relative w-12 h-12">
              <svg viewBox="0 0 48 48" className="w-full h-full -rotate-90">
                <circle cx="24" cy="24" r="20" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="3" />
                <circle
                  cx="24" cy="24" r="20"
                  fill="none"
                  stroke="url(#progressGrad)"
                  strokeWidth="3"
                  strokeLinecap="round"
                  strokeDasharray={`${2 * Math.PI * 20}`}
                  strokeDashoffset={`${2 * Math.PI * 20 * (1 - progressPct / 100)}`}
                  className="transition-all duration-700"
                />
                <defs>
                  <linearGradient id="progressGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#7c6cfc" />
                    <stop offset="100%" stopColor="#5eead4" />
                  </linearGradient>
                </defs>
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-white text-xs font-bold">{progressPct}%</span>
              </div>
            </div>
            <div>
              <p className="text-white text-sm font-semibold">{doneCount}/{totalCount}</p>
              <p className="text-zinc-500 text-[11px]">loops done today</p>
            </div>
          </div>
        )}
      </div>

      {/* ── Summary Stat Cards ────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 stagger-children">
        <StatCard
          label="Active Loops"
          value={summary?.total_loops ?? 0}
          icon="🔁"
          color="violet"
        />
        <StatCard
          label="Total Checkins"
          value={summary?.total_checkins ?? 0}
          icon="✅"
          color="teal"
        />
        <StatCard
          label="Best Streak"
          value={`${summary?.best_streak_overall ?? 0}d`}
          icon="🔥"
          color="orange"
        />
        <StatCard
          label="On Streak"
          value={summary?.loops_on_streak_today ?? 0}
          icon="⚡"
          color="yellow"
        />
      </div>

      {/* ── Today's Loops ─────────────────────────────────── */}
      <div className="animate-fade-up" style={{ animationDelay: '200ms' }}>
        <div className="flex items-center justify-between mb-5">
          <h2 className="text-white font-semibold text-lg">Today&apos;s Loops</h2>
          <div className="flex items-center gap-3">
            <span className="text-zinc-500 text-sm">
              {doneCount}/{totalCount} done
            </span>
            {/* Mini progress bar */}
            <div className="w-20 h-1.5 rounded-full bg-white/[0.06] overflow-hidden hidden sm:block">
              <div
                className="h-full rounded-full bg-gradient-to-r from-violet-500 to-teal-400 transition-all duration-700"
                style={{ width: `${progressPct}%` }}
              />
            </div>
          </div>
        </div>
        <LoopList
          loops={loops}
          todayCheckins={todayCheckins}
          showCheckin
        />
      </div>

    </div>
  );
}