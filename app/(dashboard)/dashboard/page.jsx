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

  if (isLoading && !loops.length) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto space-y-8">

      {/* Greeting */}
      <div>
        <h1 className="text-white text-2xl font-bold">
          {greeting}, {user?.full_name?.split(" ")[0] ?? "there"} 👋
        </h1>
        <p className="text-zinc-500 text-sm mt-1">
          {new Date().toLocaleDateString("en-IN", {
            weekday: "long", day: "numeric", month: "long",
          })}
        </p>
      </div>

      {/* Summary stat cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
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
          label="On Streak Today"
          value={summary?.loops_on_streak_today ?? 0}
          icon="⚡"
          color="yellow"
        />
      </div>

      {/* Today's loops */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-white font-semibold text-lg">Today&apos;s Loops</h2>
          <span className="text-zinc-500 text-sm">
            {Object.keys(todayCheckins).length}/{loops.length} done
          </span>
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